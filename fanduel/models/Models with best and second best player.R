library(arm)
library(h2o)
library(RODBC)

server <- odbcConnect("Server")
allPlayers <- sqlQuery(server, "SELECT * FROM nba.roto_preds")
odbcClose(server)

#Best and second best player
allPlayers <- subset(allPlayers, allPlayers$gameid < 401224690)

bestPlayer <- aggregate(points ~ team + date, allPlayers, max)
colnames(bestPlayer)[3] <- "bestPlayerExpPoints"

allPlayers <- merge(allPlayers, bestPlayer, by = c("team", "date"))
allPlayers$isBestPlayer <- 1 * (allPlayers$points == allPlayers$bestPlayerExpPoints)

secondBest <- aggregate(points ~ team + date, subset(allPlayers, allPlayers$isBestPlayer == 0), max)
colnames(secondBest)[3] <- "secondBestPlayerExpPoints"

allPlayers <- merge(allPlayers, secondBest, by = c("team", "date"))
allPlayers$isSecondBestPlayer <- 1 * (allPlayers$points == allPlayers$secondBestPlayerExpPoints)

allPlayers <- merge(allPlayers, subset(allPlayers[c("team", "date", "fdpoints")], allPlayers$isBestPlayer == 1), by = c("team", "date"))
allPlayers <- merge(allPlayers, subset(allPlayers[c("team", "date", "fdpoints.x")], allPlayers$isSecondBestPlayer == 1), by = c("team", "date"))

colnames(allPlayers)[colnames(allPlayers) == "fdpoints.x.x"] <- "fdPoints"

colnames(allPlayers)[colnames(allPlayers) == "fdpoints.y"] <- "bestPlayerfdPoints"

colnames(allPlayers)[colnames(allPlayers) == "fdpoints.x.y"] <- "secondBestPlayerfdPoints"

#Models
#20200114

allPlayers$id[which(allPlayers$Date == "20191022")][1]
allPlayers$id[which(allPlayers$Date == "20200114")][1]

allPlayers$pointsCeilDistance = allPlayers$ceil - allPlayers$points
allPlayers$homeExpPoints <- (allPlayers$totalpoints - allPlayers$matchspread) / 2
allPlayers$awayExpPoints <- allPlayers$totalpoints - allPlayers$homeExpPoints
allPlayers$ownExpPoints <- ifelse(allPlayers$ishomeplayer, allPlayers$homeExpPoints, allPlayers$awayExpPoints)
allPlayers$oppExpPoints <- ifelse(!allPlayers$ishomeplayer, allPlayers$homeExpPoints, allPlayers$awayExpPoints)
allPlayers$expPointsDiff <- allPlayers$ownExpPoints - allPlayers$oppExpPoints


allPlayers$homeDiff <- allPlayers$homefinalscore - allPlayers$awayfinalscore
allPlayers$scoreDiff = ifelse(allPlayers$ishomeplayer, allPlayers$homeDiff , -1 * allPlayers$homeDiff)
allPlayers$expDiff = ifelse(allPlayers$ishomeplayer, -1 * allPlayers$matchspread , allPlayers$matchspread)
allPlayers$expDiffMinusSpread <- allPlayers$expDiff - allPlayers$scoreDiff

allPlayers <- subset(allPlayers, allPlayers$gameid != 401161205 & allPlayers$gameid != 401071372 & allPlayers$gameid != 401071180 & allPlayers$gameid != 401071208)


aggPmin <- aggregate(pmin ~ gameid + team + seasonyear,  allPlayers, sum)
idsToRemove <- subset(aggPmin$gameid, abs(aggPmin$pmin - 240) > 15)

allPlayers <- subset(allPlayers, !allPlayers$gameid %in% idsToRemove)

#Zero points model
allPlayers$zeroPoints <- as.factor(1 * (allPlayers$fdPoints <= 0))

testData <- subset(allPlayers, allPlayers$seasonyear == 2020)
trainData <- subset(allPlayers, allPlayers$seasonyear < 2020)

h2o.init()

testDataH2o <- as.h2o(testData)
trainDataH2o <- as.h2o(trainData)

modelZeroPoints <- h2o.gbm(x = c("points" ,"pmin", "scoreDiff", "expDiff", "expDiffMinusSpread"), y = "zeroPoints",
                           training_frame = as.h2o(allPlayers), model_id = "fdZeroPoints", 
                           seed = 12, 
                           nfolds = 10, 
                           keep_cross_validation_predictions = TRUE, 
                           fold_assignment = "Modulo", 
                           distribution = "bernoulli",
                           max_depth = 2,
                           min_rows = 100,
                           ntrees = 100)

h2o.auc(modelZeroPoints)
h2o.auc(modelZeroPoints, xval = T)

testData$fdZeroPointsPred <- as.vector(h2o.predict(modelZeroPoints, testDataH2o)$p1)
testData$gbmResid <- as.numeric(testData$zeroPoints) - 1 - testData$fdZeroPointsPred

binnedplot(testData$bestPlayerExpPoints - testData$bestPlayerfdPoints, testData$gbmResid)

binnedplot(testData$fdZeroPointsPred, testData$gbmResid)
binnedplot(testData$points, testData$gbmResid)
binnedplot(testData$ceil, testData$gbmResid)
binnedplot(testData$pointsCeilDistance, testData$gbmResid)
binnedplot(testData$ownExpPoints, testData$gbmResid)
binnedplot(testData$oppExpPoints, testData$gbmResid)
binnedplot(testData$expPointsDiff, testData$gbmResid)

binnedplot(testData$fdZeroPointsPred[testData$seasonyear == 2020], testData$gbmResid[testData$seasonyear == 2020])
binnedplot(testData$points[testData$seasonyear == 2020], testData$gbmResid[testData$seasonyear == 2020])
binnedplot(testData$scoreDiff[testData$seasonyear == 2020], testData$gbmResid[testData$seasonyear == 2020])

#Models given a non zero prediction

allPlayersNoZero <- subset(allPlayers, allPlayers$fdPoints > 0)
testData <- subset(allPlayersNoZero, allPlayersNoZero$seasonyear == 2020)
trainData <- subset(allPlayersNoZero, allPlayersNoZero$seasonyear < 2020)


## Fd points given score diff model
h2o.init()

testDataH2o <- as.h2o(testData)
trainDataH2o <- as.h2o(trainData)

modelGBMPred <- h2o.gbm(x = c("points" ,"pmin", "scoreDiff", "expDiff", "expDiffMinusSpread"), y = "fdPoints",
                        training_frame = as.h2o(allPlayersNoZero), model_id = "fdPointsGivenDiffModel", 
                        seed = 12, 
                        nfolds = 10, 
                        keep_cross_validation_predictions = TRUE, 
                        fold_assignment = "Modulo", 
                        distribution = "gamma",
                        max_depth = 5,
                        min_rows = 600,
                        ntrees = 100)

h2o.performance(modelGBMPred)
h2o.performance(modelGBMPred, xval = T)

testData$fdPointsPred <- as.vector(h2o.predict(modelGBMPred, testDataH2o))
testData$gbmResid <- as.numeric(testData$fdPoints) - testData$fdPointsPred

binnedplot(testData$points, testData$gbmResid)
binnedplot(testData$ceil, testData$gbmResid)
binnedplot(testData$pointsCeilDistance, testData$gbmResid)
binnedplot(testData$ownExpPoints, testData$gbmResid)
binnedplot(testData$oppExpPoints, testData$gbmResid)
binnedplot(testData$expPointsDiff, testData$gbmResid)

binnedplot(testData$secondBestPlayerExpPoints - testData$secondBestPlayerfdPoints, testData$gbmResid)
binnedplot(testData$secondBestPlayerfdPoints[testData$secondBestPlayerPositionFd == testData$positionFd], testData$gbmResid[testData$secondBestPlayerPositionFd == testData$positionFd])
binnedplot(testData$secondBestPlayerfdPoints[testData$secondBestPlayerPositionFd != testData$positionFd], testData$gbmResid[testData$secondBestPlayerPositionFd != testData$positionFd])

binnedplot(testData$fdPointsPred, testData$gbmResid)

binnedplot(testData$fdPointsPred[testData$isBestPlayer == 1], testData$gbmResid[testData$isBestPlayer == 1])
binnedplot(testData$fdPointsPred[testData$isSecondBestPlayer == 1], testData$gbmResid[testData$isSecondBestPlayer == 1])

binnedplot(testData$points[testData$isBestPlayer == 1], testData$gbmResid[testData$isBestPlayer == 1])
binnedplot(testData$ceil[testData$isBestPlayer == 1], testData$gbmResid[testData$isBestPlayer == 1])
binnedplot(testData$pointsCeilDistance[testData$isBestPlayer == 1], testData$gbmResid[testData$isBestPlayer == 1])
binnedplot(testData$ownExpPoints[testData$isBestPlayer == 1], testData$gbmResid[testData$isBestPlayer == 1])
binnedplot(testData$oppExpPoints[testData$isBestPlayer == 1], testData$gbmResid[testData$isBestPlayer == 1])
binnedplot(testData$expPointsDiff[testData$isBestPlayer == 1], testData$gbmResid[testData$isBestPlayer == 1])

trainData$fdPointsPred <- as.vector(h2o.predict(modelGBMPred, trainDataH2o))
trainData$gbmResid <- as.numeric(trainData$overCeil) - 1 - trainData$fdPointsPred

binnedplot(trainData$salary, trainData$gbmResid)
binnedplot(trainData$fdPointsPred, trainData$gbmResid)
binnedplot(trainData$points, trainData$gbmResid)
binnedplot(trainData$ceil, trainData$gbmResid)
binnedplot(trainData$pointsCeilDistance, trainData$gbmResid)

#Model given best and second best player

testDataBP <- subset(testData[c("team", "date", "fdPointsPred", "fdPoints")], testData$isBestPlayer == 1)
trainDataBP <- subset(trainData[c("team", "date", "fdPointsPred", "fdPoints")], trainData$isBestPlayer == 1)

testDataSP <- subset(testData[c("team", "date", "fdPointsPred", "fdPoints")],  testData$isSecondBestPlayer == 1)
trainDataSP <- subset(trainData[c("team", "date", "fdPointsPred", "fdPoints")], trainData$isSecondBestPlayer == 1)

colnames(testDataBP) <- c("team", "date", "bestPlayerfdPointsPred", "bestPlayerFdPoints")
colnames(trainDataBP) <- c("team", "date", "bestPlayerfdPointsPred", "bestPlayerFdPoints")

colnames(testDataSP) <- c("team", "date", "secondBestPlayerfdPointsPred", "secondBestPlayerFdPoints")
colnames(trainDataSP) <- c("team", "date", "secondBestPlayerfdPointsPred", "secondBestPlayerFdPoints")


testDataNB <- subset(testData, testData$isBestPlayer == 0 & testData$isSecondBestPlayer == 0)
trainDataNB <- subset(trainData, trainData$isBestPlayer == 0 & trainData$isSecondBestPlayer == 0)

testDataNB <- merge(testDataNB, testDataBP, by = c("team", "date"))
testDataNB <- merge(testDataNB, testDataSP, by = c("team", "date"))

trainDataNB <- merge(trainDataNB, trainDataBP, by = c("team", "date"))
trainDataNB <- merge(trainDataNB, trainDataSP, by = c("team", "date"))


testDataNB$bestPlayerDiff <- testDataNB$bestPlayerfdPointsPred - testDataNB$bestPlayerFdPoints
testDataNB$secondBestPlayerDiff <- testDataNB$secondBestPlayerfdPointsPred - testDataNB$secondBestPlayerFdPoints

trainDataNB$bestPlayerDiff <- trainDataNB$bestPlayerfdPointsPred - trainDataNB$bestPlayerFdPoints
trainDataNB$secondBestPlayerDiff <- trainDataNB$secondBestPlayerfdPointsPred - trainDataNB$secondBestPlayerFdPoints


testDataH2o <- as.h2o(testDataNB)
trainDataH2o <- as.h2o(trainDataNB)

modelGBMPred <- h2o.gbm(x = c("points",  "pmin", "scoreDiff", "expPointsDiff", "oppExpPoints", "bestPlayerDiff", "secondBestPlayerDiff", "bestPlayerFdPoints", "secondBestPlayerFdPoints"), y = "fdPoints",
                                                
                        training_frame = trainDataH2o, model_id = "fdPointsGivenBestPlayerModel", 
                        seed = 12, 
                        nfolds = 10, 
                        keep_cross_validation_predictions = TRUE, 
                        fold_assignment = "Modulo", 
                        distribution = "gamma",
                        max_depth = 4,
                        min_rows = 1000,
                        ntrees = 100)

h2o.performance(modelGBMPred)
h2o.performance(modelGBMPred, xval = T)

testDataNB$fdPointsPredGivenFav <- as.vector(h2o.predict(modelGBMPred, testDataH2o))
testDataNB$gbmResidGivenFav <- as.numeric(testDataNB$fdPoints) - testDataNB$fdPointsPredGivenFav

binnedplot(testDataNB$fdPointsPredGivenFav, testDataNB$gbmResidGivenFav)
binnedplot(testDataNB$fdPointsPred, testDataNB$gbmResidGivenFav)
binnedplot(testDataNB$bestPlayerfdPoints - testDataNB$fdPointsPredGivenFav, testDataNB$gbmResidGivenFav)

binnedplot(testDataNB$bestPlayerExpPoints - testDataNB$bestPlayerfdPoints, testDataNB$gbmResidGivenFav)
binnedplot(testDataNB$bestPlayerFdPoints, testDataNB$gbmResidGivenFav)

binnedplot(testDataNB$bestPlayerFdPoints[testDataNB$points < 30], testDataNB$gbmResidGivenFav[testDataNB$points < 30])
binnedplot(testDataNB$bestPlayerFdPoints, testDataNB$gbmResidGivenFav)
binnedplot(testDataNB$bestPlayerFdPoints, testDataNB$gbmResidGivenFav)

binnedplot(testDataNB$bestPlayerExpPoints[testDataNB$bestPlayerPositionFd == testDataNB$positionFd], testDataNB$gbmResidGivenFav[testDataNB$bestPlayerPositionFd == testDataNB$positionFd])
binnedplot(testDataNB$bestPlayerExpPoints[testDataNB$bestPlayerPositionFd != testDataNB$positionFd], testDataNB$gbmResidGivenFav[testDataNB$bestPlayerPositionFd != testDataNB$positionFd])

binnedplot(testDataNB$expPointsDiff, testDataNB$gbmResidGivenFav)
binnedplot(testDataNB$oppExpPoints, testDataNB$gbmResidGivenFav)

trainDataNB$fdPointsPredGivenFav <- as.vector(h2o.predict(modelGBMPred, trainDataH2o))
trainDataNB$gbmResidGivenFav <- as.numeric(trainDataNB$fdPoints) - trainDataNB$fdPointsPredGivenFav



#Variance model
testDataNB$fdPointsPred <- testDataNB$fdPointsPredGivenFav
trainDataNB$fdPointsPred <- trainDataNB$fdPointsPredGivenFav

testDataNB <- testDataNB[,1:73]
trainDataNB <- trainDataNB[,1:73]

testData <- subset(testData[,1:73], testData$isBestPlayer == 1 | testData$isSecondBestPlayer == 1)
trainData <- subset(trainData[,1:73], trainData$isBestPlayer == 1 | trainData$isSecondBestPlayer == 1)

testData <- rbind(testData, testDataNB)
trainData <- rbind(trainData, trainDataNB)

testData$var <- (testData$fdPoints - testData$fdPointsPred) ^ 2
trainData$var <- (trainData$fdPoints - trainData$fdPointsPred) ^ 2

testDataH2o <- as.h2o(testData)
trainDataH2o <- as.h2o(trainData)

modelGBMVar <- h2o.gbm(x = c("fdPointsPred", "pmin", "teamDiff", "expPointsDiff", "floor", "ceil"), y = "var",
                       training_frame = trainDataH2o, model_id = "varModel", 
                       seed = 12, 
                       nfolds = 10, 
                       keep_cross_validation_predictions = TRUE, 
                       fold_assignment = "Modulo", 
                       distribution = "gaussian",
                       max_depth = 5,
                       min_rows = 2000,
                       ntrees = 200)
h2o.r2(modelGBMVar)
h2o.r2(modelGBMVar, xval = T)

testData$varPred <- as.vector(h2o.predict(modelGBMVar, testDataH2o))
testData$varResid <- testData$var  - testData$varPred

trainData$varPred <- as.vector(h2o.predict(modelGBMVar, trainDataH2o))
trainData$varResid <- trainData$var  - trainData$varPred

binnedplot(testData$salary, testData$varResid)
binnedplot(testData$varPred, testData$varResid)
binnedplot(testData$points, testData$varResid)
binnedplot(testData$ceil, testData$varResid)
binnedplot(testData$pointsCeilDistance, testData$varResid)
binnedplot(testData$ownExpPoints, testData$varResid)
binnedplot(testData$oppExpPoints, testData$varResid)
binnedplot(testData$ownExpPoints - testData$oppExpPoints, testData$varResid)
binnedplot(testData$ratio, testData$varResid)

##Assume points are gamma distributed

testData$scale = testData$varPred / testData$fdPointsPred
testData$shape = testData$fdPointsPred / testData$scale

trainData$scale = trainData$varPred / trainData$fdPointsPred
trainData$shape = trainData$fdPointsPred / trainData$scale

testData$varPred[1]
testData$shape[1]
testData$fdPointsPred[1]
mean(rgamma(10000, shape = 17.73583, scale = 2.618682))

testData$newCeil <- 1.5 * testData$fdPointsPred
testData$newCeilTwo <- 1.75 * testData$fdPointsPred

testData$overNewCeil <- 1 * (testData$fdPoints > testData$newCeil)
testData$overNewCeilProb <- 1 - pgamma(testData$newCeil, scale = testData$scale, shape = testData$shape)

testData$overNewCeil2 <- 1 * (testData$fdPoints > testData$newCeilTwo)
testData$overNewCeilProb2 <- 1 - pgamma(testData$newCeilTwo, scale = testData$scale, shape = testData$shape)

testData$overNewCeilResid <- testData$overNewCeil - testData$overNewCeilProb
testData$overNewCeilResid2 <- testData$overNewCeil2 - testData$overNewCeilProb2

testData$underMeanProb <- pgamma(testData$fdPointsPred, shape = testData$shape, scale = testData$scale)
testData$underMeanResid <- 1 * (testData$fdPoints < testData$fdPointsPred) - testData$underMeanProb

trainData$underMeanProb <- pgamma(trainData$fdPointsPred, shape = trainData$shape, scale = trainData$scale)
trainData$underMeanResid <- 1 * (trainData$fdPoints < trainData$fdPointsPred) - trainData$underMeanProb

binnedplot(testData$newCeil, testData$overNewCeilResid)
binnedplot(testData$fdPointsPred, testData$overNewCeilResid)
binnedplot(testData$varPred, testData$overNewCeilResid)
binnedplot(testData$teamDiff, testData$overNewCeilResid)

binnedplot(testData$newCeil, testData$overNewCeilResid2)
binnedplot(testData$fdPointsPred, testData$overNewCeilResid2)
binnedplot(testData$varPred, testData$overNewCeilResid2)
binnedplot(testData$teamDiff, testData$overNewCeilResid2)

binnedplot(testData$newCeil, testData$underMeanResid)
binnedplot(testData$fdPointsPred, testData$underMeanResid)
binnedplot(testData$varPred, testData$underMeanResid)
binnedplot(testData$teamDiff, testData$underMeanResid)

#

mean(testData$fdPoints[testData$fdPointsPred > 30 & testData$fdPointsPred < 40])
mean(testData$fdPointsPred[testData$fdPointsPred > 30 & testData$fdPointsPred < 40])

mean(testData$fdPointsPred[testData$fdPointsPred > 30 & testData$fdPointsPred < 40] < testData$fdPoints[testData$fdPointsPred > 30 & testData$fdPointsPred < 40])

#
subsetToLook <- testData$fdPointsPred > 25 & testData$fdPointsPred < 32
sum(subsetToLook)
hist(testData$fdPoints[subsetToLook], freq = F, ylim = c(0, 0.07))
curve(dgamma(x, shape = mean(testData$shape[subsetToLook]), scale = mean(testData$scale[subsetToLook])), add = T)


plotHist <- function(lowerPoint, upperPoint, df = testData){
  subsetToLook <- df$fdPointsPred > lowerPoint & df$fdPointsPred < upperPoint
  windows()
  hist(df$fdPoints[subsetToLook], freq = F, ylim = c(0, 0.07), main = paste0(sum(subsetToLook), " observations"))
  curve(dgamma(x, shape = mean(df$shape[subsetToLook]), scale = mean(df$scale[subsetToLook])), add = T, col = "red")
  pointsResid = mean(df$fdPointsPred[subsetToLook] - df$fdPoints[subsetToLook])
  
  print(paste0("Points pred resid: ",pointsResid))
  print(paste0("Under mean resid: ", mean(1 * (df$fdPoints[subsetToLook] < df$fdPointsPred[subsetToLook]) - df$underMeanProb[subsetToLook])))
}

commonCols <- c("fdPoints", "fdPointsPred", "underMeanResid", "shape", "scale", "underMeanProb")
allData <- rbind(testData[commonCols], trainData[commonCols])

plotHist(5, 15, df = allData)
plotHist(15, 25, df = allData)
plotHist(25, 30, df = allData)
plotHist(30, 35, df = allData)
plotHist(35, 45, df = allData)
plotHist(45, 80, df = allData)

plotHist(5, 15, df = testData)
plotHist(15, 25, df = testData)
plotHist(25, 30, df = testData)
plotHist(30, 40, df = testData)
plotHist(40, 80, df = testData)

plotHist(15, 25, df = trainData)

plotHist(30, 40)
plotHist(30, 40, df = trainData)

plotHist(40, 550)
plotHist(40, 550, df = trainData)


testData$scale2 = 0.9 * testData$varPred / testData$fdPointsPred
testData$shape2 = testData$fdPointsPred / testData$scale2

testData$underMeanProb2 <- pgamma(testData$fdPointsPred, shape = testData$shape2, scale = testData$scale2)
testData$underMeanResid2 <- 1 * (testData$fdPoints < testData$fdPointsPred) - testData$underMeanProb2

plotHist2 <- function(lowerPoint, upperPoint, df = testData){
  subsetToLook <- df$fdPointsPred > lowerPoint & df$fdPointsPred < upperPoint
  windows()
  hist(df$fdPoints[subsetToLook], freq = F, ylim = c(0, 0.07), main = paste0(sum(subsetToLook), " observations"))
  curve(dgamma(x, shape = mean(df$shape2[subsetToLook]), scale = mean(df$scale2[subsetToLook])), add = T, col = "red")
  print(mean(df$underMeanResid2[subsetToLook]))
}

plotHist2(30, 40)
plotHist(30, 40)

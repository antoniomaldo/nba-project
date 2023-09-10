library(arm)
library(h2o)

listFiles <- list.files("C:\\Users\\aostios\\Documents\\Basketball Model\\NBA Model\\Players New\\Best team backtest\\contests\\2018_19", full.names = T)
listFiles <- c(listFiles, list.files("C:\\Users\\aostios\\Documents\\Basketball Model\\NBA Model\\Players New\\Best team backtest\\contests\\2019_20", full.names = T))

allPlayers <- data.frame()
gameId <- 1
for(folder in listFiles){
  fileDir <- paste0(folder, "\\bestTeams.csv")
  if(file.exists(fileDir)){
    bestTeams <- read.csv(fileDir)
    maxPoints <- max(bestTeams$FdPoints)
    bestTeam  = subset(bestTeams, bestTeams$FdPoints == maxPoints)[1,]
    bestTeam = as.character(unlist(bestTeam[,2:10]))
    bestTeam <- sub(' \\(.*', '', bestTeam)
    players <- read.csv(paste0(folder, "\\players.csv"))
    players$PlayerNameId <- paste0(players$playerName, "-", players$PlayerId)
    players$bestTeam <- 1 * (players$PlayerNameId %in% bestTeam)
    players$numbTeam <- 2 * length(unique(players$GameId))
    players$difTeams <- length(unique(players$Team[players$bestTeam == 1]))
    players$teamDiff <- ifelse(players$isHomePlayer, 1, -1) * (players$Home.Final.Score - players$Away.Final.Score)
    teams <- data.frame(table(players$Team[players$bestTeam == 1]))
    colnames(teams) <- c("Team", "numbPlayersFromTeam")
    players <- merge(players, teams, by = "Team", all.x = T)
    players$numbPlayersFromTeam[is.na(players$numbPlayersFromTeam)] <- 0
    if(max(players$numbTeam) == 28){
      print(folder)
    }
    players$id <- gameId
    gameId = gameId + 1
    allPlayers <- rbind(allPlayers, players)
  }else{
    print(paste0("File doesnt exist: ", fileDir))
  }
}

agg = aggregate(bestTeam ~ date, allPlayers, sum)
agg <- subset(agg, agg$bestTeam == 9)

allPlayers <- subset(allPlayers, allPlayers$numbTeam < 30 & allPlayers$date %in% agg$date)
allPlayers$overCeil <- as.factor(1 * (allPlayers$fdPoints > allPlayers$ceil))


#Best and second best player

bestPlayer <- aggregate(points ~ Team + Date, allPlayers, max)
colnames(bestPlayer)[3] <- "bestPlayerExpPoints"

allPlayers <- merge(allPlayers, bestPlayer, by = c("Team", "Date"))
allPlayers$isBestPlayer <- 1 * (allPlayers$points == allPlayers$bestPlayerExpPoints)

secondBest <- aggregate(points ~ Team + Date, subset(allPlayers, allPlayers$isBestPlayer == 0), max)
colnames(secondBest)[3] <- "secondBestPlayerExpPoints"

allPlayers <- merge(allPlayers, secondBest, by = c("Team", "Date"))
allPlayers$isSecondBestPlayer <- 1 * (allPlayers$points == allPlayers$secondBestPlayerExpPoints)

allPlayers <- merge(allPlayers, subset(allPlayers[c("Team", "Date", "positionFd", "fdPoints")], allPlayers$isBestPlayer == 1), by = c("Team", "Date"))
allPlayers <- merge(allPlayers, subset(allPlayers[c("Team", "Date", "positionFd.x", "fdPoints.x")], allPlayers$isSecondBestPlayer == 1), by = c("Team", "Date"))

colnames(allPlayers)[colnames(allPlayers) == "fdPoints.x.x"] <- "fdPoints"
colnames(allPlayers)[colnames(allPlayers) == "positionFd.x.x"] <- "positionFd"

colnames(allPlayers)[colnames(allPlayers) == "fdPoints.y"] <- "bestPlayerfdPoints"
colnames(allPlayers)[colnames(allPlayers) == "positionFd.y"] <- "bestPlayerPositionFd"

colnames(allPlayers)[colnames(allPlayers) == "fdPoints.x.y"] <- "secondBestPlayerfdPoints"
colnames(allPlayers)[colnames(allPlayers) == "positionFd.x.y"] <- "secondBestPlayerPositionFd"

#Models
#20200114

allPlayers$id[which(allPlayers$Date == "20191022")][1]
allPlayers$id[which(allPlayers$Date == "20200114")][1]

allPlayers$pointsCeilDistance = allPlayers$ceil - allPlayers$points
allPlayers$homeExpPoints <- (allPlayers$totalPoints - allPlayers$matchSpread) / 2
allPlayers$awayExpPoints <- allPlayers$totalPoints - allPlayers$homeExpPoints
allPlayers$ownExpPoints <- ifelse(allPlayers$isHomePlayer, allPlayers$homeExpPoints, allPlayers$awayExpPoints)
allPlayers$oppExpPoints <- ifelse(!allPlayers$isHomePlayer, allPlayers$homeExpPoints, allPlayers$awayExpPoints)
allPlayers$expPointsDiff <- allPlayers$ownExpPoints - allPlayers$oppExpPoints


#Zero points model
allPlayers$zeroPoints <- as.factor(1 * (allPlayers$fdPoints <= 0))

testData <- subset(allPlayers, allPlayers$id >= 139 & allPlayers$id <= 219)
trainData <- subset(allPlayers, !allPlayers$id %in% testData$id)

testData$minSalary <- as.factor(1 * (testData$salary == 3500))
trainData$minSalary <- as.factor(1 * (trainData$salary == 3500))

h2o.init()

testDataH2o <- as.h2o(testData)
trainDataH2o <- as.h2o(trainData)

modelZeroPoints <- h2o.gbm(x = c("points",  "pmin", "teamDiff", "minSalary", "salary", "pointsCeilDistance", "expPointsDiff"), y = "zeroPoints",
                        training_frame = trainDataH2o, model_id = "fdZeroPoints", 
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

binnedplot(testData$salary, testData$gbmResid)
binnedplot(testData$bestPlayerExpPoints - testData$bestPlayerfdPoints, testData$gbmResid)
binnedplot(testData$bestPlayerfdPoints[testData$bestPlayerPositionFd == testData$positionFd], testData$gbmResid[testData$bestPlayerPositionFd == testData$positionFd])

binnedplot(testData$fdZeroPointsPred, testData$gbmResid)
binnedplot(testData$points, testData$gbmResid)
binnedplot(testData$ceil, testData$gbmResid)
binnedplot(testData$pointsCeilDistance, testData$gbmResid)
binnedplot(testData$ownExpPoints, testData$gbmResid)
binnedplot(testData$oppExpPoints, testData$gbmResid)
binnedplot(testData$expPointsDiff, testData$gbmResid)









allPlayers <- subset(allPlayers, allPlayers$fdPoints > 0)
testData <- subset(allPlayers, allPlayers$id >= 139 & allPlayers$id <= 219)
trainData <- subset(allPlayers, !allPlayers$id %in% testData$id)

## Fd points given score diff model
h2o.init()

trainData$salaryPerTeams <- trainData$salary / trainData$numbTeam
testData$salaryPerTeams <- testData$salary / testData$numbTeam
trainData$bestTeamFactor <- as.factor(trainData$bestTeam)
testData$bestTeamFactor <- as.factor(testData$bestTeam)
trainData$numbTeamFactor <- as.factor(trainData$numbTeam)
testData$numbTeamFactor <- as.factor(testData$numbTeam)
testDataH2o <- as.h2o(testData)
trainDataH2o <- as.h2o(trainData)

modelGBMPred <- h2o.gbm(x = c("points",  "pmin", "teamDiff", "pointsCeilDistance", "expPointsDiff"), y = "fdPoints",
                        training_frame = trainDataH2o, model_id = "fdPointsGivenDiffModel", 
                        seed = 12, 
                        nfolds = 10, 
                        keep_cross_validation_predictions = TRUE, 
                        fold_assignment = "Modulo", 
                        distribution = "gamma",
                        max_depth = 4,
                        min_rows = 600,
                        ntrees = 100)

h2o.performance(modelGBMPred)
h2o.performance(modelGBMPred, xval = T)

testData$fdPointsPred <- as.vector(h2o.predict(modelGBMPred, testDataH2o))
testData$gbmResid <- as.numeric(testData$fdPoints) - testData$fdPointsPred

binnedplot(testData$salary, testData$gbmResid)

binnedplot(testData$bestPlayerExpPoints - testData$bestPlayerfdPoints, testData$gbmResid)
binnedplot(testData$bestPlayerfdPoints[testData$bestPlayerPositionFd == testData$positionFd], testData$gbmResid[testData$bestPlayerPositionFd == testData$positionFd])
binnedplot(testData$bestPlayerfdPoints[testData$bestPlayerPositionFd != testData$positionFd], testData$gbmResid[testData$bestPlayerPositionFd != testData$positionFd])

binnedplot(testData$secondBestPlayerExpPoints - testData$secondBestPlayerfdPoints, testData$gbmResid)
binnedplot(testData$secondBestPlayerfdPoints[testData$secondBestPlayerPositionFd == testData$positionFd], testData$gbmResid[testData$secondBestPlayerPositionFd == testData$positionFd])
binnedplot(testData$secondBestPlayerfdPoints[testData$secondBestPlayerPositionFd != testData$positionFd], testData$gbmResid[testData$secondBestPlayerPositionFd != testData$positionFd])

binnedplot(testData$fdPointsPred, testData$gbmResid)
binnedplot(testData$points, testData$gbmResid)
binnedplot(testData$ceil, testData$gbmResid)
binnedplot(testData$pointsCeilDistance, testData$gbmResid)
binnedplot(testData$ownExpPoints, testData$gbmResid)
binnedplot(testData$oppExpPoints, testData$gbmResid)
binnedplot(testData$expPointsDiff, testData$gbmResid)

trainData$fdPointsPred <- as.vector(h2o.predict(modelGBMPred, trainDataH2o))
trainData$gbmResid <- as.numeric(trainData$overCeil) - 1 - trainData$fdPointsPred

binnedplot(trainData$salary, trainData$gbmResid)
binnedplot(trainData$fdPointsPred, trainData$gbmResid)
binnedplot(trainData$points, trainData$gbmResid)
binnedplot(trainData$ceil, trainData$gbmResid)
binnedplot(trainData$pointsCeilDistance, trainData$gbmResid)

# #GBM model
# testData$ratio <- testData$ceil / testData$points
# trainData$ratio <- trainData$ceil / trainData$points
# testData$newCeil <- testData$fdPoints
# trainData$newCeil <- trainData$fdPointsPred 
# trainData <- subset(trainData, !is.na(trainData$newCeil))
# testData$overNewCeil <- as.factor(1 * (testData$fdPointsPred > testData$fdPoints))
# trainData$overNewCeil <- as.factor(1 * (trainData$fdPointsPred > trainData$fdPoints))
# testDataH2o <- as.h2o(testData)
# trainDataH2o <- as.h2o(trainData)
# modelGBM <- h2o.gbm(x = c("fdPointsPred", "newCeil", "pmin", "teamDiff", "matchSpread", "pointsCeilDistance", "expPointsDiff"), y = "overNewCeil",
#                     training_frame = trainDataH2o, model_id = "overCeilModel", 
#                     seed = 12, 
#                     nfolds = 10, 
#                     keep_cross_validation_predictions = TRUE, 
#                     fold_assignment = "Modulo", 
#                     distribution = "bernoulli",
#                     max_depth = 4,
#                     min_rows = 600,
#                     ntrees = 100)
# h2o.auc(modelGBM)
# h2o.auc(modelGBM, xval = T)
# testData$overCeilPred <- as.vector(h2o.predict(modelGBM, testDataH2o)$p1)
# testData$overCeilResid <- as.numeric(testData$overNewCeil) - 1 - testData$overCeilPred
# binnedplot(testData$salary, testData$overCeilResid)
# binnedplot(testData$overCeilPred, testData$overCeilResid)
# binnedplot(testData$points, testData$overCeilResid)
# binnedplot(testData$ceil, testData$overCeilResid)
# binnedplot(testData$pointsCeilDistance, testData$overCeilResid)
# binnedplot(testData$ownExpPoints, testData$overCeilResid)
# binnedplot(testData$oppExpPoints, testData$overCeilResid)
# binnedplot(testData$ownExpPoints - testData$oppExpPoints, testData$overCeilResid)
# binnedplot(testData$overCeilPred[testData$overCeilPred > 0.3], testData$overCeilResid[testData$overCeilPred > 0.3])
# binnedplot(testData$overCeilPred[testData$overCeilPred > 0.3], testData$overCeilResid[testData$overCeilPred > 0.3])
# trainData$overCeilPred <- as.vector(h2o.predict(modelGBM, trainDataH2o)$p1)
# trainData$gbmResid <- as.numeric(trainData$overNewCeil) - 1 - trainData$overCeilPred
# binnedplot(trainData$salary, trainData$gbmResid)
# binnedplot(trainData$overCeilPred, trainData$gbmResid)
# binnedplot(trainData$points, trainData$gbmResid)
# binnedplot(trainData$ceil, trainData$gbmResid)
# binnedplot(trainData$pointsCeilDistance, trainData$gbmResid)
# binnedplot(trainData$ownExpPoints - trainData$oppExpPoints, trainData$gbmResid)

##Variance model
testData$var <- (testData$fdPoints - testData$fdPointsPred) ^ 2
trainData$var <- (trainData$fdPoints - trainData$fdPointsPred) ^ 2

testDataH2o <- as.h2o(testData)
trainDataH2o <- as.h2o(trainData)

modelGBMVar <- h2o.gbm(x = c("fdPointsPred", "pmin", "teamDiff", "expPointsDiff"), y = "var",
                       training_frame = trainDataH2o, model_id = "varModel", 
                       seed = 12, 
                       nfolds = 10, 
                       keep_cross_validation_predictions = TRUE, 
                       fold_assignment = "Modulo", 
                       distribution = "gaussian",
                       max_depth = 4,
                       min_rows = 600,
                       ntrees = 100)
h2o.r2(modelGBMVar)
h2o.r2(modelGBMVar, xval = T)

testData$varPred <- as.vector(h2o.predict(modelGBMVar, testDataH2o))
testData$varResid <- testData$var  - testData$varPred

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

binnedplot(testData$newCeil, testData$overNewCeilResid)
binnedplot(testData$fdPointsPred, testData$overNewCeilResid)
binnedplot(testData$varPred, testData$overNewCeilResid)
binnedplot(testData$teamDiff, testData$overNewCeilResid)

binnedplot(testData$newCeil, testData$overNewCeilResid2)
binnedplot(testData$fdPointsPred, testData$overNewCeilResid2)
binnedplot(testData$varPred, testData$overNewCeilResid2)
binnedplot(testData$teamDiff, testData$overNewCeilResid2)


#
testData$sim <- rgamma(nrow(testData), scale = testData$scale, shape = testData$shape)

day = subset(testData, testData$date == "2019-11-08")

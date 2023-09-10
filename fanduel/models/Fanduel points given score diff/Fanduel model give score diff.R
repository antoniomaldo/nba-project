library(arm)
library(h2o)

BASE_DIR = "C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate"

files19 <- list.files(paste0(BASE_DIR, "\\2019"), full.names  = T)
files20 <- list.files(paste0(BASE_DIR, "\\2020"), full.names  = T)
files21 <- list.files(paste0(BASE_DIR, "\\2021"), full.names  = T)
files22 <- list.files(paste0(BASE_DIR, "\\2022"), full.names  = T)

mappedData19 <- do.call(rbind, lapply(files19, read.csv))
mappedData20 <- do.call(rbind, lapply(files20, read.csv))
mappedData21 <- do.call(rbind, lapply(files21, read.csv))
mappedData22 <- do.call(rbind, lapply(files22, read.csv))

#mappedData20 <- subset(mappedData20, mappedData20$GameId <= 401161612)
length(unique(mappedData19$GameId))
length(unique(mappedData20$GameId))

mappedData21$matchSpread <- ifelse(mappedData21$isHomePlayer, mappedData21$oppTotal - mappedData21$total, mappedData21$total - mappedData21$oppTotal)
mappedData22$matchSpread <- ifelse(mappedData22$isHomePlayer, mappedData22$oppTotal - mappedData22$total, mappedData22$total - mappedData22$oppTotal)

mappedData21$totalPoints <- mappedData21$oppTotal + mappedData21$total
mappedData22$totalPoints <- mappedData22$oppTotal + mappedData22$total

mappedData21$positionFd <- mappedData21$positionfd
mappedData22$positionFd <- mappedData22$positionfd

mappedData21$Freq <- 1
mappedData22$Freq <- 1

allData <- rbind(mappedData19, mappedData20)
allData <- rbind(allData, mappedData21[colnames(allData)])
allData <- rbind(allData, mappedData22[colnames(allData)])

rm(mappedData19, mappedData20, mappedData21, mappedData22, files19, files20, BASE_DIR)

allData$homeDiff <- allData$Home.Final.Score - allData$Away.Final.Score
allData$scoreDiff = ifelse(allData$isHomePlayer, allData$homeDiff , -1 * allData$homeDiff)
allData$expDiff = ifelse(allData$isHomePlayer, -1 * allData$matchSpread , allData$matchSpread)
allData$expDiffMinusSpread <- allData$expDiff - allData$scoreDiff
  
trainDataIds <- sample(unique(allData$GameId), size  = 0.75 * length(unique(allData$GameId)))

allData <- subset(allData, !is.na(allData$points))

allData$zeroPoints <- as.factor(1 * (allData$fdPoints <= 0))

trainData <- subset(allData, allData$GameId %in% trainDataIds)
testData <- subset(allData, !allData$GameId %in% trainDataIds)


#Models
h2o.init()

#Zero points model

trainDataH2o <- as.h2o(trainData)
testDataH2o <- as.h2o(testData)


modelGBM <- h2o.gbm(x = c("points" ,"pmin", "scoreDiff", "expDiff", "expDiffMinusSpread"), y = "zeroPoints",
                    training_frame = as.h2o(allData), model_id = "FdZeroPoints", 
                    seed = 12, 
                    nfolds = 10, 
                    keep_cross_validation_predictions = TRUE, 
                    fold_assignment = "Modulo", 
                    distribution = "bernoulli",
                    max_depth = 5,
                    min_rows = 300,
                    ntrees = 100)

h2o.auc(modelGBM)
h2o.auc(modelGBM, xval = T)


testData$zeroPointsPred <- as.vector(h2o.predict(modelGBM, testDataH2o)$p1)
testData$zeroResid <- as.numeric(testData$zeroPoints) - 1 - testData$zeroPointsPred

binnedplot(testData$points, testData$zeroResid)
binnedplot(testData$pmin, testData$zeroResid)
binnedplot(testData$pmin[testData$pmin < 10], testData$zeroResid[testData$pmin < 10])

binnedplot(testData$scoreDiff, testData$zeroResid)

trainData$zeroPointsPred <- as.vector(h2o.predict(modelGBM, trainDataH2o)$p1)
trainData$zeroResid <- as.numeric(trainData$zeroPoints) - 1 - trainData$zeroPointsPred

#
trainDataNoZero <- subset(trainData, trainData$fdPoints > 0)
testDataNoZero <- subset(testData, testData$fdPoints > 0)

trainDataH2o <- as.h2o(trainDataNoZero)
testDataH2o <- as.h2o(testDataNoZero)


modelGBM <- h2o.gbm(x = c("points" ,"pmin", "scoreDiff", "expDiff", "expDiffMinusSpread"), y = "fdPoints",
                    
                    training_frame = as.h2o(rbind(testDataNoZero[,1:50], trainDataNoZero[,1:50])), model_id = "FdPointsGivenScoreDiff", 
                    seed = 12, 
                    nfolds = 10, 
                    keep_cross_validation_predictions = TRUE, 
                    fold_assignment = "Modulo", 
                    distribution = "gamma",
                    max_depth = 5,
                    min_rows = 200,
                    ntrees = 100)

h2o.performance(modelGBM)
h2o.performance(modelGBM, xval = T)


testDataNoZero$pointsPred <- as.vector(h2o.predict(modelGBM, testDataH2o))
testDataNoZero$fdPointsResid <- testDataNoZero$fdPoints - testDataNoZero$pointsPred

binnedplot(testDataNoZero$points, testDataNoZero$fdPointsResid)
binnedplot(testDataNoZero$pmin, testDataNoZero$fdPointsResid)
binnedplot(testDataNoZero$scoreDiff, testDataNoZero$fdPointsResid)
binnedplot(testDataNoZero$expDiffMinusSpread, testDataNoZero$fdPointsResid)

trainDataNoZero$pointsPred <- as.vector(h2o.predict(modelGBM, trainDataH2o))
trainDataNoZero$fdPointsResid <- trainDataNoZero$fdPoints - trainDataNoZero$pointsPred



trainDataNoZero$finalPred <- (1 - trainDataNoZero$zeroPointsPred) * trainDataNoZero$pointsPred


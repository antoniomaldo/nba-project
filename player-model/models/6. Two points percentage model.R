library(sqldf)
library(h2o)
library(arm)
source("C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\Model Utils.R")

modelData <- readRDS("C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\alllDataThreeProp.rds")

##Add score diff

scoreAgg <- aggregate(Points ~ GameId + Team, modelData, sum)


modelData <- sqldf("SELECT t1.*, t2.Points AS ownTeamPoints, t3.Points AS oppTeamPoints 
               FROM modelData t1 
               LEFT JOIN scoreAgg t2 ON t1.GameId = t2.GameId AND t1.Team = t2.Team 
               LEFT JOIN scoreAgg t3 ON t1.GameId = t3.GameId AND t1.Team != t3.Team")

# numbOfPlayers <- aggregate(Min ~ GameId + Team, modelData, length)
# colnames(numbOfPlayers)[3] <- "numbPlayers"
# 
# 
# modelData <- merge(modelData, numbOfPlayers, by = c("GameId", "Team"))
modelData$scoreDiff <- modelData$ownTeamPoints - modelData$oppTeamPoints
modelData$ownExpDiff <- modelData$ownExpPoints - modelData$oppExpPoints


trainIds <- getTrainIds(modelData)

trainDataGBM <- subset(modelData, modelData$GameId %in% trainIds & !is.na(modelData$twoPerc))
testDataGBM <- subset(modelData, !modelData$GameId %in% trainIds & !is.na(modelData$twoPerc))

h2o.init()

trainDataH2O <- as.h2o(trainDataGBM)
testDataH2O <- as.h2o(testDataGBM)
modelDataH2o <- as.h2o(modelData)


modelGBM = h2o.gbm(x = c("Min", "lastYeartwoPerc", "averageMinutes", "cumTwoPerc",
                         "scoreDiff", "normPred", 
                         "cumPercAttemptedPerMinute", "ownExpPoints", "threePointsProp"), 
                   y = "twoPerc",
                   training_frame = trainDataH2O, model_id = "twoPointsPerc",
                   seed = 12,
                   nfolds = 10,
                   keep_cross_validation_predictions = TRUE,
                   fold_assignment = "Modulo",
                   distribution = "gamma",
                   max_depth = 1,
                   min_rows = 1000,
                   ntrees = 300)

h2o.performance(modelGBM, xval = T) #Mean residual deviance 0.7798013
h2o.performance(modelGBM, xval = F) #Mean residual deviance 0.7790562

h2o.performance(modelGBM, newdata = trainDataH2O) #Mean residual deviance 0.653971
h2o.performance(modelGBM, newdata = testDataH2O) #Mean residual deviance 0.6926597

testDataGBM$predictionsGBM <- as.vector(h2o.predict(modelGBM, testDataH2O))
testDataGBM$residGBM <- testDataGBM$twoPerc - testDataGBM$predictionsGBM

summary(testDataGBM$predictionsGBM)
summary(testDataGBM$residGBM)

plotResiduals(testDataGBM$residGBM, testDataGBM)
plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$Min < 10)
plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$Min > 35)
plotResiduals(testDataGBM$residGBM, testDataGBM, is.na(testDataGBM$lastYeartwoPerc))

plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$averageMinutes < 10)
plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$averageMinutes > 35)
plotResiduals(testDataGBM$residGBM, testDataGBM, !is.na(testDataGBM$ownExpPoints) & testDataGBM$ownExpPoints > 115)
plotResiduals(testDataGBM$residGBM, testDataGBM, !is.na(testDataGBM$ownExpPoints) & testDataGBM$ownExpPoints < 100)
plotResiduals(testDataGBM$residGBM, testDataGBM, is.na(testDataGBM$lastYeartwoPerc))
plotResiduals(testDataGBM$residGBM, testDataGBM, !is.na(testDataGBM$lastYeartwoPerc))

binnedplot(testDataGBM$normPred, testDataGBM$residGBM)
binnedplot(testDataGBM$normPred[testDataGBM$normPred > 15], testDataGBM$residGBM[testDataGBM$normPred > 15])
binnedplot(testDataGBM$normPred[testDataGBM$normPred < 10], testDataGBM$residGBM[testDataGBM$normPred < 10])

binnedplot(testDataGBM$Three.Attempted, testDataGBM$residGBM)
binnedplot(testDataGBM$Fg.Attempted - testDataGBM$Three.Attempted, testDataGBM$residGBM)
binnedplot(testDataGBM$threePointsProp, testDataGBM$residGBM)


modelGBM = h2o.gbm(x = c("Min", "lastYeartwoPerc", "averageMinutes", "cumTwoPerc",
                         "scoreDiff", "normPred", 
                         "cumPercAttemptedPerMinute", "ownExpPoints", "threePointsProp"), 
                   y = "twoPerc",
                   training_frame = modelDataH2o, model_id = "twoPointsPerc",
                   seed = 12,
                   nfolds = 10,
                   keep_cross_validation_predictions = TRUE,
                   fold_assignment = "Modulo",
                   distribution = "gamma",
                   max_depth = 1,
                   min_rows = 1000,
                   ntrees = 300)



## Java Tests

set.seed(100)
javaData <- testDataGBM[sample(1:nrow(testDataGBM), 100),]
predictions <- as.vector(h2o.predict(modelGBM, as.h2o(javaData)))


Covariates <- with(javaData, paste(ownExpPoints, Min, lastYeartwoPerc, 
                                   averageMinutes, cumTwoPerc, scoreDiff, cumPercAttemptedPerMinute, normPred, threePointsProp
                                   
                                   , sep = ","))


test <- paste("Assert.assertEquals(", predictions, "d, MODEL.getTwoPointsPercentage(", Covariates, ") , DELTA);", sep = "")

cat(test, sep="\n")

predictTerms.glm <- function(obj, newdata) {
  t(t(model.matrix(obj$formula, newdata)) * coef(obj))
}

predTerms <- predictTerms.glm(shotMissedModel, javaData)
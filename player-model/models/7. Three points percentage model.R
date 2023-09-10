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

modelData$threePointsAttemptedPred <- modelData$normPred * modelData$threePointsProp
trainIds <- getTrainIds(modelData)

trainDataGBM <- subset(modelData, modelData$GameId %in% trainIds & !is.na(modelData$threePerc))
testDataGBM <- subset(modelData, !modelData$GameId %in% trainIds & !is.na(modelData$threePerc))

h2o.init()

trainDataH2O <- as.h2o(trainDataGBM)
testDataH2O <- as.h2o(testDataGBM)
modelDataH2o <- as.h2o(modelData)


modelGBM = h2o.gbm(x = c("ownExpPoints", "Min", "lastYearThreePerc", "averageMinutes", "cumThreePerc", "scoreDiff", 
                         "cumPercAttemptedPerMinute", "normPred", "threePointsProp", "threePointsAttemptedPred"),
                   y = "threePerc",  
                   training_frame = trainDataH2O, model_id = "threPercPerc", 
                   seed = 12, 
                   nfolds = 10,
                   keep_cross_validation_predictions = TRUE, 
                   fold_assignment = "Modulo", 
                   distribution = "gamma",
                   max_depth = 2,
                   min_rows = 500,
                   ntrees = 500)

h2o.performance(modelGBM, newdata = trainDataH2O) #Mean residual deviance 0.653971
h2o.performance(modelGBM, newdata = testDataH2O) #Mean residual deviance 0.6926597


testDataGBM$predictionsGBM <- as.vector(h2o.predict(modelGBM, testDataH2O))
testDataGBM$residGBM <- testDataGBM$threePerc - testDataGBM$predictionsGBM

mean(testDataGBM$residGBM)

plotResidualsForThree(testDataGBM$residGBM, testDataGBM)
plotResidualsForThree(testDataGBM$residGBM, testDataGBM, testDataGBM$Min < 10)
plotResidualsForThree(testDataGBM$residGBM, testDataGBM, testDataGBM$Min > 35)
plotResidualsForThree(testDataGBM$residGBM, testDataGBM, is.na(testDataGBM$lastYearThreePerc))

plotResidualsForThree(testDataGBM$residGBM, testDataGBM, testDataGBM$scoreDiff > 20)
plotResidualsForThree(testDataGBM$residGBM, testDataGBM, testDataGBM$averageMinutes > 35)
plotResidualsForThree(testDataGBM$residGBM, testDataGBM, !is.na(testDataGBM$ownExpPoints) & testDataGBM$ownExpPoints > 115)
plotResidualsForThree(testDataGBM$residGBM, testDataGBM, !is.na(testDataGBM$ownExpPoints) & testDataGBM$ownExpPoints < 100)
plotResidualsForThree(testDataGBM$residGBM, testDataGBM, is.na(testDataGBM$lastYearThreePerc))
plotResidualsForThree(testDataGBM$residGBM, testDataGBM, !is.na(testDataGBM$lastYearThreePerc))

binnedplot(testDataGBM$Three.Attempted, testDataGBM$residGBM)
binnedplot(testDataGBM$threePointsAttemptedPred, testDataGBM$residGBM)



modelGBM = h2o.gbm(x = c("ownExpPoints", "Min", "lastYearThreePerc", "averageMinutes", "cumThreePerc", "scoreDiff", 
                         "cumPercAttemptedPerMinute", "normPred", "threePointsProp", "threePointsAttemptedPred"),
                   y = "threePerc",  
                   training_frame = modelDataH2o, model_id = "threPercPerc", 
                   seed = 12, 
                   nfolds = 10,
                   keep_cross_validation_predictions = TRUE, 
                   fold_assignment = "Modulo", 
                   distribution = "gamma",
                   max_depth = 2,
                   min_rows = 500,
                   ntrees = 500)

#Java Test

## Java Tests

set.seed(100)
javaData <- testDataGBM[sample(1:nrow(testDataGBM), 100),]
predictions <- as.vector(h2o.predict(modelGBM, as.h2o(javaData)))

Covariates <- with(javaData, paste(ownExpPoints, Min, lastYearThreePerc, averageMinutes, cumThreePerc, scoreDiff, cumPercAttemptedPerMinute, normPred, threePointsProp
                                   
                                   , sep = ","))


test <- paste("Assert.assertEquals(", predictions, "d, MODEL.getThreePointsPercentage(", Covariates, ") , DELTA);", sep = "")

cat(test, sep="\n")

predictTerms.glm <- function(obj, newdata) {
  t(t(model.matrix(obj$formula, newdata)) * coef(obj))
}

predTerms <- predictTerms.glm(shotMissedModel, javaData)
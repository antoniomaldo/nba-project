library(h2o)
library(sqldf)
library(arm)

source("C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\Model Utils.R")

modelData <- readRDS(file = "C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\modelData.rds")

h2o.init()

trainIds <- getTrainIds(modelData)

modelData <- subset(modelData, modelData$Min > 0 & modelData$Fg.Attempted > 0)


trainDataGBM <- subset(modelData, modelData$GameId %in% trainIds)
testDataGBM <- subset(modelData, !modelData$GameId %in% trainIds)

trainDataH2O <- as.h2o(trainDataGBM)
testDataH2O <- as.h2o(testDataGBM)

modelDataH2o <- as.h2o(modelData)

modelGBM = h2o.gbm(x = c("lastYearThreeProp", "cumThreeProp", "normPred", "cumTwoPerc", "cumThreePerc", "ownExpPoints"
                         ), y = "threeProp",  
                                      
                   training_frame = trainDataH2O,
                   model_id = "ThreePropModel", 
                   seed = 12, 
                   nfolds = 10, 
                   keep_cross_validation_predictions = TRUE, 
                 #  fold_assignment = "Modulo", 
                   distribution = "gaussian",
                   max_depth = 4,
                   min_rows = 50,
                   ntrees = 100)

h2o.rmse(modelGBM, xval = T) #0.2033672
h2o.rmse(modelGBM, xval = F) #0.2006701

testDataGBM$predictionsGBM <- as.vector(h2o.predict(modelGBM, testDataH2O))
testDataGBM$residGBM <- testDataGBM$threeProp - testDataGBM$predictionsGBM

mean(testDataGBM$residGBM)

plotResiduals(testDataGBM$residGBM, testDataGBM)
plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$Position == "PG")
plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$Position == "SG")
plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$Position == "SF")
plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$Position == "PF")
plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$Position == "C")


plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$Min < 10)
plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$Min > 35)
plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$gamesPlayedSeason > 15)

plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$averageMinutes > 35)
plotResiduals(testDataGBM$residGBM, testDataGBM, !is.na(testDataGBM$ownExpPoints) & testDataGBM$ownExpPoints > 115)
plotResiduals(testDataGBM$residGBM, testDataGBM, !is.na(testDataGBM$ownExpPoints) & testDataGBM$ownExpPoints < 100)
plotResiduals(testDataGBM$residGBM, testDataGBM, is.na(testDataGBM$lastYeartwoPerc))
plotResiduals(testDataGBM$residGBM, testDataGBM, !is.na(testDataGBM$lastYeartwoPerc))

binnedplot(testDataGBM$predictionsGBM, testDataGBM$residGBM)


trainDataGBM$predictionsGBM <- as.vector(h2o.predict(modelGBM, trainDataH2O))
trainDataGBM$residGBM <- trainDataGBM$threeProp - trainDataGBM$predictionsGBM

mean(trainDataGBM$residGBM)

plotResiduals(trainDataGBM$residGBM, trainDataGBM)
plotResiduals(trainDataGBM$residGBM, trainDataGBM, trainDataGBM$Position == "PG")

plotResiduals(trainDataGBM$residGBM, trainDataGBM, trainDataGBM$Min < 10)
plotResiduals(trainDataGBM$residGBM, trainDataGBM, trainDataGBM$Min > 35)
plotResiduals(trainDataGBM$residGBM, trainDataGBM, trainDataGBM$gamesPlayedSeason > 15)

plotResiduals(trainDataGBM$residGBM, trainDataGBM, trainDataGBM$averageMinutes > 35)
plotResiduals(trainDataGBM$residGBM, trainDataGBM, !is.na(trainDataGBM$ownExpPoints) & trainDataGBM$ownExpPoints > 115)
plotResiduals(trainDataGBM$residGBM, trainDataGBM, !is.na(trainDataGBM$ownExpPoints) & trainDataGBM$ownExpPoints < 100)
plotResiduals(trainDataGBM$residGBM, trainDataGBM, is.na(trainDataGBM$lastYeartwoPerc))
plotResiduals(trainDataGBM$residGBM, trainDataGBM, !is.na(trainDataGBM$lastYeartwoPerc))


modelGBM = h2o.gbm(x = c("lastYearThreeProp", "cumThreeProp", "normPred", "cumTwoPerc", "cumThreePerc", "ownExpPoints"
                         ), y = "threeProp",  
                         
                         training_frame = modelDataH2o,
                         model_id = "ThreePropModel", 
                         seed = 12, 
                         nfolds = 10, 
                         keep_cross_validation_predictions = TRUE, 
                         #  fold_assignment = "Modulo", 
                         distribution = "gaussian",
                         max_depth = 4,
                         min_rows = 50,
                         ntrees = 100)

trainDataGBM$threePointsProp <- as.vector(h2o.predict(modelGBM, trainDataH2O))
testDataGBM$threePointsProp <- as.vector(h2o.predict(modelGBM, testDataH2O))

allData <- rbind(trainDataGBM, testDataGBM)

saveRDS(allData, file = "C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\alllDataThreeProp.rds")

#Java Test

## Java Tests

set.seed(100)
javaData <- testDataGBM[sample(1:nrow(testDataGBM), 100),]
predictions <- as.vector(h2o.predict(modelGBM, as.h2o(javaData)))

Covariates <- with(javaData, paste(lastYearThreeProp, cumThreeProp, normPred, cumTwoPerc, cumThreePerc, ownExpPoints
                                   
                                   , sep = ","))


test <- paste("Assert.assertEquals(", predictions, "d, MODEL.getThreePropOfShots(", Covariates, ") , DELTA);", sep = "")

cat(test, sep="\n")

predictTerms.glm <- function(obj, newdata) {
  t(t(model.matrix(obj$formula, newdata)) * coef(obj))
}

predTerms <- predictTerms.glm(shotMissedModel, javaData)

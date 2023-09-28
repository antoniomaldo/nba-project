library(h2o)
library(sqldf)
library(arm)

source("C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\Model Utils.R")

modelData <- readRDS(file = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\allPlayersWithOdds.rds")

modelData <- subset(modelData, modelData$Fg.Attempted > 0)



luka <- subset(modelData, modelData$Name == "L. Doncic" & modelData$seasonYear >= 2022)
mean(luka$threeProp)

luka$staticProp <- mean(luka$threeProp)

luka$prob_1 <- 0
luka$prob_2 <- 0
luka$prob_3 <- 0
luka$prob_4 <- 0
luka$prob_5 <- 0
luka$prob_6 <- 0
luka$prob_7 <- 0
luka$prob_8 <- 0

for(i in 1:nrow(luka)){
  probs <- dbinom(1:8, luka$Fg.Attempted[i], luka$staticProp[i])
  luka$prob_1[i] <- probs[1]
  luka$prob_2[i] <- probs[2]
  luka$prob_3[i] <- probs[3]
  luka$prob_4[i] <- probs[4]
  luka$prob_5[i] <- probs[5]
  luka$prob_6[i] <- probs[6]
  luka$prob_7[i] <- probs[7]
  luka$prob_8[i] <- probs[8]
}


mean(luka$prob_4)
mean(luka$Three.Attempted == 4)


mean(luka$prob_5)
mean(luka$Three.Attempted == 5)

mean(luka$prob_6)
mean(luka$Three.Attempted == 6)
mean(luka$prob_7)
mean(luka$Three.Attempted == 7)


allData <- data.frame()

for(i in 3001:nrow(modelData)){
  print(i)
  row <- modelData[i,]
  twoAttempted = row$Fg.Attempted - row$Three.Attempted
  twoScored = row$Fg.Made - row$Three.Made
  threeAttempted = row$Three.Attempted
  threeScored = row$Three.Made
  
  while(twoAttempted > 0){
    row$isThree = 0
    if(twoScored > 0){
      row$scored = 1
      twoScored = twoScored - 1
    }else{
      row$scored = 0
    }
    allData <- rbind(allData, row)
    twoAttempted = twoAttempted - 1
  }
  while(threeAttempted > 0){
    row$isThree = 1
    if(threeScored > 0){
      row$scored = 1
      threeScored = threeScored - 1
    }else{
      row$scored = 0
    }
    allData <- rbind(allData, row)
    threeAttempted = threeAttempted - 1
  }
  if(i %% 500 == 0){
    write.csv(allData, paste0("C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\test\\allData_", i, ".csv"))
    allData <- data.frame()
    
  }
}



allData <- do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\test\\", full.names = T), read.csv))


h2o.init()


trainIds <- getTrainIds(allData)

allData$isThreeFactor <- as.factor(allData$isThree)
trainDataGBM <- subset(allData, allData$GameId %in% trainIds)
testDataGBM <- subset(allData, !allData$GameId %in% trainIds)

trainDataH2O <- as.h2o(trainDataGBM)
testDataH2O <- as.h2o(testDataGBM)

modelDataH2o <- as.h2o(modelData)

modelGBM = h2o.gbm(x = c("lastYearThreeProp", "cumThreeProp", "normPred", "cumTwoPerc", "cumThreePerc", "ownExpPoints", "Fg.Attempted"
                         ), y = "isThreeFactor",  
                                      
                   training_frame = trainDataH2O,
                   model_id = "ThreePropModelNew", 
                   seed = 12, 
                   nfolds = 10, 
                   keep_cross_validation_predictions = TRUE, 
                 #  fold_assignment = "Modulo", 
                   distribution = "bernoulli",
                   max_depth = 4,
                   min_rows = 50,
                   ntrees = 100)

h2o.auc(modelGBM, xval = T) #0.2033672
h2o.auc(modelGBM, xval = F) #0.2006701

testDataGBM$predictionsGBM <- as.vector(h2o.predict(modelGBM, testDataH2O)$p1)
testDataGBM$residGBM <- as.numeric(testDataGBM$isThreeFactor) - 1 - testDataGBM$predictionsGBM

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
plotResiduals(testDataGBM$residGBM, testDataGBM, testDataGBM$seasonYear >= 2020)

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

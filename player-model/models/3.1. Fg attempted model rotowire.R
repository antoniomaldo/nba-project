library(h2o)
library(sqldf)
library(arm)

source("C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\Model Utils.R")

allPlayers <- readRDS(file = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\allPlayersWithOdds.rds")
minPreds <- readRDS(file = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\minutePredictions.rds")

minPreds <- subset(minPreds, minPreds$GameId %in% allPlayers$GameId)

minPreds <- merge(minPreds, allPlayers, by = c("GameId", "PlayerId"), all.x = T)
minPreds$id <- paste0(minPreds$GameId, "-", minPreds$Team)

sumGrindersPreds <- aggregate(rotoMin ~ id, minPreds, sum)

#gamesToUse <- subset(sumGrindersPreds$id, abs(sumGrindersPreds$grindersMin - 240) <= 3)
#modelData <- subset(minPreds, minPreds$id %in% gamesToUse)

modelData <- subset(minPreds, !is.na(minPreds$rotoMin))
modelData <- subset(modelData, modelData$played == 1)
modelData$pmin <- modelData$rotoMin
modelData$pmin[modelData$pmin==0] <- 1
modelData$ownExpPointsDiff = modelData$ownExpPoints - modelData$oppExpPoints
modelData$ownExpPointsDiff2 = modelData$ownExpPointsDiff ^ 2

modelData$gamesPlayedSeason2 <- modelData$gamesPlayedSeason ^ 2
modelData$gamesPlayedSeason3 <- pmax(0, modelData$gamesPlayedSeason - 30)
modelData$seasonYearFactor <- as.factor(modelData$seasonYear)
modelData$StarterFactor <- as.factor(modelData$Starter)
modelData$cumFgAttemptedPerGameAndMinute <- modelData$cumFgAttemptedPerGame / modelData$averageMinutes
modelData$cumFgAttemptedPerGameAndMinuteGivenPmin <- modelData$cumFgAttemptedPerGameAndMinute * modelData$pmin

modelData$cumFgAttemptedPerGame <- ifelse(is.na(modelData$cumFgAttemptedPerGame), modelData$lastYearFgAttemptedPerGame, modelData$cumFgAttemptedPerGame)
modelData <- subset(modelData, !is.na(modelData$pmin))# & modelData$pmin > 0)

#handle Na values for cumFgAttemptedPerGame

trainIds <- unique(modelData$GameId[modelData$seasonYear<=2022])

h2o.init()

trainDataGBM <- subset(modelData, modelData$GameId %in% trainIds)
testDataGBM <- subset(modelData, !modelData$GameId %in% trainIds)

trainDataH2O <- as.h2o(trainDataGBM)
testDataH2O <- as.h2o(testDataGBM)

modelDataH2o <- as.h2o(modelData)

modelGBM = h2o.gbm(x = c("pmin",
                         "ownExpPoints",
                         "cumFgAttemptedPerGame",
                         "cumFgAttemptedPerGameAndMinute",
                         "oppExpPoints",
                         "lastYearFgAttemptedPerGame",
                         "cumFgAttemptedPerGameAndMinuteGivenPmin"
                         #,
                         #"fgExpPerMin"

                         
                    ), y = "Fg.Attempted",
                    
                    training_frame = trainDataH2O,
                    model_id = "FgAttemptedModelRotoWire", 
                    seed = 12, 
                    nfolds = 10, 
                    keep_cross_validation_predictions = TRUE, 
                    fold_assignment = "Modulo", 
                    distribution = "poisson",
                    max_depth = 10,
                    min_rows = 100,
                    ntrees = 500)

h2o.download_mojo(modelGBM, path = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\java model\\nba-player-model-given-avg\\src\\main\\resources")

h2o.performance(modelGBM, xval = T) #Mean residual deviance 0.7798013
h2o.performance(modelGBM, xval = F) #Mean residual deviance 0.7790562

h2o.performance(modelGBM, newdata = trainDataH2O) #Mean residual deviance 0.7798013
h2o.performance(modelGBM, newdata = testDataH2O) #Mean residual deviance 0.7790562

testDataGBM$predictionsGBM <- as.vector(h2o.predict(modelGBM, testDataH2O))
testDataGBM$residGBM <- testDataGBM$Fg.Attempted - testDataGBM$predictionsGBM

mean(testDataGBM$residGBM)

binnedplot(testDataGBM$predictionsGBM, testDataGBM$residGBM)
binnedplot(testDataGBM$predictionsGBM[testDataGBM$ownExpPoints > 112], testDataGBM$residGBM[testDataGBM$ownExpPoints > 112])
binnedplot(testDataGBM$predictionsGBM[testDataGBM$ownExpPoints < 112], testDataGBM$residGBM[testDataGBM$ownExpPoints < 112])
binnedplot(testDataGBM$predictionsGBM[testDataGBM$predictionsGBM>22], testDataGBM$residGBM[testDataGBM$predictionsGBM>22])

binnedplot(testDataGBM$pmin, testDataGBM$residGBM)
binnedplot(testDataGBM$predictionsGBM[!is.na(testDataGBM$pmin)], testDataGBM$residGBM[!is.na(testDataGBM$pmin)])

#Train data

trainDataGBM$predictionsGBM <- as.vector(h2o.predict(modelGBM, trainDataH2O))
trainDataGBM$residGBM <- trainDataGBM$Fg.Attempted - trainDataGBM$predictionsGBM

mean(trainDataGBM$residGBM)

binnedplot(trainDataGBM$predictionsGBM[trainDataGBM$seasonYear == 2019], trainDataGBM$residGBM[trainDataGBM$seasonYear == 2019])
binnedplot(trainDataGBM$predictionsGBM[trainDataGBM$seasonYear == 2020], trainDataGBM$residGBM[trainDataGBM$seasonYear == 2020])
binnedplot(trainDataGBM$predictionsGBM[trainDataGBM$seasonYear == 2021], trainDataGBM$residGBM[trainDataGBM$seasonYear == 2021])
binnedplot(trainDataGBM$predictionsGBM[trainDataGBM$seasonYear == 2022], trainDataGBM$residGBM[trainDataGBM$seasonYear == 2022])
binnedplot(trainDataGBM$predictionsGBM[trainDataGBM$seasonYear <= 2022], trainDataGBM$residGBM[trainDataGBM$seasonYear <= 2022])

#

aggMin <- aggregate(Min ~ GameId + Team, testDataGBM, sum)
#What to do with a key player is missing

agg <- aggregate(predictionsGBM ~ GameId + Team, testDataGBM, sum)
agg <- merge(agg, aggregate(Fg.Attempted ~ GameId + Team, testDataGBM, sum))
agg$diff <- agg$Fg.Attempted - agg$predictionsGBM



## Java Tests

set.seed(100)
javaData <- testDataGBM[sample(1:nrow(testDataGBM), 100),]
predictions <- as.vector(h2o.predict(modelGBM, as.h2o(javaData)))

Covariates <- with(javaData, paste(pmin, 
                                   ownExpPoints, 
                                   cumFgAttemptedPerGame, 
                                   cumFgAttemptedPerGameAndMinute, 
                                   oppExpPoints,
                                   lastYearFgAttemptedPerGame,
                                   cumFgAttemptedPerGameAndMinuteGivenPmin
                                   
                                   , sep = ","))


test <- paste("Assert.assertEquals(", predictions, "d, fgAttemptedModel.getFgAttemptedRInputs(", Covariates, ") , DELTA);", sep = "")

cat(test, sep="\n")

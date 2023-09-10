library(h2o)
library(sqldf)
library(arm)

source("C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\Model Utils.R")

allPlayers <- readRDS(file = "C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\allPlayersOdds.rds")

h2o.init()

#modelData <- subset(allPlayers, allPlayers$gamesPlayedSeason > 10 & allPlayers$Min > 0 & !is.na(allPlayers$ownExpPoints))
modelData <- allPlayers
modelData$ownExpPointsDiff = modelData$ownExpPoints - modelData$oppExpPoints
modelData$ownExpPointsDiff2 = modelData$ownExpPointsDiff ^ 2

modelData$gamesPlayedSeason2 <- modelData$gamesPlayedSeason ^ 2
modelData$gamesPlayedSeason3 <- pmax(0, modelData$gamesPlayedSeason - 30)
modelData$seasonYearFactor <- as.factor(modelData$seasonYear)
modelData$StarterFactor <- as.factor(modelData$Starter)

playersInGame <- aggregate(Min ~ GameId + Team, modelData, length)
colnames(playersInGame)[3] <- "numbPlayers"
modelData <- merge(modelData, playersInGame, by = c("GameId", "Team"))

modelData <- subset(modelData, !is.na(modelData$pmin) & modelData$pmin > 0)

trainIds <- getTrainIds(modelData)

modelData$pminOver30 <- pmax(0, modelData$pmin - 30)
trainDataGBM <- subset(modelData, modelData$GameId %in% trainIds)
testDataGBM <- subset(modelData, !modelData$GameId %in% trainIds)

trainDataH2O <- as.h2o(trainDataGBM)
testDataH2O <- as.h2o(testDataGBM)

modelDataH2o <- as.h2o(modelData)

modelGBM = h2o.gbm(x = c("Min",
                         "averageMinutes",
                         "cumPercAttemptedPerMinute",
                         "ownExpPoints",
                         "oppExpPoints",
                         "cumFgAttemptedPerGame",
                         "lastGameAttemptedPerMin",
                      #   "teamGameNumber",
                         "lastYearFgAttemptedPerGame"
                     # "pminOver30",
                    #  "gamesPlayedSeason"
                         
                         ), y = "Fg.Attempted",
                   
                   training_frame = modelDataH2o,
                   model_id = "PercAttempted", 
                   seed = 12, 
                   nfolds = 10, 
                   keep_cross_validation_predictions = TRUE, 
                   fold_assignment = "Modulo", 
                   distribution = "poisson",
                   max_depth = 5,
                   min_rows = 500,
                   ntrees = 500)


h2o.performance(modelGBM, xval = T) #Mean residual deviance 0.7798013
h2o.performance(modelGBM, xval = F) #Mean residual deviance 0.7790562

h2o.performance(modelGBM, newdata = trainDataH2O) #Mean residual deviance 0.7798013
h2o.performance(modelGBM, newdata = testDataH2O) #Mean residual deviance 0.7790562

testDataGBM$predictionsGBM <- as.vector(h2o.predict(modelGBM, testDataH2O))
testDataGBM$residGBM <- testDataGBM$Fg.Attempted - testDataGBM$predictionsGBM

mean(testDataGBM$residGBM)

binnedplot(testDataGBM$predictionsGBM, testDataGBM$residGBM)
binnedplot(testDataGBM$Min, testDataGBM$residGBM)
binnedplot(testDataGBM$pmin[!is.na(testDataGBM$pmin)], testDataGBM$residGBM[!is.na(testDataGBM$pmin)])
binnedplot(testDataGBM$predictionsGBM[!is.na(testDataGBM$pmin)], testDataGBM$residGBM[!is.na(testDataGBM$pmin)])


binnedplot(testDataGBM$averageMinutes, testDataGBM$residGBM)
binnedplot(testDataGBM$lastYearFgAttemptedPerGame[!is.na(testDataGBM$lastYearFgAttemptedPerGame)], testDataGBM$residGBM[!is.na(testDataGBM$lastYearFgAttemptedPerGame)])

binnedplot(testDataGBM$cumFgAttemptedPerGame[!is.na(testDataGBM$cumFgAttemptedPerGame)], testDataGBM$residGBM[!is.na(testDataGBM$cumFgAttemptedPerGame)])
binnedplot(testDataGBM$averageMinutes, testDataGBM$residGBM)
binnedplot(testDataGBM$averageMinutes[testDataGBM$averageMinutes > 30], testDataGBM$residGBM[testDataGBM$averageMinutes > 30])
binnedplot(testDataGBM$Min - testDataGBM$averageMinutes, testDataGBM$residGBM)
binnedplot(testDataGBM$ownExpPoints, testDataGBM$residGBM)
binnedplot(testDataGBM$ownExpPoints[testDataGBM$Min > 30], testDataGBM$residGBM[testDataGBM$Min > 30])
binnedplot(testDataGBM$oppExpPoints[testDataGBM$Min > 30], testDataGBM$residGBM[testDataGBM$Min > 30])
binnedplot(testDataGBM$ownExpPointsDiff[testDataGBM$Min > 30], testDataGBM$residGBM[testDataGBM$Min > 30])
binnedplot(testDataGBM$teamGameNumber, testDataGBM$residGBM)
binnedplot(testDataGBM$teamGameNumber[testDataGBM$seasonYear == 2018], testDataGBM$residGBM[testDataGBM$seasonYear == 2018])
binnedplot(testDataGBM$teamGameNumber[testDataGBM$seasonYear == 2019], testDataGBM$residGBM[testDataGBM$seasonYear == 2019])
binnedplot(testDataGBM$teamGameNumber[testDataGBM$seasonYear == 2020], testDataGBM$residGBM[testDataGBM$seasonYear == 2020])
binnedplot(testDataGBM$teamGameNumber[testDataGBM$seasonYear == 2021], testDataGBM$residGBM[testDataGBM$seasonYear == 2021])

binnedplot(testDataGBM$gamesPlayedSeason, testDataGBM$residGBM)
binnedplot(testDataGBM$gamesPlayedSeason[testDataGBM$averageMinutes > 30], testDataGBM$residGBM[testDataGBM$averageMinutes > 30])
binnedplot(testDataGBM$gamesPlayedSeason[testDataGBM$averageMinutes < 30], testDataGBM$residGBM[testDataGBM$averageMinutes < 30])
binnedplot(testDataGBM$Starter, testDataGBM$residGBM)
binnedplot(testDataGBM$seasonYear, testDataGBM$residGBM)


binnedplot(testDataGBM$oppExpPoints, testDataGBM$residGBM)
binnedplot(testDataGBM$oppExpPoints[testDataGBM$Starter == 1], testDataGBM$residGBM[testDataGBM$Starter == 1])
binnedplot(testDataGBM$oppExpPoints[testDataGBM$Starter == 0], testDataGBM$residGBM[testDataGBM$Starter == 0])

binnedplot(testDataGBM$oppExpPoints - testDataGBM$ownExpPoints, testDataGBM$residGBM)

binnedplot(testDataGBM$homeExpPoints + testDataGBM$awayExpPoints -  testDataGBM$ownExpPoints, testDataGBM$residGBM)
binnedplot(testDataGBM$lastGameAttempted, testDataGBM$residGBM)
binnedplot(testDataGBM$lastGameAttemptedPerMin[!is.na(testDataGBM$lastGameAttemptedPerMin)], testDataGBM$residGBM[!is.na(testDataGBM$lastGameAttemptedPerMin)])
binnedplot(testDataGBM$lastGameAttemptedPerMin[!is.na(testDataGBM$lastGameAttemptedPerMin) & testDataGBM$lastGameMin < 10], testDataGBM$residGBM[!is.na(testDataGBM$lastGameAttemptedPerMin)& testDataGBM$lastGameMin < 10])
binnedplot(testDataGBM$gamesPlayedSeason[!is.na(testDataGBM$gamesPlayedSeason)], testDataGBM$residGBM[!is.na(testDataGBM$gamesPlayedSeason)])

binnedplot(testDataGBM$lastGameAttempted[testDataGBM$averageMinutes > 32], testDataGBM$residGBM[testDataGBM$averageMinutes > 32])
binnedplot(testDataGBM$lastGameAttempted[testDataGBM$averageMinutes < 15], testDataGBM$residGBM[testDataGBM$averageMinutes < 15])
binnedplot(testDataGBM$lastGameAttempted[testDataGBM$averageMinutes < 5], testDataGBM$residGBM[testDataGBM$averageMinutes < 5])
binnedplot(testDataGBM$cumPercAttemptedPerMinute[testDataGBM$lastGameAttempted == 0], testDataGBM$residGBM[testDataGBM$lastGameAttempted == 0])


binnedplot(testDataGBM$ownExpPoints[testDataGBM$ownExpPoints > 120], testDataGBM$residGBM[testDataGBM$ownExpPoints > 120])
binnedplot(testDataGBM$scoreDiff, testDataGBM$residGBM)
binnedplot(testDataGBM$scoreDiff[testDataGBM$averageMinutes > 30], testDataGBM$residGBM[testDataGBM$averageMinutes > 30])
binnedplot(testDataGBM$scoreDiff[testDataGBM$averageMinutes > 35 & abs(testDataGBM$scoreDiff) > 20], testDataGBM$residGBM[testDataGBM$averageMinutes > 35 & abs(testDataGBM$scoreDiff) > 20])


testDataGBM$lineOver1 <- round(testDataGBM$predictionsGBM) - 4
testDataGBM$lineOver1Win <- 1 * (testDataGBM$Fg.Attempted > testDataGBM$lineOver1)

testDataGBM$probOver1 <- 1 - ppois(q = testDataGBM$lineOver1, lambda = testDataGBM$predictionsGBM)
testDataGBM$residOver1 <- testDataGBM$probOver1 - testDataGBM$lineOver1Win

binnedplot(testDataGBM$predictionsGBM, testDataGBM$residOver1)
mean(testDataGBM$residOver1)
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

Covariates <- with(javaData, paste(ownExpPoints, Min, averageMinutes, cumPercAttemptedPerMinute, lastGameAttemptedPerMin, oppExpPoints, teamGameNumber, cumFgAttemptedPerGame
                                   
                                   , sep = ","))


test <- paste("Assert.assertEquals(", predictions, "d, fgAttemptedModel.getFgAttempted(", Covariates, ") , DELTA);", sep = "")

cat(test, sep="\n")
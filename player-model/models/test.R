
trainDataGBM$predictionsGBM <- as.vector(h2o.predict(modelGBM, trainDataH2O))
trainDataGBM$residGBM <- trainDataGBM$Fg.Attempted - trainDataGBM$predictionsGBM

mean(trainDataGBM$residGBM)

binnedplot(trainDataGBM$Min, trainDataGBM$residGBM)
binnedplot(trainDataGBM$averageMinutes, trainDataGBM$residGBM)
binnedplot(trainDataGBM$cumFgAttemptedPerGame[!is.na(trainDataGBM$cumFgAttemptedPerGame)], trainDataGBM$residGBM[!is.na(trainDataGBM$cumFgAttemptedPerGame)])
binnedplot(trainDataGBM$averageMinutes, trainDataGBM$residGBM)
binnedplot(trainDataGBM$averageMinutes[trainDataGBM$averageMinutes > 30], trainDataGBM$residGBM[trainDataGBM$averageMinutes > 30])
binnedplot(trainDataGBM$Min - trainDataGBM$averageMinutes, trainDataGBM$residGBM)
binnedplot(trainDataGBM$ownExpPoints, trainDataGBM$residGBM)
binnedplot(trainDataGBM$ownExpPoints[trainDataGBM$Min > 30], trainDataGBM$residGBM[trainDataGBM$Min > 30])
binnedplot(trainDataGBM$oppExpPoints[trainDataGBM$Min > 30], trainDataGBM$residGBM[trainDataGBM$Min > 30])
binnedplot(trainDataGBM$ownExpPointsDiff[trainDataGBM$Min > 30], trainDataGBM$residGBM[trainDataGBM$Min > 30])
binnedplot(trainDataGBM$teamGameNumber, trainDataGBM$residGBM)
binnedplot(trainDataGBM$gamesPlayedSeason, trainDataGBM$residGBM)
binnedplot(trainDataGBM$gamesPlayedSeason[trainDataGBM$averageMinutes > 30], trainDataGBM$residGBM[trainDataGBM$averageMinutes > 30])
binnedplot(trainDataGBM$gamesPlayedSeason[trainDataGBM$averageMinutes < 30], trainDataGBM$residGBM[trainDataGBM$averageMinutes < 30])

###

agg <- aggregate(predictionsGBM ~ GameId + Team, testDataGBM, sum)
agg <- merge(agg, aggregate(Fg.Attempted ~ GameId + Team, testDataGBM, sum))
agg$diff <- agg$Fg.Attempted - agg$predictionsGBM

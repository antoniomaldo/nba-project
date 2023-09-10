modelData <- readRDS(file = "C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\allPlayersOdds.rds")

modelData$predictionsGBM <- as.vector(h2o.predict(modelGBM, modelDataH2o))
modelData$residGBM <- modelData$Fg.Attempted - modelData$predictionsGBM

normalizeFgForTeam <- function(teamGame, par){
  fgAttemptedCoef = par[1]
  fgAttemtedLessTwo = par[2]
  toAddCoef = par[3]
  toAdd = sum(teamGame$Fg.Attempted) - sum(teamGame$predictionsGBM)
  
  teamGame$coef = exp(fgAttemptedCoef * pmax(10, teamGame$predictionsGBM) + 
                        fgAttemtedLessTwo * pmin(2, teamGame$predictionsGBM) +
                        toAddCoef * pmax(toAdd - 5, 0) * pmax(0, 5 - teamGame$predictionsGBM)
                        )
  teamGame$pred = teamGame$coef * teamGame$predictionsGBM
  
  allPred = sum(teamGame$pred)
  
  teamGame$normPred = teamGame$pred * (sum(teamGame$Fg.Attempted)) / allPred
  teamGame$toAdd = toAdd
  return(teamGame)
}

normalizePreds <- function(allData, par){
  uniquePair  = unique(allData[c("GameId", "Team")])
  df = data.frame()
  for(j in 1:nrow(uniquePair)){
    teamGame = subset(allData[c("GameId", "PlayerId", "Min", "Team", "predictionsGBM", "Fg.Attempted")], allData$GameId == uniquePair$GameId[j]  & allData$Team == uniquePair$Team[j])
    normTeam = normalizeFgForTeam(teamGame, par)
    df = rbind(df, normTeam)
  }
  return(df)
}

optimizeI <- function(allData, par){
  norm = normalizePreds(allData, par)
  norm$likelihood = dpois(x = norm$Fg.Attempted, lambda = norm$normPred)
  return(-1* sum(log(norm$likelihood)))
}

test = optimizeI(subset(modelData, modelData$seasonYear >= 2020), 1)

a = optim(par = c(0, 0, 0), fn = optimizeI, allData = subset(modelData, modelData$seasonYear >= 2020))
#0.004574184 0.048600605 0.002416979

par <- c(0.004574184, 0.048600605, 0.002416979)
norm = normalizePreds(modelData, par)

norm$residNorm <- norm$Fg.Attempted - norm$normPred
norm$resid <- norm$Fg.Attempted - norm$predictionsGBM

binnedplot(norm$normPred, norm$residNorm)
binnedplot(norm$predictionsGBM, norm$residNorm)
binnedplot(norm$predictionsGBM, norm$resid)

binnedplot(norm$toAdd, norm$residNorm)
binnedplot(norm$toAdd, norm$resid)

binnedplot(norm$normPred[norm$toAdd > 10], norm$residNorm[norm$toAdd > 10])
binnedplot(norm$normPred[norm$toAdd < -10], norm$residNorm[norm$toAdd < -10])

binnedplot(norm$normPred[norm$toAdd > 10], norm$resid[norm$toAdd > 10])
binnedplot(norm$normPred[norm$toAdd < -10], norm$resid[norm$toAdd < -10])

binnedplot(norm$normPred[abs(norm$toAdd) < 10], norm$residNorm[abs(norm$toAdd) < 10])
binnedplot(norm$normPred[abs(norm$toAdd) < 10], norm$resid[abs(norm$toAdd) < 10])

binnedplot(norm$predictionsGBM[norm$toAdd > 7], norm$resid[norm$toAdd > 7])
binnedplot(norm$predictionsGBM[norm$toAdd > 7], norm$residNorm[norm$toAdd > 7])
binnedplot(norm$normPred[norm$toAdd > 7], norm$residNorm[norm$toAdd > 7])

View(subset(norm, norm$GameId == norm$GameId[1] & norm$Team == norm$Team[1]))


modelData <- merge(modelData, norm[c("GameId", "PlayerId", "normPred")], by = c("GameId", "PlayerId"))
saveRDS(modelData, file = "C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\modelData.rds")

#Testing

#Over 3 fg
i=0
norm$over3FgPred <- dpois(i, norm$predictionsGBM)
norm$over3FG <- 1 * (norm$Fg.Attempted == i)
norm$over3FGResid <- norm$over3FG - norm$over3FgPred

binnedplot(norm$predictionsGBM, norm$over3FGResid)
binnedplot(norm$Min, norm$over3FGResid)

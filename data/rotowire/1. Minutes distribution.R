source("C:\\Users\\aostios\\Documents\\rotowire csvs\\Join to espn data.R")

minPreds <- getMinutePredictions()
colnames(minPreds) <- c("GameId", "PlayerId", "rotoMin")

allPlayers <- getPlayersForYear(2021)
allPlayers <- rbind(allPlayers, getPlayersForYear(2022))
allPlayers <- rbind(allPlayers, getPlayersForYear(2023))


allPlayers <- merge(allPlayers, minPreds, by = c("GameId", "PlayerId"), all.x = T)

allPlayers$naPred <- 1 * is.na(allPlayers$rotoMin)

naPreds <- aggregate(naPred ~ GameId + Team, allPlayers, sum)
mean(naPreds$naPred<=4)


noNa <- subset(allPlayers, !is.na(allPlayers$rotoMin))

#ExpectedValue
library(splines)

model <- glm(Min ~ bs(rotoMin, k=c(35), B=c(1, 44)), data = noNa, family=poisson)
summary(model)

noNa$pred <- predict(model, noNa, type = "response")
noNa$resid <- noNa$Min - noNa$pred

mean(noNa$resid[noNa$Name == "L. Doncic"])
mean(noNa$resid[noNa$Name == "K. Irving"])

binnedplot(noNa$pred, noNa$resid)

mean(noNa$Min[abs(noNa$pred - 38)<=2])
var(noNa$Min[abs(noNa$pred - 38)<=2])

#

aggPred <- aggregate(Min ~ rotoMin, noNa, mean)
colnames(aggPred)[2] <- "meanMin"
aggPred <- merge(aggPred, aggregate(Min ~ rotoMin, noNa, sd))
colnames(aggPred)[3] <- "sdMin"
aggPred <- merge(aggPred, aggregate(Min ~ rotoMin, noNa, length))
colnames(aggPred)[4] <- "numbPlayers"


generateMinutesDist <- function(wantedMean, wantedSd){
  dist = rnorm(100000,mean = wantedMean, sd = wantedSd)
  while(sum(dist < 0) > 0 | sum(dist > 46) > 0){
    dist[dist < 0] = rnorm(sum(dist < 0),mean = wantedMean, sd = wantedSd)
    dist[dist > 46] = rnorm(sum(dist > 46),mean = wantedMean, sd = wantedSd)
    
  }
  #dist <- round(dist)
  return(dist)
}



optimizerMinDist <- function(par, wantedMean, wantedSd){
#  print(par)
  dist = generateMinutesDist(exp(par[1]), exp(par[2]))
  return((mean(dist) - wantedMean) ^ 2 + (sd(dist) - wantedSd) ^ 2)
}

aggPred$targetMean <- NA
aggPred$targetSd <- NA

for(i in 1:nrow(aggPred)){
  print(i)
  rotoMin = aggPred$rotoMin[i]
  wantedMean=aggPred$meanMin[aggPred$rotoMin == rotoMin]
  wantedSd=aggPred$sdMin[aggPred$rotoMin == rotoMin]
  optimizedPar <- optim(par=c(log(wantedMean), log(wantedSd)), optimizerMinDist, wantedMean=wantedMean, wantedSd=wantedSd)
  
  aggPred$targetMean[i] <- exp(optimizedPar$par[1])
  aggPred$targetSd[i] <- exp(optimizedPar$par[2])
}


cat(paste0("new MinuteDistribution(",aggPred$rotoMin, ",", aggPred$targetMean, ",", aggPred$targetSd,");"), sep = "\n")


#Predict minutes for team

fullGames <- subset(naPreds, naPreds$naPred == 0)

gameId = 401468976

gameTest <- subset(allPlayers, allPlayers$GameId == gameId)

gameTest <- merge(gameTest, aggPred[c("rotoMin", "meanMin", "sdMin")], by = "rotoMin")

teamTest = subset(gameTest[c("Min", "Name", "meanMin", "sdMin")], gameTest$Team == "LAL")
teamTotalMin = sum(teamTest$Min)
for(i in 1:100){
  teamTest$generated <- NA
  for(p in 1:nrow(teamTest)){
    playerMin = generateMinutesDist(teamTest$meanMin[p], teamTest$sdMin[p])[1]
    teamTest$generated[p] = playerMin
  }
  totalGenerated = sum(teamTest$generated)
  teamTest$generated <- teamTest$generated * teamTotalMin / totalGenerated
  colnames(teamTest)[i + 4] <- paste0("generated_", i)
}

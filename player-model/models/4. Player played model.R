library(h2o)
library(sqldf)
library(arm)

source("C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\Model Utils.R")

allPlayers <- readRDS(file = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\allPlayersWithOdds.rds")
minPreds <- readRDS(file = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\minutePredictions.rds")


minPreds <- merge(minPreds, allPlayers, by = c("GameId", "PlayerId"), all.x = T)
minPreds$id <- paste0(minPreds$GameId, "-", minPreds$Team)

sumGrindersPreds <- aggregate(grindersMin ~ id, minPreds, sum)

gamesToUse <- subset(sumGrindersPreds$id, abs(sumGrindersPreds$grindersMin - 240) <= 3)

modelData <- subset(minPreds, minPreds$id %in% gamesToUse)
modelData <- subset(modelData, !is.na(modelData$grindersMin))


#


testDataAgg <- aggregate(played ~ grindersMin, subset(modelData, modelData$seasonYear < 2022), mean)
testDataAgg <- merge(testDataAgg, aggregate(GameId ~ grindersMin, subset(modelData, modelData$seasonYear < 2022), length))
testDataAgg <- subset(testDataAgg, testDataAgg$GameId > 50)

trainData <- aggregate(played ~ grindersMin, subset(modelData, modelData$seasonYear >= 2022), mean)
trainData <- merge(trainData, aggregate(GameId ~ grindersMin, subset(modelData, modelData$seasonYear >= 2022), length))
trainData <- subset(trainData, trainData$GameId > 20)

testData <- subset(modelData, modelData$seasonYear < 2022)
model <- glm(played ~ grindersMin + I(grindersMin ^ 2)+ I(grindersMin ^ 3), testData, family = binomial)
summary(model)
testDataAgg$pred <- predict(model, testDataAgg, type = "response")


trainData$pred <- predict(model, trainData, type = "response")


# Find a way to simulate what players will play (maybe simulate how many wont play or similar)

playersWithPred <- aggregate(grindersMin ~ GameId + Team, modelData, FUN = function(x){sum(!is.na(x))})
playersThatPlayed <- merge(playersWithPred, aggregate(Min.x ~ GameId + Team, modelData, FUN = function(x){sum(x > 0)}))
playersThatPlayed$notPlayingPlayers <- playersThatPlayed$grindersMin - playersThatPlayed$Min.x

agg <- aggregate(notPlayingPlayers ~ grindersMin, playersThatPlayed, mean)


#Game test

team <- subset(modelData, modelData$GameId ==401071536 & modelData$Team == "LAC")

team <- team[c("Name", "grindersMin")]
team$probPlay <- predict(model, team, type = "response")

#simulate players
#Min to play -> 8

allData <- data.frame()
for(gId in unique(modelData$GameId)){
  print(gId)
  game <- subset(modelData, modelData$GameId == gId)
  for(t in unique(game$Team)){
    team <- subset(game, game$Team == t)[c("Name", "grindersMin", "played")]
    team$probPlay <- predict(model, team, type = "response")
    team$cumPlayed <- 0
    playersPlayed <- c()
    for(i in 1:10000){
      sim = team
      sim$simPlayed <- 0
     # secondLess <- sort(sim$grindersMin)[2]
     # secondLess <- max(20, secondLess)
      while(sum(sim$simPlayed) < 8){
        sim$simPlayed <- sim$probPlay > runif(nrow(sim))  
        sim$simPlayed[sim$grindersMin > 15] <- 1
      }
      
      team$cumPlayed = team$cumPlayed + sim$simPlayed 
      playersPlayed <- c(playersPlayed, sum(sim$simPlayed))
    }
    
    allData <- rbind(allData, data.frame(GameId = gId,
                                         Team = t,
                                         numbPlayers = nrow(sim), 
                                         playingPlayers = sum(sim$played),
                                         minPred = min(sim$grindersMin),
                                         eightProb = mean(playersPlayed == 8), 
                                         nineProb = mean(playersPlayed == 9), 
                                         tenProb = mean(playersPlayed == 10), 
                                         elevenProb = mean(playersPlayed == 11), 
                                         twelbeProb = mean(playersPlayed == 12) ))
  }
}

mean(allData$playingPlayers==8)
mean(allData$eightProb)

mean(allData$playingPlayers==9)
mean(allData$nineProb)

mean(allData$playingPlayers==10)
mean(allData$tenProb)

mean(allData$playingPlayers==11)
mean(allData$elevenProb)

mean(allData$playingPlayers==12)
mean(allData$twelbeProb)

allData$allPlayed <- 1 * (allData$numbPlayers == allData$playingPlayers)

allData$allPlayedPred <- ifelse(allData$playingPlayers == 8, allData$eightProb, 
                                ifelse(allData$playingPlayers == 9, allData$nineProb, 
                                       ifelse(allData$playingPlayers == 10, allData$tenProb, 
                                              ifelse(allData$playingPlayers == 11, allData$elevenProb, 
                                                     ifelse(allData$playingPlayers == 12, allData$twelbeProb, 0)))))

mean(allData$allPlayed)
mean(allData$allPlayedPred)

allData$allPlayedResid <- allData$allPlayed - allData$allPlayedPred

binnedplot(allData$minPred, allData$allPlayedResid)

mean(allData$allPlayed)
mean(allData$allPlayedPred)

modelData$playedProb <-  predict(model, modelData, type = "response")
View(unique(modelData[c("grindersMin", "playedProb")]))

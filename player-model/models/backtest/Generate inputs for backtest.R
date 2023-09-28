library(plyr)

allPlayers <- readRDS(file = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\allPlayersWithOdds.rds")
minPreds <- readRDS(file = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\minutePredictions.rds")

minPreds <- merge(minPreds, allPlayers, by = c("GameId", "PlayerId"), all.x = T)
minPreds$id <- paste0(minPreds$GameId, "-", minPreds$Team)

sumGrindersPreds <- aggregate(grindersMin ~ id, minPreds, sum)

gamesToUse <- subset(sumGrindersPreds$id, abs(sumGrindersPreds$grindersMin - 240) <= 3)

modelData <- subset(minPreds, minPreds$id %in% gamesToUse)
modelData <- subset(modelData, !is.na(modelData$grindersMin))

modelData <- subset(modelData, modelData$seasonYear >= 2022)
modelData$pmin <- modelData$grindersMin
for(decentId in unique(modelData$GameId)){
  print(decentId)
  game = subset(modelData, modelData$GameId == decentId)
  print(nrow(game))
  write.csv(game, paste0("C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\backtest\\input\\", decentId, ".csv"))
}








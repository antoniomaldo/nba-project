library(plyr)

allPlayers <- readRDS(file = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\allPlayersWithOdds.rds")
minPreds <- readRDS(file = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\minutePredictions.rds")

minPreds <- merge(minPreds, allPlayers, by = c("GameId", "PlayerId"), all.x = T)
minPreds$id <- paste0(minPreds$GameId, "-", minPreds$Team)

sumGrindersPreds <- aggregate(rotoMin ~ id, minPreds, sum)

gamesToUse <- subset(sumGrindersPreds$id, abs(sumGrindersPreds$rotoMin - 240) <= 3)

modelData <- subset(minPreds, minPreds$id %in% gamesToUse)
modelData <- subset(modelData, !is.na(modelData$rotoMin))

modelData <- subset(modelData, modelData$seasonYear >= 2023)
modelData$pmin <- modelData$rotoMin
modelData$pmin[modelData$pmin == 0] <- 1
for(decentId in unique(modelData$GameId)){
  print(decentId)
  game = subset(modelData, modelData$GameId == decentId)
  print(nrow(game))
  write.csv(game, paste0("C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\backtest\\input_rotowire\\", decentId, ".csv"))
}



401468016




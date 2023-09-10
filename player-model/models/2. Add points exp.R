allPlayers <- readRDS(file = "C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\allPlayers.rds")

mappedData <- do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\2018", full.names = T), read.csv))
mappedData <- rbind(mappedData, do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\2019", full.names = T), read.csv)))
mappedData <- rbind(mappedData, do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\2020", full.names = T), read.csv)))
twentyOne <-  do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\2021", full.names = T), read.csv))
twentyOne <-  rbind(twentyOne, do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\2022", full.names = T), read.csv)))

pMinsDf <- rbind(mappedData[c("GameId", "PlayerId", "pmin")], twentyOne[c("GameId", "PlayerId", "pmin")])

mappedData <- mappedData[c("GameId", "HomeTeam", "AwayTeam","matchSpread", "totalPoints")]

twentyOne$totalPoints <- twentyOne$oppTotal + twentyOne$total
twentyOne$matchSpread <- ifelse(twentyOne$ishomeplayer, twentyOne$oppTotal - twentyOne$total, twentyOne$total - twentyOne$oppTotal)

oddsData <- rbind(unique(mappedData), unique(twentyOne[c("GameId", "HomeTeam", "AwayTeam", "matchSpread", "totalPoints")]))
oddsData <- subset(oddsData, !is.na(oddsData$matchSpread))

allPlayers$id <- 1:nrow(allPlayers)
allPlayers <- merge(allPlayers, oddsData, by = "GameId", all.x = T)

idsToRemove <- which(table(allPlayers$id) > 1)
gameIdsToRemove <- unique(subset(allPlayers$GameId, allPlayers$id %in% idsToRemove))

allPlayers <- subset(allPlayers, !allPlayers$GameId %in% gameIdsToRemove)
allPlayers <- subset(allPlayers, !is.na(allPlayers$matchSpread))

allPlayers$homeExp = (allPlayers$totalPoints - allPlayers$matchSpread) / 2
allPlayers$awayExp = allPlayers$totalPoints - allPlayers$homeExp

allPlayers$ownExpPoints = ifelse(allPlayers$HomeTeam == allPlayers$Team, allPlayers$homeExp, allPlayers$awayExp)
allPlayers$oppExpPoints = ifelse(allPlayers$AwayTeam == allPlayers$Team, allPlayers$homeExp, allPlayers$awayExp)

pMinsDf <- unique(pMinsDf)
pMinsDf <- aggregate(pmin ~ GameId + PlayerId, pMinsDf, mean)

allPlayers <- merge(allPlayers, pMinsDf, by = c("GameId", "PlayerId"), all.x = T)

## Testing ##

# odds <- data.frame()
# 
# for(gameid in unique(allPlayers$GameId)){
#   game = subset(allPlayers, allPlayers$GameId == gameid)
#   home = subset(game, game$HomeTeam == game$Team)
#   away = subset(game, game$AwayTeam == game$Team)
#   homeScore = sum(home$Points)
#   awayScore = sum(away$Points)
#   odds <- rbind(odds, data.frame(gameid = gameid, homeScore, awayScore, game$matchSpread[1], game$totalPoints[1]))
#}

saveRDS(allPlayers, file = "C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\allPlayersOdds.rds")
write.csv(allPlayers, file = "C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\allPlayersOddsCsv.csv")


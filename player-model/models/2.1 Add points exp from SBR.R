library(sqldf)
source("C:\\Users\\Antonio\\Documents\\nba-project\\data\\utils\\Utils.R")
source("C:\\Users\\Antonio\\Documents\\nba-project\\data\\mappings\\mappings-service.R")

allData <- readRDS("C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\allPlayers.rds")

games <- getMatchesForYear(2018)
games <- rbind(games, getMatchesForYear(2019))
games <- rbind(games, getMatchesForYear(2020))
games <- rbind(games, getMatchesForYear(2021))
games <- rbind(games, getMatchesForYear(2022))
games <- rbind(games, getMatchesForYear(2023))

odds <- mapSbrDataToEspn(games)

allData <- merge(allData, odds, by = "GameId", all.x = T)
allData <- subset(allData, !is.na(allData$matchSpread) & !is.na(allData$totalPoints))

allData$homeExp <- (allData$totalPoints - allData$matchSpread) / 2
allData$awayExp <- (allData$totalPoints + allData$matchSpread) / 2

allData$ownExpPoints <- ifelse(allData$Team == allData$HomeTeam, allData$homeExp, allData$awayExp)
allData$oppExpPoints <- ifelse(allData$Team != allData$HomeTeam, allData$homeExp, allData$awayExp)


saveRDS(allData, "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\allPlayers.rds")

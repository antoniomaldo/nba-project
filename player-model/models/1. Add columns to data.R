library(sqldf)
library(arm)
library(stringr)
source("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\Utils.R")

boxscores <-  getPlayersForYear(2018)
boxscores <- rbind(boxscores, getPlayersForYear(2019))
boxscores <- rbind(boxscores, getPlayersForYear(2020))
boxscores <- rbind(boxscores, getPlayersForYear(2021))
boxscores <- rbind(boxscores, getPlayersForYear(2022))

games <- getMatchesForYear(2018)
games <- rbind(games, getMatchesForYear(2019))
games <- rbind(games, getMatchesForYear(2020))
games <- rbind(games, getMatchesForYear(2021))
games <- rbind(games, getMatchesForYear(2022))

allPlayers = boxscores #remove this
allPlayers <- allPlayers[order(allPlayers$PlayerId, allPlayers$seasonYear, allPlayers$GameId),]
allPlayers$gamesPlayedSeason <-  unlist(aggregate(Min ~ seasonYear + PlayerId, allPlayers, function(x) {1:length(x)})$Min)

#Add cumulative columns
allPlayers <- allPlayers[order(allPlayers$PlayerId, allPlayers$seasonYear, allPlayers$GameId),]

allPlayers$setOfFts <- (allPlayers$FT.Attempted - (allPlayers$FT.Attempted %% 2)) / 2
allPlayers$extraFt <- (allPlayers$FT.Attempted %% 2)

allPlayers$cumThreeAttempted <- unlist(aggregate(Three.Attempted ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$Three.Attempted)
allPlayers$cumFgAttempted <- unlist(aggregate(Fg.Attempted ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$Fg.Attempted)
allPlayers$cumFTAttempted <- unlist(aggregate(FT.Attempted ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$FT.Attempted)
allPlayers$cumThreeMade <- unlist(aggregate(Three.Made ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$Three.Made)
allPlayers$cumFgMade <- unlist(aggregate(Fg.Made ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$Fg.Made)
allPlayers$cumFTMade <- unlist(aggregate(FT.Made ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$FT.Made)
allPlayers$cumRebounds <- unlist(aggregate(Total.Rebounds ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$Total.Rebounds)
allPlayers$cumAssists <- unlist(aggregate(Assists ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$Assists)
allPlayers$cumSteals <- unlist(aggregate(Steals ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$Steals)
allPlayers$cumBlocks <- unlist(aggregate(Blocks ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$Blocks)
allPlayers$cumTurnovers <- unlist(aggregate(Turnovers ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$Turnovers)
allPlayers$cumMin <- unlist(aggregate(Min ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$Min)
allPlayers$cumSetOfFts <- unlist(aggregate(setOfFts ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$setOfFts)
allPlayers$cumExtraFt <- unlist(aggregate(extraFt ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$extraFt)

#Last season averages
lastYear <- subset(allPlayers, allPlayers$seasonYear < 2022)
colnames(lastYear) <- str_replace(colnames(lastYear),pattern = "\\.","_")
agg <- sqldf("SELECT seasonYear, PlayerId, Name, 
             COUNT(Min) AS LastYearNumbGames,
             SUM(Min) AS LastYearMin, 
             SUM(Three_Made) AS LastYearThreeMade, SUM(Three_Attempted) AS LastYearThreeAttempted,
             SUM(Fg_Made) AS LastYearFgMade, SUM(Fg_Attempted) AS LastYearFgAttempted,
             SUM(FT_Made) AS LastYearFtMade, SUM(FT_Attempted) AS LastYearFTAttempted,
             SUM(Total_Rebounds) AS LastYearRebounds, 
             SUM(Assists) AS LastYearAssists, 
             SUM(Steals) AS LastYearSteals, 
             SUM(Blocks) AS LastYearBlocks, 
             SUM(Turnovers) AS LastYearTurnovers,
             SUM(setOfFts) AS LastYearSetOfFts,
             SUM(extraFt) AS LastYearExtraFts
             FROM lastYear
             GROUP BY seasonYear, PlayerId")

agg$seasonYear <- agg$seasonYear + 1
allPlayers <- merge(allPlayers, agg,  all.x = T)

#Team totals
boxscores <- allPlayers
colnames(boxscores) <- str_replace_all(colnames(boxscores), "\\.", "_")
gameStats <- sqldf("SELECT seasonYear, GameId, Team,
                   SUM(Min) AS Min, 
                   SUM(Points) AS Points,
                   SUM(Three_Made) AS Three_Made, SUM(Three_Attempted) AS Three_Attempted,
                   SUM(Fg_Made) AS Fg_Made, SUM(Fg_Attempted) AS Fg_Attempted,
                   SUM(FT_Made) AS FT_Made, SUM(FT_Attempted) AS FT_Attempted,
                   setOfFts, extraFt,
                   SUM(Offensive_Rebound) AS Offensive_Rebound, 
                   SUM(Defensive_Rebound) AS Defensive_Rebound, 
                   SUM(Total_Rebounds) AS Total_Rebounds, 
                   SUM(Assists) AS Assists, 
                   SUM(Steals) AS Steals, 
                   SUM(Blocks) AS Blocks, 
                   SUM(Turnovers) AS Turnovers,
                   SUM(Personal_Fouls) AS Personal_Fouls
                   FROM boxscores
                   GROUP BY seasonYear, GameId, Team")
rm(boxscores)

gameStats <- sqldf("SELECT t1.*, t2.Steals as oppSteals, t2.Blocks AS oppBlocks, t2.Personal_Fouls as oppPersonalFouls
                   FROM gameStats t1 
                   LEFT JOIN gameStats t2 on t1.GameId = t2.GameId AND t1.Team != t2.Team
                   ")
allPlayers <- sqldf("SELECT t1.*, t2.Fg_Attempted as teamTotalAttempted
                    FROM allPlayers t1
                    LEFT JOIN gameStats t2 ON t1.GameId = t2.GameId AND t1.Team = t2.Team")

allPlayers <- allPlayers[order(allPlayers$PlayerId, allPlayers$seasonYear, allPlayers$GameId),]

allPlayers$percAttempted <- allPlayers$Fg.Attempted / allPlayers$teamTotalAttempted
allPlayers$percAttemptedPerMin <- allPlayers$percAttempted / allPlayers$Min
allPlayers <- allPlayers[order(allPlayers$PlayerId, allPlayers$seasonYear, allPlayers$GameId),]
allPlayers$teamAttempted <-  unlist(aggregate(teamTotalAttempted ~ seasonYear + PlayerId, allPlayers, function(x) {cumsum(c(0, x[-length(x)]))})$teamTotalAttempted)
allPlayers$cumPercAttempted <- allPlayers$cumFgAttempted / allPlayers$teamAttempted
allPlayers$averageMinutes <- allPlayers$cumMin / allPlayers$gamesPlayedSeason
allPlayers$cumPercAttemptedPerMinute <- allPlayers$cumPercAttempted / allPlayers$averageMinutes

allPlayers$lastGameAttempted <- unlist(aggregate(percAttempted ~ seasonYear + PlayerId, allPlayers, function(x) {(c(0, x[-length(x)]))})$percAttempted)
allPlayers$lastGameMin <- unlist(aggregate(Min ~ seasonYear + PlayerId, allPlayers, function(x) {(c(0, x[-length(x)]))})$Min)
allPlayers$lastGameAttemptedPerMin <- allPlayers$lastGameAttempted / allPlayers$lastGameMin 

allPlayers$cumThreePerc <- allPlayers$cumThreeMade / allPlayers$cumThreeAttempted
allPlayers$threePerc <-  allPlayers$Three.Made / allPlayers$Three.Attempted
allPlayers$lastYearThreePerc <-  allPlayers$LastYearThreeMade /  allPlayers$LastYearThreeAttempted

allPlayers$cumTwoPerc <- (allPlayers$cumFgMade - allPlayers$cumThreeMade) / (allPlayers$cumFgAttempted - allPlayers$cumThreeAttempted)
allPlayers$twoPerc <- (allPlayers$Fg.Made - allPlayers$Three.Made) / (allPlayers$Fg.Attempted - allPlayers$Three.Attempted)
allPlayers$lastYeartwoPerc <- (allPlayers$LastYearFgMade - allPlayers$LastYearThreeMade) / (allPlayers$LastYearFgAttempted - allPlayers$LastYearThreeAttempted)

allPlayers$lastYearThreeProp <- allPlayers$LastYearThreeAttempted / allPlayers$LastYearFgAttempted
allPlayers$cumThreeProp <- allPlayers$cumThreeAttempted / allPlayers$cumFgAttempted

allPlayers$lastYearThreeAttemptedPerMin <- allPlayers$LastYearThreeAttempted / allPlayers$LastYearMin
allPlayers$lastYearTwoAttemptedPerMin <- (allPlayers$LastYearFgAttempted - allPlayers$LastYearThreeAttempted) / allPlayers$LastYearMin

allPlayers$threeAttemptedPerMin <- allPlayers$cumThreeAttempted / allPlayers$cumMin
allPlayers$twoAttemptedPerMin <- (allPlayers$cumFgAttempted - allPlayers$cumThreeAttempted) / allPlayers$cumMin

allPlayers$threeProp <- allPlayers$Three.Attempted / allPlayers$Fg.Attempted

allPlayers$cumFtMadePerFgAttempted <- allPlayers$cumFTMade / allPlayers$cumFgAttempted
allPlayers$cumSetOfFtsPerFgAttempted <- allPlayers$cumSetOfFts / allPlayers$cumFgAttempted
allPlayers$lastYearSetOfFtsPerFg <- allPlayers$LastYearSetOfFts / allPlayers$LastYearFgAttempted

allPlayers$lastYearFtPerc <- allPlayers$LastYearFtMade / allPlayers$LastYearFTAttempted
allPlayers$cumFtPerc <- allPlayers$cumFTMade / allPlayers$cumFTAttempted

allPlayers$cumFgAttemptedPerGame = allPlayers$cumFgAttempted / (allPlayers$gamesPlayedSeason - 1)

allPlayers$lastYearFgAttemptedPerGame = allPlayers$LastYearFgAttempted / allPlayers$LastYearNumbGames
allPlayers$lastYearFgMadePerGame = allPlayers$LastYearFgMade / allPlayers$LastYearNumbGames

#

teamGames <- unique(allPlayers[c("seasonYear", "GameId", "Team")])
teamGames <- teamGames[order(teamGames$Team, teamGames$seasonYear, teamGames$GameId),]
teamGames$teamGameNumber <-  unlist(aggregate(GameId ~ seasonYear + Team, teamGames, function(x) {1:length(x)})$GameId)

allPlayers <- merge(allPlayers, teamGames, by = c("seasonYear", "GameId", "Team"), all.x = T)

saveRDS(allPlayers, file = "C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\allPlayers.rds")

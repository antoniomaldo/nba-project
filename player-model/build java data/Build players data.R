library(sqldf)
library(arm)
library(stringr)
source("C:\\Users\\Antonio\\Documents\\NBA\\player-model\\build java data\\Utils.R")

TODAY_DIR = paste0("C:\\Users\\Antonio\\Documents\\NBA\\player-model\\build java data\\data\\", Sys.Date())
#Players that played in 2019 but not in 2020
createMissingPlayers <- function(naPlayers){
  lastGameLastYear <- aggregate(gamesPlayedSeason ~ PlayerId, naPlayers, max)
  colnames(lastGameLastYear) <- c("PlayerId", "lastYearLastGame")
  naPlayers <- merge(naPlayers, lastGameLastYear, by = "PlayerId", all.x = T)
  naPlayers <- subset(naPlayers, naPlayers$gamesPlayedSeason == naPlayers$lastYearLastGame)  

  naPlayers$lastYeartwoPerc <- naPlayers$cumTwoPerc
  naPlayers$lastYearThreePerc <- naPlayers$cumThreePerc
  naPlayers$lastYearThreeProp <- naPlayers$cumThreeProp
  naPlayers$lastYearFtPerc <- naPlayers$cumFtPerc
  
  naPlayers$cumPercAttemptedPerMinute <- NA
  naPlayers$lastGameAttemptedPerMin <- NA
  naPlayers$cumTwoPerc <- NA
  naPlayers$cumThreePerc <- NA
  naPlayers$cumThreeProp <- NA
  naPlayers$cumFtPerc <- NA
  
  return(naPlayers[,1:(ncol(naPlayers) - 1)])
}


getPlayersData <- function(){
  
  allPlayers <- getPlayersForYear(2023)
  allPlayers <- subset(allPlayers, !allPlayers$Team %in% c("LEB", "GIA", "USA", "WORLD"))
  allPlayers <- allPlayers[order(allPlayers$PlayerId),]
  allPlayers$cumThreeAttempted <- unlist(aggregate(Three.Attempted ~ PlayerId, allPlayers, function(x) {cumsum(x)})$Three.Attempted)
  allPlayers$cumFgAttempted <- unlist(aggregate(Fg.Attempted ~ PlayerId, allPlayers, function(x) {cumsum(x)})$Fg.Attempted)
  allPlayers$cumFTAttempted <- unlist(aggregate(FT.Attempted ~ PlayerId, allPlayers, function(x) {cumsum(x)})$FT.Attempted)
  allPlayers$cumThreeMade <- unlist(aggregate(Three.Made ~ PlayerId, allPlayers, function(x) {cumsum(x)})$Three.Made)
  allPlayers$cumFgMade <- unlist(aggregate(Fg.Made ~ PlayerId, allPlayers, function(x) {cumsum(x)})$Fg.Made)
  allPlayers$cumFTMade <- unlist(aggregate(FT.Made ~ PlayerId, allPlayers, function(x) {cumsum(x)})$FT.Made)
  allPlayers$cumRebounds <- unlist(aggregate(Total.Rebounds ~ PlayerId, allPlayers, function(x) {cumsum(x)})$Total.Rebounds)
  allPlayers$cumAssists <- unlist(aggregate(Assists ~ PlayerId, allPlayers, function(x) {cumsum(x)})$Assists)
  allPlayers$cumSteals <- unlist(aggregate(Steals ~ PlayerId, allPlayers, function(x) {cumsum(x)})$Steals)
  allPlayers$cumBlocks <- unlist(aggregate(Blocks ~ PlayerId, allPlayers, function(x) {cumsum(x)})$Blocks)
  allPlayers$cumTurnovers <- unlist(aggregate(Turnovers ~ PlayerId, allPlayers, function(x) {cumsum(x)})$Turnovers)
  allPlayers$cumMin <- unlist(aggregate(Min ~ PlayerId, allPlayers, function(x) {cumsum(x)})$Min)
  #Last season averages
  lastYear <- getPlayersForYear(2022)
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
               SUM(Turnovers) AS LastYearTurnovers
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
  allPlayers$percAttempted <- allPlayers$Fg.Attempted / allPlayers$teamTotalAttempted
  allPlayers$percAttemptedPerMin <- allPlayers$percAttempted / allPlayers$Min
  allPlayers <- allPlayers[order(allPlayers$PlayerId, allPlayers$seasonYear, allPlayers$GameId),]
  allPlayers$teamAttempted <-  unlist(aggregate(teamTotalAttempted ~ PlayerId, allPlayers, function(x) {cumsum(x)})$teamTotalAttempted)
  allPlayers$cumPercAttempted <- allPlayers$cumFgAttempted / allPlayers$teamAttempted
  allPlayers$gamesPlayedSeason <-  unlist(aggregate(Min ~ PlayerId, allPlayers, function(x) {1:length(x)})$Min)
  allPlayers$averageMinutes <- allPlayers$cumMin / allPlayers$gamesPlayedSeason
  allPlayers$cumPercAttemptedPerMinute <- allPlayers$cumPercAttempted / allPlayers$averageMinutes
  allPlayers$lastGameAttempted <- unlist(aggregate(percAttempted ~ PlayerId, allPlayers, function(x) {(x)})$percAttempted)
  allPlayers$lastGameMin <- unlist(aggregate(Min ~ PlayerId, allPlayers, function(x) {(x)})$Min)
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
  allPlayers$lastYearFtPerc <- allPlayers$LastYearFtMade / allPlayers$LastYearFTAttempted
  allPlayers$cumFtPerc <- allPlayers$cumFTMade / allPlayers$cumFTAttempted
  #########
  allPlayers <- allPlayers[order(allPlayers$PlayerId, allPlayers$GameId),]
  thisYearLastGame <- aggregate(gamesPlayedSeason ~ PlayerId, subset(allPlayers, allPlayers$seasonYear == 2023 & allPlayers$Min > 0), max)
  colnames(thisYearLastGame) <- c("PlayerId", "lastGame")
  allPlayers <- merge(allPlayers, thisYearLastGame, by = "PlayerId", all.x = T)
  naPlayers <- subset(allPlayers, is.na(allPlayers$lastGame))
  allPlayers <- subset(allPlayers, allPlayers$seasonYear == 2023 & allPlayers$gamesPlayedSeason == allPlayers$lastGame)
  if(nrow(naPlayers) > 0){
    missingPlayers <- createMissingPlayers(naPlayers)
    allPlayers <- rbind(allPlayers, missingPlayers)
  }
  #create dir
  if(!dir.exists(TODAY_DIR)){
    dir.create(TODAY_DIR)
  }
  saveRDS(allPlayers, file = paste0(TODAY_DIR, "\\allPlayers.rds"))
  return(allPlayers)
}
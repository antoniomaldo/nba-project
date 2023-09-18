library(stringr)
source("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\Utils.R")
source("C:\\Users\\Antonio\\Documents\\NBA\\data\\mappings\\mappings-service.R")

SEASON = 2019

boxscores <- getPlayersForYear(SEASON)
games <- getMatchesForYear(SEASON)

#games <- addOdds(games)

boxscores <- merge(boxscores, games[c("GameId", "Date", "AwayTeam", "HomeTeam", "Away.Final.Score", "Home.Final.Score")], all.x = T)
boxscores <- mapToPlayerId(boxscores)

#Get roto predictions for a day

boxscores$isHomePlayer <- as.character(boxscores$Team) == as.character(boxscores$HomeTeam)

BASE_DIR = paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\csvs\\",SEASON,"\\")

files = list.files(BASE_DIR)

teamAbbrevMappings <- read.csv("C:\\Users\\Antonio\\Documents\\NBA\\data\\mappings\\grinders-team-abbrev.csv")
colnames(teamAbbrevMappings) <- c("Team", "team")

addMissingPlayers <- function(cl, bx, fd){
  sumProjMins <- aggregate(pmin ~ Team, cl, sum)
  teamWithMissingPlayers <- subset(sumProjMins, abs(sumProjMins$pmin - 240) > 1)
  
  for(t in teamWithMissingPlayers$Team){
    teamCleanData <- subset(cleanData, cleanData$Team == t)
    teamFormatData <- subset(fd, fd$Team == t)
    
    missingPlayers <- subset(teamFormatData, !teamFormatData$playerName %in% teamCleanData$playerName)
    teamStats <- subset(cl, cl$Team == t)
    
    for(pl in unique(missingPlayers$playerName)){
      plId <- subset(bx, bx$playerName == pl)[1,]
      
      if(pl == "C.J. McCollum" & nrow(plId) == 0){
        pl = "CJ McCollum"
        plId <- subset(bx, bx$playerName == pl)[1,]
      }
      
      fdPlayer <- subset(fd, fd$playerName == pl)[1,]
      cl <- rbind(cl, data.frame(playerName = pl, 
                                 PlayerId = plId$PlayerId,
                                 GameId = teamStats$GameId[1],
                                 Team = teamStats$Team[1], 
                                 Name = plId$Name,  
                                 Position = plId$Position,
                                 Starter = 0,
                                 Min = 0,
                                 Fg.Made = 0,  
                                 Fg.Attempted = 0,
                                 Three.Made = 0,
                                 Three.Attempted = 0,  
                                 FT.Made = 0, 
                                 FT.Attempted = 0,
                                 Offensive.Rebound = 0, 
                                 Defensive.Rebound = 0,
                                 Total.Rebounds = 0, 
                                 Assists = 0, 
                                 Steals = 0, 
                                 Blocks = 0, 
                                 Turnovers = 0, 
                                 Personal.Fouls = 0, 
                                 Plus.Minus = 0, 
                                 Points = 0, 
                                 seasonYear = plId$seasonYear[1],
                                 Date = teamStats$Date[1],
                                 AwayTeam = teamStats$AwayTeam[1], 
                                 HomeTeam = teamStats$HomeTeam[1], 
                                 Away.Final.Score = teamStats$Away.Final.Score[1],
                                 Home.Final.Score = teamStats$Home.Final.Score[1],
                                 isHomePlayer = teamStats$HomeTeam[1] == fdPlayer$team,
                                 X = fdPlayer$X[1],        
                                 slateId = fdPlayer$slateId[1],
                                 playerId = fdPlayer$playerId[1],
                                 name = fdPlayer$name[1],
                                 team = fdPlayer$team[1], 
                                 opp = fdPlayer$opp[1],
                                 ishomeplayer = fdPlayer$ishomeplayer[1],
                                 pmin = fdPlayer$pmin[1],
                                 points = fdPlayer$points[1],
                                 floor = fdPlayer$floor[1],
                                 ceil = fdPlayer$ceil[1],
                                 salary = fdPlayer$salary[1],
                                 positionfd = fdPlayer$positionfd[1],
                                 total = fdPlayer$total[1],
                                 oppTotal = fdPlayer$oppTotal[1],
                                 date = fdPlayer$date[1],
                                 fdPoints = 0))
      
    }
  }
  return(cl)
}

for(file in files){
  print(file)
  
  formatData <- read.csv(paste0(BASE_DIR, file))
  formatData = unique(formatData)
  
  formatData$date <- str_replace(file, ".csv", "")
  formatData$playerName = str_trim(as.character(formatData$name))
  
  #Map nba team name
  
  dayBoxscore = subset(boxscores, boxscores$Date == str_remove_all(formatData$date[1], "-"))
  if(nrow(dayBoxscore) > 0){
    
    dayBoxscore = merge(dayBoxscore, formatData, by = "playerName", all.x = T)
    formatData <- merge(formatData, teamAbbrevMappings, by = "team", all.x = T)
    
    dayBoxscore$fdPoints <- dayBoxscore$Points + dayBoxscore$Total.Rebounds * 1.2 + dayBoxscore$Assists * 1.5 + dayBoxscore$Steals * 3 + dayBoxscore$Blocks * 3 - dayBoxscore$Turnovers 
    
    cleanData <- removeDupPredictions(dayBoxscore)
    
    cleanData <- addMissingPlayers(cl = cleanData, bx = boxscores, fd = formatData)
    write.csv(cleanData, file = paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\",SEASON,"\\", formatData$date[1], ".csv"))
  }
}

## Tests
test = do.call(rbind, lapply(list.files(paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\", SEASON), full.names = T), read.csv))

test$isNaPmin <- is.na(test$pmin)
agg <- aggregate(isNaPmin ~ GameId, test, mean)

aggTotal <- aggregate(pmin ~ GameId + Team, test, sum)

agg <- merge(agg, aggTotal)

View(subset(test[c("GameId", "PlayerId", "Name", "Min", "pmin")], test$GameId == 401468825))


a = aggregate(Min ~ GameId + PlayerId, test, length)

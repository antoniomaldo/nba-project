library(stringr)
source("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\Utils.R")
source("C:\\Users\\Antonio\\Documents\\NBA\\data\\mappings\\mappings-service.R")

SEASON = 2022

boxscores <- getPlayersForYear(SEASON)
games <- getMatchesForYear(SEASON)

#games <- addOdds(games)

boxscores <- merge(boxscores, games[c("GameId", "Date", "AwayTeam", "HomeTeam", "Away.Final.Score", "Home.Final.Score")], all.x = T)
boxscores <- mapToPlayerId(boxscores)

#Get roto predictions for a day

boxscores$isHomePlayer <- as.character(boxscores$Team) == as.character(boxscores$HomeTeam)

BASE_DIR = paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\csvs\\",SEASON,"\\")

files = list.files(BASE_DIR)

for(file in files){
  print(file)
  
  formatData <- read.csv(paste0(BASE_DIR, file))
  formatData = unique(formatData)
  
  formatData$date <- str_replace(file, ".csv", "")
  formatData$playerName = str_trim(as.character(formatData$name))
  
  dayBoxscore = subset(boxscores, boxscores$Date == str_remove_all(formatData$date[1], "-"))
  if(nrow(dayBoxscore) > 0){
    
    dayBoxscore = merge(dayBoxscore, formatData, by = "playerName", all.x = T)
    
    dayBoxscore$fdPoints <- dayBoxscore$Points + dayBoxscore$Total.Rebounds * 1.2 + dayBoxscore$Assists * 1.5 + dayBoxscore$Steals * 3 + dayBoxscore$Blocks * 3 - dayBoxscore$Turnovers 
    
    cleanData <- removeDupPredictions(dayBoxscore)
    write.csv(cleanData, file = paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\",SEASON,"\\", formatData$date[1], ".csv"))
  }
}

## Tests
test = do.call(rbind, lapply(list.files(paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\", SEASON), full.names = T), read.csv))

test$isNaPmin <- is.na(test$pmin)
agg <- aggregate(isNaPmin ~ GameId, test, mean)

aggTotal <- aggregate(pmin ~ GameId, test, sum)

agg <- merge(agg, aggTotal)

View(subset(test[c("GameId", "PlayerId", "Name", "Min", "pmin")], test$GameId == 401468825))


a = aggregate(Min ~ GameId + PlayerId, test, length)

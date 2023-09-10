library(stringr)
library(arm)

loadPlayersData <- function(){
  
  boxscores <- getMatchesForYear(2019)
  boxscores <- rbind(boxscores, getMatchesForYear(2020))
  boxscores <- rbind(boxscores, getMatchesForYear(2021))
  boxscores <- rbind(boxscores, getMatchesForYear(2022))
  boxscores <- rbind(boxscores, getMatchesForYear(2023))
  
  allPlayers <- getPlayersForYear(2019)
  allPlayers <- rbind(allPlayers, getPlayersForYear(2020))
  allPlayers <- rbind(allPlayers, getPlayersForYear(2021))
  allPlayers <- rbind(allPlayers, getPlayersForYear(2022))
  allPlayers <- rbind(allPlayers, getPlayersForYear(2023))
  
  boxscores$date <- as.Date(as.character(boxscores$Date), "%Y%m%d")
  
  aggOvertime <- aggregate(Min ~ GameId + Team, allPlayers, sum)
  aggOvertime$overtime <- 1 * (aggOvertime$Min > 250)
  
  allPlayers <- merge(allPlayers, boxscores[c("GameId", "date")], by = "GameId")
  allPlayers$date = as.character(allPlayers$date)
  
  return(allPlayers)
}

mapPlayerIds <- function(df){
  mappings <- unique(read.csv("C:/Users/Antonio/Documents/NBA/data/mappings/rotowire-mappings.csv")[c(1,3)])
  charPos <- which(mappings$PlayerId == 3988)
  specialChar <- substr(mappings$rotoName[charPos], start = 6, stop = 8)
  mappings$Name <- str_replace_all(as.character(mappings$rotoName), specialChar, " ")
  
  mappings <- unique(mappings[c("PlayerId", "Name")])
  df <- merge(df, mappings, by = "Name", all.x = T)
#  missing <- unique(subset(df[c("Name", "Team", "PlayerId")], is.na(allRotoData$PlayerId)))
#  cat(paste0(missing$Name, ",", missing$Team), sep = "\n")
  return(df)
}

loadRotowireData <- function(){
  allFiles <- list.files("C:/Users/Antonio/Documents/NBA/data/rotowire/", full.names = T)
  allFiles <- allFiles[!grepl(".R", allFiles)]
  allRotoData <- do.call(rbind, lapply(allFiles, loadCsvForDay))
  
  allRotoData$Name = allRotoData$NAME
  return(allRotoData)
}

loadCsvForDay <- function(file){
  dayCsv = read.csv(file)
  colNames = as.character(dayCsv[1,])
  dayCsv = dayCsv[-1,]
  colnames(dayCsv) = colNames
  dayCsv$date = str_remove_all(file, pattern = "C:/Users/Antonio/Documents/NBA/data/rotowire/rotowire-nba-projections-|.csv")
  
  return(dayCsv)
}

getMatchesForYear <- function(season){
  files =  list.files(paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\espn\\Boxscores\\", season), full.names = T)
  
  seasonData <- do.call(rbind, lapply(files, read.csv))
  seasonData$seasonYear = season
  
  return(seasonData)
}

getPlayersForYear <- function(season){
  files =  list.files(paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\espn\\Players\\", season), full.names = T)
  
  seasonData <- do.call(rbind, lapply(files, read.csv))
  seasonData$seasonYear = season
  
  return(seasonData)
}

getMinutePredictions <- function(){
  allPlayers <- loadPlayersData()
  allRotoData <- loadRotowireData()
  allRotoData <- mapPlayerIds(allRotoData)
  
  #Mapped by exact date
  mergedData <- merge(allRotoData[c("PlayerId", "date", "Name", "MIN")], allPlayers[c("GameId", "date", "PlayerId", "Min")], by = c("date", "PlayerId"), all.x = T)
  
  #split mapped
  mergedData$isNaGameId <- 1 * is.na(mergedData$GameId)
  mapped <- subset(mergedData, mergedData$isNaGameId == 0)
  nonMapped <- subset(mergedData, mergedData$isNaGameId == 1)
  
  
  #Mapped by day before
  
  nonMapped$yesterday <- as.Date(nonMapped$date) - 1
  nonMapped$date <- as.character(nonMapped$yesterday)
  
  nonMapped <- merge(nonMapped[c("PlayerId", "date", "Name", "MIN")], allPlayers[c("GameId", "PlayerId", "date", "Min")], all.x = T, by = c("date", "PlayerId"))
  
  #Join back
  mergedData <- rbind(mapped[c("GameId", "PlayerId", "date", "Name", "MIN", "Min")], 
                      nonMapped[c("GameId", "PlayerId", "date", "Name", "MIN", "Min")])
  mergedData$MIN <- as.numeric(mergedData$MIN)
  
  return(mergedData[c("GameId", "PlayerId", "MIN", "Min")])
}

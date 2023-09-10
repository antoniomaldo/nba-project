library(stringr)
library(jsonlite)
library(stringr)

source("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\build java data\\1.Read rotogrinders data.R")
source("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\build java data\\2. Format todays fd data.R")
source("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\build java data\\Build players data.R")

TODAY_DIR = paste0("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\data\\", Sys.Date())

FD_CSV_DIR <- paste0("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\data\\", Sys.Date(),"\\fd-data.csv")
ALL_DATA_RDS_DIR <- paste0(TODAY_DIR, "\\allPlayers.rds")

SHOULD_UPDATE_ROTO_DATA <- T


if(file.exists(ALL_DATA_RDS_DIR)){
  allPlayers <- readRDS(file = ALL_DATA_RDS_DIR)
  if(max(as.Date(as.character(allPlayers$Date), "%Y%m%d")) != Sys.Date() - 1){
    allPlayers <- getPlayersData()
  }
}else{
  allPlayers <- getPlayersData()
}


fdData <- read.csv(paste0("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\data\\", Sys.Date(),"\\fd-data.csv"))
fdData <- unique(fdData[,-which(colnames(fdData) %in% c("X", "slateId", "salary", "positionfd"))])

fdData$O.U <- NA
fdData$Total <- NA

mappings <- unique(read.csv("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\build java data\\MAPPINGS_ROTO.csv")[c(1,3)])
strangeChar <- substr(mappings$rotoName[106],start = 6,stop = 6)
mappings$Name <- str_replace_all(as.character(mappings$rotoName), strangeChar, " ")

mappings <- unique(mappings[c("PlayerId", "Name")])

colnames(fdData)[colnames(fdData) == "name"] <- "Name"

fdData <- merge(fdData, mappings, by = "Name", all.x = T)

allPlayers$cumFgAttemptedPerGame = allPlayers$cumFgAttempted / allPlayers$gamesPlayedSeason
allPlayers$cumFTAttemptedPerGame <- allPlayers$cumFTAttempted / (allPlayers$gamesPlayedSeason)

allPlayers <- allPlayers[c("PlayerId", "Position", "averageMinutes", "cumPercAttemptedPerMinute", "lastGameAttemptedPerMin", 
                           "lastYeartwoPerc", "cumTwoPerc", "lastYearThreePerc", "cumThreePerc",
                           "lastYearThreeProp", "cumThreeProp", "cumFtMadePerFgAttempted", "lastYearFgAttemptedPerGame",
                           "lastYearSetOfFtsPerFg", "cumSetOfFtsPerFgAttempted", "lastYearExtraProb", "cumExtraProb",
                           "lastYearFtPerc", "cumFtPerc", "LastYearFTAttempted", "LastYearNumbGames", "gamesPlayedSeason", "cumFgAttemptedPerGame", "cumFTAttemptedPerGame", "cumFTAttempted")]



fdData <- merge(fdData, allPlayers, by = "PlayerId", all.x = T)

fdData$timestamp <- as.numeric(Sys.time())

write.csv(fdData, paste0(paste0("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\data\\", Sys.Date()), "\\javaData.csv"))


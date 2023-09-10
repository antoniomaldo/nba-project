library(stringr)
library(sqldf)
source("C:\\Users\\Antonio\\Documents\\NBA\\data\\utils\\Utils.R")

mapToPlayerId <- function(df, mappingsFile = "C:/Users/Antonio/Documents/NBA/data/mappings/rotowire-mappings.csv"){
  
  playerMappins <- unique(read.csv(mappingsFile)[c(1,3)])
  
  charPos <- which(playerMappins$PlayerId == 3988)
  specialChar <- substr(playerMappins$rotoName[charPos], start = 6, stop = 8)
  playerMappins$rotoName <- str_replace_all(playerMappins$rotoName, specialChar, " ")
  playerMappins <- unique(playerMappins)
  
  colnames(playerMappins) <- c("PlayerId", "playerName")
  
  merged <- merge(df, playerMappins, by = "PlayerId", all.x = T)
  
  return(merged)
}

removeDupPredictions <- function(df){
  #If for a gameID, there are more than 1 players, keep the one with the predictions, or keep 1 row without a prediction
  
  dupPreds <- aggregate(Min ~ PlayerId, df, length)
  dupPreds <- subset(dupPreds, dupPreds$Min > 1)
  
  uniquePred <- subset(df, !df$PlayerId %in% dupPreds$PlayerId)
  multiplePred <- subset(df, df$PlayerId %in% dupPreds$PlayerId)
  
  cleanedDf <- data.frame()
  for(id in unique(multiplePred$PlayerId)){
    dupPlayer <- subset(multiplePred, multiplePred$PlayerId == id)
    dupPlayer$hasPred <- !is.na(dupPlayer$pmin)
    
    if(sum(dupPlayer$hasPred) > 0){
      cleanedDf <- rbind(cleanedDf,(subset(dupPlayer, dupPlayer$hasPred == 1)[1,]))
    }else{
      cleanedDf <- rbind(cleanedDf,dupPlayer[1,])
    }
  }
  
  return(rbind(uniquePred, cleanedDf[-which(colnames(cleanedDf) == "hasPred")]))
}

loadCsvForDay <- function(fileDir){
  if(grepl("rotowire", fileDir)){
    dayCsv = read.csv(fileDir)
    colNames = as.character(dayCsv[1,])
    dayCsv = dayCsv[-1,]
    colnames(dayCsv) = colNames
    dayCsv$date = str_remove_all(fileDir, pattern = "C:/Users/Antonio/Documents/NBA/data/rotowire/rotowire-nba-projections-|.csv")
    dayCsv$name = dayCsv$NAME
    return(dayCsv)
  }else{
    return(read.csv(fileDir))
  }
}


mapMinutesForSeasonForRotowire <- function(seasonYear){
  return(mapMinutesForSeason(seasonYear = seasonYear, 
                             mappingsFile = "C:/Users/Antonio/Documents/NBA/data/mappings/rotowire-mappings.csv",
                             csvMinPredsDir = "C:\\Users\\Antonio\\Documents\\NBA\\data\\rotowire\\",
                             csvPreffix = "rotowire-nba-projections-"))
}


mapMinutesForSeasonForRotogrinders <- function(seasonYear){
  return(mapMinutesForSeason(seasonYear = seasonYear))
}

mapMinutesForSeason <- function(seasonYear, mappingsFile = "C:/Users/Antonio/Documents/NBA/data/mappings/rotowire-mappings.csv", csvMinPredsDir = "C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\csvs\\", csvPreffix = ""){
  boxscores <- getPlayersForYear(seasonYear)
  games <- getMatchesForYear(seasonYear)
  boxscores <- merge(boxscores, games[c("GameId", "Date")], all.x = T)
  
  boxscores <- mapToPlayerId(boxscores, mappingsFile)
  
  yearDir <- paste0(csvMinPredsDir, seasonYear, "\\")
  files = list.files(yearDir)
  
  allData <- data.frame()
  for(file in files){
    csvData <- loadCsvForDay(paste0(yearDir, file))
    if(csvPreffix != ""){
      fileDate = str_replace(file, csvPreffix, "")
      fileDate= str_replace(fileDate, ".csv", "")
    }else {
      fileDate= str_replace(file, ".csv", "")
    }
    
    csvData$date = fileDate
    csvData$playerName = str_trim(as.character(csvData$name))
    
    dayBoxscore = subset(boxscores, boxscores$Date == str_remove_all(csvData$date[1], "-"))
    
    if(nrow(dayBoxscore) > 0){
      dayBoxscore = merge(dayBoxscore, csvData, by = "playerName", all.x = T)
      
      dayBoxscore$fdPoints <- dayBoxscore$Points + dayBoxscore$Total.Rebounds * 1.2 + dayBoxscore$Assists * 1.5 + dayBoxscore$Steals * 3 + dayBoxscore$Blocks * 3 - dayBoxscore$Turnovers 
      
      if(!("pmin" %in% colnames(dayBoxscore))){
        dayBoxscore$pmin = dayBoxscore$MIN
      }
      
      cleanData <- removeDupPredictions(dayBoxscore)
      
      allData <- rbind(allData, cleanData)
      #write.csv(cleanData, file = paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\",SEASON,"\\", formatData$date[1], ".csv"))
    }
  }
  return(allData)
}


## Map sbr data

loadSbrDataForCsv <- function(file){
  fileData <- read.csv(file, row.names = NULL)
  return(fileData)
}

pickWantedBookamer <- function(file){
  oddsData <- read.csv(file, row.names = NULL)
  oddsData <- subset(oddsData, !grepl("Opening", oddsData$bookmaker))
  finalData <- data.frame()
  for(at in unique(oddsData$awayTeam)){
    game <- subset(oddsData, oddsData$awayTeam == at)
    if("bet365" %in% oddsData$bookmaker){
      finalData <- rbind(finalData, subset(game, game$bookmaker == "bet365")[1,])
    }else if("williamhill" %in% oddsData$bookmaker){
      finalData <- rbind(finalData, subset(game, game$bookmaker == "williamhill")[1,])
    }else if("betway" %in% oddsData$bookmaker){
      finalData <- rbind(finalData, subset(game, game$bookmaker == "betway")[1,])
    }else if("888sport" %in% oddsData$bookmaker){
      finalData <- rbind(finalData, subset(game, game$bookmaker == "888sport")[1,])
    }else {
      finalData <- rbind(finalData, game[1,])
    }
  }
  return(finalData)
}

loadSbrData <- function(wantedYears = 2018:2023){
  sbrDir <- "C:\\Users\\Antonio\\Documents\\NBA\\data\\sbr-odds\\"
  sbrData <- data.frame()
  for(year in 2018:2021){
    if(year %in% wantedYears){
      csvsFolder <- paste0(sbrDir, year, "\\")
      csvsFiles <- list.files(csvsFolder, full.names = T)  
      for(csvFile in csvsFiles){
        csvData <- loadSbrDataForCsv(csvFile)
        csvData$seasonYear = year
        sbrData <- rbind(sbrData, loadSbrDataForCsv(csvFile)[c("seasonYear", "seasonPeriod", "date", "awayTeam", "homeTeam", "matchSpread", "totalPoints")])
      }
    }
  } 
  
  for(year in 2022:2023){
    if(year %in% wantedYears){
      csvsFolder <- paste0(sbrDir, year, "\\")
      csvsFiles <- list.files(csvsFolder, full.names = T)  
      for(csvFile in csvsFiles){
        oddsData <- pickWantedBookamer(csvFile)
        if(nrow(oddsData) > 0){
          oddsData <- oddsData[c("seasonYear", "seasonPeriod", "date", "awayTeam", "homeTeam", "home1QScore", "home4QScore" )]
          colnames(oddsData)[6:7] <- c("matchSpread", "totalPoints")
          oddsData$seasonYear = year
          sbrData <- rbind(sbrData, oddsData[c("seasonYear", "seasonPeriod", "date", "awayTeam", "homeTeam", "matchSpread", "totalPoints")])
        }
      }
    }
  }
  return(sbrData)
}

mapSbrDataToEspn <- function(bx){
  sbrData = loadSbrData(unique(bx$seasonYear))
  mappings <- read.csv("C:\\Users\\Antonio\\Documents\\NBA\\data\\mappings\\sbr_espn_team_mappings.csv")
  
  bx <- sqldf("SELECT t.*, t1.sbr_name AS homeTeamSbrName, t2.sbr_name AS awayTeamSbrName
                 FROM bx t
                 LEFT JOIN mappings t1 ON t.HomeTeam = t1.espn_abbrev
                 LEFT JOIN mappings t2 ON t.AwayTeam = t2.espn_abbrev")
  
  bx$date <- as.Date(as.character(bx$Date), format = "%Y%m%d")
  
  sbrData$date <- as.Date(sbrData$date, format = "%d/%m/%Y")
  sbrData$prevDate <- sbrData$date - 1
  
  bx = bx[,-which(colnames(bx) == "Date")]
  odds <- sqldf("SELECT g.GameId, o.* FROM bx g
               LEFT JOIN sbrData o
               ON g.homeTeamSbrName = o.homeTeam AND g.awayTeamSbrName = o.awayTeam
               AND (g.date = o.prevDate)")
  
  #try to mapped the ones not mapped using the same day
  notMapped <- subset(odds, is.na(odds$totalPoints))
  bxNotMapped <- subset(bx, bx$GameId %in% notMapped$GameId)
  bxMapped <- subset(bx, !bx$GameId %in% notMapped$GameId) 
  
  oddsNotMapped <- sqldf("SELECT g.GameId, o.* FROM bxNotMapped g
                          LEFT JOIN sbrData o
                          ON g.homeTeamSbrName = o.homeTeam AND g.awayTeamSbrName = o.awayTeam
                          AND (g.date = o.date)")
  
  odds <- subset(odds, odds$GameId %in% bxMapped$GameId)
  odds <- rbind(odds, oddsNotMapped)
  
  return(odds[c("GameId", "matchSpread", "totalPoints")])
}

bx = getMatchesForYear(2023)
oddsToBx <- mapSbrDataToEspn(bx)

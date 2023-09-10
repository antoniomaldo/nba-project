getPlayersForYear <- function(season){
  files =  list.files(paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\espn\\Players\\", season), full.names = T)
  
  seasonData <- do.call(rbind, lapply(files, read.csv))
  seasonData$seasonYear = season
  
  return(seasonData)
}

getMatchesForYear <- function(season){
  files =  list.files(paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\espn\\Boxscores\\", season), full.names = T)
  
  seasonData <- do.call(rbind, lapply(files, read.csv))
  seasonData$seasonYear = season
  
  return(seasonData)
}

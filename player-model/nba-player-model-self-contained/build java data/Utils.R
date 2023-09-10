getPlayersForYear <- function(season){
  files =  list.files(paste0("C:\\Users\\aostios\\Documents\\NBA\\data\\espn\\Players\\", season), full.names = T)
  
  seasonData <- do.call(rbind, lapply(files, read.csv))
  seasonData$seasonYear = season
  
  return(seasonData)
}

getMatchesForYear <- function(season){
  files =  list.files(paste0("C:\\Users\\aostios\\Documents\\NBA\\data\\espn\\Boxscores\\", season), full.names = T)
  
  seasonData <- do.call(rbind, lapply(files, read.csv))
  seasonData$seasonYear = season
  
  return(seasonData)
}

plotResiduals <- function(resid, df, subset = rep(T, nrow(df))){
  windows()
  par(mfrow = c(3,3))

  binnedplot(df$Min[subset], df$residGBM[subset], main = "Min")
  binnedplot(df$scoreDiff[subset], df$residGBM[subset], main = "scoreDiff")
  binnedplot(df$ownExpPoints[!is.na(df$ownExpPoints) & subset], df$residGBM[!is.na(df$ownExpPoints) & subset], main = "ownExpPoints")
  binnedplot(df$averageMinutes[subset], df$residGBM[subset], main = "averageMinutes")
  binnedplot(df$cumPercAttemptedPerMinute[!is.na(df$cumPercAttemptedPerMinute) & subset], df$residGBM[!is.na(df$ownExpPoints) & subset], main = "cumPercAttemptedPerMinute")
  binnedplot(df$lastYeartwoPerc[!is.na(df$lastYeartwoPerc) & subset], df$residGBM[!is.na(df$lastYeartwoPerc) & subset], main = "lastYeartwoPerc")
  binnedplot(df$Min[subset] - df$averageMinutes[subset], df$residGBM,main = "diffMinAndAverage")
  binnedplot(df$cumTwoPerc[subset], df$residGBM[subset],main = "cumTwoPerc")
  binnedplot(df$gamesPlayedSeason[subset], df$residGBM[subset],main = "gamesPlayedSeason")
}

plotResidualsForThree <- function(resid, df, subset = rep(T, nrow(df))){
  windows()
  par(mfrow = c(3,3))
  
  binnedplot(df$Min[subset], df$residGBM[subset], main = "Min")
  binnedplot(df$scoreDiff[subset], df$residGBM[subset], main = "scoreDiff")
  binnedplot(df$ownExpPoints[!is.na(df$ownExpPoints) & subset], df$residGBM[!is.na(df$ownExpPoints) & subset], main = "ownExpPoints")
  binnedplot(df$averageMinutes[subset], df$residGBM[subset], main = "averageMinutes")
  binnedplot(df$cumPercAttemptedPerMinute[subset], df$residGBM[subset], main = "cumPercAttemptedPerMinute")
  binnedplot(df$lastYearThreePerc[!is.na(df$lastYearThreePerc) & subset], df$residGBM[!is.na(df$lastYearThreePerc) & subset], main = "lastYearThreePerc")
  binnedplot(df$Min[subset] - df$averageMinutes[subset], df$residGBM,main = "diffMinAndAverage")
  binnedplot(df$cumThreePerc[subset], df$residGBM[subset],main = "cumThreePerc")
  binnedplot(df$gamesPlayedSeason[subset], df$residGBM[subset],main = "gamesPlayedSeason")
}

plotResidualsForMin <- function(resid, df, subset = rep(T, nrow(df))){
  windows()
  par(mfrow = c(2,1))
  binnedplot(df$pmin[subset], df$residGBM[subset], main = "pmin")
  binnedplot(df$scoreDiff[subset], df$residGBM[subset], main = "scoreDiff")
}

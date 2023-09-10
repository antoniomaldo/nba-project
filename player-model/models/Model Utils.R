getTrainIds <- function(df){
  set.seed(1)
  trainIds <- c()
  for(season in unique(df$seasonYear)){
    gameIdsForSeason = unique(subset(df$GameId, df$seasonYear == season))
    trainIds = c(trainIds, sample(gameIdsForSeason, size = 0.8 * length(gameIdsForSeason)))
  }
  return(trainIds)
}

plotResiduals <- function(resid, df, subset = rep(T, nrow(df))){
  windows()
  par(mfrow = c(3,2))
  
#  binnedplot(df$Min[subset], df$residGBM[subset], main = "Min")
 # binnedplot(df$scoreDiff[subset], df$residGBM[subset], main = "scoreDiff")
  #binnedplot(df$ownExpPoints[!is.na(df$ownExpPoints) & subset], df$residGBM[!is.na(df$ownExpPoints) & subset], main = "ownExpPoints")
  binnedplot(df$averageMinutes[subset], df$residGBM[subset], main = "averageMinutes")
 # binnedplot(df$cumPercAttemptedPerMinute[!is.na(df$cumPercAttemptedPerMinute) & subset], df$residGBM[!is.na(df$ownExpPoints) & subset], main = "cumPercAttemptedPerMinute")
  binnedplot(df$lastYeartwoPerc[!is.na(df$lastYeartwoPerc) & subset], df$residGBM[!is.na(df$lastYeartwoPerc) & subset], main = "lastYeartwoPerc")
 # binnedplot(df$Min[subset] - df$averageMinutes[subset], df$residGBM,main = "diffMinAndAverage")
  binnedplot(df$cumTwoPerc[subset & !is.na(df$cumTwoPerc)], df$residGBM[subset & !is.na(df$cumTwoPerc)],main = "cumTwoPerc")
  binnedplot(df$gamesPlayedSeason[subset], df$residGBM[subset],main = "gamesPlayedSeason")
  binnedplot(df$Fg.Attempted[subset], df$residGBM[subset],main = "Fg.Attempted")
  
}

plotResidualsForThree <- function(resid, df, subset = rep(T, nrow(df))){
  windows()
  par(mfrow = c(3,3))
  
 # binnedplot(df$Min[subset], df$residGBM[subset], main = "Min")
#  binnedplot(df$pmin[subset & !is.na(df$pmin)], df$residGBM[subset & !is.na(df$pmin)],main = "pmin")

  binnedplot(df$ownExpPoints[!is.na(df$ownExpPoints) & subset], df$residGBM[!is.na(df$ownExpPoints) & subset], main = "ownExpPoints")
  binnedplot(df$averageMinutes[subset], df$residGBM[subset], main = "averageMinutes")
  binnedplot(df$cumPercAttemptedPerMinute[subset & !is.na(df$cumPercAttemptedPerMinute)], df$residGBM[subset & !is.na(df$cumPercAttemptedPerMinute)], main = "cumPercAttemptedPerMinute")
  binnedplot(df$lastYearThreePerc[!is.na(df$lastYearThreePerc) & subset], df$residGBM[!is.na(df$lastYearThreePerc) & subset], main = "lastYearThreePerc")
#  binnedplot(df$Min[subset] - df$averageMinutes[subset], df$residGBM,main = "diffMinAndAverage")
  binnedplot(df$cumThreePerc[subset & !is.na(df$cumThreePerc)], df$residGBM[subset & !is.na(df$cumThreePerc)],main = "cumThreePerc")
#  binnedplot(df$gamesPlayedSeason[subset], df$residGBM[subset],main = "gamesPlayedSeason")
}

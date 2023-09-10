
buildPlayers <- function(df){
  playersList = list()
  for(i in 1:nrow(df)){
    playersList[[i]] = list(
      name = df$name[i],
      team = df$team[i],
      opp = df$opp[i],
      exp = df$points[i],
      modelExpPoints = df$points[i],
      pmin = df$pmin[i],
      salary = 0,
      isStarter = df$Starter[i],
      totalPoints = df$total[i] + df$oppTotal[i],
      matchSpread = ifelse(df$ishomeplayer[i], df$oppTotal[i] - df$total[i], df$total[i] - df$oppTotal[i]),
      position = df$Position[i],
      isHomePlayer = df$ishomeplayer[i],
      averageMinutes = fdData$averageMinutes[i],
      cumPercAttemptedPerMinute = fdData$cumPercAttemptedPerMinute[i],
      lastGameAttemptedPerMin = fdData$lastGameAttemptedPerMin[i],
      lastYearTwoPerc = fdData$lastYeartwoPerc[i],
      cumTwoPerc = fdData$cumTwoPerc[i],
      lastYearThreePerc = fdData$lastYearThreePerc[i],
      cumThreePerc = fdData$cumThreePerc[i],
      lastYearThreeProp = fdData$lastYearThreeProp[i],
      cumThreeProp = fdData$cumThreeProp[i],
      cumFtMadePerFgAttempted  = fdData$cumFtMadePerFgAttempted[i],
      lastYearFtPerc = fdData$lastYearFtPerc[i],
      cumFtPerc = fdData$cumFtPerc[i],
      dailyFantasyProj = fdData$points[i],
      shouldExclude = F,
      shouldInclude = T,
      teamDesiredScoreDiff = 0
    )
  }
  return(playersList)
}

buildGameRequest <- function(players){
  
  players$eventName = paste0(players$awayteam, " @ ", players$hometeam)
  
  gameRequest = list()
  counter = 1
  for(event in unique(players$eventName)){
    game = subset(players, players$eventName == event)
    
    homePlayers = buildPlayers(subset(game, game$ishomeplayer))
    awayPlayers = buildPlayers(subset(game, !game$ishomeplayer))
    
    gameRequest[[counter]] = list(
      homeTeamName = game$hometeam[1],
      awayTeamName = game$awayteam[1],
      totalPoints = game$totalpoints[1],
      matchSpread = game$matchspread[1],
      homePlayers = homePlayers,
      awayPlayers = awayPlayers
    )
    
    counter = counter + 1
  }
  return(gameRequest)
}

sendRequestToTheModel <- function(gameRequest, url = "http://localhost:2323/getLineups"){
  response = POST(url = url, body = jsonlite::toJSON(gameRequest, auto_unbox = T), content_type_json(), accept_json())
  
  jsonRespText<-content(response,as="text") 
  
  return(data.frame(jsonlite::fromJSON(jsonRespText)))
}

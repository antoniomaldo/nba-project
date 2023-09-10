
buildPlayers <- function(df){
  playersList = list()
  for(i in 1:nrow(df)){
    playersList[[i]] = list(
      name = df$name[i],
      position = df$positionfd[i],
      expPoints = df$points[i],
      salary = df$salary[i],
      ceil = df$ceil[i],
      floor = df$floor[i],
      pmin = df$pmin[i]
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

buildRequestForMain <- function(gameRequest, numbSimulation, lineupsPerSimulation, numSimulationsForDistModel){
  return(list(
    gameRequestList = gameRequest,
    numbSimulation = numbSimulation,
    lineupsPerSimulation = lineupsPerSimulation,
    numSimulationsForDistModel = numSimulationsForDistModel
  ))
}

sendRequestToTheModel <- function(gameRequest, url = "http://localhost:2323/getLineups"){
  response = POST(url = url, body = jsonlite::toJSON(gameRequest, auto_unbox = T), content_type_json(), accept_json())
  
  jsonRespText<-content(response,as="text") 
  
  return(data.frame(jsonlite::fromJSON(jsonRespText)))
}

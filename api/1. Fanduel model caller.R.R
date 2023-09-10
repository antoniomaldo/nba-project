library(jsonlite)
library(httr)
library(RODBC)

source("C:\\Users\\Antonio\\Documents\\NBA\\api\\Utils.R")

getLineUpsForSlateId <- function(id, url = "http://localhost:2323/getLineups"){
  players = getPlayersForSlateId(id)

  return(getLineUpsForPlayers(players, url))
}

getPlayersForSlateId <- function(id){
  server <- odbcConnect("Server")
  
  players <- sqlQuery(server, paste0("SELECT t1.*, t2.* from nba.salary_pos_slate t1 
                                      LEFT JOIN nba.roto_preds t2 ON 
                                      t1.gameid = t2.gameid AND 
                                      t1.playerid = t2.playerid  
                                      WHERE t1.slateid = ",id,";"))
  odbcClose(server)
  return(players)
} 

getLineUpsForPlayers <- function(players, url = "http://localhost:2323/getLineups"){
  gameRequest = buildGameRequest(players)
  
  print("Sending request to the model")
  
  return(sendRequestToTheModel(gameRequest, url))
}

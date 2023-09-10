library(jsonlite)
library(stringr)

source("C:\\Users\\Antonio\\Documents\\NBA\\api\\2. Read rotogrinders data.R")
source("C:\\Users\\Antonio\\Documents\\NBA\\api\\3. Format rotogrinders data.R")

source("C:\\Users\\Antonio\\Documents\\NBA\\api\\Utils.R")
source("C:\\Users\\Antonio\\Documents\\NBA\\fanduel\\backtest\\Utils.R")

PLAYER_DIR = paste0("C:\\Users\\Antonio\\Documents\\NBA\\api\\data\\", Sys.Date(), "\\players.csv")
BASE_DIR <- paste0("C:/Users/Antonio/Documents/NBA/api/data/", Sys.Date())

files <- list.files(BASE_DIR, full.names = T)

players <- read.csv(PLAYER_DIR)
players$hometeam <- ifelse(players$ishomeplayer, players$team, players$opp)
players$awayteam <- ifelse(!players$ishomeplayer, players$team, players$opp)
players$oppTotal <- as.numeric(players$oppTotal)
players$total <- as.numeric(players$total)
players$matchspread <- ifelse(players$ishomeplayer, 1, -1) * (players$oppTotal - players$total)
players$totalpoints <- players$total + players$oppTotal

paddyCsv <- files[grepl("FanDuel-NBA", files)]
id <- str_remove_all(pattern = "-entries-upload-template.csv",string =  str_remove_all(pattern = paste0(BASE_DIR, "/FanDuel-NBA-", Sys.Date(), "-"), string = paddyCsv))
playersForSlate <- subset(players, players$slateId == id)

#playersForSlate <- subset(playersForSlate, !playersForSlate$playerId %in% c( 1227,408990, 2439514 ))

gameRequest <- buildGameRequest(playersForSlate)

response <- sendRequestToTheModel(gameRequest, url = "http://localhost:8080/getLineups")
write.csv(response, file = paste0("C:\\Users\\Antonio\\Documents\\NBA\\api\\data\\",Sys.Date(),"\\responseGetLineUps.csv"))

response$topThree <- response$top1 + response$top2 + response$top3
response$topFiftyPerc <- response$top1 + response$top2 + response$top3 + response$top4 + response$top5

response = response[order(-1 * response$topFiftyPerc),] #chosen


chosenLineUps <- response[c(1,1,2),]

#,

requestForMain = buildRequestForMain(gameRequest = gameRequest, numbSimulation = 100, lineupsPerSimulation = 5, numSimulationsForDistModel = 100)

allResponses <- data.frame()
for(i in 1:300){
  print(i)
  responseForMain <- sendRequestToTheModel(requestForMain, url = "http://localhost:8080/getLineupsForMain" )
  responseForMain = cbind(responseForMain$lineupDto, responseForMain[,-1])
  allResponses <- rbind(responseForMain, allResponses)
}

allResponses = allResponses[order(-1 * allResponses$overFourHundredProb),] #chosen
chosenLineUps <-  allResponses[1:4,1:9]



responseForMain = responseForMain[order(-1 * responseForMain$overFourHundredTwentyFiveProb, -1 * responseForMain$overFourHundredProb),] #chosen
chosenLineUps <- rbind(chosenLineUps[,1], responseForMain[1:16,1])

chosenLineUps <-  responseForMain[1:9,1:9]

a = unique(chosenLineUps)
# 
# 
#For main
# write.csv(responseForMain, file = paste0("C:\\Users\\Antonio\\Documents\\NBA\\api\\data\\",Sys.Date(),"\\responseGetLineUpsForMain.csv"))
# 
# #responseForMain <- read.csv( file = paste0("C:\\Users\\Antonio\\Documents\\NBA\\api\\data\\",Sys.Date(),"\\responseGetLineUpsForMain.csv"))
# 
# 


# chosenLineUps <- chooseLineUps(responseForMain, 31, maxCommon = 6)
# 
# chosenLineUps <- chosenLineUps$lineupDto
# chosenLineUps <- rbind(chosenLineUps, response$lineupDto[1,])
# chosenLineUps <- rbind(chosenLineUps, response$lineupDto[1,])
# chosenLineUps <- rbind(chosenLineUps, response$lineupDto[1,])
# chosenLineUps <- rbind(chosenLineUps, response$lineupDto[1,])
# chosenLineUps <- rbind(chosenLineUps, response$lineupDto[1,])

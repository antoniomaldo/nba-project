library(httr)
library(stringr)
library(jsonlite)
library(sqldf)
library(plyr)

source("C:\\Users\\Antonio\\Documents\\NBA\\api\\Utils.R")

CONTESTS_DIR <- "C:\\Users\\Antonio\\Documents\\NBA\\data\\fanduel\\contests\\2020_21\\"

playersFolder <- "C:\\Users\\Antonio\\Documents\\NBA\\api\\data"

contestFiles <- list.files(path = CONTESTS_DIR)
allContests <- data.frame()

for(contestFile in contestFiles){
  contest = read.csv(paste0(CONTESTS_DIR,contestFile))
  contest$date = str_remove(contestFile, "\\.csv")
  allContests <- rbind(allContests, contest)
}

boxscores <- do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\espn\\Boxscores\\2021", full.names = T), read.csv))
players <- do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\espn\\Players\\2021", full.names = T), read.csv))
players$fdPoints <- players$Points + 1.2 * players$Total.Rebounds + 1.5 * players$Assists + 3 * (players$Steals + players$Blocks) - players$Turnovers
mappings <- unique(read.csv("C:\\Users\\Antonio\\Documents\\NBA\\data\\espn\\MAPPINGS_ROTO.csv")[,c(1,3)])

mappings$rotoName[mappings$PlayerId == "4397020"] <- "Lu Dort"
mappings <- unique(mappings)

players = merge(players, mappings, by = "PlayerId", all.x = T)

shouldSimulate = T
listFiles <- list.files(playersFolder, full.names = T)

for(file in listFiles){
  folderFiles <- list.files(file, full.names = T)
  playersCsv <- read.csv(file = paste0(file, "\\players.csv"))
  paddCsv <- folderFiles[grepl("padd",list.files( file))][1]
  if(!is.na(paddCsv)){
    
    
    contestId <- read.csv(paddCsv)$contest_id[1]
   # contestId <- "58184-246073553"
    slate <- str_split(contestId, "-")[[1]][1]
   # slate <- 58182
    print(slate)
    

    
    if(shouldSimulate){
      
      
      playersForSlate <- subset(playersCsv, playersCsv$slateId == slate)
      playersForSlate$hometeam <- ifelse(playersForSlate$ishomeplayer, playersForSlate$team, playersForSlate$opp)
      playersForSlate$awayteam <- ifelse(!playersForSlate$ishomeplayer, playersForSlate$team, playersForSlate$opp)
      playersForSlate$oppTotal <- as.numeric(playersForSlate$oppTotal)
      playersForSlate$total <- as.numeric(playersForSlate$total)
      playersForSlate$matchspread <- ifelse(playersForSlate$ishomeplayer, 1, -1) * (playersForSlate$oppTotal - playersForSlate$total)
      playersForSlate$totalpoints <- playersForSlate$total + playersForSlate$oppTotal
      
      games <- length(unique(playersForSlate$team)) / 2
      if(nrow(playersForSlate) > 0 & games > 2 ){
        
        gameRequest <- buildGameRequest(playersForSlate)
        requestForMain = buildRequestForMain(gameRequest = gameRequest, numbSimulation = 10000, lineupsPerSimulation = 1, numSimulationsForDistModel = 1)
        
        responseForMain <- sendRequestToTheModel(requestForMain, url = "http://localhost:8080/getLineupsForMain" )
        responseForMain = cbind(responseForMain$lineupDto, responseForMain[,-1])[,1:12]
        responseForMain$slateId <- slate
        responseForMain$games <- games
        responseForMain$contestId <- contestId
        
        write.csv(responseForMain ,file = paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\backtest\\fourth\\", slate, ".csv"))
      }
    }
    if(slate == "54140"){
      shouldSimulate = T
    }
    
  }
}

allDataNotScraped <- data.frame()
slates <- list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\backtest\\fourth")
allData <- data.frame()
for(sl in slates){
  print(sl)
  sl <- str_remove(sl, ".csv")
  
  contestsForSlate = subset(allContests, allContests$slateId == sl)
  
  dateEspn <- str_remove_all(contestsForSlate$date, "-")[1]
  
  boxscoresForSlate <- subset(boxscores, boxscores$Date == dateEspn)
  playersForSlate <- subset(players, players$GameId %in% boxscoresForSlate$GameId)
  playersForSlate$playerName <- playersForSlate$rotoName
  #mappedSlated2 <- do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\2021", full.names = T), read.csv))
  
  strategy <- read.csv(paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\backtest\\fourth\\",sl,".csv"))
  
  strategy$firstPgName <- unlist(lapply( str_split(strategy$firstPg, " \\("), FUN = function(x){x[1]}))
  strategy$secondPgName <- unlist(lapply(str_split(strategy$secondPg, " \\("), FUN = function(x){x[1]}))
  strategy$firstSgName <- unlist(lapply( str_split(strategy$firstSg, " \\("), FUN = function(x){x[1]}))
  strategy$secondSgName <- unlist(lapply(str_split(strategy$secondSg, " \\("), FUN = function(x){x[1]}))
  strategy$firstSfName <- unlist(lapply( str_split(strategy$firstSf, " \\("), FUN = function(x){x[1]}))
  strategy$secondSfName <- unlist(lapply(str_split(strategy$secondSf, " \\("), FUN = function(x){x[1]}))
  strategy$firstPfName <- unlist(lapply( str_split(strategy$firstPf, " \\("), FUN = function(x){x[1]}))
  strategy$secondPfName <- unlist(lapply(str_split(strategy$secondPf, " \\("), FUN = function(x){x[1]}))
  strategy$centerName <- unlist(lapply(  str_split(strategy$center, " \\("), FUN = function(x){x[1]}))
  
  
  #playersForSlate <- subset(mappedSlated, mappedSlated$slateId == sl)
  colnames(playersForSlate)[colnames(playersForSlate) == "playerId"] <- "playerId2"
  colnames(playersForSlate)[colnames(playersForSlate) == "name"] <- "name2"
  colnames(playersForSlate)[colnames(playersForSlate) == "team"] <- "team2"
  colnames(playersForSlate)[colnames(playersForSlate) == "ishomeplayer"] <- "ishomeplayer2"
  colnames(playersForSlate)[colnames(playersForSlate) == "points"] <- "pointsExp"
  colnames(playersForSlate)[colnames(playersForSlate) == "date"] <- "date2"
  
  strategy = sqldf("SELECT t1.*, 
                  t2.fdPoints as pg1Points,
                  t3.fdPoints as pg2Points,
                  t4.fdPoints as sg1Points,
                  t5.fdPoints as sg2Points,
                  t6.fdPoints as sf1Points,
                  t7.fdPoints as sf2Points,
                  t8.fdPoints as pf1Points,
                  t9.fdPoints as pf2Points,
                  t10.fdPoints as cPoints
            FROM strategy t1 
            LEFT JOIN playersForSlate t2 ON t1.firstPgName = t2.playerName
            LEFT JOIN playersForSlate t3 ON t1.secondPgName = t3.playerName
            LEFT JOIN playersForSlate t4 ON t1.firstSgName = t4.playerName
            LEFT JOIN playersForSlate t5 ON t1.secondSgName = t5.playerName
            LEFT JOIN playersForSlate t6 ON t1.firstSfName = t6.playerName
            LEFT JOIN playersForSlate t7 ON t1.secondSfName = t7.playerName
            LEFT JOIN playersForSlate t8 ON t1.firstPfName = t8.playerName
            LEFT JOIN playersForSlate t9 ON t1.secondPfName = t9.playerName
            LEFT JOIN playersForSlate t10 ON t1.centerName = t10.playerName

          ")
  
  strategy$pg1Points <- ifelse(is.na(strategy$pg1Points), 0, strategy$pg1Points)
  strategy$pg2Points <- ifelse(is.na(strategy$pg2Points), 0, strategy$pg2Points)
  strategy$sg1Points <- ifelse(is.na(strategy$sg1Points), 0, strategy$sg1Points)
  strategy$sg2Points <- ifelse(is.na(strategy$sg2Points), 0, strategy$sg2Points)
  strategy$sf1Points <- ifelse(is.na(strategy$sf1Points), 0, strategy$sf1Points)
  strategy$sf2Points <- ifelse(is.na(strategy$sf2Points), 0, strategy$sf2Points)
  strategy$pf1Points <- ifelse(is.na(strategy$pf1Points), 0, strategy$pf1Points)
  strategy$pf2Points <- ifelse(is.na(strategy$pf2Points), 0, strategy$pf2Points)
  strategy$centerName <- ifelse(is.na(strategy$centerName), 0, strategy$centerName)
  
  strategy$totalFdPoints <- 
    strategy$pg1Points + strategy$pg2Points +
    strategy$sg1Points + strategy$sg2Points +
    strategy$sf1Points + strategy$sf2Points +
    strategy$pf1Points + strategy$pf2Points +
    strategy$cPoints 
  
  strategy <- subset(strategy, !is.na(strategy$totalFdPoints))
  
  if(nrow(strategy) > 0){
    contestsForSlate$winnerPrize = as.numeric(str_remove(contestsForSlate$Winner_Prize, "\\$"))
    contestsForSlate$entryFreeNum <- as.numeric(str_remove(contestsForSlate$EntryFee, "\\$"))
    
    contestsForSlate <- subset(contestsForSlate, contestsForSlate$entryFreeNum < 10)
    mainContest <- subset(contestsForSlate ,contestsForSlate$winnerPrize == max(contestsForSlate$winnerPrize) & contestsForSlate$MaxPlayers > 5000)
    
    strategy <- strategy[order(-1 * strategy$totalModelExpPoints),]
    strategy$distanceToWinner <-  max(mainContest$Top_Score_Points) - strategy$totalFdPoints
    
    strategy$id <- 1:nrow(strategy)
    strategy$entryFee <- as.numeric(str_remove(mainContest$EntryFee, "\\$"))
    mainContest$cutLinePrize = as.numeric(str_remove(mainContest$Cutline_Prize, "\\$"))
    strategy$returns <- ifelse(strategy$totalFdPoints > mainContest$Top_Score_Points, mainContest$winnerPrize, ifelse(strategy$totalFdPoints > mainContest$Cutline_Points, mainContest$cutLinePrize , 0))
    
    strategy$returns[strategy$totalFdPoints > mainContest$Top_Score_Points] <- strategy$returns[strategy$totalFdPoints > mainContest$Top_Score_Points] / sum(strategy$totalFdPoints > mainContest$Top_Score_Points)
    allData <- rbind(allData, strategy)
  }
}

allData$gw <- allData$returns - allData$entryFee
allData$ratio <- allData$totalModelExpPoints / allData$average

allDataNotScraped <- rbind(allDataNotScraped, allData)

sum(allData$gw[allData$id > 2000]) / sum(allData$entryFee[allData$id > 2000])
sum(allData$gw[allData$id < 1000]) / sum(allData$entryFee[allData$id < 1000])


sum(allData$gw[allData$ratio >2.5 ]) / sum(allData$entryFee[allData$ratio > 2.5])
sum(allData$gw[allData$ratio <2 ]) / sum(allData$entryFee[allData$ratio < 2])

allData <- allData[order(allData$id),]

plot.ts(cumsum(allData$gw))


agg <- aggregate(gw ~ id, allData, sum)
agg <- merge(agg, aggregate(X ~ id, allData, length))
agg <- subset(agg, agg$X > 17)
plot.ts(agg$distanceToWinner)
library(arm)

binnedplot(test2$totaFdPoints, test2$totalModelExpPoints)



model <- lm(gw ~  id, allData)

summary(model)

allData$pred <- predict(model, allData)
allData$resid <- allData$gw - allData$pred

plot(allData$ratio, allData$resid)

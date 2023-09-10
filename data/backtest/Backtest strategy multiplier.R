library(httr)
library(stringr)
library(jsonlite)
library(sqldf)

source("C:\\Users\\Antonio\\Documents\\NBA\\api\\Utils.R")

CONTESTS_DIR <- "C:\\Users\\Antonio\\Documents\\NBA\\data\\fanduel\\contests\\2020_21\\"
MAPPED_SLATE_PLAYERS_DIR <- "C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\2021\\"

contestFiles <- list.files(path = CONTESTS_DIR)
allContests <- data.frame()

for(contestFile in contestFiles){
  contest = read.csv(paste0(CONTESTS_DIR,contestFile))
  contest$date = str_remove(contestFile, "\\.csv")
  allContests <- rbind(allContests, contest)
}
allContests$entryFreeNum = as.numeric(str_remove(allContests$EntryFee, "\\$"))


shouldSimulate = F
for(contestDate in unique(allContests$date)[93:126]){
  mainContestSlate = subset(allContests$slateId, allContests$date == contestDate)[1]
  playersForContest <- read.csv(paste0(MAPPED_SLATE_PLAYERS_DIR, as.Date(contestDate) - 1, ".csv"))
  playersForSlate <- subset(playersForContest, playersForContest$slateId == mainContestSlate)
  print(mainContestSlate)
  
  if(shouldSimulate){
    
    playersForSlate$hometeam <- ifelse(playersForSlate$ishomeplayer, playersForSlate$team, playersForSlate$opp)
    playersForSlate$awayteam <- ifelse(!playersForSlate$ishomeplayer, playersForSlate$team, playersForSlate$opp)
    playersForSlate$oppTotal <- as.numeric(playersForSlate$oppTotal)
    playersForSlate$total <- as.numeric(playersForSlate$total)
    playersForSlate$matchspread <- ifelse(playersForSlate$ishomeplayer, 1, -1) * (playersForSlate$oppTotal - playersForSlate$total)
    playersForSlate$totalpoints <- playersForSlate$total + playersForSlate$oppTotal
    
    games <- length(unique(playersForSlate$team)) / 2
    if(nrow(playersForSlate) > 0){
      
      
      
      gameRequest <- buildGameRequest(playersForSlate)
      
      response <- sendRequestToTheModel(gameRequest, url = "http://localhost:8080/getLineups")
      response = cbind(response$lineupDto, response[,-1])
      response$slateId <- mainContestSlate
      response$games <- games
      
      
      write.csv(response ,file = paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\backtest\\scraped\\multiplier\\first\\", mainContestSlate, ".csv"))
    }
  }
  if(mainContestSlate == 52500){
    shouldSimulate = T
  }
}


boxscores <- do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\espn\\Boxscores\\2021", full.names = T), read.csv))
players <- do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\espn\\Players\\2021", full.names = T), read.csv))
players$fdPoints <- players$Points + 1.2 * players$Total.Rebounds + 1.5 * players$Assists + 3 * (players$Steals + players$Blocks) - players$Turnovers
mappings <- unique(read.csv("C:\\Users\\Antonio\\Documents\\NBA\\data\\espn\\MAPPINGS_ROTO.csv")[,c(1,3)])

mappings$rotoName[mappings$PlayerId == "4397020"] <- "Lu Dort"
mappings <- unique(mappings)

players = merge(players, mappings, by = "PlayerId", all.x = T)


loadStrategyCsvFromDir <- function(dirPath){
  
  slates = list.files(dirPath)
  allData = data.frame()
  for(sl in slates){
    print(sl)
    sl = str_remove(sl, ".csv")
    
    contestsForSlate = subset(allContests, allContests$slateId == sl)
    
    # contestsForSlate <- subset(contestsForSlate, contestsForSlate$entryFreeNum > 2)
    # contestsForSlate <- contestsForSlate[order(-1 * contestsForSlate$ActualPlayers), ]
    # quintuple <- contestsForSlate[1,]
    # 
    quintuple <- subset(contestsForSlate, grepl("uintuple|ouble Up|riple Up", contestsForSlate$contestName))
    
    if(nrow(quintuple) > 0){
      
      
      dateEspn = str_remove_all(contestsForSlate$date, "-")[1]
      
      boxscoresForSlate = subset(boxscores, boxscores$Date == dateEspn)
      playersForSlate = subset(players, players$GameId %in% boxscoresForSlate$GameId)
      playersForSlate$playerName = playersForSlate$rotoName
      #mappedSlated2 = do.call(rbind, lapply(list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\2021", full.names = T), read.csv))
      
      strategy = read.csv(paste0(dirPath, "\\",sl,".csv"))
      
      strategy$firstPgName = unlist(lapply( str_split(strategy$firstPg, " \\("), FUN = function(x){x[1]}))
      strategy$secondPgName = unlist(lapply(str_split(strategy$secondPg, " \\("), FUN = function(x){x[1]}))
      strategy$firstSgName = unlist(lapply( str_split(strategy$firstSg, " \\("), FUN = function(x){x[1]}))
      strategy$secondSgName = unlist(lapply(str_split(strategy$secondSg, " \\("), FUN = function(x){x[1]}))
      strategy$firstSfName = unlist(lapply( str_split(strategy$firstSf, " \\("), FUN = function(x){x[1]}))
      strategy$secondSfName = unlist(lapply(str_split(strategy$secondSf, " \\("), FUN = function(x){x[1]}))
      strategy$firstPfName = unlist(lapply( str_split(strategy$firstPf, " \\("), FUN = function(x){x[1]}))
      strategy$secondPfName = unlist(lapply(str_split(strategy$secondPf, " \\("), FUN = function(x){x[1]}))
      strategy$centerName = unlist(lapply(  str_split(strategy$center, " \\("), FUN = function(x){x[1]}))
      
      
      #playersForSlate = subset(mappedSlated, mappedSlated$slateId == sl)
      # colnames(playersForSlate)[colnames(playersForSlate) == "playerId"] = "playerId2"
      # colnames(playersForSlate)[colnames(playersForSlate) == "name"] = "name2"
      # colnames(playersForSlate)[colnames(playersForSlate) == "team"] = "team2"
      # colnames(playersForSlate)[colnames(playersForSlate) == "ishomeplayer"] = "ishomeplayer2"
      # colnames(playersForSlate)[colnames(playersForSlate) == "points"] = "pointsExp"
      # colnames(playersForSlate)[colnames(playersForSlate) == "date"] = "date2"
      
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
      
    #  strategy$pg1Points = ifelse(is.na(strategy$pg1Points), 0, strategy$pg1Points)
    #  strategy$pg2Points = ifelse(is.na(strategy$pg2Points), 0, strategy$pg2Points)
    #  strategy$sg1Points = ifelse(is.na(strategy$sg1Points), 0, strategy$sg1Points)
    #  strategy$sg2Points = ifelse(is.na(strategy$sg2Points), 0, strategy$sg2Points)
    #  strategy$sf1Points = ifelse(is.na(strategy$sf1Points), 0, strategy$sf1Points)
    #  strategy$sf2Points = ifelse(is.na(strategy$sf2Points), 0, strategy$sf2Points)
    #  strategy$pf1Points = ifelse(is.na(strategy$pf1Points), 0, strategy$pf1Points)
    #  strategy$pf2Points = ifelse(is.na(strategy$pf2Points), 0, strategy$pf2Points)
    #  strategy$centerName = ifelse(is.na(strategy$centerName), 0, strategy$centerName)
      
      strategy$totalFdPoints = strategy$pg1Points + strategy$pg2Points +
        strategy$sg1Points + strategy$sg2Points +
        strategy$sf1Points + strategy$sf2Points +
        strategy$pf1Points + strategy$pf2Points +
        strategy$cPoints 
      
      
    #  strategy = subset(strategy, !is.na(strategy$totalFdPoints))
      
      strategy$firstThree <- strategy$top1 + strategy$top2 + strategy$top3
      strategy$firstFive <- strategy$firstThree + strategy$top4 + strategy$top5
      strategy$firstTen <- strategy$firstFive + strategy$top6 + strategy$top7 + strategy$top8 + strategy$top9 + strategy$top10
      
      if(nrow(strategy) > 0){
        strategy$gw2 <- 0
        strategy$entryFee2 <- 0
        strategy$gw3 <- 0
        strategy$entryFee3 <- 0
        strategy$gw5 <- 0
        strategy$entryFee5 <- 0
        
        quintuple$winnerPrize = as.numeric(str_remove(quintuple$Winner_Prize, "\\$"))
        quintuple$cutLinePrize = as.numeric(str_remove(quintuple$Cutline_Prize, "\\$"))
        
        quintuple$entryFreeNum = as.numeric(str_remove(quintuple$EntryFee, "\\$"))
        
        for(i in 1:nrow(quintuple)){
          quintupleContest <- quintuple[i,]
          if(grepl("ouble", quintupleContest$contestName)){
            strategy$gw2 <- strategy$gw2 + ifelse(strategy$totalFdPoints >= quintupleContest$Cutline_Points, quintupleContest$cutLinePrize, 0)
            strategy$entryFee2 <- strategy$entryFee2 + quintupleContest$entryFreeNum
          }else if(grepl("riple", quintupleContest$contestName)){
            strategy$gw3 <- strategy$gw3 + ifelse(strategy$totalFdPoints >= quintupleContest$Cutline_Points, quintupleContest$cutLinePrize, 0)
            strategy$entryFee3 <- strategy$entryFee3 + quintupleContest$entryFreeNum
          }else if(grepl("uintupl", quintupleContest$contestName)){
            strategy$gw5 <- strategy$gw5 + ifelse(strategy$totalFdPoints >= quintupleContest$Cutline_Points, quintupleContest$cutLinePrize, 0)
            strategy$entryFee5 <- strategy$entryFee5 + quintupleContest$entryFreeNum
          }
          
        }
        
        allData = rbind(allData, strategy)
        
      }
    }
  }
  
  return(allData)
}

dirPath <- "C:\\Users\\Antonio\\Documents\\NBA\\data\\backtest\\scraped\\multipliers\\first\\"

test <- loadStrategyCsvFromDir(dirPath = dirPath)

sum(test$gw)
sum(test$entryFee)

gw <- 0
fee <- 0
allData <- data.frame()
for(i in unique(test$slateId)){
  slateData <- subset(test, test$slateId == i & !is.na(test$totalFdPoints))
  slateData <- slateData[order(-1 * slateData$firstTen),]
  slateData <- slateData[1:3,]
  allData <- rbind(allData, slateData)
  
}

sum(allData$gw2)
sum(allData$entryFee2)


sum(allData$gw3)
sum(allData$entryFee3)

sum(allData$gw5)
sum(allData$entryFee5)

sum(allData$gw2 + allData$gw3 + allData$gw5)
sum(allData$entryFee2 + allData$entryFee3 + allData$entryFee5)

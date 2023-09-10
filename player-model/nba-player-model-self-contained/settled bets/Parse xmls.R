library(xml2)
library(stringr)

day = "10-11-2022"

getBetsForDay <- function(day){
  xmlDir = paste0("C:\\Users\\Antonio\\Documents\\NBA\\player-model\\nba-player-model-self-contained\\settled bets\\bets-", day, ".xml")
  
  xml_data <- read_xml(xmlDir)
  bets_as_list <- as_list(xml_data)[[1]]
  
  getReturns <- function(b){
    if(length(b[[1]][[2]][[2]]) == 0){
      return(bet[[1]][[2]][[1]][[1]][1])
    }else{
      return(b[[1]][[2]][[2]][[1]][1])
    }
  }
  
  df = data.frame()
  for(bet in bets_as_list){
    stake = bet[[1]][[1]]$div$div[[1]]
    returns = getReturns(bet)
    selection = bet[[2]][[1]]$div$div$div$div[2]$div$span[[1]]
    market = bet[[2]][[1]]$div$div$div[[2]]$div[[1]]
    odds = bet[[2]][[1]]$div$div[[2]][[1]]
    
    df = rbind(df, data.frame(stake = stake, returns = returns, selection = selection, market = market, odds = odds))
  }
  df$date = day
  return(df)
}

settledBets <- getBetsForDay("07-11-2022")
settledBets <- rbind(settledBets, getBetsForDay("08-11-2022"))
settledBets <- rbind(settledBets, getBetsForDay("12-11-2022"))

extractMultiplier <- function(row){
  split = str_split(row, " x ")[[1]]
  if(length(split) == 2){
    return(split[1])
  }else{
    return(1)
  }
}


extractStake <- function(row){
  split = str_split(row, " x ")[[1]]
  if(length(split) == 2){
    return(split[2])
  }else{
    return(NA)
  }
}
##handle accas
settledBets$isDoubles <- grepl(" Doubles", settledBets$stake)
settledBets$stake <- str_remove_all(" Doubles",string =  settledBets$stake)
settledBets$multiplier <- unlist(lapply(settledBets$stake, FUN =function(x) extractMultiplier(x)))
settledBets$baseStake <- unlist(lapply(settledBets$stake, FUN =function(x) extractStake(x)))

settledBets$baseStake[!settledBets$isDoubles] <- settledBets$stake[!settledBets$isDoubles]
settledBets$stakeGBP <- as.numeric(str_remove_all(settledBets$baseStake, "£| Single")) * as.numeric(settledBets$multiplier)
settledBets$selection[settledBets$isDoubles] <- "Doubles -1"

#extract line

str <- settledBets$selection[1:2]
settledBets$selection <- str_remove(settledBets$selection, "76ers")

settledBets$line = as.numeric(unlist(regmatches(settledBets$selection,
                                                gregexpr("[[:digit:]]+\\.*[[:digit:]]*",settledBets$selection))))
settledBets$line[settledBets$isDoubles] <- NA

settledBets$returns[settledBets$returns == "Lost"] = 0
settledBets$returnsGBP <- as.numeric(str_remove_all(settledBets$returns, "£"))

settledBets$GW <- settledBets$returnsGBP - settledBets$stakeGBP
settledBets$MarketType <- ifelse(grepl(settledBets$market, pattern = "Threes Made"), "Three Made", "Points")
settledBets$SelectionType <- ifelse(grepl(settledBets$selection, pattern = " Under "), "Under", "Over")

sum(settledBets$GW[settledBets$line < 18], na.rm = T)
sum(settledBets$GW[settledBets$line > 18], na.rm = T)

settledBets = settledBets[order(settledBets$line),]
settledBets$cumsumGW <- cumsum(settledBets$GW)
settledBets$cumsumStake <- cumsum(settledBets$stakeGBP)
settledBets$cumsumPerc <- (settledBets$cumsumGW) / settledBets$cumsumStake

plot.ts(settledBets$cumsumGW)


bigPrices <- subset(settledBets, settledBets$odds > 2.2)
smallPrices <- subset(settledBets, settledBets$odds < 2.2)

bigPrices$cumsumGW <- cumsum(bigPrices$GW)
smallPrices$cumsumGW <- cumsum(smallPrices$GW)

plot.ts(bigPrices$cumsumGW)
plot.ts(smallPrices$cumsumGW)


settledBets = settledBets[order(settledBets$odds),]
settledBets$cumsumGW <- cumsum(settledBets$GW)
settledBets$cumsumStake <- cumsum(settledBets$stakeGBP)
settledBets$cumsumPerc <- (settledBets$cumsumGW) / settledBets$cumsumStake

plot.ts(settledBets$cumsumGW)

sum(settledBets$GW[settledBets$line>20], na.rm = T)
sum(settledBets$GW[settledBets$line<20], na.rm = T)

singles <- subset(settledBets, !grepl("Doubles", settledBets$selection))
singles$won <- 1 * (singles$returnsGBP > 0)



singles$stakeGBP <- as.numeric(str_remove_all(singles$stake, "£| Single"))
singles$returns[singles$returns == "Lost"] = 0
singles$returnsGBP <- as.numeric(str_remove_all(singles$returns, "£"))

singles$GW <- singles$returnsGBP - singles$stakeGBP
singles$MarketType <- ifelse(grepl(singles$market, pattern = "Threes Made"), "Three Made", "Points")
singles$SelectionType <- ifelse(grepl(singles$selection, pattern = " Under "), "Under", "Over")

sum(singles$GW) / sum(singles$stakeGBP)
aggregate(GW ~ MarketType + SelectionType, singles, sum)
aggregate(stakeGBP ~ MarketType + SelectionType, singles, sum)

singles = singles[order(singles$odds),]

singles <- subset(singles, singles$stakeGBP != singles$returnsGBP)

#unit stake
singles$odds <- as.numeric(singles$odds)
(sum(singles$odds[singles$won == 1]) - nrow(singles)) / nrow(singles)
(sum(singles$returnsGBP[singles$won == 1]) - sum(singles$stakeGBP)) / sum(singles$stakeGBP)

plot.ts(cumsum(singles$GW))
plot(singles$odds, (singles$GW))

sum(singles$GW[singles$odds < 2])/ sum(singles$stakeGBP[singles$odds <  2])  
sum(singles$GW[singles$odds < 3])/ sum(singles$stakeGBP[singles$odds <  3])  
sum(singles$GW[singles$odds >  3]) / sum(singles$stakeGBP[singles$odds >  3])  


#Random results

singles <- subset(settledBets, !settledBets$isDoubles)

singles$prob <- 1 / as.numeric(singles$odds) -0.03

df = singles

simulateReturns <- function(df){
  df$selectionWon <- df$prob > runif(nrow(df))  
  df$simReturns <- ifelse(df$selectionWon, df$stakeGBP * df$odds, 0)
  
  return(sum(df$simReturns))
}


df= singles
df$odds <- as.numeric(df$odds)
df$returns[df$returns == "Lost"] = 0
df$returnsGBP <- as.numeric(str_remove_all(df$returns, "£"))

df$expvalue = df$stakeGBP * (df$odds * df$prob)
df$GW <- df$returnsGBP - df$stakeGBP

simResturnsLog <- c()
for(i in 1:40000){
  simResturnsLog <- c(simResturnsLog, simulateReturns(df))
}

simGW <- simResturnsLog - sum(df$stakeGBP)

summary(simGW)

mean(simGW >= sum(df$GW))

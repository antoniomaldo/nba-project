library(xml2)

xml2::read_xml('C:\\Users\\Antonio\\Documents\\NBA\\player-model\\nba-player-model-self-contained\\settledBets.xml')

library(XML)

xml   <- xmlInternalTreeParse('C:\\Users\\Antonio\\Documents\\NBA\\player-model\\nba-player-model-self-contained\\settledBets.xml')  # assumes your xml in variable xml.text

bets = xmlToList(xml)


df <- data.frame()
for(bet in bets){
  if(length(bet) == 3)
    df <- rbind(df, data.frame(
                        date = bet[[1]][[1]]$div$text,
                        stake = bet[[1]][[4]][[1]]$text,
                        selection = bet[[1]][[2]][[1]]$div$div$text,
                        #result = bet[[1]][[2]]$div,
                      #  marketName = bet[[2]][[1]][[1]]$div[[1]][2]$div$div$text,
                        odds = bet[[1]][[2]][[2]]$text,
                        returns = bet[[1]][[4]][[3]]$div$text
  ))
}

returns <- function(divsion){
  if(length(divsion[[1]][[2]]$div) == 2){
    return(divsion[[1]][[2]][2]$div$text)
  }else{
    return(divsion[[1]][[2]]$div) 
  }
}

df <- data.frame()
for(bet in bets){
  df <- rbind(df, data.frame(
    stake = bet[[1]][[1]][1]$div$div$text,
    selection = bet[[1]][[1]][2]$div$text,
    result = returns(bet)
  ))
}

df$stakeGBP = str_remove_all(df$stake, " Single")
> df$stakeGBP = str_remove_all(df$stakeGBP, "£")
> df$returnsGBP=ifelse(df$result == "Lost", 0, df$result)
> df$returnsGBP = str_remove_all(df$returnsGBP, "£")

sum(as.numeric(df$stakeGBP))
sum(as.numeric(df$returnsGBP))

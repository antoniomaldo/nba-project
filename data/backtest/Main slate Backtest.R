library(sqldf)
library(stringr)

mappedSlates <- do.call(rbind, lapply(list.files(path = "C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\2021\\", full.names = T  ), read.csv))
allContests <- do.call(rbind, lapply(list.files(path = "C:\\Users\\Antonio\\Documents\\NBA\\data\\fanduel\\contests\\2020_21", full.names = T  ), read.csv))


outputFiles <- list.files(path = "C:\\Users\\Antonio\\Documents\\NBA\\data\\backtest\\first", full.names = F)
outputFiles <- outputFiles[grepl("csv", outputFiles)]

allData <- data.frame()
for(file in outputFiles){
  
  csv <- read.csv(paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\backtest\\first\\", file))
  
  playersForSlate <- subset(mappedSlates[c("playerName", "points","fdPoints")], mappedSlates$slateId == str_remove(file, ".csv"))
  contests <- subset(allContests, allContests$slateId ==  str_remove(file, ".csv"))
  
  csv = sqldf("SELECT t1.*, 
                  t2.fdPoints as pg1Points, t2.points as pg1PointsExp,
                  t3.fdPoints as pg2Points, t3.points as pg2PointsExp,
                  t4.fdPoints as sg1Points, t4.points as sg1PointsExp ,
                  t5.fdPoints as sg2Points, t5.points as sg2PointsExp,
                  t6.fdPoints as sf1Points, t6.points as sf1PointsExp,
                  t7.fdPoints as sf2Points, t7.points as sf2PointsExp,
                  t8.fdPoints as pf1Points, t8.points as pf1PointsExp,
                  t9.fdPoints as pf2Points, t9.points as pf2PointsExp,
                  t10.fdPoints as cPoints, t10.points as cPointsExp
            FROM csv t1 
            LEFT JOIN playersForSlate t2 ON t1.PG1 = t2.playerName
            LEFT JOIN playersForSlate t3 ON t1.PG2 = t3.playerName
            LEFT JOIN playersForSlate t4 ON t1.SG1 = t4.playerName
            LEFT JOIN playersForSlate t5 ON t1.SG2 = t5.playerName
            LEFT JOIN playersForSlate t6 ON t1.SF1 = t6.playerName
            LEFT JOIN playersForSlate t7 ON t1.SF2 = t7.playerName
            LEFT JOIN playersForSlate t8 ON t1.PF1 = t8.playerName
            LEFT JOIN playersForSlate t9 ON t1.PF2 = t9.playerName
            LEFT JOIN playersForSlate t10 ON t1.C = t10.playerName

          ")
  
  csv <- csv[order(-1 * csv$overFourHundredProb),]
  
  csv$totalPoints <- csv$pg1Points + csv$pg2Points + csv$sg1Points + csv$sg2Points + csv$sf1Points + csv$sf2Points + csv$pf1Points + csv$pf2Points + csv$cPoints
  csv$totalPointsExp <- csv$pg1PointsExp + csv$pg2PointsExp + csv$sg1PointsExp + csv$sg2PointsExp + csv$sf1PointsExp + csv$sf2PointsExp + csv$pf1PointsExp + csv$pf2PointsExp + csv$cPointsExp
  
  print(max(csv$totalPoints[!is.na(csv$totalPoints)]))
  print(max(contests$Top_Score_Points))
  
  allData <- rbind(allData, csv)
  
}

allData <- subset(allData, !is.na(allData$totalPoints))

library(arm)

allData$overForty <- 1 * (allData$totalPoints >= 400)
allData$overFortyResid  <- allData$overFourHundredProb -  1 * (allData$totalPoints >= 400)
allData$overThreeSeventyFiveResid  <- allData$overThreeHundredSeventyFiveProb -  1 * (allData$totalPoints >= 375)
allData$overThreeFifty  <- allData$overThreeHundredFiftyProb -  1 * (allData$totalPoints >= 350)
allData$pointsResid <- allData$avg - allData$totalPoints
allData$pointsExpResid <- allData$totalPointsExp - allData$totalPoints

binnedplot(allData$overFourHundredProb, allData$overFortyResid)
binnedplot(allData$overThreeHundredSeventyFiveProb, allData$overThreeFifty)
binnedplot(allData$avg, allData$pointsResid)
binnedplot(allData$totalPointsExp, allData$pointsExpResid)


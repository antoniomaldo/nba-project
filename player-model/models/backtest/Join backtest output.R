library(stringr)
library(arm)

OUTPUT_CSV_LOCATION = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\backtest\\not_normalized\\"
outputCsvs <- list.files(OUTPUT_CSV_LOCATION, full.names = F)

allPlayers <- readRDS(file = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\allPlayersWithOdds.rds")
allPlayers$rowId = paste0(allPlayers$Team,"-",allPlayers$Name)
minPreds <- readRDS(file = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\minutePredictions.rds")

allPlayers <- merge(minPreds, allPlayers, by = c("GameId", "PlayerId"), all.x = T)


outputDf <- data.frame()

for(outputCsv in outputCsvs){
  gameId = str_remove(outputCsv, "Game")
  gameId = str_remove(gameId, ".csv")
  
  outputForId = read.csv(paste0(OUTPUT_CSV_LOCATION, outputCsv))
  outputForId$GameId = gameId
  outputDf <- rbind(outputDf, outputForId)
  
}

teamPoints <- aggregate(Points ~ GameId + Team, allPlayers, sum)
colnames(teamPoints)[3] <- "TeamTotalPoints"
allPlayers$pmin <- allPlayers$rotoMin
allData <- merge(outputDf, allPlayers[c("rowId", "seasonYear", "Name", "GameId", "Team", "Min.x", "Fg.Attempted", "Fg.Made", "Points", "Three.Attempted", "Three.Made", "FT.Made","FT.Attempted", "ownExpPoints", "oppExpPoints", "pmin", "played")], by = c("rowId", "GameId"))
allData <- merge(allData, teamPoints)

allData$fieldGoalAttempted <- allData$averageTwosAttempted + allData$averageThreesAttempted
allData$fieldGoalAttempted <- allData$fieldGoalAttempted * allData$playProb

allData$pointsResid <- allData$pointsAvg - allData$Points
allData$ftsResid <- allData$FT.Made - allData$averageFts
allData$ftsAttResid <- allData$FT.Attempted - allData$averageFtsAttempted
allData$threesResid <- allData$Three.Attempted - allData$averageThreesAttempted
allData$twosResid <- allData$Fg.Attempted - allData$Three.Attempted - allData$fieldGoalAttempted  + allData$averageThreesAttempted
allData$fgAttResid <- allData$Fg.Attempted - allData$fieldGoalAttempted
allData$twoMadeResid <- allData$Fg.Made - allData$Three.Made - allData$averageTwos
allData$threeMadeResid <- allData$Three.Made - allData$averageThrees

allData$propFg <- allData$pointsAvg / allData$fieldGoalAttempted

allData$fgResid <- allData$Fg.Attempted - allData$fieldGoalAttempted
allData$fgResidMult <- allData$fgMultiplier * allData$fieldGoalAttempted - allData$Fg.Attempted

allData$zeroFgResid <- allData$zeroFgProb - 1 * (allData$Fg.Attempted == 0)

allData$zeroFtResid <- allData$zeroFtProb - 1 * (allData$FT.Attempted == 0)

#allData$fieldGoalAttempted = allData$fieldGoalAttempted * allData$fgMultiplier
binnedplot(allData$pointsAvg, allData$pointsResid)
binnedplot(allData$pointsAvg, allData$ftsResid)
binnedplot(allData$pointsAvg, allData$ftsAttResid)
binnedplot(allData$pointsAvg, allData$threesResid)
binnedplot(allData$pointsAvg, allData$threeMadeResid)
binnedplot(allData$pointsAvg, allData$twoMadeResid)
binnedplot(allData$averageTwos, allData$twoMadeResid)

binnedplot(allData$pointsAvg, allData$twosResid)
binnedplot(allData$pointsAvg, allData$threesResid)
binnedplot(allData$pointsAvg, allData$ftsResid)

binnedplot(allData$pointsAvg, allData$fgAttResid)
binnedplot(allData$fieldGoalAttempted, allData$fgAttResid)
binnedplot(allData$fieldGoalAttempted, allData$fgResid)
binnedplot(allData$fieldGoalAttempted[allData$played == 1], allData$fgResid[allData$played == 1])

binnedplot(allData$fieldGoalAttempted, allData$ftsResid)
binnedplot(allData$fieldGoalAttempted, allData$ftsAttResid)

binnedplot(allData$zeroFgProb, allData$zeroFgResid)
binnedplot(allData$fieldGoalAttempted, allData$zeroFgResid2)

binnedplot(allData$zeroFtProb, allData$zeroFtResid)

binnedplot(allData$Points_0_Prob, allData$pointsResid)

binnedplot(allData$fieldGoalAttempted, allData$fgResid)
binnedplot(allData$fgMultiplier, allData$fgResid)
binnedplot(allData$fgMultiplier, allData$pointsResid)

binnedplot(allData$pointsAvg[allData$fgMultiplier > 0.02], allData$pointsResid[allData$fgMultiplier > 0.02])
binnedplot(allData$pointsAvg[allData$fgMultiplier > 0.02], allData$threeMadeResid[allData$fgMultiplier > 0.02])
binnedplot(allData$pointsAvg[allData$fgMultiplier < 0], allData$threeMadeResid[allData$fgMultiplier < 0])
binnedplot(allData$pointsAvg[allData$fgMultiplier < -0.01], allData$threeMadeResid[allData$fgMultiplier < -0.01])

binnedplot(allData$pointsAvg[allData$fgMultiplier < -0.001], allData$pointsResid[allData$fgMultiplier < -0.001])
binnedplot(allData$pointsAvg[allData$fgMultiplier < -0.0015], allData$pointsResid[allData$fgMultiplier < -0.0015])
binnedplot(allData$pointsAvg[allData$fgMultiplier < -0.0015], allData$twoMadeResid[allData$fgMultiplier < -0.0015])
binnedplot(allData$pointsAvg[allData$fgMultiplier < -0.0015], allData$threeMadeResid[allData$fgMultiplier < -0.0015])

binnedplot(allData$pointsAvg[allData$fgMultiplier > 0.005], allData$pointsResid[allData$fgMultiplier > 0.005])
binnedplot(allData$pointsAvg[allData$fgMultiplier > 0.001], allData$pointsResid[allData$fgMultiplier > 0.001])

binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier < -0.05], allData$ftsAttResid[allData$fgMultiplier < -0.05])

binnedplot(allData$pointsAvg[allData$fgMultiplier > 0.01], allData$pointsResid[allData$fgMultiplier > 0.01])
binnedplot(allData$pointsAvg[allData$fgMultiplier > 0.05], allData$pointsResid[allData$fgMultiplier > 0.05])

binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier < -0.02], allData$threeMadeResid[allData$fgMultiplier < -0.02])
binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier < -0.02], allData$twoMadeResid[allData$fgMultiplier < -0.02])
binnedplot(allData$pointsAvg[allData$fgMultiplier < -0.02], allData$pointsResid[allData$fgMultiplier < -0.02])
binnedplot(allData$pointsAvg[allData$fgMultiplier < -0.02], allData$ftsResid[allData$fgMultiplier < -0.02])

binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 2], allData$threeMadeResid[allData$pointsDiff > 2])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 2], allData$twoMadeResid[allData$pointsDiff > 2])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 2], allData$ftsResid[allData$pointsDiff > 2])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 5], allData$fgResid[allData$pointsDiff > 5])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff < -5], allData$fgResid[allData$pointsDiff < -5])
binnedplot(allData$pointsAvg[allData$pointsDiff > 5], allData$pointsResid[allData$pointsDiff > 5])

binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier > 0.02], allData$threeMadeResid[allData$fgMultiplier > 0.02])
binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier > 0.02], allData$twoMadeResid[allData$fgMultiplier > 0.02])

binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier < -0.02], allData$fgResid[allData$fgMultiplier < -0.02])
binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier < -0.02], allData$threeMadeResid[allData$fgMultiplier < -0.02])
binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier < -0.02], allData$threesResid[allData$fgMultiplier < -0.02])
binnedplot(allData$propFg[allData$fgMultiplier < -0.02], allData$threeMadeResid[allData$fgMultiplier < -0.02])
binnedplot(allData$pointsAvg[allData$fgMultiplier < -0.02], allData$pointsResid[allData$fgMultiplier < -0.02])

binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier < -0.04], allData$fgResid[allData$fgMultiplier < -0.04])
binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier < -0.04], allData$threeMadeResid[allData$fgMultiplier < -0.04])
binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier < -0.04], allData$threesResid[allData$fgMultiplier < -0.04])

binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier > 80], allData$fgResid[allData$fgMultiplier > 80])
binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier > 88], allData$fgResid[allData$fgMultiplier > 88])

binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier > 1.1] * allData$fgMultiplier[allData$fgMultiplier > 1.1], allData$fgResid[allData$fgMultiplier > 1.1])
binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier > 1.1] * allData$fgMultiplier[allData$fgMultiplier > 1.1], allData$fgResidMult[allData$fgMultiplier > 1.1])
binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier > 1.2] * allData$fgMultiplier[allData$fgMultiplier > 1.2], allData$fgResidMult[allData$fgMultiplier > 1.2])
binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier < 0.9] * allData$fgMultiplier[allData$fgMultiplier < 0.9], allData$fgResidMult[allData$fgMultiplier < 0.9])
binnedplot(allData$fieldGoalAttempted[abs(allData$fgMultiplier - 1) <= 0.1] * allData$fgMultiplier[abs(allData$fgMultiplier - 1) <= 0.1], allData$fgResidMult[abs(allData$fgMultiplier - 1) <= 0.1])

#Per game

agg <- aggregate(pointsAvg ~ GameId + Team, allData, sum)
agg <- merge(agg, aggregate(ownExpPoints ~ GameId + Team, allData, mean))
agg <- merge(agg, aggregate(Fg.Attempted ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(fieldGoalAttempted ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(rowId ~ GameId + Team, allData, length))
agg <- merge(agg, aggregate(TeamTotalPoints ~ GameId + Team, allData, mean))
agg <- merge(agg, aggregate(Points ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(pmin ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(fgMultiplier ~ GameId + Team, allData, mean))
agg <- merge(agg, aggregate(seasonYear ~ GameId + Team, allData, mean))
agg <- merge(agg, aggregate(averageFts ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(FT.Made ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(Three.Made ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(averageThreesAttempted ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(averageThrees ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(averageTwos ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(Fg.Made ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(Three.Attempted ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(averageTwosAttempted ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(Points ~ GameId + Team, allData, sum))
agg <- merge(agg, aggregate(oppExpPoints ~ GameId + Team, allData, mean))
agg <- merge(agg, aggregate(averageFtsAttempted ~ GameId + Team, allData, sum))

agg <- merge(agg, aggregate(FT.Attempted ~ GameId + Team, allData, sum))
agg <- subset(agg, agg$pmin == 240)

colnames(agg)[6] <- "Total.Fg.Attempted"
colnames(agg)[8] <- "TotalPlayers"
colnames(agg)[10] <- "TeamTotalPointsNoNaPmin"

agg$missingPoints <- agg$TeamTotalPoints - agg$TeamTotalPointsNoNaPmin
agg$missingPointsExp <- agg$ownExpPoints - agg$pointsAvg
agg$ftsResid <- agg$FT.Made - agg$averageFts
agg$ftsAttResid <- agg$FT.Attempted - agg$averageFtsAttempted

agg$expDiff <- abs(agg$ownExpPoints - agg$oppExpPoints)
  
agg$pointsDiff <- agg$pointsAvg - agg$ownExpPoints
agg$pointsResid <- agg$pointsAvg - agg$Points

agg$fgDiff <- agg$Total.Fg.Attempted - agg$fieldGoalAttempted
agg$threeDiff <- agg$Three.Made - agg$averageThrees
agg$twoDiff <- agg$Fg.Made - agg$Three.Made - agg$averageTwos
agg$threeAttDiff <- agg$Three.Attempted - agg$averageThreesAttempted
agg$twoAttDiff <- agg$Total.Fg.Attempted - agg$Three.Attempted - agg$averageTwosAttempted

allData <- merge(allData, agg[c("GameId", "Team", "pointsDiff", "fgDiff")], by = c("GameId", "Team"))

allData$sixResid = allData$Points_6_Prob - 1 * (allData$Points == 6)
allData$underSixPointFiveProb = allData$Points_0_Prob + allData$Points_1_Prob + allData$Points_2_Prob + allData$Points_3_Prob + allData$Points_4_Prob + allData$Points_5_Prob + allData$Points_6_Prob
allData$underSixPointFiveResid = allData$underSixPointFiveProb - 1 * (allData$Points < 6.5)


binnedplot(agg$fgMultiplier, agg$fgDiff)
binnedplot(agg$fgMultiplier, agg$ftsResid)
binnedplot(agg$fg, agg$fgDiff)
binnedplot(agg$fgMultiplier, agg$ftsResid)
binnedplot(agg$averageFts, agg$ftsResid)

binnedplot(agg$averageThrees, agg$threeDiff)
binnedplot(agg$averageTwos, agg$twoDiff)

binnedplot(agg$fgMultiplier, agg$threeDiff)
binnedplot(agg$fgMultiplier, agg$twoDiff)
binnedplot(agg$fgMultiplier, agg$fgDiff)
binnedplot(agg$fgMultiplier, agg$threeAttDiff)
binnedplot(agg$fgMultiplier, agg$twoAttDiff)
binnedplot(agg$fgMultiplier, agg$pointsDiff)
binnedplot(agg$pointsAvg, agg$pointsDiff)
binnedplot(agg$pointsAvg, agg$pointsResid)
binnedplot(agg$pointsAvg[agg$pointsDiff < 10], agg$pointsResid[agg$pointsDiff < 10])

binnedplot(agg$ownExpPoints, agg$pointsDiff)
binnedplot(agg$ownExpPoints, agg$expDiff)


##
allData <- merge(allData, agg)

binnedplot(allData$fieldGoalAttempted, allData$fgResid)
binnedplot(allData$fieldGoalAttempted * allData$fgMultiplier, allData$fgResid)

binnedplot(allData$pointsAvg, allData$pointsResid)
binnedplot(allData$pointsAvg[allData$pointsDiff > 0], allData$pointsResid[allData$pointsDiff > 0])
binnedplot(allData$pointsAvg[allData$pointsDiff < -10], allData$pointsResid[allData$pointsDiff < -10])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff < -7], allData$twoMadeResid[allData$pointsDiff < -7])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff < -7], allData$threeMadeResid[allData$pointsDiff < -7])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff < -7], allData$fgResid[allData$pointsDiff < -7])

binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 5], allData$pointsResid[allData$pointsDiff > 5])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 5], allData$twoMadeResid[allData$pointsDiff > 5])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 5], allData$threeMadeResid[allData$pointsDiff > 5])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 5], allData$fgResid[allData$pointsDiff > 5])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 5], allData$ftsResid[allData$pointsDiff > 5])

binnedplot(allData$averageTwos[allData$pointsDiff < -7], allData$twoMadeResid[allData$pointsDiff < -7])
binnedplot(allData$averageThrees[allData$pointsDiff < -7], allData$threeMadeResid[allData$pointsDiff < -7])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff < -7], allData$ftsResid[allData$pointsDiff < -7])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff < -7], allData$fgResid[allData$pointsDiff < -7])

binnedplot(allData$pointsAvg[allData$fgMultiplier > 0.0051], allData$pointsResid[allData$fgMultiplier > 0.0051])
binnedplot(allData$pointsAvg[allData$fgMultiplier < -0.003], allData$pointsResid[allData$fgMultiplier < -0.03])
binnedplot(allData$pointsAvg[allData$fgMultiplier < -0.05], allData$pointsResid[allData$fgMultiplier < -0.05])

binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier > 1.03], allData$pointsResid[allData$fgMultiplier > 1.03])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 1], allData$pointsResid[allData$pointsDiff > 1])

binnedplot(allData$pointsAvg[allData$fgMultiplier < 0.97], allData$pointsResid[allData$fgMultiplier < 0.97])

binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 10], allData$pointsResid[allData$pointsDiff > 10])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff < -5], allData$pointsResid[allData$pointsDiff < -5])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff < -10], allData$pointsResid[allData$pointsDiff < -10])
binnedplot(allData$fieldGoalAttempted[allData$pointsDiff < -10], allData$fgResid[allData$pointsDiff < -10])

binnedplot(allData$pointsAvg[allData$pointsAvg > 25], allData$pointsResid[allData$pointsAvg > 25])
binnedplot(allData$pointsAvg[allData$pointsAvg > 20], allData$pointsResid[allData$pointsAvg > 20])
binnedplot(allData$pointsAvg[allData$pointsAvg < 10], allData$pointsResid[allData$pointsAvg < 10])

binnedplot(allData$fgMultiplier, allData$pointsResid)

binnedplot(allData$pointsAvg, allData$sixResid)
binnedplot(allData$fieldGoalAttempted, allData$underSixPointFiveResid)

binnedplot(allData$fieldGoalAttempted[allData$fgMultiplier > 1.1], allData$fgResid[allData$fgMultiplier > 1.1])


binnedplot(allData$fieldGoalAttempted[allData$pointsDiff > 2], allData$pointsDiff[allData$pointsDiff > 2])
binnedplot(allData$fieldGoalAttempted[abs(allData$pointsDiff) <= 1], allData$pointsDiff[abs(allData$pointsDiff) <= 1])
binnedplot(allData$pointsAvg[abs(allData$pointsDiff) <= 1], allData$pointsDiff[abs(allData$pointsDiff) <= 1])

binnedplot(allData$fieldGoalAttempted[abs(allData$pointsDiff - 0) <= 3], allData$fgResid[abs(allData$pointsDiff - 0) <= 3])
binnedplot(allData$fieldGoalAttempted[abs(allData$pointsDiff - 5) <= 2], allData$fgResid[abs(allData$pointsDiff - 5) <= 2])
binnedplot(allData$fieldGoalAttempted[abs(allData$pointsDiff - 10) <= 3], allData$fgResid[abs(allData$pointsDiff - 10) <= 3])
binnedplot(allData$fieldGoalAttempted[abs(allData$pointsDiff + 10) <= 3], allData$fgResid[abs(allData$pointsDiff + 10) <= 3])


#threes


allData$overOneThree <- 1 - allData$Threes_0_Prob - allData$Threes_1_Prob
allData$overTwoThree <- 1 - allData$Threes_0_Prob - allData$Threes_1_Prob - allData$Threes_2_Prob

allData$overOneThreeResid <- allData$overOneThree - 1 * (allData$Three.Made > 1)
allData$overTwoThreeResid <- allData$overTwoThree - 1 * (allData$Three.Made > 2)


allData$overSixPoints = 1 - allData$Points_0_Prob - allData$Points_1_Prob - allData$Points_2_Prob - allData$Points_3_Prob - allData$Points_4_Prob - allData$Points_5_Prob - allData$Points_6_Prob
allData$overEightPoints = 1 - allData$Points_0_Prob - allData$Points_1_Prob - allData$Points_2_Prob - allData$Points_3_Prob - allData$Points_4_Prob - allData$Points_5_Prob - allData$Points_6_Prob - allData$Points_7_Prob - allData$Points_8_Prob

allData$overSixResid <- allData$overSixPoints - 1 * (allData$Points > 6)
allData$overEightResid <- allData$overEightPoints - 1 * (allData$Points > 8)

binnedplot(allData$overOneThree, allData$overOneThreeResid)
binnedplot(allData$pointsAvg, allData$overTwoThreeResid)
binnedplot(allData$fgMultiplier, allData$overTwoThreeResid)


#
binnedplot(allData$Points_0_Prob, allData$Points_0_Prob - (1 * allData$Points == 0))
binnedplot(allData$fgMultiplier, allData$Points_0_Prob - (1 * allData$Points == 0))

binnedplot(allData$Points_2_Prob, allData$Points_2_Prob - (1 * allData$Points == 2))

binnedplot(allData$Points_9_Prob, allData$Points_9_Prob - (1 * allData$Points == 9))
binnedplot(allData$Points_8_Prob, allData$Points_8_Prob - (1 * allData$Points == 8))

binnedplot(allData$overSixPoints, allData$overSixResid)
binnedplot(allData$overSixPoints[allData$fgMultiplier < -0.02], allData$overSixResid[allData$fgMultiplier < -0.02])
binnedplot(allData$overSixPoints[allData$fgMultiplier > 0.01], allData$overSixResid[allData$fgMultiplier > 0.01])

binnedplot(allData$overEightPoints, allData$overEightResid)


##

binnedplot(allData$pointsAvg[allData$seasonYear >= 2020], allData$pointsResid[allData$seasonYear >= 2020])
binnedplot(allData$pointsAvg[allData$seasonYear >= 2020], allData$overOneThreeResid[allData$seasonYear >= 2020])
binnedplot(allData$pointsAvg[allData$seasonYear >= 2020], allData$overTwoThreeResid[allData$seasonYear >= 2020])

binnedplot(allData$pointsAvg[allData$seasonYear >= 2020], allData$pointsResid[allData$seasonYear >= 2020])
binnedplot(allData$pointsAvg[allData$Name == "L. James"], allData$pointsResid[allData$Name == "L. James"])
binnedplot(allData$pointsAvg[allData$Name == "K. Durant"], allData$pointsResid[allData$Name == "K. Durant"])

binnedplot(allData$overTwoThree[allData$Name == "L. James"], allData$overTwoThreeResid[allData$Name == "L. James"])
binnedplot(allData$overTwoThree[allData$Name == "K. Durant"], allData$overTwoThreeResid[allData$Name == "K. Durant"])
binnedplot(allData$overTwoThree[allData$Name == "S. Curry" & allData$Team == "GS"], allData$overTwoThreeResid[allData$Name == "S. Curry" & allData$Team == "GS"])
binnedplot(allData$overTwoThree[allData$seasonYear >= 2020 & allData$Name == "K. Thompson"], allData$overTwoThreeResid[allData$seasonYear >= 2020 & allData$Name == "K. Thompson"])



#### modle adjusted field goal 
# Points re distribution

trainData <- subset(allData, allData$seasonYear <= 2020)
testData <- subset(allData, allData$seasonYear < 2020)

trainData$propResid <- trainData$Fg.Attempted / trainData$fieldGoalAttempted - 1

binnedplot(trainData$fieldGoalAttempted, trainData$propResid)
binnedplot(trainData$fieldGoalAttempted[trainData$pointsDiff > 5], trainData$propResid[trainData$pointsDiff > 5])
binnedplot(trainData$fieldGoalAttempted[trainData$pointsDiff > 0], trainData$propResid[trainData$pointsDiff > 0])

binnedplot(trainData$fieldGoalAttempted[trainData$pointsDiff < -5], trainData$propResid[trainData$pointsDiff < -5])
binnedplot(trainData$fieldGoalAttempted[trainData$pointsDiff < -1], trainData$fgResid[trainData$pointsDiff < -1])

model <- lm(propResid ~ -1 +
              #pointsDiff +
              pmax(0, pointsDiff) : pmax(0, 10 - fieldGoalAttempted) + 
              pmin(0, pointsDiff) : pmax(0, 10 - fieldGoalAttempted)
            , data = trainData)

summary(model)

testData$propResidModel <- predict(model, testData)


testData$newFieldGoalAttempted = testData$fieldGoalAttempted * (testData$propResidModel + 1)
summary(testData$newFieldGoalAttempted)
testData$fgResid2 = testData$newFieldGoalAttempted - testData$Fg.Attempted
binnedplot(testData$newFieldGoalAttempted[testData$pointsDiff > 5], testData$fgResid2[testData$pointsDiff > 5])
binnedplot(testData$newFieldGoalAttempted[testData$pointsDiff < -5], testData$fgResid2[testData$pointsDiff < -5])
binnedplot(testData$newFieldGoalAttempted[testData$pointsDiff > 0], testData$fgResid2[testData$pointsDiff > 0])
binnedplot(testData$newFieldGoalAttempted[testData$pointsDiff < 0], testData$fgResid2[testData$pointsDiff < 0])

agg <- aggregate(newFieldGoalAttempted ~ GameId + Team , testData, sum)
agg <- merge(agg, aggregate(Fg.Attempted ~ GameId + Team, testData, sum))
agg <- merge(agg, aggregate(pointsDiff ~ GameId + Team, testData, mean))

agg$resid <- agg$newFieldGoalAttempted - agg$Fg.Attempted
binnedplot(agg$newFieldGoalAttempted, agg$resid)
binnedplot(agg$pointsDiff, agg$resid)

allData$propExp <- allData$playerDiff / allData$pointsAvg

View(allData[c("GameId", "pointsAvg", )])



test <- subset(modelData, modelData$GameId %in% ids & !is.na(modelData$twoPerc))


test$predictionsGBM <- as.vector(h2o.predict(modelGBM, as.h2o(test)))
test$residGBM <- test$twoPerc - test$predictionsGBM

summary(test$predictionsGBM)
summary(test$residGBM)

plotResiduals(test$residGBM, test)
binnedplot(test$predictionsGBM, test$residGBM)

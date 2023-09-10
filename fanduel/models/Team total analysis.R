allPlayers$fdZeroPointsPred <- as.vector(h2o.predict(modelZeroPoints, as.h2o(allPlayers))$p1)
allPlayers$fdPointsPred <- as.vector(h2o.predict(modelGBMPred, as.h2o(allPlayers)))

allPlayers$finalPred <- (1 - allPlayers$fdZeroPointsPred) * allPlayers$fdPointsPred


agg <- aggregate(pmin ~ gameid + team, allPlayers, sum)
agg <- merge(agg, aggregate(finalPred ~ gameid + team, allPlayers, sum), by = c("gameid", "team"))
agg <- merge(agg, aggregate(fdPoints ~ gameid + team, allPlayers, sum), by = c("gameid", "team"))
agg <- merge(agg, aggregate(ownExpPoints ~ gameid + team, allPlayers, max), by = c("gameid", "team"))
agg <- merge(agg, aggregate(oppExpPoints ~ gameid + team, allPlayers, max), by = c("gameid", "team"))

colnames(agg) <- c("gameid", "team", "totalTeamPmin", "totalTeamPredPoints", "totalFdTeamPoints", "ownExpPoints", "oppExpPoints")

agg <- subset(agg, abs(agg$totalTeamPmin - 240) < 5)


agg$resid <- agg$totalTeamPredPoints - agg$totalFdTeamPoints

binnedplot(agg$totalTeamPmin, agg$resid)

binnedplot(agg$ownExpPoints, agg$resid)
binnedplot(agg$oppExpPoints, agg$resid)
binnedplot(agg$ownExpPoints - agg$oppExpPoints, agg$resid)


allPlayers <- merge(allPlayers, agg, by = c("gameid", "team"))


allPlayers <- subset(allPlayers, abs(allPlayers$totalTeamPmin - 240) < 5)


allPlayers$resid <- allPlayers$totalFdTeamPoints - allPlayers$totalTeamPoints



binnedplot(agg$totalTeamPoints, agg$resid)


binnedplot(allPlayers$totalTeamPmin, allPlayers$op)


allPlayers$pointsCeilDistance = allPlayers$ceil - allPlayers$points
allPlayers$homeExpPoints <- (allPlayers$totalpoints - allPlayers$matchspread) / 2
allPlayers$awayExpPoints <- allPlayers$totalpoints - allPlayers$homeExpPoints
allPlayers$ownExpPoints <- ifelse(allPlayers$ishomeplayer, allPlayers$homeExpPoints, allPlayers$awayExpPoints)
allPlayers$oppExpPoints <- ifelse(!allPlayers$ishomeplayer, allPlayers$homeExpPoints, allPlayers$awayExpPoints)
allPlayers$expPointsDiff <- allPlayers$ownExpPoints - allPlayers$oppExpPoints

binnedplot(allPlayers$totalTeamPmin, allPlayers$ownExpPoints)

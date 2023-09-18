library(arm)
source("C:\\Users\\Antonio\\Documents\\NBA\\data\\mappings\\mappings-service.R")

minPreds <- mapMinutesForSeasonForRotowire(2021)
minPreds <- rbind(minPreds,mapMinutesForSeasonForRotowire(2022))
minPreds <- rbind(minPreds,mapMinutesForSeasonForRotowire(2023))

minPreds$PTS <- as.numeric(minPreds$PTS)

summary(minPreds$PTS)

minPreds <- subset(minPreds, !is.na(minPreds$PTS))

minPreds$resid <- minPreds$Points - minPreds$PTS

binnedplot(minPreds$PTS, minPreds$resid)

View(minPreds[c("Name", "Points", "PTS", "MIN")])

bx = getMatchesForYear(2021)
bx = rbind(bx, getMatchesForYear(2022))
bx = rbind(bx, getMatchesForYear(2023))

oddsToBx <- mapSbrDataToEspn(bx)

merged <- merge(minPreds, oddsToBx, by = "GameId", all.x = T)
merged <- subset(merged, !is.na(merged$matchSpread))

merged$homeExp <- (merged$totalPoints - merged$matchSpread) / 2
merged$awayExp <- (merged$totalPoints + merged$matchSpread) / 2

merged$ownExp <- ifelse(merged$Team == merged$HomeTeam, merged$homeExp, merged$awayExp)
merged$oppExp <- ifelse(merged$Team != merged$HomeTeam, merged$homeExp, merged$awayExp)

merged$expDiff <- abs(merged$ownExp - merged$oppExp)

library(arm)

binnedplot(merged$PTS[merged$seasonYear == 2021], merged$resid[merged$seasonYear == 2021])
binnedplot(merged$PTS[merged$seasonYear == 2022], merged$resid[merged$seasonYear == 2022])
binnedplot(merged$PTS[merged$seasonYear == 2023], merged$resid[merged$seasonYear == 2023])

binnedplot(merged$PTS[!is.na(merged$ownExp) & merged$ownExp >  114], merged$resid[!is.na(merged$ownExp) & merged$ownExp >  114])
binnedplot(merged$PTS[!is.na(merged$ownExp) & merged$ownExp <  114], merged$resid[!is.na(merged$ownExp) & merged$ownExp <  114])


aggPoints <- aggregate(PTS ~ GameId + Team, merged, sum)
aggPoints <- merge(aggPoints, aggregate(Points ~ GameId + Team, merged, sum))
aggPoints <- merge(aggPoints, aggregate(ownExp ~ GameId + Team, merged, mean))

aggPoints$resid <- aggPoints$Points - aggPoints$PTS

binnedplot(aggPoints$PTS, aggPoints$resid)


merged$predFdPoints <- as.numeric(merged$PTS) + 
                       as.numeric(merged$REB) * 1.2 + 
                       as.numeric(merged$AST) * 1.5 + 
                       as.numeric(merged$STL) * 3 + 
                       as.numeric(merged$BLK) * 3 - 
                       as.numeric(merged$TO) 

summary(merged$predFdPoints)
summary(merged$fdPoints)

merged$fdPointsResid <- merged$fdPoints - merged$predFdPoints

binnedplot(merged$predFdPoints, merged$fdPointsResid)
binnedplot(merged$predFdPoints[merged$seasonYear == 2021], merged$fdPointsResid[merged$seasonYear == 2021])
binnedplot(merged$predFdPoints[merged$seasonYear == 2022], merged$fdPointsResid[merged$seasonYear == 2022])
binnedplot(merged$predFdPoints[merged$seasonYear == 2023], merged$fdPointsResid[merged$seasonYear == 2023])


aggPoints <- aggregate(predFdPoints ~ GameId + Team + seasonYear, merged, sum)
aggPoints <- merge(aggPoints, aggregate(fdPoints ~ GameId + Team+ seasonYear, merged, sum))
aggPoints <- merge(aggPoints, aggregate(ownExp ~ GameId + Team+ seasonYear, merged, mean))
aggPoints$fdPointsResid <- aggPoints$fdPoints - aggPoints$predFdPoints

binnedplot(aggPoints$predFdPoints[aggPoints$seasonYear == 2021], aggPoints$fdPointsResid[aggPoints$seasonYear == 2021])
binnedplot(aggPoints$predFdPoints[aggPoints$seasonYear == 2022], aggPoints$fdPointsResid[aggPoints$seasonYear == 2022])
binnedplot(aggPoints$predFdPoints[aggPoints$seasonYear == 2023], aggPoints$fdPointsResid[aggPoints$seasonYear == 2023])


library(splines)

merged <- subset(merged, !is.na(merged$ownExp))
model <- lm(fdPoints ~ ownExp*predFdPoints + bs(predFdPoints, knots = c(-2, 0, 10), B = c(-2, 71)), data = merged)
summary(model)

merged$modelPred <- predict(model, merged)

merged$modelResid <- merged$fdPoints - merged$modelPred
merged$diff <- abs(merged$predFdPoints - merged$modelPred)

binnedplot(merged$modelPred, merged$modelResid)
binnedplot(merged$modelPred[aggPoints$seasonYear == 2021], merged$modelResid[aggPoints$seasonYear == 2021])
binnedplot(merged$modelPred[aggPoints$seasonYear == 2022], merged$modelResid[aggPoints$seasonYear == 2022])
binnedplot(merged$modelPred[aggPoints$seasonYear == 2023], merged$modelResid[aggPoints$seasonYear == 2023])
binnedplot(merged$ownExp[merged$seasonYear == 2021], merged$modelResid[merged$seasonYear == 2021])
binnedplot(merged$ownExp[merged$seasonYear == 2022], merged$modelResid[merged$seasonYear == 2022])
binnedplot(merged$ownExp[merged$seasonYear == 2023], merged$modelResid[merged$seasonYear == 2023])

binnedplot(merged$ownExp[merged$modelPred > 40], merged$modelResid[merged$modelPred > 40])
binnedplot(merged$ownExp[abs(merged$modelPred - 40) <= 5], merged$modelResid[abs(merged$modelPred - 40) <= 5])

binnedplot(merged$diff[merged$seasonYear == 2023], merged$modelResid[merged$seasonYear == 2023])

View(merged[merged$PTS > 0, c("Name", "predFdPoints", "modelPred", "fdPoints", "diff")])

aggPoints <- aggregate(modelPred ~ GameId + Team + seasonYear, merged, sum)
aggPoints <- merge(aggPoints, aggregate(fdPoints ~ GameId + Team+ seasonYear, merged, sum))
aggPoints <- merge(aggPoints, aggregate(ownExp ~ GameId + Team+ seasonYear, merged, mean))
aggPoints$fdPointsResid <- aggPoints$fdPoints - aggPoints$modelPred

binnedplot(aggPoints$modelPred[aggPoints$seasonYear == 2021], aggPoints$fdPointsResid[aggPoints$seasonYear == 2021])
binnedplot(aggPoints$modelPred[aggPoints$seasonYear == 2023], aggPoints$fdPointsResid[aggPoints$seasonYear == 2023])

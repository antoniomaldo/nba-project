library(arm)

source("C:\\Users\\Antonio\\Documents\\NBA\\data\\mappings\\mappings-service.R")

rotoWirePreds <- mapMinutesForSeasonForRotowire(seasonYear = 2023)
rotoGrindersPreds <- mapMinutesForSeasonForRotogrinders(seasonYear = 2023)

mean(is.na(rotoWirePreds$pmin))
mean(is.na(rotoGrindersPreds$pmin))


rotoMin <- aggregate(Min ~ GameId, rotoWirePreds, sum)
grinderMin <- aggregate(Min ~ GameId, rotoGrindersPreds, sum)

rotoWirePreds$wirePred <- as.numeric(rotoWirePreds$pmin)
rotoGrindersPreds$grinderPred <- as.numeric(rotoGrindersPreds$pmin)

subsetRotoWire <- subset(rotoWirePreds, rotoWirePreds$GameId %in% rotoGrindersPreds$GameId)

merged <- merge(rotoGrindersPreds[c("playerName", "PlayerId", "GameId", "grinderPred", "Min")],
                subsetRotoWire[c("playerName", "PlayerId", "GameId", "wirePred")], 
                 
                by = c("playerName", "PlayerId", "GameId"), all = T)

mergedMin <- aggregate(Min ~ GameId, merged, sum)


merged <- subset(merged, !is.na(merged$grinderPred) | !is.na(merged$wirePred))


#roto wire

rotoWirePredsGivenPred <- subset(rotoWirePreds, !is.na(rotoWirePreds$wirePred))
rotoWirePredsGivenPred <- subset(rotoWirePredsGivenPred, rotoWirePredsGivenPred$Min > 0)

rotoWirePredsGivenPred$resid <- rotoWirePredsGivenPred$wirePred - rotoWirePredsGivenPred$Min

binnedplot(rotoWirePredsGivenPred$wirePred, rotoWirePredsGivenPred$resid)

sumPreds <- aggregate(wirePred ~ GameId, rotoWirePredsGivenPred, sum)
sumPredsGrinders <- aggregate(grinderPred ~ GameId, rotoGrindersPreds, sum)

summary(merged$Min[is.na(merged$grinderPred)] )

View(subset(merged, is.na(merged$grinderPred)))

allData$pmin <- as.numeric(allData$pmin)
allData$pmin[is.na(allData$pmin)] <- 0

allData$resid <- allData$Min - allData$pmin

binnedplot(allData$pmin, allData$resid)

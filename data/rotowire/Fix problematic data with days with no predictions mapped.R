allRotoData2 <- merge(allRotoData, allPlayers[c("GameId", "date", "PlayerId", "Min", "Team", "Fg.Attempted", "Points")], by = c("date", "PlayerId"), all.x = T)

a = aggregate(Min ~ GameId, allRotoData2, sum)


allRotoData2$rotoMinPred <- as.numeric(allRotoData2$MIN)
allRotoData2$Min[is.na(allRotoData2$Min)] <- 0

allRotoData2$minResid <- allRotoData2$rotoMinPred - allRotoData2$Min

summary(allRotoData2$minResid)

hist(allRotoData2$minResid)

binnedplot(allRotoData2$rotoMinPred, allRotoData2$minResid)


binnedplot(allRotoData2$rotoMinPred[allRotoData2$date > '2022-05-05'], 
           allRotoData2$minResid[allRotoData2$date > '2022-05-05'])


allRotoData2$noPlay <- 1 * (allRotoData2$Min == 0)
summary(allRotoData2$rotoMinPred[allRotoData2$noPlay == 1])
summary(allRotoData2$rotoMinPred[allRotoData2$noPlay == 0])

View(subset(allRotoData2, allRotoData2$noPlay == 1))

##Problematic dates

allRotoData2$isNaGameId <- 1 * is.na(allRotoData2$GameId)
naDatesPerc <- aggregate(isNaGameId ~ date, 
                         allRotoData2, FUN = function(x){mean(x)})


#split mapped
mapped <- subset(allRotoData2, allRotoData2$isNaGameId == 0)
nonMapped <- subset(allRotoData2, allRotoData2$isNaGameId == 1)

#Try to map a day earlier

nonMapped$yesterday <- as.Date(nonMapped$date)-1
nonMapped$date <- as.character(nonMapped$yesterday)

nonMapped <- merge(nonMapped[c("PlayerId", "date", "Name", "MIN")], allPlayers[c("GameId", "PlayerId", "date")], all.x = T, by = c("date", "PlayerId"))

nonMapped <- subset(nonMapped, nonMapped$date < '2020-03-11' | nonMapped$date > '2020-07-29')

nonZeroPreds <- subset(nonMapped, nonMapped$MIN>0)
mean(is.na(nonZeroPreds$GameId))

nonZeroPreds$naGameId <- is.na(nonZeroPreds$GameId)

n <- aggregate(naGameId ~ date, nonZeroPreds, mean)



source("C:\\Users\\Antonio\\Documents\\nba-project\\data\\mappings\\mappings-service.R")

boxscores <-  getPlayersForYear(2018)
boxscores <- rbind(boxscores, getPlayersForYear(2019))
boxscores <- rbind(boxscores, getPlayersForYear(2020))
boxscores <- rbind(boxscores, getPlayersForYear(2021))
boxscores <- rbind(boxscores, getPlayersForYear(2022))
boxscores <- rbind(boxscores, getPlayersForYear(2023))

minPredsRotowire <- mapMinutesForSeasonForRotowire(2019)
minPredsRotowire <- rbind(minPredsRotowire,mapMinutesForSeasonForRotowire(2020))
minPredsRotowire <- rbind(minPredsRotowire,mapMinutesForSeasonForRotowire(2021))
minPredsRotowire <- rbind(minPredsRotowire,mapMinutesForSeasonForRotowire(2022))
minPredsRotowire <- rbind(minPredsRotowire,mapMinutesForSeasonForRotowire(2023))

minPredsGrinders <- mapMinutesForSeasonForRotogrinders(2018)
minPredsGrinders <- rbind(minPredsGrinders,mapMinutesForSeasonForRotogrinders(2019))
minPredsGrinders <- rbind(minPredsGrinders,mapMinutesForSeasonForRotogrinders(2020))
minPredsGrinders <- rbind(minPredsGrinders,mapMinutesForSeasonForRotogrinders(2020))
minPredsGrinders <- rbind(minPredsGrinders,mapMinutesForSeasonForRotogrinders(2021))
minPredsGrinders <- rbind(minPredsGrinders,mapMinutesForSeasonForRotogrinders(2022))
minPredsGrinders <- rbind(minPredsGrinders,mapMinutesForSeasonForRotogrinders(2023))

minPredsRotowire <- unique(minPredsRotowire[c("GameId", "PlayerId", "MIN")])
colnames(minPredsRotowire)[3] <- "rotoMin"
minPredsRotowire$rotoMin <- as.numeric(minPredsRotowire$rotoMin)

minPredsGrinders <- unique(minPredsGrinders[c("GameId", "PlayerId", "pmin")])
colnames(minPredsGrinders)[3] <- "grindersMin"
minPredsGrinders$grindersMin <- as.numeric(minPredsGrinders$grindersMin)

boxscores <- merge(boxscores[c("GameId", "PlayerId", "Min")], minPredsRotowire, by = c("GameId", "PlayerId"), all.x = T)
boxscores <- merge(boxscores, minPredsGrinders, by = c("GameId", "PlayerId"), all.x = T)

saveRDS(boxscores, "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\minutePredictions.rds")

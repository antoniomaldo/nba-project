
library(RODBC)

listFiles <- list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate", full.names = T)


year18 <- do.call(rbind, lapply(list.files(listFiles[1], full.names = T), read.csv))
year19 <- do.call(rbind, lapply(list.files(listFiles[2], full.names = T), read.csv))
year20 <- do.call(rbind, lapply(list.files(listFiles[3], full.names = T), read.csv))

year18$seasonYear = 2018
year19$seasonYear = 2019
year20$seasonYear = 2020

allPlayers <- rbind(year18, year19)
allPlayers <- rbind(allPlayers, year20)

toRemove <- c(1, 7, 35, 36, 37)

test <- allPlayers[-toRemove]
test <- unique(test)

server <- odbcConnect("Server")

colnames(test)[colnames(test) == "Points"] <- "PointsScored"
colnames(test)[colnames(test) == "Date"] <- "DateString"

sqlSave(server, test, tablename = "nba.roto_preds")

odbcClose(server)

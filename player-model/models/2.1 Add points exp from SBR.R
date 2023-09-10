library(sqldf)
allData <- readRDS("C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\allPlayers.rds")

boxscores <- list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\espn\\Boxscores\\2022\\", full.names = T)
sbrFiles <- list.files("C:\\Users\\Antonio\\Documents\\NBA\\data\\sbr-odds\\2022\\", full.names = T)

sbrData <- do.call(rbind, lapply(sbrFiles, read.csv))
bsData <- do.call(rbind, lapply(boxscores, read.csv))

whData <- subset(sbrData, sbrData$bookmaker == "williamhill")


mappings <- read.csv("C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models/mapping_nba.csv")

whData <- sqldf("SELECT t.*, t1.espn_abbrev AS homeTeamEspnName, t2.espn_abbrev AS awayTeamEspnName
                 FROM whData t
                 LEFT JOIN mappings t1 ON t.hometeam = t1.sbr_name
                 LEFT JOIN mappings t2 ON t.awayteam = t2.sbr_name")


whData$date <- as.Date(whData$date, format = "%d/%m/%Y")
bsData$Date <- as.Date(as.character(bsData$Date), format="%Y%m%d")

whData$prevDate <- whData$date - 1


odds <- sqldf("SELECT g.GameId, o.* FROM bsData g
               INNER JOIN whData o
               ON g.HomeTeam = o.homeTeamEspnName AND g.AwayTeam = o.awayTeamEspnName
               AND (g.Date = o.date OR g.Date = o.prevDate)")


odds$homeExp = (odds$home4QScore - odds$home1QScore) / 2
odds$awayExp = (odds$home4QScore - odds$homeExp)

allData22 <- merge(allData, odds[c("GameId", "homeExp", "awayExp", "homeTeamEspnName", "awayTeamEspnName")])
allData22$ownExpPoints = ifelse(allData22$Team == allData22$homeTeamEspnName, allData22$homeExp, allData22$awayExp)
allData22$oppExpPoints = ifelse(allData22$Team != allData22$homeTeamEspnName, allData22$homeExp, allData22$awayExp)

saveRDS(allData22, "C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\allPlayersWithOdds22.rds")

######
setwd("C:/models/basketball/NBA/NBA Model Review 2018")
source("C:\\models\\R Packages\\fastSqlSave2.R")
library(tictoc)
library(sqldf)
library(RODBC)
library(chron)
library(stringr)

##This data is saved into nba_2019.pbp_with_odds

server <- odbcConnect("Server")

games <- sqlQuery(server, "SELECT * FROM nba_2019.events;")
events <- sqlQuery(server, "SELECT * FROM nba_2019.pbp;")

odds <- sqlQuery(server, "SELECT * FROM nba_2019.matches_odds;")

odbcClose(server)

mappings <- read.csv("C:\\models\\basketball\\NBA\\NBA Model Review 2018\\Mapping NBA.csv")

odds <- sqldf("SELECT t.*, t1.espn_name AS homeTeamEspnName, t2.espn_name AS awayTeamEspnName
                 FROM odds t
                 LEFT JOIN mappings t1 ON t.hometeam = t1.sbr_name
                 LEFT JOIN mappings t2 ON t.awayteam = t2.sbr_name")

odds$hometeam <-  odds$homeTeamEspnName
odds$awayteam <-  odds$awayTeamEspnName

odds <- odds[, 2:32]

odds$seasonyear[odds$seasonyear == 2020] <- 2019

#odds <- sqldf("SELECT o.*, m.espn_name AS espnAwayTeam FROM odds o INNER JOIN mappings m ON o.awayTeam = m.sbr_name;")
odds$date <- as.Date(odds$date)
games$date <- as.Date(games$date)

## set TV timeout to no team
#events$whichteam <- ifelse(events$action %in% c("official timeout", "Official timeout"), NA, events$whichteam)
#events$whichteam <- ifelse(events$whichteam == 1, "away", ifelse(events$whichteam == 2, "home", events$whichteam))

events$action <- tolower(events$action)
# signal event for each action

events$homeTechFT <- ifelse(grepl("technical free throw", events$action) & events$whichteam == "home", 1, 0)
events$awayTechFT <- ifelse(grepl("technical free throw", events$action) & events$whichteam == "away", 1, 0)
events$homeTechFTScored <- ifelse(grepl("makes", events$action) & events$homeTechFT == 1, 1, 0)
events$awayTechFTScored <- ifelse(grepl("makes", events$action) & events$awayTechFT == 1, 1, 0)

events$homeFT <- ifelse(grepl("free throw", events$action) & events$whichteam == "home" & events$homeTechFT == 0, 1, 0)
events$awayFT <- ifelse(grepl("free throw", events$action) & events$whichteam == "away" & events$awayTechFT == 0, 1, 0)
events$homeFTScored <- ifelse(grepl("makes", events$action) & events$homeFT == 1, 1, 0)
events$awayFTScored <- ifelse(grepl("makes", events$action) & events$awayFT == 1, 1, 0)

events$shotMadeDistance <- ifelse(grepl("makes [1-9]{1,2}", events$action), 1, 0)
events$shotMadeDistance <- ifelse(events$shotMadeDistance == 1, str_extract(events$action, "makes [0-9]{1,2}"), NA)
events$shotMadeDistance <- ifelse(is.na(events$shotMadeDistance), NA, as.integer(gsub("makes ", "",events$shotMadeDistance)))

#set two and three pointers bases on "two/three point" specifically being in the action
events$home3Pts <- ifelse(grepl("makes", events$action) & grepl("three point", events$action) & events$whichteam == "home", 1, 0)
events$away3Pts <- ifelse(grepl("makes", events$action) & grepl("three point", events$action) & events$whichteam == "away", 1, 0)
events$home2Pts <- ifelse(grepl("makes|made", events$action) & grepl("two point", events$action) & events$whichteam == "home" & events$homeFTScored == 0 & events$home3Pts == 0, 1, 0)
events$away2Pts <- ifelse(grepl("makes|made", events$action) & grepl("two point", events$action) & events$whichteam == "away" & events$awayFTScored == 0 & events$away3Pts == 0, 1, 0)

#where two/three pointers arent already set, set two and three pointers based on shotMadeDistance
events$home3Pts <- ifelse(events$whichteam == "home" & !is.na(events$shotMadeDistance) & events$home3Pts == 0 & events$home2Pts == 0, as.integer(events$shotMadeDistance) >= 24, events$home3Pts)
events$away3Pts <- ifelse(events$whichteam == "away" & !is.na(events$shotMadeDistance) & events$away3Pts == 0 & events$away2Pts == 0, as.integer(events$shotMadeDistance) >= 24, events$away3Pts)
events$home2Pts <- ifelse(events$whichteam == "home" & !is.na(events$shotMadeDistance) & events$home3Pts == 0 & events$home2Pts == 0, as.integer(events$shotMadeDistance) < 22 ,events$home2Pts)
events$away2Pts <- ifelse(events$whichteam == "away" & !is.na(events$shotMadeDistance) & events$away3Pts == 0 & events$away2Pts == 0, as.integer(events$shotMadeDistance) < 22 ,events$away2Pts)

#where two/three pointers still arent set, set as 2 pointer
events$home2Pts <- ifelse(grepl("makes|made", events$action) & events$whichteam == "home" & events$homeFTScored == 0 & events$homeTechFTScored == 0 & events$home3Pts == 0, 1, 0)
events$away2Pts <- ifelse(grepl("makes|made", events$action) & events$whichteam == "away" & events$awayFTScored == 0 & events$awayTechFTScored == 0 & events$away3Pts == 0, 1, 0)

########## old methods of setting 2/3 pointers ###########
# events$home3Pts <- ifelse(grepl("makes", events$action) & grepl("three point", events$action) & events$whichteam == "home", 1, 0)
# events$away3Pts <- ifelse(grepl("makes", events$action) & grepl("three point", events$action) & events$whichteam == "away", 1, 0)
# events$home2Pts <- ifelse(grepl("makes|made", events$action) & events$whichteam == "home" & events$homeFTScored == 0 & events$home3Pts == 0, 1, 0)
# events$away2Pts <- ifelse(grepl("makes|made", events$action) & events$whichteam == "away" & events$awayFTScored == 0 & events$away3Pts == 0, 1, 0)


events$homeTechFoulConceded <- ifelse(grepl("technical foul", events$action) & events$whichteam == "home" , 1, 0)
events$awayTechFoulConceded <- ifelse(grepl("technical foul", events$action) & events$whichteam == "away" , 1, 0)

events$homeFoulConceded <- ifelse(grepl("foul|charge", events$action) & events$whichteam == "home" & events$homeTechFoulConceded == 0, 1, 0)
events$awayFoulConceded <- ifelse(grepl("foul|charge", events$action) & events$whichteam == "away" & events$awayTechFoulConceded == 0, 1, 0)

events$homeOffensiveFoul <- ifelse(grepl("offensive foul|ofensive foul|offensive charge|ofensive charge", events$action) & events$whichteam == "home", 1, 0)
events$awayOffensiveFoul <- ifelse(grepl("offensive foul|ofensive foul|offensive charge|ofensive charge", events$action) & events$whichteam == "away", 1, 0)

events$homeTurnover <- ifelse(grepl("turnover|bad pass|travelling|traveling", events$action) & !grepl("off|offensive|ofensive", events$action) & events$whichteam == "home", 1, 0)
events$awayTurnover <- ifelse(grepl("turnover|bad pass|travelling|traveling", events$action) & !grepl("off|offensive|ofensive", events$action) & events$whichteam == "away", 1, 0)

events$homeTimeOut <- ifelse(grepl("timeout", events$action) & events$whichteam == "home", 1, 0)
events$awayTimeOut <- ifelse(grepl("timeout", events$action) & events$whichteam == "away", 1, 0)

events$homeSteal <- ifelse(grepl("steals", events$action) & events$whichteam == "away", 1, 0)
events$awaySteal <- ifelse(grepl("steals", events$action) & events$whichteam == "home", 1, 0)

events$homeOffensiveRebound <- ifelse(grepl("offensive rebound|offensive team rebound", events$action) & events$whichteam == "home", 1, 0)
events$awayOffensiveRebound <- ifelse(grepl("offensive rebound|offensive team rebound", events$action) & events$whichteam == "away", 1, 0)

events$homeDefensiveRebound <- ifelse(grepl("defensive rebound|defensive team rebound", events$action) & events$whichteam == "home", 1, 0)
events$awayDefensiveRebound <- ifelse(grepl("defensive rebound|defensive team rebound", events$action) & events$whichteam == "away", 1, 0)

events$homeBlock <- ifelse(grepl("blocks|blocked", events$action) & events$whichteam == "home", 1, 0)
events$awayBlock <- ifelse(grepl("blocks|blocked", events$action) & events$whichteam == "away", 1, 0)

events$homeWonJumpBall <- ifelse(grepl("gains possession", events$action) & events$whichteam == "home", 1, 0)
events$awayWonJumpBall <- ifelse(grepl("gains possession", events$action) & events$whichteam == "away", 1, 0)
events$homeFTMissed <- ifelse(grepl("misses", events$action) & events$homeFT == 1, 1, 0)
events$awayFTMissed <- ifelse(grepl("misses", events$action) & events$awayFT == 1, 1, 0)
events$homeMissed3Pts <- ifelse(grepl("three point", events$action) & events$home3Pts != 1 & events$whichteam == "home", 1, 0)
events$awayMissed3Pts <- ifelse(grepl("three point", events$action) & events$away3Pts != 1 & events$whichteam == "away", 1, 0)
events$homeMissed2Pts <- ifelse(grepl("miss", events$action) & events$whichteam == "home" & events$homeFTMissed == 0 & events$homeMissed3Pts == 0, 1, 0)
events$awayMissed2Pts <- ifelse(grepl("miss", events$action) & events$whichteam == "away" & events$awayFTMissed == 0 & events$awayMissed3Pts == 0, 1, 0)
events$homeSubstitution <- ifelse(grepl("enters the game for", events$action) & events$whichteam == "home", 1, 0)
events$awaySubstitution <- ifelse(grepl("enters the game for", events$action) & events$whichteam == "away", 1, 0)
events$ptsh <- ifelse(events$homeFTScored == 1, 1, ifelse(events$home2Pts == 1, 2, ifelse(events$home3Pts == 1, 3, 0)))
events$ptsa <- ifelse(events$awayFTScored == 1, 1, ifelse(events$away2Pts == 1, 2, ifelse(events$away3Pts == 1, 3, 0)))

# set team score before current play
events$homeScoreInRow <- events$homeTechFTScored + events$homeFTScored + 2 * events$home2Pts + 3 * events$home3Pts
events$awayScoreInRow <- events$awayTechFTScored + events$awayFTScored + 2 * events$away2Pts + 3 * events$away3Pts

events$homeScoreSoFar <- unlist(aggregate(homeScoreInRow ~ gameid, data = events, cumsum)$homeScoreInRow)
events$awayScoreSoFar <- unlist(aggregate(awayScoreInRow ~ gameid, data = events, cumsum)$awayScoreInRow)

events$homeScoreBeforeCurrentPlay <- unlist(aggregate(homeScoreSoFar ~ gameid, data = events, FUN = function(x){c(0, x)[-length(x)]})$homeScoreSoFar)
events$awayScoreBeforeCurrentPlay <- unlist(aggregate(awayScoreSoFar ~ gameid, data = events, FUN = function(x){c(0, x)[-length(x)]})$awayScoreSoFar)

View(events[c("gameid", "action","homeScoreSoFar", "homeScoreBeforeCurrentPlay","awayScoreSoFar", "awayScoreBeforeCurrentPlay")])

# remove end of period lines
#events <- subset(events, !(events$action %in% c("End of the 1st Quarter", "End of the 2nd Quarter", "End of the 3rd Quarter", "End of the 4th Quarter", "End of Fourth Quarter", "End of the 1ST Overtime", "End of the 1st Overtime", "End of Game")))

# split time to mins and secs
events$time <- str_replace(events$time, "[.]0", "")
events$time <- ifelse(grepl("[:]", events$time), events$time, ifelse(nchar(events$time) == 2, paste0("0:", events$time), paste0("0:0", events$time)))
events$mins <- as.numeric(gsub(":.*", "", events$time))
events$secs <- as.numeric(gsub(".*:", "", events$time))

# set time remaining in seconds
events$timeRemInSecs <- ifelse(events$half <= 4, (4 - events$half) * 12 * 60 + events$mins * 60 + events$secs, events$mins * 60 + events$secs)
events$timeRemInQuarter <- events$mins * 60 + events$secs

# remove final lines that have null action
events$playID <- 1:nrow(events)
toRemove <- subset(events, action == 'null' & time == '0:00')$playID
events <- subset(events, !(playID %in% toRemove))

# # remove games that have any null actions
# toRemove <- subset(events, action == 'null')$gameid
# events <- subset(events, !(gameid %in% toRemove))

allNBAData <- sqldf("SELECT * FROM games g INNER JOIN events e ON g.gameid = e.gameid;")

# combine with odds data
#odds$nextDate <- odds$date + 1
odds$prevDate <- odds$date - 1


odds <- sqldf("SELECT g.gameid, o.* FROM games g
               INNER JOIN odds o
               ON g.homeTeam = o.homeTeam AND g.awayTeam = o.awayTeam
               AND (g.date = o.date OR g.date = o.prevDate)
               AND g.homeQ1Score = o.home1qscore
               AND g.awayQ1Score = o.away1qscore


Sent from my Galaxy

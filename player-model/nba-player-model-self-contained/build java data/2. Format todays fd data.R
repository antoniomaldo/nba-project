library(stringr)

TODAY_DIR = paste0("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\data\\", Sys.Date())

fileDir = paste0(TODAY_DIR, "\\dfRotoPred.json")

dayData <- read.csv(file = fileDir, sep = ":", row.names = NULL)

dayData = subset(dayData, dayData$row.names %in% c( "player_name", "team", "opp","home?", "position", "salary","id", "pmin", "points", "ceil", "floor"))

dayData$playerId <- 1 * (dayData$row.names == "id")
dayData$nchars <- nchar(as.character(dayData$X.))
dayData <- subset(dayData, dayData$nchars < 37)

dayData$playerId <- cumsum(dayData$playerId)

dayData$X. <- str_replace(dayData$X., ",", "")

getPosition <- function(x){
 # allowPos <- c("SG", "PG", "SF", "PF", "C")
#  x <- x[x %in% allowPos]
  return(x[1])
}

formatData <- data.frame()
for(i in unique(dayData$playerId)){
  playerData <- subset(dayData, dayData$playerId == i)
  if(nrow(playerData) > 9){
    name = playerData$X.[playerData$row.names == "player_name"]
    if(length(name) > 0){
      team = playerData$X.[playerData$row.names == "team"]
      team = team[team != "null"]
      isHome = playerData$X.[playerData$row.names == "home?"]
      formatData <- rbind(formatData, data.frame(
        Name = trimws(as.character(name)),
        Salary = as.numeric(trimws(as.character(playerData$X.[playerData$row.names == "salary"])))[1],
        Team = trimws(as.character(team[1])),
        Position = trimws(getPosition(as.character(playerData$X.[playerData$row.names == "position"]))),
        Opp = trimws(as.character(playerData$X.[playerData$row.names == "opp"])),
        IsHome = trimws(as.character(ifelse(length(isHome) == 0, "UNKNOWN", isHome))),
        
        PMIN = as.numeric(playerData$X.[playerData$row.names == "pmin"]),
        Points = as.numeric(playerData$X.[playerData$row.names == "points"]),
        Ceil = as.numeric(playerData$X.[playerData$row.names == "ceil"]),
        Floor = as.numeric(playerData$X.[playerData$row.names == "floor"]))
      )
    }
  }
}


write.csv(formatData, paste0(TODAY_DIR, "\\fd-data.csv"))

source("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\build java data\\1.Read rotogrinders data.R")
source("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\build java data\\2. Format todays fd data.R")

TODAY_DIR = paste0("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\data\\", Sys.Date())

fdData <- read.csv(paste0(TODAY_DIR, "\\fd-data.csv"))
mappings <- unique(read.csv("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\build java data\\MAPPINGS_ROTO.csv")[c(1,3)])

fdData$rotoName = fdData$Name

merged <- merge(fdData, mappings, all.x = T)

naVals <- subset(merged, is.na(merged$PlayerId))

cat(paste0(naVals$rotoName, ",", naVals$Team), sep = "\n")

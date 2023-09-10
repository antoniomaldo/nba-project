library(httr)
library(stringr)
library(jsonlite)

DRAFTKINGS_DIR = paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\jsons\\draftkings\\2021_22\\")
FANDUEL_DIR = paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\jsons\\fanduel\\2021_22\\")

saveContent <- function(day, text, dir){
  json = str_extract(text, "data =(.*);")
  json = str_replace(json, "data = |;|\"", "")
  json =  substr(json, 2, nchar(json)-2)
  json <- str_replace_all(str_replace_all(json, ",", ",\n"), "\\{", "\\{\n")
  json = paste0(paste0("[", json), "]")

  write(json, file = paste0(dir, "\\", day, ".json"))
}


days <- seq(as.Date("2021-11-20"), as.Date("2022-06-18"), by = 1)

for(day in as.character(days)){
  
  fanduel <- paste0("https://rotogrinders.com/projected-stats/nba?date=", day)
  responseFD <- GET(url = fanduel)
  saveContent(day, text = content(responseFD, "text"), dir = FANDUEL_DIR)
  
  draftkings = paste0("https://rotogrinders.com/projected-stats/nba?site=draftkings&date=", day)
  responseDK <- GET(url = draftkings)
  saveContent(day, text = content(responseDK, "text"), dir = DRAFTKINGS_DIR)
  Sys.sleep(1)
}

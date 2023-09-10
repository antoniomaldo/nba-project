library(httr)
library(stringr)
library(jsonlite)

TODAY_DIR = paste0("C:\\Users\\aostios\\Documents\\NBA\\nba-player-model-self-contained\\data\\", Sys.Date())

saveContent <- function(day, text, dir){
  json = str_extract(text, "data =(.*);")
  json = str_replace(json, "data = |;|\"", "")
  json =  substr(json, 2, nchar(json)-2)
  json <- str_replace_all(str_replace_all(json, ",", ",\n"), "\\{", "\\{\n")
  
  if(!dir.exists(TODAY_DIR)){
    dir.create(TODAY_DIR)
  }
  write(json, file = paste0(dir, "\\", day, ".json"))
}

#Get current data
fanduel <- "https://rotogrinders.com/projected-stats/nba?site=fanduel"
responseFD <- GET(url = fanduel)
saveContent("dfRotoPred", text = content(responseFD, "text"), dir = TODAY_DIR)

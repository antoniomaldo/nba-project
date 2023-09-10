library(stringr)
library(rjson)

FANDUEL_DIR = paste0("C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\jsons\\fanduel\\2022_23\\")
OUTPUT_DIR = "C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\csvs\\2023\\"

jsons <- list.files(path = FANDUEL_DIR, full.names = F)

orNa <- function(val){
  if(is.null(val)){
    return(NA)
  }else{
    return(val)
  }
}

for(json in jsons){
  print(json)
  dayData = rjson::fromJSON(file = paste0(FANDUEL_DIR, json))
  
  allData <- data.frame()
  for(player in dayData){

    slateId = player$slate_id
    salary = player$salary
    type = player$type
    position = player$position
    
    name = player$player_name
    team = player$team
    opp = player$opp
    isHomeTeam = player$`home?`
    playerId = player$player_id
    pmin = player$pmin
    points = player$points
    floor = player$floor
    ceil = player$ceil
    total = player$total
    oppTotal = player$opp_total
    allData <- rbind(allData, data.frame(slateId = orNa(slateId),
                                         playerId = orNa(playerId), 
                                         name = orNa(name),
                                         team = orNa(team),
                                         opp = orNa(opp),
                                         ishomeplayer = orNa(isHomeTeam),
                                         pmin = orNa(pmin), 
                                         points = orNa(points), 
                                         floor = orNa(floor),
                                         ceil = orNa(ceil),
                                         salary = orNa(salary),
                                         positionfd = orNa(position),
                                         total = orNa(total),
                                         oppTotal = orNa(oppTotal)
                                         
                                         
                                         
    ))
  }
  
  
  day = str_replace_all(json, ".json", ".csv")
  write.csv(allData, file = paste0(OUTPUT_DIR, day))
}

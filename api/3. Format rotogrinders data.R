library(stringr)
library(rjson)

TODAY_DIR = paste0("C:\\Users\\Antonio\\Documents\\NBA\\api\\data\\", Sys.Date())

fileDir = paste0(TODAY_DIR, "\\dfRotoPred.json")

dayData = rjson::fromJSON(file = fileDir)


allData <- data.frame()
for(player in dayData){
  playerData = player$schedule$data$salaries$collection
  
  slateData <- data.frame()
  for(col in playerData){
    colData = col$data
    siteId = colData$site_id
    for(slate in colData$import_id){
      slateId = slate$slate_id
      if(!is.null(slateId)){
        salary = slate$salary
        type = slate$type
        position = slate$position
        if(!is.null(slateId) & !is.null(salary) & !is.null(position)){
          
          slateData <- rbind(slateData, data.frame(slateId = slateId,
                                                   salary = salary, 
                                                   position = position)
          )
        }
      }
    }
  }
  if(nrow(slateData) > 0){
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
    for(i in 1:nrow(slateData)){
      allData <- rbind(allData, data.frame(slateId = slateData$slateId[i],
                                           playerId = playerId, 
                                           name = name,
                                           team = team,
                                           opp = opp,
                                           ishomeplayer = isHomeTeam,
                                           pmin = ifelse(is.null(pmin), NA, pmin) , 
                                           points = points, 
                                           floor = floor,
                                           ceil = ceil,
                                           salary = slateData$salary[i],
                                           positionfd = slateData$position[i],
                                           total = total,
                                           oppTotal = oppTotal
                                           
                                           
                                           
      ))
    }
  }
}

write.csv(allData, file = paste0(TODAY_DIR, "\\players.csv"))

#rm(list = ls())

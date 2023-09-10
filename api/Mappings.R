library(sqldf)

loadMappedData <- function(pl, mp){
  
  mappedData <- sqldf("SELECT t1.name, t2.playerId FROM pl t1 
                     LEFT JOIN mp t2 ON t1.name = t2.playerName")
  
  mappedData <- unique(mappedData)
  
  slateId = pl$slateId[1]
  mappedData$playerId[mappedData$name == "Derrick Jones Jr."] <- paste0(slateId, "-66968")
  mappedData$playerId[mappedData$name == "Michael Porter Jr."] <- paste0(slateId, "-84682")
  mappedData$playerId[mappedData$name == "Danuel House Jr."] <- paste0(slateId, "-23294")
  mappedData$playerId[mappedData$name == "C.J. McCollum"] <- paste0(slateId, "-19067")
  mappedData$playerId[mappedData$name == "Lu Dort"] <- paste0(slateId, "-111273")
  mappedData$playerId[mappedData$name == "Gary Trent Jr."] <- paste0(slateId, "-84695")
  mappedData$playerId[mappedData$name == "P.J. Dozier"] <- paste0(slateId, "-66196")
  mappedData$playerId[mappedData$name == "Shaq Harrison"] <- paste0(slateId, "-82744")
  mappedData$playerId[mappedData$name == "Robert Williams III"] <- paste0(slateId, "-84708")
  mappedData$playerId[mappedData$name == "Tim Hardaway Jr."] <- paste0(slateId, "-15846")
  mappedData$playerId[mappedData$name == "PJ Washington"] <- paste0(slateId, "-110352")
  mappedData$playerId[mappedData$name == "Lonnie Walker IV"] <- paste0(slateId, "-84702")
  mappedData$playerId[mappedData$name == "Otto Porter Jr."] <- paste0(slateId, "-15628")
  mappedData$playerId[mappedData$name == "Wendell Carter Jr."] <- paste0(slateId, "-84676")
  mappedData$playerId[mappedData$name == "Troy Brown Jr."] <- paste0(slateId, "-84668")
  mappedData$playerId[mappedData$name == "Larry Nance Jr."] <- paste0(slateId, "-20992")
  mappedData$playerId[mappedData$name == "J.J. Redick"] <- paste0(slateId, "-9655")
  mappedData$playerId[mappedData$name == "Marvin Bagley III"] <- paste0(slateId, "-84679")
  mappedData$playerId[mappedData$name == "Glenn Robinson III"] <- paste0(slateId, "-23800")
  mappedData$playerId[mappedData$name == "James Ennis III"] <- paste0(slateId, "-17491")
  mappedData$playerId[mappedData$name == "Dennis Smith Jr."] <- paste0(slateId, "-80814")
  mappedData$playerId[mappedData$name == "Xavier Tillman Sr."] <- paste0(slateId, "-145336")
  mappedData$playerId[mappedData$name == "Kira Lewis Jr."] <- paste0(slateId, "-145316")
  mappedData$playerId[mappedData$name == "Harry Giles III"] <- paste0(slateId, "-80819")
  mappedData$playerId[mappedData$name == "KJ Martin Jr."] <- paste0(slateId, "-145533")
  mappedData$playerId[mappedData$name == "Kevin Porter Jr."] <- paste0(slateId, "-110345")
  mappedData$playerId[mappedData$name == "Cam Johnson"] <- paste0(slateId, "-110316")
  mappedData$playerId[mappedData$name == "Patrick Williams"] <- paste0(slateId, "-145308")
  mappedData$playerId[mappedData$name == "Juancho Hernangomez"] <- paste0(slateId, "-70822")
  mappedData$playerId[mappedData$name == "KJ Martin"] <- paste0(slateId, "-145533")
  
  
  
  
  return(mappedData)
}


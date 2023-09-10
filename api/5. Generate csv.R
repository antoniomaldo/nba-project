library(stringr)
source("C:\\Users\\Antonio\\Documents\\NBA\\api\\Mappings.R")

csv = read.csv(paddyCsv, sep = "\n")

contestsInfo <- data.frame()

for(i in 1:nrow(csv)){
   name =  str_split(csv[i,1], pattern = ",")[[1]][3]
   if(name != ""){
      
      isDouble = F
      isTriple = F
      isQuintuple = F
      isMain = F
      if(grepl("Quintuple", name)){
         isQuintuple = T
      }else if(grepl("Triple", name)){
         isTriple = T
      }else if(grepl("Double", name)){
         isDouble = T
      }else if(grepl("NBA Clutch", name) | grepl("NBA Beat", name)){
         isMain = T
      }
      contestsInfo <- rbind(contestsInfo, data.frame(id =  str_split(csv[i,1], pattern = ",")[[1]][2],
                                                     isDouble = isDouble, 
                                                     isTriple = isTriple, 
                                                     isQuintuple = isQuintuple,
                                                     isMain = isMain
                                                     ))
   }
}

df <- data.frame()

for(i in 1:nrow(contestsInfo)){
   row =  str_split(csv[i,1], pattern = ",")[[1]][1:12]
   df <- rbind(df, data.frame(entry_id = row[1],
                              contest_id = row[2],
                              contest_name = row[3],
                              PG = row[4],
                              PG = row[5],
                              SG = row[6],
                              SG = row[7],
                              SF = row[8],
                              SF = row[9],
                              PF = row[10],
                              PF = row[11],
                              C = row[12],
                              blank = "",
                              Intructions = ""
                              
                              
   ))
   
}


mappings <- data.frame()
for(i in 7:nrow(csv)){
   row =  str_split(csv[i,1], pattern = ",")[[1]]
   mappings <- rbind(mappings, data.frame(
      playerId = row[15],
      playerName = row[18]
      
      
   ))
   
}

mappedData <- loadMappedData(playersForSlate, mappings)

removePoints <- function(st){
   pName = str_split(st, pattern = " \\(")[[1]][1]
   
   return(mappedData$playerId[mappedData$name == pName])
}

#mappedData from R script

counter = 0
counterMain = 1

contestsInfo$isMain = T
for(k in 1:nrow(contestsInfo)){
   if(contestsInfo$isTriple[k] & F){
      lineUp = chosenLineUps[1,]
   }else if(contestsInfo$isMain[k]){
      lineUp = chosenLineUps[counterMain,]
      counterMain = counterMain + 1
    #  counterMain = ifelse(counterMain == 21, 1, counterMain)
   }else{
      lineUp = chosenLineUps[counter %% 3 + 1,]
      counter = counter + 1
   }
   
   df$PG[k] <- removePoints(lineUp$firstPg)
   df$PG.1[k] <- removePoints(lineUp$secondPg)
   df$SG[k] <- removePoints(lineUp$firstSg)
   df$SG.1[k] <- removePoints(lineUp$secondSg)
   df$SF[k] <- removePoints(lineUp$firstSf)
   df$SF.1[k] <- removePoints(lineUp$secondSf)
   df$PF[k] <- removePoints(lineUp$firstPf)
   df$PF.1[k] <- removePoints(lineUp$secondPf)
   df$C[k] <- removePoints(lineUp$center)
}

colnames(df) <- c("entry_id","contest_id","contest_name","PG","PG.1","SG","SG.1","SF","SF.1","PF","PF.1","C","","Intructions")
write.csv(df, file = paste0(BASE_DIR, "\\paddCsv.csv"), row.names = F)

library(arm)
library(h2o)

listFiles <- list.files("C:\\Users\\aostios\\Documents\\Basketball Model\\NBA Model\\Players New\\Best team backtest\\contests\\2018_19", full.names = T)
listFiles <- c(listFiles, list.files("C:\\Users\\aostios\\Documents\\Basketball Model\\NBA Model\\Players New\\Best team backtest\\contests\\2019_20", full.names = T))

allPlayers <- data.frame()
gameId <- 1
for(folder in listFiles){
  fileDir <- paste0(folder, "\\bestTeams.csv")
  if(file.exists(fileDir)){
    
    bestTeams <- read.csv(fileDir)
    maxPoints <- max(bestTeams$FdPoints)
    bestTeam  = subset(bestTeams, bestTeams$FdPoints == maxPoints)[1,]
    bestTeam = as.character(unlist(bestTeam[,2:10]))
    
    bestTeam <- sub(' \\(.*', '', bestTeam)
    
    players <- read.csv(paste0(folder, "\\players.csv"))
    players$PlayerNameId <- paste0(players$playerName, "-", players$PlayerId)
    
    players$bestTeam <- 1 * (players$PlayerNameId %in% bestTeam)
    players$numbTeam <- 2 * length(unique(players$GameId))
    players$difTeams <- length(unique(players$Team[players$bestTeam == 1]))
    players$teamDiff <- ifelse(players$isHomePlayer, 1, -1) * (players$Home.Final.Score - players$Away.Final.Score)
    
    teams <- data.frame(table(players$Team[players$bestTeam == 1]))
    colnames(teams) <- c("Team", "numbPlayersFromTeam")
    
    players <- merge(players, teams, by = "Team", all.x = T)
    players$numbPlayersFromTeam[is.na(players$numbPlayersFromTeam)] <- 0
    
    if(max(players$numbTeam) == 28){
      print(folder)
    }
    players$id <- gameId
    gameId = gameId + 1
    allPlayers <- rbind(allPlayers, players)
  }else{
    print(paste0("File doesnt exist: ", fileDir))
  }
}

agg = aggregate(bestTeam ~ date, allPlayers, sum)
agg <- subset(agg, agg$bestTeam == 9)

allPlayers <- subset(allPlayers, allPlayers$numbTeam < 30 & allPlayers$date %in% agg$date)

allPlayers$bestCenter <- 1 * (allPlayers$bestTeam == 1 & allPlayers$positionFd == "C")

centerTeam <- subset(allPlayers[c("date", "Team", "salary", "teamDiff")], allPlayers$bestCenter == 1)
colnames(centerTeam) <- c("date", "centerTeam", "centerSalary", "centerTeamDiff")

allPlayers <- merge(allPlayers, centerTeam, by = "date")

allPlayers$sameTeamCenter <- 1 * (allPlayers$centerTeam == allPlayers$Team)

allPlayers <- subset(allPlayers, allPlayers$positionFd != "C")
allPlayers$pgSameTeam <- as.factor(1 * (allPlayers$positionFd == "PG" & allPlayers$sameTeamCenter == 1))
allPlayers$sgSameTeam <- as.factor(1 * (allPlayers$positionFd == "SG" & allPlayers$sameTeamCenter == 1))
allPlayers$sfSameTeam <- as.factor(1 * (allPlayers$positionFd == "SF" & allPlayers$sameTeamCenter == 1))
allPlayers$pfSameTeam <- as.factor(1 * (allPlayers$positionFd == "PF" & allPlayers$sameTeamCenter == 1))

#Models
#20200114
allPlayers$id[which(allPlayers$Date == "20191022")][1]
allPlayers$id[which(allPlayers$Date == "20200114")][1]

testData <- subset(allPlayers, allPlayers$id >= 139 & allPlayers$id <= 219)
trainData <- subset(allPlayers, !allPlayers$id %in% testData$id)

#GBM model
h2o.init()
trainData$salaryPerTeams <- trainData$salary / trainData$numbTeam
testData$salaryPerTeams <- testData$salary / testData$numbTeam

trainData$bestTeamFactor <- as.factor(trainData$bestTeam)
testData$bestTeamFactor <- as.factor(testData$bestTeam)

trainData$numbTeamFactor <- as.factor(trainData$numbTeam)
testData$numbTeamFactor <- as.factor(testData$numbTeam)

testDataH2o <- as.h2o(testData)
trainDataH2o <- as.h2o(trainData)

modelGBM <- h2o.gbm(x = c("points" ,"salary", "numbTeamFactor", "teamDiff", "salaryPerTeams", "sameTeamCenter", "pgSameTeam"), y = "bestTeamFactor",
                    
                    training_frame = trainDataH2o, model_id = "BestTeamGivenCenterModel", 
                    seed = 12, 
                    nfolds = 10, 
                    keep_cross_validation_predictions = TRUE, 
                    fold_assignment = "Modulo", 
                    distribution = "bernoulli",
                    max_depth = 5,
                    min_rows = 200,
                    ntrees = 100)

h2o.auc(modelGBM)
h2o.auc(modelGBM, xval = T)

testData$gbmPred <- as.vector(h2o.predict(modelGBM, testDataH2o)$p1)
testData$gbmResid <- testData$bestTeam - testData$gbmPred

#GLM model
model <- glm(bestTeam ~ points * salary +
               numbTeam + 
               salary : numbTeam +
               points : numbTeam +
               teamDiff +
               pgSameTeam + 
               sgSameTeam +
               sfSameTeam + 
               pfSameTeam + 
               centerSalary
             ,data = trainData, family = binomial)

summary(model)

testData$glmPred <- predict(model, testData, type = "response")

preds <- data.frame()
for(i in unique(testData$id)){
  day = subset(testData, testData$id == i)
  
  day$glmPred[day$positionFd == "PG"] <- 2 * day$glmPred[day$positionFd == "PG"] / (sum(day$glmPred[day$positionFd == "PG"]))
  day$glmPred[day$positionFd == "SG"] <- 2 * day$glmPred[day$positionFd == "SG"] / (sum(day$glmPred[day$positionFd == "SG"]))
  day$glmPred[day$positionFd == "SF"] <- 2 * day$glmPred[day$positionFd == "SF"] / (sum(day$glmPred[day$positionFd == "SF"]))
  day$glmPred[day$positionFd == "PF"] <- 2 * day$glmPred[day$positionFd == "PF"] / (sum(day$glmPred[day$positionFd == "PF"]))
  day$glmPred[day$positionFd == "C"] <- day$glmPred[day$positionFd == "C"] / (sum(day$glmPred[day$positionFd == "C"]))
  
  day$gbmPred[day$positionFd == "PG"] <- 2 * day$gbmPred[day$positionFd == "PG"] / (sum(day$gbmPred[day$positionFd == "PG"]))
  day$gbmPred[day$positionFd == "SG"] <- 2 * day$gbmPred[day$positionFd == "SG"] / (sum(day$gbmPred[day$positionFd == "SG"]))
  day$gbmPred[day$positionFd == "SF"] <- 2 * day$gbmPred[day$positionFd == "SF"] / (sum(day$gbmPred[day$positionFd == "SF"]))
  day$gbmPred[day$positionFd == "PF"] <- 2 * day$gbmPred[day$positionFd == "PF"] / (sum(day$gbmPred[day$positionFd == "PF"]))
  day$gbmPred[day$positionFd == "C"] <- day$gbmPred[day$positionFd == "C"] / (sum(day$gbmPred[day$positionFd == "C"]))
  
  preds <- rbind(preds, day)
}

preds$glmResid <- preds$bestTeam - preds$glmPred
preds$gbmResid <- preds$bestTeam - preds$gbmPred

binnedplot(preds$teamDiff[preds$points > 30], preds$glmResid[preds$points > 30])
binnedplot(preds$teamDiff[preds$points > 30], preds$gbmResid[preds$points > 30])

binnedplot(preds$salary, preds$glmResid)
binnedplot(preds$salary, preds$gbmResid)

binnedplot(preds$centerSalary, preds$gbmResid)
binnedplot(preds$centerSalary, preds$gbmResid)

binnedplot(preds$gbmPred[preds$pgSameTeam == 1], preds$gbmResid[preds$pgSameTeam == 1])
binnedplot(preds$gbmPred[preds$sgSameTeam == 1], preds$gbmResid[preds$sgSameTeam == 1])
binnedplot(preds$gbmPred[preds$sfSameTeam == 1], preds$gbmResid[preds$sfSameTeam == 1])
binnedplot(preds$gbmPred[preds$pfSameTeam == 1], preds$gbmResid[preds$pfSameTeam == 1])



binnedplot(preds$pmin[preds$teamDiff < -25], preds$glmResid[preds$teamDiff< -25])
binnedplot(preds$pmin[preds$teamDiff < -25], preds$gbmResid[preds$teamDiff< -25])

binnedplot(preds$salary[preds$numbTeam > 14], preds$glmResid[preds$numbTeam > 14])
binnedplot(preds$salary[preds$numbTeam > 14], preds$gbmResid[preds$numbTeam > 14])

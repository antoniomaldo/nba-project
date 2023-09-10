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

modelGBM <- h2o.gbm(x = c("points" ,"salary", "numbTeamFactor", "teamDiff", "salaryPerTeams"), y = "bestTeamFactor",
                    #modelGBM <- h2o.gbm(x = c("points" ,"salary", "teamDiff"), y = "bestTeamFactor",
                    
                    training_frame = trainDataH2o, model_id = "BestTeamModel", 
                    seed = 12, 
                    nfolds = 10, 
                    keep_cross_validation_predictions = TRUE, 
                    fold_assignment = "Modulo", 
                    distribution = "bernoulli",
                    max_depth = 4,
                    min_rows = 400,
                    ntrees = 100)

h2o.auc(modelGBM)
h2o.auc(modelGBM, xval = T)

testData$gbmPred <- as.vector(h2o.predict(modelGBM, testDataH2o)$p1)
testData$gbmResid <- testData$bestTeam - testData$gbmPred

binnedplot(testData$salary, testData$gbmResid)
binnedplot(testData$salary[testData$numbTeam > 22], testData$gbmResid[testData$numbTeam > 22])

trainData$gbmPred <- as.vector(h2o.predict(modelGBM, trainDataH2o)$p1)

#GLM model
model <- glm(bestTeam ~ points * salary +
               numbTeam + 
               salary : numbTeam +
               points : numbTeam +
               #salary : I(numbTeam < 18) +
               #points : I(numbTeam < 18) +
               teamDiff 
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

preds$pooledPred <- (preds$glmPred + preds$gbmPred) / 2 

preds$glmResid <- preds$bestTeam - preds$glmPred
preds$gbmResid <- preds$bestTeam - preds$gbmPred
preds$pooledResid <- preds$bestTeam - preds$pooledPred

binnedplot(preds$teamDiff[preds$points > 30], preds$glmResid[preds$points > 30])
binnedplot(preds$teamDiff[preds$points > 30], preds$gbmResid[preds$points > 30])
binnedplot(preds$teamDiff[preds$points > 30], preds$pooledResid[preds$points > 30])

binnedplot(preds$salary, preds$glmResid)
binnedplot(preds$salary, preds$gbmResid)
binnedplot(preds$salary, preds$pooledResid)

binnedplot(preds$pmin[preds$teamDiff < -25], preds$glmResid[preds$teamDiff< -25])
binnedplot(preds$pmin[preds$teamDiff < -25], preds$gbmResid[preds$teamDiff< -25])
binnedplot(preds$pmin[preds$teamDiff < -25], preds$pooledResid[preds$teamDiff< -25])

binnedplot(preds$salary[preds$numbTeam > 14], preds$glmResid[preds$numbTeam > 14])
binnedplot(preds$salary[preds$numbTeam > 14], preds$gbmResid[preds$numbTeam > 14])
binnedplot(preds$salary[preds$numbTeam > 14], preds$pooledResid[preds$numbTeam > 14])

binnedplot(preds$salaryPerTeams[preds$numbTeam > 14], preds$glmResid[preds$numbTeam > 14])
binnedplot(preds$salaryPerTeams[preds$numbTeam > 14], preds$gbmResid[preds$numbTeam > 14])
binnedplot(preds$salaryPerTeams[preds$numbTeam > 14], preds$pooledResid[preds$numbTeam > 14])

binnedplot(preds$salary[preds$numbTeam < 14], preds$glmResid[preds$numbTeam < 14])
binnedplot(preds$salary[preds$numbTeam < 14], preds$gbmResid[preds$numbTeam < 14])

binnedplot(preds$salary[preds$numbTeam < 5], preds$glmResid[preds$numbTeam < 5])
binnedplot(preds$salary[preds$numbTeam < 5], preds$gbmResid[preds$numbTeam < 5])

binnedplot(preds$points[preds$numbTeam < 5], preds$glmResid[preds$numbTeam < 5])
binnedplot(preds$points[preds$numbTeam < 5], preds$gbmResid[preds$numbTeam < 5])

binnedplot(preds$teamDiff[preds$points < 20], preds$glmResid[preds$points < 20])
binnedplot(preds$teamDiff[preds$points < 20], preds$gbmResid[preds$points < 20])

binnedplot(preds$glmPred[abs(preds$matchSpread) > 5], preds$bestTeam[abs(preds$matchSpread) > 5] - preds$glmPred[abs(preds$matchSpread) > 5])
binnedplot(preds$glmPred[abs(preds$matchSpread) < 5], preds$bestTeam[abs(preds$matchSpread) < 5] - preds$glmPred[abs(preds$matchSpread) < 5])

binnedplot(preds$gbmPred[abs(preds$matchSpread) > 5], preds$bestTeam[abs(preds$matchSpread) > 5] - preds$gbmPred[abs(preds$matchSpread) > 5])
binnedplot(preds$gbmPred[abs(preds$matchSpread) < 5], preds$bestTeam[abs(preds$matchSpread) < 5] - preds$gbmPred[abs(preds$matchSpread) < 5])


binnedplot(preds$teamDiff[preds$points > 20], preds$glmResid[preds$points > 20])
binnedplot(preds$teamDiff[preds$points < 20], preds$glmResid[preds$points < 20])

binnedplot(preds$ceil, preds$glmResid)
binnedplot(preds$ceil, preds$gbmResid)

binnedplot(preds$points, preds$glmResid)
binnedplot(preds$points, preds$gbmResid)

binnedplot(preds$floor, preds$glmResid)
binnedplot(preds$floor, preds$gbmResid)

binnedplot(preds$glmPred, preds$glmResid)
binnedplot(preds$gbmPred, preds$gbmResid)
binnedplot(preds$pooledPred, preds$pooledResid)

binnedplot(preds$pmin, preds$glmResid)
binnedplot(preds$pmin, preds$gbmResid)
binnedplot(preds$pooledPred, preds$pooledResid)

mean(preds$bestTeam[preds$glmPred < 0.1])
mean(preds$bestTeam[preds$glmPred < 0.05])
mean(preds$bestTeam[preds$glmPred > 0.25])
mean(preds$bestTeam[preds$glmPred > 0.5])
mean(preds$bestTeam[preds$glmPred > 0.6])

#Adjust for salary and teams

trainData$glmPred <- predict(model, trainData, type = "response")

modelSalary <- glm(bestTeam ~ 
                     offset(log(glmPred / (1 - glmPred))) +
                     #salary : I(numbTeam == 18) +
                     #salary : I(numbTeam == 20) +
                     salary : I(numbTeam > 20) 
                   
                   , data = trainData, family = binomial)
summary(modelSalary)

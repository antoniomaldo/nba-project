baseDir = "C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\"

years <- list.files(baseDir, full.names = T)

alldata <- data.frame()

for(year in years){
  yearData <- do.call(rbind, lapply(list.files(year, full.names = T), read.csv))
  if(year ==  "C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\2021" | year ==  "C:\\Users\\Antonio\\Documents\\NBA\\data\\RotoGrinders\\mapped slate\\2022"){
    yearData$totalPoints = yearData$total + yearData$oppTotal
    yearData$matchSpread = ifelse(yearData$ishomeplayer, 1, -1) * (yearData$oppTotal - yearData$total) / 2
  }
  alldata <- rbind(alldata, yearData[c("seasonYear", "playerName", "PlayerId", "GameId","matchSpread","totalPoints", "HomeTeam", "Team", "pmin", "points", "fdPoints")])
}

alldata$isHomeTeam <- alldata$Team == alldata$HomeTeam
alldata$homeExp <- (alldata$totalPoints - alldata$matchSpread) / 2
alldata$awayExp <- (alldata$totalPoints + alldata$matchSpread) / 2

alldata$ownExp <- ifelse(alldata$isHomeTeam, alldata$homeExp, alldata$awayExp)
alldata$oppExp <- alldata$totalPoints - alldata$ownExp

alldata <- unique(alldata)

alldata$resid <- alldata$points - alldata$fdPoints

summary(alldata$resid)

alldata <- subset(alldata, !is.na(alldata$points))

binnedplot(alldata$points, alldata$resid)
binnedplot(alldata$ownExp, alldata$resid)
binnedplot(alldata$oppExp, alldata$resid)
binnedplot(alldata$pmin, alldata$resid)

binnedplot(alldata$points[alldata$seasonYear == 2018], alldata$resid[alldata$seasonYear == 2018])
binnedplot(alldata$points[alldata$seasonYear == 2019], alldata$resid[alldata$seasonYear == 2019])
binnedplot(alldata$points[alldata$seasonYear == 2020], alldata$resid[alldata$seasonYear == 2020])
binnedplot(alldata$points[alldata$seasonYear == 2021], alldata$resid[alldata$seasonYear == 2021])
binnedplot(alldata$points[alldata$seasonYear == 2022], alldata$resid[alldata$seasonYear == 2022])
binnedplot(alldata$ownExp[alldata$seasonYear == 2022], alldata$resid[alldata$seasonYear == 2022])

agg <- aggregate(pmin ~ GameId + Team, alldata, sum)
agg <- subset(agg, abs(agg$pmin - 240) <= 2)

agg$id = paste0(agg$GameId,"-",agg$Team)
alldata$id = paste0(alldata$GameId,"-",alldata$Team)

alldata <- subset(alldata, alldata$id %in% agg$id)

aggPoints <- aggregate(points ~ GameId + Team, alldata, sum)
colnames(aggPoints)[3] <- "teamPoints"
aggPoints <- merge(aggPoints, aggregate(fdPoints ~ GameId + Team, alldata, sum))
colnames(aggPoints)[4] <- "teamFdPoints"

aggPoints$totalResid <- aggPoints$teamPoints - aggPoints$teamFdPoints
binnedplot(aggPoints$teamPoints, aggPoints$totalResid)

alldata <- merge(alldata, aggPoints)
binnedplot(alldata$teamPoints, alldata$resid)

aggPoints$ratio <- aggPoints$teamFdPoints / aggPoints$teamPoints

aggPoints$over260RatioNeeded <- 260 / aggPoints$teamPoints
aggPoints$over260 <- 1 - pnorm(aggPoints$over260RatioNeeded, 1, sqrt(0.01282))
aggPoints$resid260 <- 1 * (aggPoints$teamFdPoints > 260) - aggPoints$over260

binnedplot(aggPoints$teamPoints, aggPoints$over260)
###

h2o.init()
testData <- subset(alldata, alldata$seasonYear > 2020 & alldata$fdPoints > 0)
testDataH2o <- as.h2o(subset(alldata, alldata$seasonYear > 2020 & alldata$fdPoints > 0))
trainDataH2o <- as.h2o(subset(alldata, alldata$seasonYear <= 2020 & alldata$fdPoints > 0))

modelGBMPred <- h2o.gbm(x = c("points" ,"pmin", "ownExp", "oppExp", "teamPoints"), y = "fdPoints",
                        training_frame = trainDataH2o, model_id = "fdPointsModel", 
                        seed = 12, 
                        nfolds = 10, 
                        keep_cross_validation_predictions = TRUE, 
                        fold_assignment = "Modulo", 
                        distribution = "gamma",
                        max_depth = 2,
                        min_rows = 600,
                        ntrees = 100)

h2o.performance(modelGBMPred)
h2o.performance(modelGBMPred, xval = T)

testData$fdPointsPred <- as.vector(h2o.predict(modelGBMPred, testDataH2o))
testData$gbmResid <- as.numeric(testData$fdPoints) - testData$fdPointsPred

binnedplot(testData$points, testData$gbmResid)
binnedplot(testData$teamPoints, testData$gbmResid)
binnedplot(testData$pmin, testData$gbmResid)
binnedplot(testData$oppExp, testData$gbmResid)

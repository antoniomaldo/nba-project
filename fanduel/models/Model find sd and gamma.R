#Find sd

#Assume gaussian

optimizeSd <- function(par, mean, ceil, probOverCeil){
  probOver = 1 - pnorm(q = ceil, mean = mean, sd = par)
  return((probOverCeil - probOver) ^ 2)
}

optimizeGammaShape <- function(par, mean, ceil, probOverCeil){
  probOver = 1 - pgamma(q = ceil, shape = mean / par, scale = par)
  return(abs((probOverCeil - probOver)))
}

findSd <- function(mean, ceil, probOverCeil){
  sol = optim(par = 1, fn = optimizeSd, mean = mean, ceil = ceil, probOverCeil = probOverCeil, method = "Brent", lower = 0, upper = 100)  
  return(sol$par)
}

findShape <- function(mean, ceil, probOverCeil){
  sol = optimize(f = optimizeGammaShape, mean = mean, ceil = ceil, probOverCeil = probOverCeil, c(0, 100), tol = 0.02)  
  minValue = 1
  for(i in 1:1000){
    value = optimizeGammaShape(i / 10, mean, ceil, probOverCeil)
    if(value < minValue){
      point = i / 10
      minValue = value
    }
  }
  if(minValue < 0.01){
    return(point)
  }else{
    return(-1)
  }
}

findSdV <- Vectorize(findSd)
findShapeV <- Vectorize(findShape)

testData$testSd <- findSdV(mean = testData$gbmPointsPred, ceil = testData$ceil, probOverCeil = testData$gbmPred)
testData$testShape <- findShapeV(mean = testData$gbmPointsPred, ceil = testData$ceil, probOverCeil = testData$gbmPred)


sensibleGamma <- subset(testData, testData$testShape > 2 & testData$testShape < 5)

sensibleGamma$sim <- 0
for(i in 1:nrow(sensibleGamma)){
  sensibleGamma$sim[i] <- rgamma(1, shape = sensibleGamma$gbmPointsPred[i] / sensibleGamma$testShape[i], scale = sensibleGamma$testShape[i])
}

sensibleGamma$resid <- sensibleGamma$fdPoints - sensibleGamma$sim

binnedplot(sensibleGamma$gbmPointsPred, sensibleGamma$resid)
binnedplot(sensibleGamma$testShape, sensibleGamma$resid)

binnedplot(sensibleGamma$gbmPointsPred[sensibleGamma$testShape > 4], sensibleGamma$resid[sensibleGamma$testShape > 4])
binnedplot(sensibleGamma$gbmPointsPred[sensibleGamma$testShape < 4], sensibleGamma$resid[sensibleGamma$testShape < 4])

cleanData <- function(data) {
  data$date_recorded <- as.Date(data$date_recorded) 
  data$age <- 0
  data[data$construction_year>0,]$age <- (data[data$construction_year>0,]$date_recorded - as.Date(ISOdate(data[data$construction_year>0,]$construction_year, 7, 1)))
  data$age <- round(data$age / 365.25)
  
  data$has_population <- 0
  data[data$population>0,]$has_population <- 1
  
  data$has_amount_tsh <- 0
  data[data$amount_tsh>0,]$has_amount_tsh <- 1
  
  data$has_construction_year <- 1
  data[data$construction_year==0,]$has_construction_year <- 0 
  
  return(data)
}



readAndCleanData <- function() {
  library(lubridate)
  water_table <- read.csv(paste(RootFilePath, "tanzania-X-train.csv", sep=""))
  water_table_y <<- read.csv(paste(RootFilePath, "tanzania-y-train.csv", sep=""))
  water_table_test <- read.csv(paste(RootFilePath, "tanzania-X-test.csv", sep=""))
  
  #water_table$y <- water_table_y$status_group
  
  water_table <<- cleanData(water_table)
  water_table_test <<- cleanData(water_table_test)
}

load_packages <- function (packagesToLoad){
  for(packageToLoad in packagesToLoad) {
    if (!require(packageToLoad, character.only = TRUE)) {
      install.packages(packageToLoad)
      library(packageToLoad, character.only = TRUE)
    }
  }
}

readAndCleanData()
remove(readAndCleanData)
remove(cleanData)

writeFile <- function(fileName, data){
  toSave <- data.frame(water_table_test$id, data)
  colnames(toSave) = c("id","status_group")
  if(!endsWith(fileName, ".csv"))
    fileName <- paste(OutputFilePath, fileName, ".csv")
  write.csv(toSave, file=fileName, row.names=FALSE)
}



cleanData <- function(data) {
  data$date_recorded <- as.Date(data$date_recorded) 
  data$age <- 0
  data[data$construction_year>0,]$age <- (data[data$construction_year>0,]$date_recorded - as.Date(ISOdate(data[data$construction_year>0,]$construction_year, 7, 1)))
  data$age <- round(data$age / 365.25)
  data[data$age <0,]$age <- 0 
  
  data$has_population <- 0
  data[data$population>0,]$has_population <- 1
  
  data$has_amount_tsh <- 0
  data[data$amount_tsh>0,]$has_amount_tsh <- 1
  
  data$has_construction_year <- 1
  data[data$construction_year==0,]$has_construction_year <- 0
  
  data$has_gps_height <- 1
  data[data$gps_height==0,]$has_gps_height <- 0
  
  data$has_cpg_missing_data <- !(data$has_construction_year & data$has_population  & data$has_gps_height)
  data$has_cpg_some_data <- (data$has_construction_year | data$has_population  | data$has_gps_height)
  
  data$has_bad_latOrLong <- 0
  data[(round(data$latitude,3) ==0 | round(data$longitude,3) == 0),]$has_bad_latOrLong <- 1 
  
  data <- addElevation(data)
  return(data)
}

addElevation <- function(data) {
  
  
  data_latlong <- data.frame(data$id, data$latitude, data$longitude)
  nrow(data_latlong)
  colnames(data_latlong) <- c("id", "latitude","longitude")
  
  ## Round to 5 variables since that's the precision on the elevation file 
  data_latlong$latitude <- round(data_latlong$latitude,5)
  data_latlong$longitude<- round(data_latlong$longitude,5)
  
  ### rename to have consistent column names for merge
  colnames(elevation_file) <- c("latitude","longitude","elevation")
  elevation_file$elevation <- round(elevation_file$elevation)
  
  
  
  data_latlong_joined <- left_join(data_latlong,elevation_file,by=c("latitude","longitude"))
  data$elevation <- data_latlong_joined$elevation
  data[data$has_gps_height==1,]$elevation <- data[data$has_gps_height==1,]$gps_height
  
  data$missing_elevation <- 0 
  data[is.na(data$elevation),]$missing_elevation <- 1

  return(data)
}

fixNAElevationValues <- function (){
  elevation_by_region <- water_table[!is.na(water_table$elevation),c("region","elevation")]
  elevation_by_region <- rbind(elevation_by_region, water_table_test[!is.na(water_table_test$elevation),c("region","elevation")])
  elevation_by_region <- group_by(elevation_by_region, region)
  elevation_by_region <- data.frame(summarize(elevation_by_region, mean_elevation=mean(elevation)))
  
  water_table[water_table$missing_elevation==1,]$elevation <<-
    round(merge(water_table[is.na(water_table$elevation),], elevation_by_region, by=c("region"))$mean_elevation)
  
  water_table_test[is.na(water_table_test$elevation),]$elevation <<-
    round(merge(water_table_test[is.na(water_table_test$elevation),], elevation_by_region, by=c("region"))$mean_elevation)
}


readAndCleanData <- function() {
  library(lubridate)
  water_table <- read.csv(paste(RootFilePath, "tanzania-X-train.csv", sep=""))
  water_table_y <<- read.csv(paste(RootFilePath, "tanzania-y-train.csv", sep=""))
  water_table_test <- read.csv(paste(RootFilePath, "tanzania-X-test.csv", sep=""))
  elevation_file1 <- read.csv(paste(RootFilePath, "elevation.csv", sep=""))
  elevation_file2 <- read.csv(paste(RootFilePath, "test-elevation.csv", sep=""))
  elevation_file <<- rbind(elevation_file1, elevation_file2)
  colnames(elevation_file) <- c("latitude","longitude","elevation")
  
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

load_packages(c("dplyr"))
readAndCleanData()
fixNAElevationValues()
remove(readAndCleanData)
remove(cleanData)
remove(elevation_file)
remove(addElevation)


writeFile <- function(fileName, data){
  toSave <- data.frame(water_table_test$id, data)
  colnames(toSave) = c("id","status_group")
  if(!endsWith(fileName, ".csv"))
    fileName <- paste(OutputFilePath, fileName, ".csv")
  write.csv(toSave, file=fileName, row.names=FALSE)
}



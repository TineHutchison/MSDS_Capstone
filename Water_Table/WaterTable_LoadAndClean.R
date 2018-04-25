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
  
  data$monthRecorded <- month(data$date_recorded)
  
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

addFunderCategory <- function(data) {
  ########### START::: shameless borrowed from https://nycdatascience.com/blog/student-works/linlin_cheng_proj_5/: 
  #generate a new variable to categorize funders:
  fun<-as.character(data$funder)
  
  #
  f_gov<-c('danida', 'A/co germany', 'belgian', 'british', 'england', 'german', 'germany',
           'china', 'egypt', 'European Union', 'finland', 'japan', 'france', 'greec',
           'netherlands', 'holland', 'holand', 'nethe', 'nethalan', 'netherla', 'netherlands',
           'iran', 'irish', 'islam','italy', 'U.S.A', 'usa', 'usaid', 'swiss', 'swedish','korea', 'niger'
  ) #'Jica',
  NGO<-c('World Bank', 'Ngo', "Ngos", "Un","Un Habitat", "Un/wfp", "Undp", "Undp/aict", "Undp/ilo", "Unesco",                        
         "Unhcr", "Unhcr/government", "Unice", "Unice/ Cspd", "Unicef", "Unicef/ Csp", "Unicef/african Muslim Agency", 
         "Unicef/central", "Unicef/cspd", "Uniceg", "Unicet", "Unicrf", "Uniseg", "Unp/aict", "wwf", "wfp")
  local_commu <- unique(c(agrep('commu', data$funder, value=TRUE), #includes commu for community, vill for village
                          agrep('vill', data$funder, value=TRUE)))
  tanz_gov<- unique(c(agrep('Government of Tanzania', data$funder, value=TRUE), #includes commu for community, vill for village
                      agrep('wsdp', data$funder, value=TRUE)))               
  
  unique(fun[agrep('wsdp', fun)])
  
  data$funder = as.character(data$funder)
  
  temp = data$funder
  
  for (i in 1:length(NGO)){
    temp = replace(temp, 
                   agrep(NGO[i], temp),
                   'UN_agencies')
  }
  
  for (i in 1:length(f_gov)){
    temp = replace(temp, 
                   agrep(f_gov[i], temp),
                   'foreign_gov')
  }
  
  for (i in 1:length(local_commu)){
    temp = replace(temp, 
                   agrep(local_commu[i], temp), 
                   "local_community")
  }
  
  
  for (i in 1:length(tanz_gov)){
    temp = replace(temp, 
                   agrep(tanz_gov[i], temp), 
                   "Tanzania_Gov")
  }
  
  
  temp = replace(temp, 
                 temp != "UN_agencies" & temp != 'foreign_gov' & temp != 'local_community' & temp != 'Tanzania_Gov',
                 'other')
  
  #table(data$label, data$funder_cat)
  data$funder_cat<-factor(temp)
  return(data)
  ########### END::: shameless borrowed from https://nycdatascience.com/blog/student-works/linlin_cheng_proj_5/: 
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

fixSchemeManagement <- function() {
  water_table_test$scheme_management <<- factor(water_table_test$scheme_management, levels=c(levels(water_table$scheme_management)))
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

library("dplyr")
library("lubridate")
readAndCleanData()
fixNAElevationValues()
water_table <<- addFunderCategory(water_table)
water_table_test <<- addFunderCategory(water_table_test)
fixSchemeManagement()
remove(readAndCleanData)
remove(cleanData)
remove(elevation_file)
remove(addElevation)

set.seed(3)
train_size <- .75
training_rows <- sample(nrow(water_table), round(nrow(water_table)*train_size))
water_table_train <<- water_table[training_rows,] 
water_table_train_y <<- water_table_y[training_rows,] 
water_table_holdout <<- water_table[-training_rows,] 
water_table_holdout_y <<- water_table_y[-training_rows,] 



writeFile <- function(fileName, data){
  toSave <- data.frame(water_table_test$id, data)
  colnames(toSave) = c("id","status_group")
  if(!endsWith(fileName, ".csv"))
    fileName <- paste(OutputFilePath, fileName, ".csv")
  write.csv(toSave, file=fileName, row.names=FALSE)
}



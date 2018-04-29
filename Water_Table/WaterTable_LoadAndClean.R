library("dplyr")
library("lubridate")
library("tree")



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
  
  data$logpop <- log(data$population+1)
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
  water_table <- read.csv("tanzania-X-train.csv")
  water_table_y <<- read.csv("tanzania-y-train.csv")
  water_table_test <- read.csv( "tanzania-X-test.csv")
  elevation_file1 <- read.csv("elevation.csv")
  elevation_file2 <- read.csv("test-elevation.csv")
  elevation_file <<- rbind(elevation_file1, elevation_file2)
  colnames(elevation_file) <- c("latitude","longitude","elevation")
  
  water_table <<- cleanData(water_table)
  water_table_test <<- cleanData(water_table_test)

}




generateTrainingAndHoldout <- function() {
  set.seed(3)
  train_size <- .75
  training_rows <- sample(nrow(water_table), round(nrow(water_table)*train_size))
  
  water_table_train <<- water_table[training_rows,] 
  water_table_train_y <<- water_table_y[training_rows,] 
  water_table_holdout <<- water_table[-training_rows,] 
  water_table_holdout_y <<- water_table_y[-training_rows,] 
}






writeFile <- function(fileName, data){
  toSave <- data.frame(water_table_test$id, data)
  colnames(toSave) = c("id","status_group")
  if(!endsWith(fileName, ".csv"))
    fileName <- paste( fileName, ".csv")
  write.csv(toSave, file=fileName, row.names=FALSE)
}



imputeElevation2 <- function() {
  FieldList <- c(
    #"id"
    "amount_tsh"
    #"date_recorded"
    #,"funder"
    ,"gps_height"
    #,"installer"
    ,"longitude"
    ,"latitude"
    #,"wpt_name"
    ,"num_private"
    ,"basin"
    #,"subvillage"
    #,"region"
    ,"region_code"
    ,"district_code"
    #,"lga"
    #,"ward"
    #,"population"
    ,"public_meeting"
    #,"recorded_by"
    #,"scheme_management"
    #,"scheme_name"
    ,"permit"
    ,"construction_year"
    #,"extraction_type"
    ,"extraction_type_group"
    ,"extraction_type_class"
    #,"management"
    ,"management_group"
    ,"payment"
    #,"payment_type"
    ,"water_quality"
    #,"quality_group"
    #,"quantity"
    ,"quantity_group"
    ,"source"
    ,"source_type"
    ,"source_class"
    #,"waterpoint_type"
    ,"waterpoint_type_group"
    #,"age"
    #,"has_population"
    #,"has_amount_tsh"
    ,"has_construction_year"
    #,"has_gps_height"
    #,"has_cpg_missing_data"
    #,"has_cpg_some_data"
    #,"has_bad_latOrLong"
    #,"monthRecorded"
    ,"logpop"
    #,"elevation"
    #,"missing_elevation"
    #,"funder_cat"
    #,"age_imp"
    #,"region_new"
  )
  
  data_elevation_train <- water_table[,FieldList]
  data_elevation_test <- water_table_test[,FieldList]

  library(randomForest)
  set.seed(42)
  elevationForest <- randomForest(data_elevation_train[water_table$has_gps_height==1,]$gps_height ~ .,data=data_elevation_train[water_table$has_gps_height==1,], ntree=20)
  water_table$elevation2 <- round(predict(elevationForest, data_elevation_train))
  water_table[water_table$has_gps_height==1,]$elevation2 <- water_table[water_table$has_gps_height==1,]$gps_height

  water_table_test$elevation2 <- round(predict(elevationForest, data_elevation_test))
  water_table_test[water_table_test$has_gps_height==1,]$elevation2 <- water_table_test[water_table_test$has_gps_height==1,]$gps_height

  water_table_test <<- water_table_test
  water_table <<- water_table
}


addLogPop2 <- function(){
  library(randomForest)
  AddLogPopFieldList <- c(
    #"id"
    "amount_tsh"
    #"date_recorded"
    #,"funder"
    ,"gps_height"
    #,"installer"
    ,"longitude"
    ,"latitude"
    #,"wpt_name"
    ,"num_private"
    ,"basin"
    #,"subvillage"
    #,"region"
    ,"region_code"
    ,"district_code"
    #,"lga"
    #,"ward"
    #,"population"
    ,"public_meeting"
    #,"recorded_by"
    #,"scheme_management"
    #,"scheme_name"
    ,"permit"
    ,"construction_year"
    #,"extraction_type"
    ,"extraction_type_group"
    ,"extraction_type_class"
    #,"management"
    ,"management_group"
    ,"payment"
    #,"payment_type"
    ,"water_quality"
    #,"quality_group"
    #,"quantity"
    ,"quantity_group"
    ,"source"
    ,"source_type"
    ,"source_class"
    #,"waterpoint_type"
    ,"waterpoint_type_group"
    #,"age"
    #,"has_population"
    #,"has_amount_tsh"
    ,"has_construction_year"
    #,"has_gps_height"
    #,"has_cpg_missing_data"
    #,"has_cpg_some_data"
    #,"has_bad_latOrLong"
    #,"monthRecorded"
    ,"logpop"
    #,"elevation"
    #,"missing_elevation"
    #,"funder_cat"
    #,"age_imp"
    #,"region_new"
  )
  
  
  data_age_train <- water_table[,AddLogPopFieldList]
  data_age_test <- water_table_test[,AddLogPopFieldList]
  
  library(randomForest)
  populationForest <- randomForest(logpop ~ .,data=data_age_train[data_age_train$logpop>0,], ntree=10)

  data_age_train$logpop_imp <- predict(populationForest, data_age_train)
  data_age_train[data_age_train$logpop>0,]$logpop_imp <- data_age_train[data_age_train$logpop>0,]$logpop

  data_age_test$logpop_imp <- predict(populationForest, data_age_test)
  data_age_test[data_age_test$logpop>0,]$logpop_imp <- data_age_test[data_age_test$logpop>0,]$logpop
  
  water_table$logpop_imp <- data_age_train$logpop_imp
  water_table_test$logpop_imp <- data_age_test$logpop_imp
  water_table <<- water_table
  water_table_test <<- water_table_test
}





imputeAge <- function() {
  treeAge <- tree(age ~ .  - date_recorded - gps_height - latitude -longitude -region - region_code - id - recorded_by - extraction_type  - funder - construction_year - installer - wpt_name - subvillage - ward - lga  
                                 - scheme_name - scheme_management
                                 , data=water_table[water_table$has_construction_year==1,])
  
  water_table$age_imp <- water_table$age
  water_table[water_table$has_construction_year==0,]$age_imp <- predict(treeAge, water_table[water_table$has_construction_year==0,])
  water_table$age_imp <- round(water_table$age_imp)
  
  water_table_test$age_imp <- water_table_test$age
  water_table_test[water_table_test$has_construction_year==0,]$age_imp <- predict(treeAge, water_table_test[water_table_test$has_construction_year==0,])
  water_table_test$age_imp <- round(water_table_test$age_imp)
  
  water_table_test <<- water_table_test
  water_table <<- water_table
}

addNewRegion <- function() {
  tz_region_train <- read.csv("TZ_region_train.csv")
  water_table$region_new <- factor(toupper(tz_region_train$TZ_Region))
  
  
  tz_region_test <- read.csv("TZ_region_test.csv")
  water_table_test$region_new <- factor(toupper(tz_region_test$TZ_Region))

  water_table_test <<- water_table_test
  water_table <<- water_table
}

imputeLatLong <- function() {
  
  group_by_latitude <- water_table[water_table$has_bad_latOrLong==0,] %>%
    group_by(region_code) %>%
    summarise(median(latitude))
  
  
  colnames(group_by_latitude) <- c("region_code","latitude_imp") 
  
  
  
  group_by_longitude <- water_table[water_table$has_bad_latOrLong==0,] %>%
    group_by(region_code) %>%
    summarise(median(longitude))
  
  colnames(group_by_longitude) <- c("region_code","longitude_imp") 
  
  group_by_longitude
  
  left_join(water_table, group_by_longitude, c=c("region_code"))
  
  water_table$longitude_imp <- left_join(water_table, group_by_longitude, c=c("region_code"))[,c("longitude_imp")]
  water_table[water_table$has_bad_latOrLong==0,]$longitude_imp <- water_table[water_table$has_bad_latOrLong==0,]$longitude
  
  water_table$latitude_imp <- left_join(water_table, group_by_latitude, c=c("region_code"))[,c("latitude_imp")]
  water_table[water_table$has_bad_latOrLong==0,]$latitude_imp <- water_table[water_table$has_bad_latOrLong==0,]$latitude
  
  
  water_table_test$longitude_imp <- left_join(water_table_test, group_by_longitude, c=c("region_code"))[,c("longitude_imp")]
  water_table_test[water_table_test$has_bad_latOrLong==0,]$longitude_imp <- water_table_test[water_table_test$has_bad_latOrLong==0,]$longitude
  
  water_table_test$latitude_imp <- left_join(water_table_test, group_by_latitude, c=c("region_code"))[,c("latitude_imp")]
  water_table_test[water_table_test$has_bad_latOrLong==0,]$latitude_imp <- water_table_test[water_table_test$has_bad_latOrLong==0,]$latitude
  
  water_table_test <<- water_table_test
  water_table <<- water_table
  
}

readAndCleanData()
fixNAElevationValues()
water_table <<- addFunderCategory(water_table)
water_table_test <<- addFunderCategory(water_table_test)
fixSchemeManagement()
remove(readAndCleanData)
remove(cleanData)
remove(elevation_file)
remove(addElevation)
imputeAge() 
addNewRegion()
imputeElevation2()
addLogPop2()
imputeLatLong()
generateTrainingAndHoldout() 

# write.csv(water_table,"tanzania-X-train-v3.csv", row.names = FALSE)
# write.csv(water_table_test,"tanzania-X-test-v3.csv", row.names = FALSE)


write.csv(water_table,"v4.csv", row.names = FALSE)
write.csv(water_table_test,"testv4.csv", row.names = FALSE)

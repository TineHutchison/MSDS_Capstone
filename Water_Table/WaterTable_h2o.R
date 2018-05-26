################# START: variables and libraries for submission information
library("randomForest")
library("caret")
library("e1071")
library("lubridate")
library("h2o" )

################# END: variables and libraries for submission information

#source("WaterTable_LoadAndClean.R")
source("WaterTable_LoadAndClean_v2.R")
source("WaterTable_WriteResults.R")
set.seed(400)
RandomForestFieldList <<- c(
  #"id"
  #"amount_tsh"
  #,
  "log_amount_tsh"
  #,
  ,"has_amount_tsh"
  
  
  #,
  ,"date_recorded"
  ,"monthRecorded"
  
  #### funder or funder_cat. 
  ,"funder"
  #,"funder_cat"     
  
  
  ## either gps_height, elevation, gps_height_mice or elevation2
  ,"has_gps_height"    # 1 if gps_height != 0
  #,"gps_height"
  #,"elevation"
  #,"missing_elevation"    #if gps_height == 0 and it can't be imputed based on GPS coordinates
  ,"elevation2"           # imputed elevation based on a randomForest
  
  
  ### missing latitude and longitude
  ,"has_bad_latOrLong"
  
  ###longitude or logitude_imp
  #,"longitude"
  ,"longitude_imp"        
  
  ###latitude or latitude_imp
  #,"latitude"
  ,"latitude_imp"
  
  
  ### region, region_new, region_code (they mostly overlap, although not entirely). 
  #   Region is slightly preferred since it doesn't have the potential to be interpretted as a numeric.  
  ,"region"
  #,"region_code"
  #,"region_new"
  
  
  ### Make sure this is a factor. 
  #,"district_code"
  
  ### other location based fields
  ,"basin"
  #,"subvillage"
  ,"lga"
  #,"ward"
  
  
  ### use only construction_year, age or age_imp
  #,"construction_year"
  ,"has_construction_year"
  #,"age"
  ,"age_imp"
  
  
  ### population fields. Pick population, logpop, logpop_imp
  ,"has_population"
  #,"population"
  #,"logpop"
  ,"logpop_imp"
  
  
  
  ,"installer"
  #,"wpt_name"
  ,"num_private"
  ,"public_meeting"
  #,"recorded_by"
  ,"scheme_management"
  ,"scheme_name"
  ,"permit"
  ,"extraction_type"
  ,"extraction_type_group"
  ,"extraction_type_class"
  ,"management"
  ,"management_group"
  
  #### only need payment or payment_type since they're a 1-to-1 match
  ,"payment"
  #,"payment_type"
  
  
  ,"water_quality"
  ,"quality_group"
  
  ### quantity 
  #,"quantity"
  ,"quantity_group"
  
  ,"source"
  ,"source_type"
  ,"source_class"
  ,"waterpoint_type"
  ,"waterpoint_type_group"
  
  #### whether cpg has any missing data
  #,"has_cpg_missing_data"    # missing all construction_year, population, gps_height
  ,"has_cpg_some_data"       # missing some of the fields construction_year, population, gps_height
  #,"funder_sz"
  #,"has_scheme_name"
)

randomForest_data_train <- water_table_train[,RandomForestFieldList]
randomForest_data_holdout <- water_table_holdout[,RandomForestFieldList]

randomForest_data_train$days <- as.integer(as.Date("14/01/01", format="%y/%m/%d") - randomForest_data_train$date_recorded )
randomForest_data_holdout$days <- as.integer(as.Date("14/01/01", format="%y/%m/%d") - randomForest_data_holdout$date_recorded) 



library(h2o)
#h2o.shutdown(prompt=FALSE)

h2o.init(nthreads=-1)
h2o.removeAll()
?h2o.init

set.seed(42)
# 
# 
# 
# water_table_train_h2o <- cbind(randomForest_data_train, water_table_train_y$status_group)
# water_table_holdout_h2o <- cbind(randomForest_data_holdout, water_table_holdout_y$status_group)
# 
# colnames(water_table_train_h2o)[ncol(water_table_train_h2o)] <- "status_group"
# colnames(water_table_holdout_h2o)[ncol(water_table_train_h2o)] <- "status_group"
# 
# trainH2o<-as.h2o(water_table_train_h2o)
# features<-colnames(trainH2o)
# 
# holdoutH2o<-as.h2o(water_table_holdout_h2o)
# randomForesth2o_trainData <- h2o.randomForest(features,"status_group", trainH2o, ntrees=1000, mtries=9, max_depth=22, nbins=22, seed=42)
# summary(randomForesth2o_trainData)
# h2o.varimp_plot(randomForesth2o_trainData)
# 
# 
# 
# predictionH2o <- predict(randomForesth2o_trainData, holdoutH2o)
# confusionMatrix(as.data.frame(predictionH2o$predict)$predict, water_table_holdout_y$status_group)
# 
# vip <- as.data.frame(h2o.varimp(randomForesth2o_trainData))
# print(vip)
# 
# 







#### For file for submission
randomForest_data_full <- water_table[,RandomForestFieldList]
randomForest_data_test <- water_table_test[,RandomForestFieldList]
randomForest_data_full$days <- as.integer(as.Date("14/01/01", format="%y/%m/%d") - randomForest_data_full$date_recorded )
randomForest_data_test$days <- as.integer(as.Date("14/01/01", format="%y/%m/%d") - randomForest_data_test$date_recorded )


water_table_h2o <- cbind(randomForest_data_full, water_table_y$status_group)
water_table_test_h2o <- cbind(randomForest_data_test) 

colnames(water_table_h2o)[ncol(water_table_h2o)] <- "status_group"


fullH2o<-as.h2o(water_table_h2o)
features<-colnames(fullH2o)
testH2o <- as.h2o(water_table_test_h2o)

#summary(randomForesth2o_AllData)
### Current best - randomForesth2o_AllData <- h2o.randomForest(features,mtries=9, max_depth=22, nbins=22,"status_group", fullH2o, ntrees=2500, seed=42)
### Test #2 - randomForesth2o_AllData <- h2o.randomForest(features,mtries=9, max_depth=21, nbins=21,"status_group", fullH2o, ntrees=2500, seed=42)
#### Original - randomForesth2o_AllData <- h2o.randomForest(features,mtries=16,"status_group", fullH2o, ntrees=2500, seed=42)
randomForesth2o_AllData <- h2o.randomForest(features,mtries=9, max_depth=21, nbins=21,"status_group", fullH2o, ntrees=2500, seed=42)
randomForesth2o_AllData
predictionH2o <- predict(randomForesth2o_AllData, testH2o)

writeResultsFileForSubmission("Winning model - h20 elevation imputation(with has_cpg_some_data ) - Random Forest (h2o) Simple added (+high factor vars) and post grid search (21-9-21), trees=2500", as.data.frame(predictionH2o$predict))

h2o.varimp_plot(randomForesth2o_AllData)
#h2o.shutdown(prompt=FALSE)

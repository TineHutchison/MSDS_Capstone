################# START: variables and libraries for submission information

numberOfTrees <- 5000
submissionName <- "Random Forest Simple with missing and imputed elevation added, funder category"

library("randomForest")
library("caret")
library("e1071")
?library
library("lubridate")
library("h2o" )
h2o.getVersion()
################# END: variables and libraries for submission information

#source("WaterTable_LoadAndClean.R")

RandomForestFieldList <<- c(
  #"id"
  #,"amount_tsh"
  #,"has_amount_tsh"
  
  
  "date_recorded"
  ,"monthRecorded"
  
  #### funder or funder_cat. 
  #,"funder"
  #,"funder_cat"     
  
  
  ## either gps_height, elevation, gps_height_mice or elevation2
  #,"has_gps_height"    # 1 if gps_height != 0
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
  #,"lga"
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
  
  
  
  #,"installer"
  #,"wpt_name"
  ,"num_private"
  ,"public_meeting"
  #,"recorded_by"
  ,"scheme_management"
  #,"scheme_name"
  ,"permit"
  #,"extraction_type"
  ,"extraction_type_group"
  ,"extraction_type_class"
  ,"management"
 # ,"management_group"
  
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
  #,"funder_sz"
  
  #### whether cpg has any missing data
  #,"has_cpg_missing_data"    # missing all construction_year, population, gps_height
  #,"has_cpg_some_data"       # missing some of the fields construction_year, population, gps_height
)
randomForest_data_train <- water_table_train[,RandomForestFieldList]
randomForest_data_holdout <- water_table_holdout[,RandomForestFieldList]
randomForest_data_full <- water_table[,RandomForestFieldList]
randomForest_data_test <- water_table_test[,RandomForestFieldList]

randomForest_data_train$days <- as.integer(as.Date("14/01/01", format="%y/%m/%d") - randomForest_data_train$date_recorded )
randomForest_data_holdout$days <- as.integer(as.Date("14/01/01", format="%y/%m/%d") - randomForest_data_holdout$date_recorded) 
randomForest_data_full$days <- as.integer(as.Date("14/01/01", format="%y/%m/%d") - randomForest_data_full$date_recorded )
randomForest_data_test$days <- as.integer(as.Date("14/01/01", format="%y/%m/%d") - randomForest_data_test$date_recorded )

as.integer()
class(as.integer(randomForest_data_train$days))
?as.Date
?Date
summary(randomForest_data_train)


h2o.init(nthreads=-1,max_mem_size='16G')
#h2o.shutdown(prompt=FALSE)
set.seed(42)




water_table_train_h2o <- cbind(randomForest_data_train, water_table_train_y$status_group)
water_table_holdout_h2o <- cbind(randomForest_data_holdout, water_table_holdout_y$status_group) 

colnames(water_table_train_h2o)[ncol(water_table_train_h2o)] <- "status_group"
#remove(features)
colnames(water_table_holdout_h2o)[ncol(water_table_train_h2o)] <- "status_group"


#importance(randomForest_Training)
#confusionMatrix(water_table_holdout_y$status_group, predict(randomForest_Training, water_table_holdout))

trainH2o<-as.h2o(water_table_train_h2o)
features<-colnames(trainH2o)
#features[35] <- "status_group"

holdoutH2o<-as.h2o(water_table_holdout_h2o)
features<-colnames(holdoutH2o)
#features[35] <- "status_group"
summary(holdoutH2o)
####### run full model and write results to file
#set.seed(42)
#h2o.getFrame(water_table)
randomForest_AllData <- h2o.randomForest(features,mtries=16,"status_group", trainH2o, ntrees=1000)
?h2o.randomForest
randomForest_AllData
summary(randomForest_AllData)
predictionH2o <- predict(randomForest_AllData, holdoutH2o)
colnames(as.data.frame(predictionH2o$predict))
confusionMatrix(as.data.frame(predictionH2o$predict)$predict, water_table_holdout_y$status_group)


water_table_h2o <- cbind(randomForest_data_full, water_table_y$status_group)
water_table_test_h2o <- cbind(randomForest_data_test) 

colnames(water_table_h2o)[ncol(water_table_h2o)] <- "status_group"
#remove(features)
#colnames(water_table_test_h2o)[ncol(water_table_test_h2o)] <- "status_group"

fullH2o<-as.h2o(water_table_h2o)
features<-colnames(fullH2o)
testH2o <- as.h2o(water_table_test_h2o)

summary(randomForesth2o_AllData)
randomForesth2o_AllData <- h2o.randomForest(features,mtries=16,"status_group", fullH2o, ntrees=2500)

 
predictionH2o <- predict(randomForesth2o_AllData, testH2o)
colnames(as.data.frame(predictionH2o$predict))


writeFile("Random Forest (h2o) Simple with missing and imputed elevation added, trees=2500", as.data.frame(predictionH2o$predict))


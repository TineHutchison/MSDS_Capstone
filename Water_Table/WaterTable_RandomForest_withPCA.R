source("WaterTable_LoadAndClean_v2.R")
source("WaterTable_WriteResults.R")




library("caret")
library("randomForest")
################# START: variables and libraries for submission information
numberOfTrees <- 500
################# END: variables and libraries for submission information


PCAFieldList <<- c(
  #"amount_tsh"
  "monthRecorded"
  ,"elevation2"           # imputed elevation based on a randomForest
  ,"longitude_imp"        
  ,"latitude_imp"
  ,"age_imp"
  ,"logpop_imp"
)

PCA_data_train <- water_table_train[,PCAFieldList]
PCA_data_holdout <- water_table_holdout[,PCAFieldList]
PCA_data_full <- water_table[,PCAFieldList]
PCA_data_test <- water_table_test[,PCAFieldList]

colMeans(PCA_data_full)
pca_data <- prcomp(PCA_data_full,
                   center = TRUE,
                   scale. = TRUE) 

pca1 <- predict(pca_data, PCA_data_holdout)
plot(pca_data, type = "l")
summary(pca_data)
pca_data$rotation
pca1 <- data.frame(pca1)

water_table$pc1 <- pca1$PC1
water_table$pc2 <- pca1$PC2
water_table$pc3 <- pca1$PC3
water_table$pc4 <- pca1$PC4
water_table$pc5 <- pca1$PC5
#pca1$PC1
pca1_test <- predict(pca_data, PCA_data_test)
pca1_test <- data.frame(pca1_test)
water_table_test$pc1 <- pca1_test$PC1
water_table_test$pc2 <- pca1_test$PC2
water_table_test$pc3 <- pca1_test$PC3
water_table_test$pc4 <- pca1_test$PC4
water_table_test$pc5 <- pca1_test$PC5


generateTrainingAndHoldout()

################# START: Libraries 

library("randomForest")
library("caret")
library("e1071")
library("lubridate")

################# END: Libraries

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
  ,"district_code"
  
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
  #,"management_group"
  
  #### only need payment or payment_type since they're a 1-to-1 match
  ,"payment"
  #,"payment_type"
  
  
  ,"water_quality"
  #,"quality_group"
  
  ### quantity 
  #,"quantity"
  ,"quantity_group"
  
  ,"source"
  ,"source_type"
  #,"source_class"
  ,"waterpoint_type"
  ,"waterpoint_type_group"
  
  #### whether cpg has any missing data
  #,"has_cpg_missing_data"    # missing all construction_year, population, gps_height
  #,"has_cpg_some_data"       # missing some of the fields construction_year, population, gps_height
  #,"funder_sz"
  ,"pc1"
  ,"pc2"
  ,"pc3"
)

randomForest_data_train <- water_table_train[,RandomForestFieldList]
randomForest_data_holdout <- water_table_holdout[,RandomForestFieldList]
randomForest_data_full <- water_table[,RandomForestFieldList]
randomForest_data_test <- water_table_test[,RandomForestFieldList]




#tuneRF(randomForest_data_full, water_table_y$status_group, ntreeTry = 25, stepFactor = 1.5, trace=TRUE)
startTime <- proc.time()
set.seed(42)

randomForest_Training <- randomForest(water_table_train_y$status_group ~ ., data=randomForest_data_train, ntree=numberOfTrees)
importance(randomForest_Training)

set.seed(42)
confusionMatrix(predict(randomForest_Training, randomForest_data_holdout), water_table_holdout_y$status_group)

### Optional step to add results to file
# writeResultsRandomForest(randomForest_Training)







####### run full model and write results to file - to enter for submission

set.seed(42)
randomForest_AllData <- randomForest(water_table_y$status_group ~ .
                                     , data=randomForest_data_full, ntree=numberOfTrees)
writeResultsFileForSubmission(
  paste("Random Forest Simple v2 age imputed, imputed log population, imputed elevation, imputed lat_long region_district ntree=",numberOfTrees,", ",sep=""), 
  predict(randomForest_AllData, water_table_test)
)

importance(randomForest_AllData)
writeResultsFileForSubmission(paste("Random Forest with PC ntree=",numberOfTrees,sep=""), predict(randomForest_AllData, randomForest_data_test))



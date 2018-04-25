################# START: variables and libraries for submission information

numberOfTrees <- 500
submissionName <- "Random Forest Simple with missing and imputed elevation added, funder category"

library("randomForest")
library("caret")
library("e1071")
library("lubridate")
################# END: variables and libraries for submission information

setwd("~/Documents/Predict 498")
RootFilePath = "MSDS_Capstone//Water_Table//"
OutputFilePath = "MSDS_Capstone//Water_Table//"
source(paste(RootFilePath,"WaterTable_LoadAndClean.R", sep=""))



set.seed(42)
randomForest_Training <- randomForest(
    water_table_train_y$status_group ~ .  
      - id - gps_height - recorded_by - extraction_type  
      - funder - construction_year - installer 
      - wpt_name - subvillage 
      - ward - lga  - scheme_name - scheme_management
    , data=water_table_train
    , ntree=numberOfTrees)

confusionMatrix(water_table_holdout_y$status_group, predict(randomForest_Training, water_table_holdout))
 


####### run full model and write results to file
set.seed(42)
randomForest_AllData <- randomForest(water_table_y$status_group ~ .  - id - gps_height - recorded_by - extraction_type  - funder - construction_year - installer - wpt_name - subvillage - ward - lga  - scheme_name - scheme_management
                                      , data=water_table, ntree=numberOfTrees)

importance(randomForest_AllData)

writeFile(paste("Random Forest Simple with missing and imputed elevation added, funder category ntree=",numberOfTrees,sep=""), predict(randomForest_AllData, water_table_test))


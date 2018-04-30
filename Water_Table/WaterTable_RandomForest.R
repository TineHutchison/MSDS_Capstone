source("WaterTable_LoadAndClean_v2.R")
source("WaterTable_WriteResults.R")
source("WaterTable_RandomForest_LoadData.R")

library("caret")
library("randomForest")
################# START: variables and libraries for submission information
numberOfTrees <- 500
################# END: variables and libraries for submission information

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
  paste("Random Forest Simple with elevation, age imputed, imputed log population, imputed elevation, imputed lat_long (no has_construction_year or bad_latlong) ntree=",numberOfTrees,", ",sep=""), 
  predict(randomForest_AllData, water_table_test)
)

#importance(randomForest_AllData)



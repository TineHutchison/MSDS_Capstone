RootFilePath = "MSDS_Capstone//Water_Table//"
OutputFilePath = "MSDS_Capstone//Water_Table//"
source(paste(RootFilePath,"WaterTable_LoadAndClean.R", sep=""))

load_packages("randomForest")


set.seed(42)
randomForest_AllData <- randomForest(water_table_y$status_group ~ . - id  - recorded_by - extraction_type  - funder - construction_year - installer - wpt_name - subvillage - ward - lga  - scheme_name - scheme_management
                                               , data=water_table, ntree=500)

randomForest_AllData
importance(randomForest_AllData)

writeFile("Random Forest Simple", predict(randomForest_AllData, water_table_test))




#  age imputation which gives a slight performance boost but is REALLY, REALLY slow, so I commented it out for now... 
# 
# #### IMPUTING AGE FROM A RANDOM FOREST.... 
# #.... Lets find a better method to impute than this. 
# #.... We're already tracking that this has been imputed based on the variable has_construction_year
# set.seed(42)
# rf_hasConstructionYear <- randomForest(age ~ .  - date_recorded - latitude -longitude -region - region_code - id - recorded_by - extraction_type  - funder - construction_year - installer - wpt_name - subvillage - ward - lga  - scheme_name - scheme_management
#                                        , data=water_table[water_table$has_construction_year==1,], ntree=50)
# 
# water_table$age_imp <- water_table$age
# water_table[water_table$has_construction_year==0,]$age_imp <- predict(rf_hasConstructionYear, water_table[water_table$has_construction_year==0,])
# water_table$age_imp <- round(water_table$age_imp)
# 
# water_table_test$age_imp <- water_table_test$age
# water_table_test[water_table_test$has_construction_year==0,]$age_imp <- predict(rf_hasConstructionYear, water_table_test[water_table_test$has_construction_year==0,])
# water_table_test$age_imp <- round(water_table_test$age_imp)
# 

# set.seed(42)
# randomForest_AllData_ImputedAge <- randomForest(water_table_y$status_group ~ . - id  - recorded_by - extraction_type  - funder - construction_year - installer - wpt_name - subvillage - ward - lga  - scheme_name - scheme_management
#                                                 , data=water_table, ntree=500)
# 
# randomForest_AllData_ImputedAge
# 
# importance(randomForest_AllData_ImputedAge)
# 
# writeFile("Random Forest Simple with Age Imputation", predict(randomForest_AllData_ImputedAge, water_table_test))

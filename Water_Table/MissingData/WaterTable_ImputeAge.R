source("./WaterTable_LoadAndClean_v2.R")



############## BASELINE DATA
set.seed(42)
randomForest_AllData_ImputedAge <- randomForest(water_table_train_y$status_group ~  .  
                                                - id - gps_height - recorded_by - extraction_type  
                                                - funder - construction_year - installer 
                                                - wpt_name - subvillage 
                                                - ward - lga  - scheme_name - scheme_management
                                                , data=water_table_train, ntree=500)
#randomForest_AllData_ImputedAge
confusionMatrix(predict(randomForest_AllData_ImputedAge, water_table_holdout),water_table_holdout_y$status_group)

# Prediction                functional functional needs repair non functional
# functional                    7315                     162            659
# functional needs repair        524                     363            135
# non functional                1169                      73           4450
# 
# Overall Statistics
# 
# Accuracy : 0.8167   

###############
## Decision tree
# Accuracy : 0.8178   

## Random forest (n=50)
# Accuracy : 0.8164 

## Random forest missForest - nTree=20




#### IMPUTING AGE FROM A RANDOM FOREST....
#.... Lets find a better method to impute than this.
#.... We're already tracking that this has been imputed based on the variable has_construction_year
library(tree)
set.seed(42)
rf_hasConstructionYear <- tree(age ~ .  - date_recorded - gps_height - latitude -longitude -region - region_code - id - recorded_by - extraction_type  - funder - construction_year - installer - wpt_name - subvillage - ward - lga  - scheme_name - scheme_management
                                       , data=water_table_train[water_table_train$has_construction_year==1,])

water_table_train$age_imp <- water_table_train$age
water_table_train[water_table_train$has_construction_year==0,]$age_imp <- predict(rf_hasConstructionYear, water_table_train[water_table_train$has_construction_year==0,])
water_table_train$age_imp <- round(water_table_train$age_imp)

water_table_holdout$age_imp <- water_table_holdout$age
water_table_holdout[water_table_holdout$has_construction_year==0,]$age_imp <- predict(rf_hasConstructionYear, water_table_holdout[water_table_holdout$has_construction_year==0,])
water_table_holdout$age_imp <- round(water_table_holdout$age_imp)


hist(water_table_train$age)
hist(water_table_train$age_imp)
hist(water_table_holdout$age)
hist(water_table_holdout$age_imp)

factor(water_table$funder)
str(water_table)
   


set.seed(42)
randomForest_AllData_ImputedAge <- randomForest(water_table_train_y$status_group ~  .  
                                                - age
                                                - id - gps_height - recorded_by - extraction_type  
                                                - funder - construction_year - installer 
                                                - wpt_name - subvillage 
                                                - ward - lga  - scheme_name - scheme_management
                                                , data=water_table_train, ntree=500)

#randomForest_AllData_ImputedAge
confusionMatrix(water_table_holdout_y$status_group, predict(randomForest_AllData_ImputedAge, water_table_holdout))

# Prediction                functional functional needs repair non functional
# functional                    7317                     159            660
# functional needs repair        530                     355            137
# non functional                1149                      71           4472
# 
# Overall Statistics
# 
# Accuracy : 0.8178         




#### IMPUTING AGE FROM A RANDOM FOREST....
#.... Lets find a better method to impute than this.
#.... We're already tracking that this has been imputed based on the variable has_construction_year
library(randomForest)
set.seed(42)

rf_hasConstructionYear <- randomForest(age ~ .  - date_recorded - gps_height - latitude -longitude -region - region_code - id - recorded_by - extraction_type  - funder - construction_year - installer - wpt_name - subvillage - ward - lga  - scheme_name - scheme_management
                               - funder_cat - age_imp - region_new - elevation2 - logpop_imp
                               - longitude_imp - latitude_imp - log_amount_tsh
                                       , data=water_table_train[water_table_train$has_construction_year==1,], ntree=3)

rf_hasConstructionYear$importance
plot(water_table_holdout[water_table_holdout$has_construction_year==1,]$age, predict(rf_hasConstructionYear, water_table_holdout[water_table_holdout$has_construction_year==1,]))
mean(abs(water_table_holdout[water_table_holdout$has_construction_year==1,]$age- predict(rf_hasConstructionYear, water_table_holdout[water_table_holdout$has_construction_year==1,])))

water_table_train$age_imp <- water_table_train$age
water_table_train[water_table_train$has_construction_year==0,]$age_imp <- predict(rf_hasConstructionYear, water_table_train[water_table_train$has_construction_year==0,])
water_table_train$age_imp <- round(water_table_train$age_imp)

water_table_holdout$age_imp <- water_table_holdout$age
water_table_holdout[water_table_holdout$has_construction_year==0,]$age_imp <- predict(rf_hasConstructionYear, water_table_holdout[water_table_holdout$has_construction_year==0,])
water_table_holdout$age_imp <- round(water_table_holdout$age_imp)


hist(water_table_train$age)
hist(water_table_train$age_imp)
hist(water_table_holdout$age)
hist(water_table_holdout$age_imp)

sum(is.na(water_table_train_y$status_group))
water_table_train[is.na(water_table_train),]$age <- 0


set.seed(42)
randomForest_AllData_ImputedAge <- randomForest(water_table_train_y$status_group ~  .  
                                                - age
                                                - id - gps_height - recorded_by - extraction_type  
                                                - funder - construction_year - installer 
                                                - wpt_name - subvillage 
                                                - ward - lga  - scheme_name - scheme_management
                                                , data=water_table_train, ntree=500)

#randomForest_AllData_ImputedAge
confusionMatrix(water_table_holdout_y$status_group, predict(randomForest_AllData_ImputedAge, water_table_holdout))

# 
# Prediction                functional functional needs repair non functional
# functional                    7299                     168            669
# functional needs repair        518                     359            145
# non functional                1147                      80           4465
# 
# Overall Statistics
# 
# Accuracy : 0.8164        




#### IMPUTING AGE FROM A RANDOM FOREST - missForest package....
#install.packages("missForest")

#hist(water_table_train[water_table_train$age < 10,]$age)
importance(rf_hasConstructionYear)
importance(rf_hasConstructionYear)[order(importance(rf_hasConstructionYear),decreasing=TRUE),]

#water_table_train[is.na(water_table_train$age),]$age <- 0
#water_table_holdout[is.na(water_table_holdout$age),]$age <- 0
library(missForest)
set.seed(3)
train_size <- .75
training_rows <- sample(nrow(water_table), round(nrow(water_table)*train_size))

water_table_train[water_table_train$has_construction_year==0,]$age <- NA
missForestData <- water_table[,c("age","basin","elevation", "has_construction_year",
                                 "funder_cat","extraction_type_group","district_code",
                                 "management","quantity_group","monthRecorded",
                                 "source","waterpoint_type","source_type","payment_type","waterpoint_type_group",
                                 "extraction_type_class","quantity","permit","public_meeting",
                                 "water_quality","quality_group","source_class")]
missForestData[missForestData$has_construction_year==0,]$age <- NA
missForestDataDone <- missForest(missForestData  ,  ntree=20)

?missForest

water_table_train$imp_age <- 0
water_table_train$imp_age <- round(missForestDataDone$ximp[training_rows,]$age)
water_table_holdout$imp_age <- 0
water_table_holdout$imp_age <- round(missForestDataDone$ximp[-training_rows,]$age)

plot(water_table_train$age,water_table_train$imp_age)
plot(water_table_holdout$age,water_table_holdout$imp_age)

set.seed(42)
randomForest_AllData_ImputedAge <- randomForest(water_table_train_y$status_group ~  .  
                                                - age
                                                - id - gps_height - recorded_by - extraction_type  
                                                - funder - construction_year - installer 
                                                - wpt_name - subvillage 
                                                - ward - lga  - scheme_name - scheme_management
                                                , data=water_table_train, ntree=500)

#randomForest_AllData_ImputedAge
confusionMatrix(water_table_holdout_y$status_group, predict(randomForest_AllData_ImputedAge, water_table_holdout))

##########          ntrees=20
# Prediction                functional functional needs repair non functional
# functional                    7310                     164            662
# functional needs repair        522                     365            135
# non functional                1151                      72           4469
# 
# Overall Statistics
# 
# Accuracy : 0.8170

#missForest()
#install.packages("mice")
library(mice)
init=mice(water_table_train, max_it=0)
meth = init$method
predM = init$predictorMatrix
predM[,c("age")] = 0


rf_hasConstructionYear <- randomForest(age ~ .  - date_recorded - gps_height - latitude -longitude -region - region_code - id - recorded_by - extraction_type  - funder - construction_year - installer - wpt_name - subvillage - ward - lga  - scheme_name - scheme_management
                                       , data=water_table_train[water_table_train$has_construction_year==1,], ntree=20)

water_table_train$age_imp <- water_table_train$age
water_table_train[water_table_train$has_construction_year==0,]$age_imp <- predict(rf_hasConstructionYear, water_table_train[water_table_train$has_construction_year==0,])
water_table_train$age_imp <- round(water_table_train$age_imp)

water_table_holdout$age_imp <- water_table_holdout$age
water_table_holdout[water_table_holdout$has_construction_year==0,]$age_imp <- predict(rf_hasConstructionYear, water_table_holdout[water_table_holdout$has_construction_year==0,])
water_table_holdout$age_imp <- round(water_table_holdout$age_imp)


hist(water_table_train$age)
hist(water_table_train$age_imp)
hist(water_table_holdout$age)
hist(water_table_holdout$age_imp)



set.seed(42)
randomForest_AllData_ImputedAge <- randomForest(water_table_train_y$status_group ~  .  
                                                - age
                                                - id - gps_height - recorded_by - extraction_type  
                                                - funder - construction_year - installer 
                                                - wpt_name - subvillage 
                                                - ward - lga  - scheme_name - scheme_management
                                                , data=water_table_train, ntree=500)

#randomForest_AllData_ImputedAge
confusionMatrix(water_table_holdout_y$status_group, predict(randomForest_AllData_ImputedAge, water_table_holdout))









FieldList <- c(
  #"id"
  "amount_tsh"
  #"date_recorded"
  #,"funder"
  #,"gps_height"
  #,"installer"
  ,"longitude"
  ,"latitude"
  #,"wpt_name"
  ,"num_private"
  ,"basin"
  #,"subvillage"
  ,"region"
  #,"region_code"
  ,"district_code"
  #,"lga"
  #,"ward"
  ,"population"
  ,"public_meeting"
  #,"recorded_by"
  ,"scheme_management"
  #,"scheme_name"
  ,"permit"
  #,"construction_year"
  #,"extraction_type"
  ,"extraction_type_group"
  ,"extraction_type_class"
  #,"management"
  ,"management_group"
  ,"payment"
  #,"payment_type"
  ,"water_quality"
  ,"quality_group"
  #,"quantity"
  ,"quantity_group"
  ,"source"
  ,"source_type"
  ,"source_class"
  ,"waterpoint_type"
  ,"waterpoint_type_group"
  ,"age"
  #,"has_population"
  #,"has_amount_tsh"
  #,"has_construction_year"
  #,"has_gps_height"
  #,"has_cpg_missing_data"
  #,"has_cpg_some_data"
  #,"has_bad_latOrLong"
  #,"monthRecorded"
  #,"logpop"
  #,"elevation"
  #,"missing_elevation"
  #,"funder_cat"
  #,"age_imp"
  #,"region_new"
)


data_train <- water_table_train[water_table_train$has_construction_year==1,FieldList]
data_holdout <- water_table_holdout[water_table_holdout$has_construction_year==1,FieldList]
data_full <- water_table[water_table$has_construction_year==1,FieldList]
data_missing <- water_table[water_table$has_construction_year==0,FieldList]
data_missing_test <- water_table_test[water_table_test$has_construction_year==0,FieldList]


library(randomForest)
ageForest <- randomForest(data_train$age ~ .,data=data_train, ntree=50)
plot(data_holdout$age, predict(ageForest, data_holdout))
mean(abs(data_holdout$age- predict(ageForest, data_holdout)))
plot(ageForest$mse)




water_table$age_imp <- water_table$age
water_table[water_table$has_construction_year==0,]$age_imp <- predict(ageForest, data_missing)

water_table_test$age_imp <- water_table_test$age
water_table_test[water_table_test$has_construction_year==0,]$age_imp <- predict(ageForest,data_missing_test)



generateTrainingAndHoldout()

writeFiles()

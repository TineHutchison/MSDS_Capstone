source("./WaterTable_LoadAndClean_v2.R")


##### Ultimately due to the large amount of missing data, attempting to impute this field
##### provided no additional predictive value

##### this file could likely use some clean-up... 

water_table$log_amount_tsh <- log(water_table$amount_tsh + 1)
water_table_test$log_amount_tsh <- log(water_table_test$amount_tsh + 1)

generateTrainingAndHoldout()
boxplot(water_table$log_amount_tsh ~ water_table$district_code)
boxplot(water_table$log_amount_tsh ~ water_table$basin)
boxplot(water_table$log_amount_tsh ~ water_table$region)
boxplot(water_table$log_amount_tsh ~ water_table$region_code)
boxplot(water_table$log_amount_tsh ~ water_table$lga)
boxplot(water_table$log_amount_tsh ~ water_table$ward)
boxplot(water_table$log_amount_tsh ~ water_table$waterpoint_type_group)
boxplot(water_table$log_amount_tsh ~ water_table$quality_group)
boxplot(water_table$log_amount_tsh ~ water_table$quantity)
boxplot(water_table$log_amount_tsh ~ water_table$construction_year)

boxplot(water_table$logpop ~ round(water_table$logpop))
FieldList <- c(
  #"id"
  #"amount_tsh"
  "log_amount_tsh"
  ,"date_recorded"
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
  #,"district_code"
  ,"lga"
  #,"ward"
  #,"population"
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
  #,"age"
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

data_train <- water_table_train[water_table_train$has_cpg_some_data==1,FieldList]
data_holdout <- water_table_holdout[water_table_holdout$has_cpg_some_data==1,FieldList]
data_full <- water_table[water_table$has_cpg_some_data==1,FieldList]
data_missing <- water_table[water_table$has_cpg_some_data==0,FieldList]
data_missing_test <- water_table_test[water_table_test$has_cpg_some_data==0,FieldList]


library(tree)
atTree <- tree(log_amount_tsh ~ .,data=data_train)
plot(data_holdout$log_amount_tsh, predict(atTree, data_holdout))
mean(abs(data_holdout$log_amount_tsh- predict(atTree, data_holdout)))

hist(data_train$log_amount_tsh)
hist(predict(atTree, data_train))


library(randomForest)
atForest <- randomForest(log_amount_tsh ~ .,data=data_train, ntree=10)
plot(data_holdout$log_amount_tsh, predict(atForest, data_holdout))
mean(abs(data_holdout$log_amount_tsh- predict(atForest, data_holdout)))
plot(atForest$mse)
hist(data_train$atForest)
hist(predict(atForest, data_train))





library(h2o)
h2o.shutdown(prompt=FALSE)
Sys.sleep(5)
h2o.init(nthreads=-1,max_mem_size='18G', min_mem_size = '18G')
#
set.seed(42)




##### h2o imputation
#### For file for submission
randomForest_data_full <- data_train[,FieldList]
randomForest_data_test <- data_holdout[,FieldList]
randomForest_data_full$days <- as.integer(as.Date("14/01/01", format="%y/%m/%d") - randomForest_data_full$date_recorded )
randomForest_data_test$days <- as.integer(as.Date("14/01/01", format="%y/%m/%d") - randomForest_data_test$date_recorded )



water_table_h2o <- randomForest_data_full
water_table_test_h2o <- cbind(randomForest_data_test) 


holdoutH2o<-as.h2o(data_holdout)
features<-colnames(holdoutH2o)

#colnames(water_table_h2o)[ncol(water_table_h2o)] <- "status_group"
#remove(features)
#colnames(water_table_test_h2o)[ncol(water_table_test_h2o)] <- "status_group"

fullH2o<-as.h2o(water_table_h2o)
features<-colnames(fullH2o)



#library(caret)
randomForest_amountTsh <- h2o.randomForest(features,"log_amount_tsh", fullH2o, ntrees=1000, mtries=9, max_depth=22, nbins=22, seed=42)

predictionH2o <- predict(randomForest_amountTsh, holdoutH2o)

predictions <- as.data.frame(predictionH2o$predict)$predict

#class(predictions)
#colnames(as.data.frame(predictionH2o$predict))
#confusionMatrix(
mean(abs(data_holdout$log_amount_tsh- predictions))
plot(predictions, data_holdout$log_amount_tsh)
#plot(predictions, water_table_holdout$log_amount_tsh)

class(predictionH2o$predict)
class(holdoutH2o$log_amount_tsh)

holdoutH2o<-as.h2o(data_full)
features<-colnames(holdoutH2o)

randomForest_amountTsh <- h2o.randomForest(features,"log_amount_tsh", fullH2o, ntrees=1000, mtries=9, max_depth=22, nbins=22, seed=42)


data_missing <- water_table[water_table$has_cpg_some_data==0,FieldList]
data_missing_test <- water_table_test[water_table_test$has_cpg_some_data==0,FieldList]

h2omissing <- as.h2o(data_missing)
h2omissing_test <- as.h2o(data_missing_test)

predictionH2o <- predict(randomForest_amountTsh, h2omissing)
predictionH2oTest <- predict(randomForest_amountTsh, h2omissing_test)
water_table[water_table$has_cpg_some_data==0,]$log_amount_tsh <- as.data.frame(predictionH2o)$predict
water_table_test[water_table_test$has_cpg_some_data==0,]$log_amount_tsh <- as.data.frame(predictionH2oTest)$predict

generateTrainingAndHoldout()
table()

# mean(data_train$logpop, data_train$region_code)
# group_by(data_train$region_code, sum(data_train$gps_height))
# 
# group_by_gps_height <- data_train[data_train$gps_height!=0,] %>%
#   group_by(region_code) %>%
#   summarise(mean(gps_height), round(median(gps_height)))
# 
# 
# head(merge(data_holdout, group_by_gps_height, c("region_code")))
# 



library(randomForest)
atForest <- randomForest(log_amount_tsh ~ ., data=data_full, ntree=10)
plot(data_holdout$log_amount_tsh, predict(atForest, data_holdout))
mean(abs(data_holdout$log_amount_tsh - predict(atForest, data_holdout)))
plot(atForest$mse)


log_amount_tsh <- water_table$log_amount_tsh
plot(log_amount_tsh, water_table$log_amount_tsh)
#water_table$log_amount_tsh <- water_table$log_amount_tsh
water_table[water_table$has_cpg_some_data==0,]$log_amount_tsh <- predict(atForest, data_missing)

#water_table_test$log_amount_tsh <- water_table_test$log_amount_tsh
water_table_test[water_table_test$has_cpg_some_data==0,]$log_amount_tsh <- predict(atForest,data_missing_test)


generateTrainingAndHoldout()




source("./WaterTable_LoadAndClean_v2.R")

sum(!water_table$has_gps_height)


boxplot(water_table$gps_height ~ water_table$district_code)
boxplot(water_table$gps_height ~ water_table$basin)
boxplot(water_table$gps_height ~ water_table$region)
boxplot(water_table$gps_height ~ water_table$region_code)
boxplot(water_table$gps_height ~ water_table$lga)
boxplot(water_table$gps_height ~ water_table$ward)
boxplot(water_table$gps_height ~ water_table$waterpoint_type_group)
boxplot(water_table$gps_height ~ water_table$quality_group)
boxplot(water_table$gps_height ~ water_table$quantity)
boxplot(water_table$gps_height ~ water_table$construction_year)

boxplot(water_table$gps_height ~ round(water_table$logpop))
FieldList <- c(
  #"id"
  #"amount_tsh"
  #"date_recorded"
  #,"funder"
  "gps_height"
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
  #,"population"
  ,"public_meeting"
  #,"recorded_by"
  #,"scheme_management"
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

library(tree)

data_train <- water_table_train[water_table_train$has_gps_height==1,FieldList]
data_holdout <- water_table_holdout[water_table_holdout$has_gps_height==1,FieldList]
data_full <- water_table[water_table$has_gps_height==1,FieldList]
data_missing <- water_table[water_table$has_gps_height==0,FieldList]
data_missing_test <- water_table_test[water_table_test$has_gps_height==0,FieldList]


elevationTree <- tree(data_train$gps_height ~ .,data=data_train)
plot(data_holdout$gps_height, predict(elevationTree, data_holdout))
mean(abs(data_holdout$gps_height- predict(elevationTree, data_holdout)))


# library(randomForest)
# elevationForest <- randomForest(data_train$gps_height ~ .,data=data_train, ntree=30)
# plot(data_holdout$gps_height, predict(elevationForest, data_holdout))
# mean(abs(data_holdout$gps_height- predict(elevationForest, data_holdout)))
# plot(elevationForest$mse)
# 
# mean(data_train$gps_height, data_train$region_code)
# group_by(data_train$region_code, sum(data_train$gps_height))
# 
# group_by_gps_height <- data_train[data_train$gps_height!=0,] %>%
#   group_by(region) %>%
#   summarise(mean(gps_height), round(median(gps_height)))
# 



water_table_train_h2o <- cbind(data_train)
water_table_holdout_h2o <- cbind(data_holdout) 


library(h2o)
# h2o.shutdown(prompt=FALSE)
# Sys.sleep(5)
# h2o.init(nthreads=-1,max_mem_size='18G', min_mem_size = '18G')
#
set.seed(42)


trainH2o<-as.h2o(water_table_train_h2o)
holdoutH2o<-as.h2o(water_table_holdout_h2o)
features<-colnames(trainH2o)

randomForest_elevation <- h2o.randomForest(features,"gps_height", trainH2o, ntrees=100, mtries=10, max_depth=22, nbins=26, seed=42)

#plot(randomForest_elevation$mse)
predictionH2o <- predict(randomForest_elevation, holdoutH2o)
#colnames(as.data.frame(predictionH2o$predict))
plot(round(as.data.frame(predictionH2o$predict)$predict), data_holdout$gps_height)
mean(abs(round(as.data.frame(predictionH2o$predict)$predict)- data_holdout$gps_height))
#### mean: 20.86533
### updated:  19.76969


mtries=c(6,10:12)#c(-1,12:19)
max_depth=c(20,22,24)#c(15,20,25,30)
nbins=c(26,28,30)#c(15,20,25,30)
#ntrees = c(100,200,500)

sqrt(33)
hyper_params = list(mtries=mtries, max_depth=max_depth, nbins=nbins)
?h2o.randomForest
randomForest_AllData <- h2o.randomForest(features,"status_group", trainH2o, ntrees=100, mtries=9, max_depth=22, nbins=22, seed=42)
summary(randomForest_AllData)
randomForest_AllData <- h2o.grid("randomForest", nfolds = 5, grid_id = "mygrid",  x=features,hyper_params = hyper_params,y="gps_height", training_frame=trainH2o, seed=42, ntrees=100)










###### Build out elevation
water_table_full_h2o <- cbind(data_full)
#water_table_test_h2o <- cbind(data_missing_test) 


#library(h2o)
# h2o.shutdown(prompt=FALSE)
# Sys.sleep(5)
# h2o.init(nthreads=-1,max_mem_size='18G', min_mem_size = '18G')
#
set.seed(42)


trainH2o<-as.h2o(water_table_full_h2o)

features<-colnames(trainH2o)

randomForest_elevation <- h2o.randomForest(features,"gps_height", trainH2o, ntrees=100, mtries=10, max_depth=22, nbins=26, seed=42)

show(randomForest_elevation)


missingH2o<-as.h2o(data_missing)
missingH2o<-as.h2o(missingH2o)
predictions  <- predict(randomForest_elevation, missingH2o)
water_table[water_table$has_gps_height==0,]$elevation2 <- round(as.data.frame(predictions)$predict)


missingH2o<-as.h2o(data_missing_test)
missingH2o<-as.h2o(missingH2o)
predictions  <- predict(randomForest_elevation, missingH2o)
water_table_test[water_table_test$has_gps_height==0,]$elevation2 <- round(as.data.frame(predictions)$predict)

#data_missing_test <- water_table_test[water_table_test$has_gps_height==0,FieldList]




generateTrainingAndHoldout()

#writeFiles()

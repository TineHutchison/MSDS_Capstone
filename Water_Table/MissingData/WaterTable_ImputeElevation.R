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
  ,"region"
  #,"region_code"
  ,"district_code"
  #,"lga"
  #,"ward"
  ,"population"
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


library(randomForest)
elevationForest <- randomForest(data_train$gps_height ~ .,data=data_train, ntree=30)
plot(data_holdout$gps_height, predict(elevationForest, data_holdout))
mean(abs(data_holdout$gps_height- predict(elevationForest, data_holdout)))
plot(elevationForest$mse)

mean(data_train$gps_height, data_train$region_code)
group_by(data_train$region_code, sum(data_train$gps_height))

group_by_gps_height <- data_train[data_train$gps_height!=0,] %>%
  group_by(region) %>%
  summarise(mean(gps_height), round(median(gps_height)))


head(merge(data_holdout, group_by_gps_height, c("region_code")))

plot(data_holdout$gps_height)



library(randomForest)
elevationForest <- randomForest(gps_height ~ .,data=data_full, ntree=30)
plot(data_holdout$gps_height, predict(elevationForest, data_holdout))
mean(abs(data_holdout$gps_height- predict(elevationForest, data_holdout)))
plot(elevationForest$mse)

hist(water_table_test$elevation2)
hist(water_table_test$gps_height)
water_table$elevation2 <- water_table$gps_height
water_table[water_table$has_gps_height==0,]$elevation2 <- round(predict(elevationForest, data_missing))

water_table_test$elevation2 <- water_table_test$gps_height
water_table_test[water_table_test$has_gps_height==0,]$elevation2 <- predict(elevationForest,data_missing_test)


plot(water_table[!water_table$has_gps_height,]$elevation, water_table[!water_table$has_gps_height,]$elevation2)
mean(abs(water_table[!water_table$has_gps_height,]$elevation - water_table[!water_table$has_gps_height,]$elevation2))

generateTrainingAndHoldout()

writeFiles()

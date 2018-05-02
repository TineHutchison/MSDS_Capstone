RootFilePath = "MSDS_Capstone//Water_Table//"
OutputFilePath = "MSDS_Capstone//Water_Table//"
source(paste(RootFilePath,"WaterTable_LoadAndClean.R", sep=""))

tz_region_train <- read.csv(paste(RootFilePath,"TZ_region_train.csv", sep=""))
water_table$region_new <- toupper(tz_region_train$TZ_Region)

  table(water_table$region_new, water_table$region)
sum(is.na(water_table$region_new))
  colnames(tz_region_train)


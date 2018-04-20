#setwd("~/Documents/Predict 498/")
water_table <- read.csv("MSDS_Capstone/Water_Table/tanzania-X-train.csv")
water_table_y <- read.csv("MSDS_Capstone/Water_Table/tanzania-y-train.csv")

water_table_test <- read.csv("MSDS_Capstone/Water_Table/tanzania-X-test.csv")

library(lubridate)


water_table$y <- water_table_y$status_group
maxYear <- 2013


cleanData <- function(data) {
  data$date_recorded <- as.Date(data$date_recorded) 
  data$age <- 0
  data[data$construction_year>0,]$age <- maxYear -  data[data$construction_year>0,]$construction_year
  
  data$has_population <- 0
  data[data$population>0,]$has_population <- 1
  
  data$has_amount_tsh <- 0
  data[data$amount_tsh>0,]$has_amount_tsh <- 1
  
  data$has_construction_year <- 1
  data[data$construction_year==0,]$has_construction_year <- 0 
  
  return(data)
}

water_table <- cleanData(water_table)
water_table_test <- cleanData(water_table_test)





library(randomForest)
set.seed(1)
rf_hasConstructionYear <- randomForest(y ~ .- extraction_type - funder - construction_year - installer - wpt_name - subvillage - ward - lga  - scheme_name - scheme_management
                                       , data=water_table[water_table$has_construction_year==1,], ntree=500)
rf_hasConstructionYear
set.seed(1)
rf_doesNotHaveConstructionYear <- randomForest(y ~ .- extraction_type  - funder - construction_year - installer - wpt_name - subvillage - ward - lga  - scheme_name - scheme_management
                                               , data=water_table[water_table$has_construction_year==0,], ntree=500)

rf_doesNotHaveConstructionYear



set.seed(1)
randomForest_All <- randomForest(y ~ .- extraction_type  - funder - construction_year - installer - wpt_name - subvillage - ward - lga  - scheme_name - scheme_management
                                               , data=water_table[water_table$has_construction_year==0,], ntree=500)

randomForest_All

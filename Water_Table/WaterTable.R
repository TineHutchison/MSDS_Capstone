setwd("~/Documents/Predict 498/MSDS_Capstone/")
water_table <- read.csv("Water_Table/tanzania-X-train.csv")
water_table_y <- read.csv("Water_Table/tanzania-y-train.csv")

water_table_test <- read.csv("Water_Table/tanzania-X-test.csv")
library(lubridate)

sum(water_table$population)
class(water_table$has_amount_tsh)
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



#install.packages("tree")
library(tree)
tree.donr = tree(y ~ 
                   factor(has_amount_tsh) + 
                   factor(has_construction_year) + 
                   age + 
                   source + 
                   management + 
                   water_quality + 
                   quantity + 
                   extraction_type + 
                   extraction_type_group + 
                   extraction_type_class + 
                   source_type + 
                   permit +
                   population 
                   ,data=water_table)
plot(tree.donr)
text(tree.donr, pretty=0) 


status_group <- predict(tree.donr, water_table_test, type="class")


simpleTree <- data.frame(water_table_test$id, status_group)
colnames(simpleTree) = c("id","status_group")
write.csv(simpleTree, file="Water_Table//simpleTree.csv", row.names=FALSE) 








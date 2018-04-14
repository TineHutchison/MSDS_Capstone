setwd("~/Documents/Predict 498/MSDS_Capstone/")
water_table <- read.csv("Water_Table/tanzania-X-train.csv")
water_table_y <- read.csv("Water_Table/tanzania-y-train.csv")

library(lubridate)

sum(water_table$population)
class(water_table$has_amount_tsh)
water_table$y <- water_table_y$status_group


water_table$date_recorded <- as.Date(water_table$date_recorded) 

maxYear <- max(water_table$construction_year)
water_table$age <- NA
water_table[water_table$construction_year>0,]$age <- maxYear -  water_table[water_table$construction_year>0,]$construction_year

water_table$has_population <- 0
water_table[water_table$population>0,]$has_population <- 1

water_table$has_amount_tsh <- 0
water_table[water_table$amount_tsh>0,]$has_amount_tsh <- 1

water_table$has_construction_year <- 1
water_table[water_table$construction_year==0,]$has_construction_year <- 0 

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




library(MASS)
##### CLASSIFICATION MODEL - LINEAR DISCRIMINANT ANALYSIS
model.lda1 <- lda(y ~ 
                    has_amount_tsh + 
                    has_construction_year + 
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

hist(log(water_table[water_table$has_amount_tsh==1,]$amount_tsh + 1))

head(water_table[,c(2,24,41, 42)])
#kdepairs(water_table[,c(2,24,42, 43)], pch=19)

summary(water_table[water_table$has_population==1,])



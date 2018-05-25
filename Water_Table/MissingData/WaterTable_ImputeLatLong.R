source("./WaterTable_LoadAndClean_v2.R")

water_table_all <- rbind(water_table, water_table_test)


boxplot(water_table$latitude ~ water_table$region)

group_by_latitude_district <- water_table[water_table$has_bad_latOrLong==0,] %>%
  group_by(region_code, district_code) %>%
  summarise(median(latitude))

colnames(group_by_latitude_district)[ncol(group_by_latitude_district)] <- "latitude_new" 


group_by_latitude <- water_table[water_table$has_bad_latOrLong==0,] %>%
  group_by(region_code) %>%
  summarise(median(latitude))

colnames(group_by_latitude)[ncol(group_by_latitude)] <- "latitude_new" 



group_by_longitude_district <- water_table[water_table$has_bad_latOrLong==0,] %>%
  group_by(region_code, district_code) %>%
  summarise(median(longitude))

colnames(group_by_longitude_district)[ncol(group_by_longitude_district)]  <- "longitude_new" 


group_by_longitude <- water_table[water_table$has_bad_latOrLong==0,] %>%
  group_by(region_code) %>%
  summarise(median(longitude))

colnames(group_by_longitude)[ncol(group_by_longitude)] <- "longitude_new" 

group_by_longitude

left_join(water_table, group_by_longitude_district, c=c("region_code", "district_code"))



hist(water_table$longitude_imp - water_table$longitude_imp2)

water_table$longitude_imp2 <- left_join(water_table, group_by_longitude_district, c=c("region_code","district_code"))[,c("longitude_new")]
water_table[is.na(water_table$latitude_imp2),]$longitude_imp2 <- left_join(water_table[is.na(water_table$latitude_imp2),], group_by_longitude, c=c("region_code"))[,c("longitude_new")]
water_table[water_table$has_bad_latOrLong==0,]$longitude_imp2 <- water_table[water_table$has_bad_latOrLong==0,]$longitude

sum(is.na(water_table$latitude_imp2))
sum(is.na(water_table$longitude_imp2))

left_join(water_table[is.na(water_table$latitude_imp2),], group_by_latitude, c=c("region_code"))[,c("latitude_new")]

water_table$latitude_imp2 <- left_join(water_table, group_by_latitude_district, c=c("region_code","district_code"))[,c("latitude_new")]
water_table[is.na(water_table$latitude_imp2),]$latitude_imp2 <- left_join(water_table[is.na(water_table$latitude_imp2),], group_by_latitude, c=c("region_code"))[,c("latitude_new")]
water_table[water_table$has_bad_latOrLong==0,]$latitude_imp2 <- water_table[water_table$has_bad_latOrLong==0,]$latitude




generateTrainingAndHoldout()










group_by_latitude_district <- water_table_all[water_table_all$has_bad_latOrLong==0,] %>%
  group_by(region_code, district_code) %>%
  summarise(median(latitude))

colnames(group_by_latitude_district)[ncol(group_by_latitude_district)] <- "latitude_new" 


group_by_latitude <- water_table_all[water_table_all$has_bad_latOrLong==0,] %>%
  group_by(region_code) %>%
  summarise(median(latitude))

colnames(group_by_latitude)[ncol(group_by_latitude)] <- "latitude_new" 



group_by_longitude_district <- water_table_all[water_table_all$has_bad_latOrLong==0,] %>%
  group_by(region_code, district_code) %>%
  summarise(median(longitude))

colnames(group_by_longitude_district)[ncol(group_by_longitude_district)]  <- "longitude_new" 


group_by_longitude <- water_table_all[water_table_all$has_bad_latOrLong==0,] %>%
  group_by(region_code) %>%
  summarise(median(longitude))

colnames(group_by_longitude)[ncol(group_by_longitude)] <- "longitude_new" 



water_table_test$longitude_imp2 <- left_join(water_table_test, group_by_longitude_district, c=c("region_code","district_code"))[,c("longitude_new")]
water_table_test[is.na(water_table_test$longitude_imp2),]$longitude_imp2 <- left_join(water_table_test[is.na(water_table_test$longitude_imp2),], group_by_longitude, c=c("region_code"))[,c("longitude_new")]
water_table_test[water_table_test$has_bad_latOrLong==0,]$longitude_imp2 <- water_table_test[water_table_test$has_bad_latOrLong==0,]$longitude


left_join(water_table_test[is.na(water_table_test$latitude_imp2),], group_by_latitude, c=c("region_code"))[,c("latitude_new")]

water_table_test$latitude_imp2 <- left_join(water_table_test, group_by_latitude_district, c=c("region_code","district_code"))[,c("latitude_new")]
water_table_test[is.na(water_table_test$latitude_imp2),]$latitude_imp2 <- left_join(water_table_test[is.na(water_table_test$latitude_imp2),], group_by_latitude, c=c("region_code"))[,c("latitude_new")]
water_table_test[water_table_test$has_bad_latOrLong==0,]$latitude_imp2 <- water_table_test[water_table_test$has_bad_latOrLong==0,]$latitude

sum(is.na(water_table_test$latitude_imp2))
sum(is.na(water_table_test$longitude_imp2))




water_table$longitude_imp2 <- left_join(water_table, group_by_longitude_district, c=c("region_code","district_code"))[,c("longitude_new")]
water_table[is.na(water_table$longitude_imp2),]$longitude_imp2 <- left_join(water_table[is.na(water_table$longitude_imp2),], group_by_longitude, c=c("region_code"))[,c("longitude_new")]
water_table[water_table$has_bad_latOrLong==0,]$longitude_imp2 <- water_table[water_table$has_bad_latOrLong==0,]$longitude



left_join(water_table[is.na(water_table$latitude_imp2),], group_by_latitude, c=c("region_code"))[,c("latitude_new")]

water_table$latitude_imp2 <- left_join(water_table, group_by_latitude_district, c=c("region_code","district_code"))[,c("latitude_new")]
water_table[is.na(water_table$latitude_imp2),]$latitude_imp2 <- left_join(water_table[is.na(water_table$latitude_imp2),], group_by_latitude, c=c("region_code"))[,c("latitude_new")]
water_table[water_table$has_bad_latOrLong==0,]$latitude_imp2 <- water_table[water_table$has_bad_latOrLong==0,]$latitude

sum(is.na(water_table$latitude_imp2))
sum(is.na(water_table$longitude_imp2))


generateTrainingAndHoldout()
















##### By LGA

library(caret)
library(dplyr)

group_by_longitude_lga <- water_table_all[water_table_all$has_bad_latOrLong==0,] %>%
  group_by(lga) %>%
  summarise(median(longitude))

colnames(group_by_longitude_lga)[ncol(group_by_longitude_lga)] <- "longitude_new" 


group_by_latitude_lga <- water_table_all[water_table_all$has_bad_latOrLong==0,] %>%
  group_by(lga) %>%
  summarise(median(latitude))

colnames(group_by_latitude_lga)[ncol(group_by_latitude_lga)] <- "latitude_new" 




group_by_latitude <- water_table[water_table$has_bad_latOrLong==0,] %>%
  group_by(region) %>%
  summarise(median(latitude))

colnames(group_by_latitude)[ncol(group_by_latitude)] <- "latitude_new" 





group_by_longitude <- water_table[water_table$has_bad_latOrLong==0,] %>%
  group_by(region) %>%
  summarise(median(longitude))

colnames(group_by_longitude)[ncol(group_by_longitude)] <- "longitude_new" 


water_table$longitude_imp2 <- left_join(water_table, group_by_longitude_lga, c=c("lga"))[,c("longitude_new")]
water_table[is.na(water_table$longitude_imp2),]$longitude_imp2 <- left_join(water_table[is.na(water_table$longitude_imp2),], group_by_longitude, c=c("region"))[,c("longitude_new")]
#water_table_test[water_table_test$has_bad_latOrLong==0,]$longitude_imp2 <- water_table_test[water_table_test$has_bad_latOrLong==0,]$longitude


left_join(water_table_test[is.na(water_table_test$latitude_imp2),], group_by_latitude, c=c("region_code"))[,c("latitude_new")]

water_table$latitude_imp2 <- left_join(water_table, group_by_latitude_lga, c=c("lga"))[,c("latitude_new")]
water_table[is.na(water_table$latitude_imp2),]$latitude_imp2 <- left_join(water_table_test[is.na(water_table$latitude_imp2),], group_by_latitude, c=c("region"))[,c("latitude_new")]
#water_table_test[water_table_test$has_bad_latOrLong==0,]$latitude_imp2 <- water_table_test[water_table_test$has_bad_latOrLong==0,]$latitude




sum(is.na(water_table_test$longitude_imp2))
water_table_test$longitude_imp2 <- left_join(water_table_test, group_by_longitude_lga, c=c("lga"))[,c("longitude_new")]
water_table_test[is.na(water_table_test$longitude_imp2),]$longitude_imp2 <- left_join(water_table_test[is.na(water_table_test$longitude_imp2),], group_by_longitude, c=c("region"))[,c("longitude_new")]
#water_table_test[water_table_test$has_bad_latOrLong==0,]$longitude_imp2 <- water_table_test[water_table_test$has_bad_latOrLong==0,]$longitude


left_join(water_table_test[is.na(water_table_test$latitude_imp2),], group_by_latitude, c=c("region_code"))[,c("latitude_new")]

water_table_test$latitude_imp2 <- left_join(water_table_test, group_by_latitude_lga, c=c("lga"))[,c("latitude_new")]
water_table_test[is.na(water_table_test$latitude_imp2),]$latitude_imp2 <- left_join(water_table_test[is.na(water_table_test$latitude_imp2),], group_by_latitude, c=c("region"))[,c("latitude_new")]
#water_table_test[water_table_test$has_bad_latOrLong==0,]$latitude_imp2 <- water_table_test[water_table_test$has_bad_latOrLong==0,]$latitude

sum(is.na(water_table_test$latitude_imp2))
sum(is.na(water_table_test$longitude_imp2))




sum(is.na(water_table$latitude_imp2))
sum(is.na(water_table$longitude_imp2))


generateTrainingAndHoldout()

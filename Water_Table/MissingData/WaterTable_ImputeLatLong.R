source("./WaterTable_LoadAndClean_v2.R")


boxplot(water_table$latitude ~ water_table$region)

group_by_latitude <- water_table[water_table$has_bad_latOrLong==0,] %>%
  group_by(region_code) %>%
  summarise(median(latitude))


colnames(group_by_latitude) <- c("region_code","latitude_imp") 



group_by_longitude <- water_table[water_table$has_bad_latOrLong==0,] %>%
  group_by(region_code) %>%
  summarise(median(longitude))

colnames(group_by_longitude) <- c("region_code","longitude_imp") 

group_by_longitude

left_join(water_table, group_by_longitude, c=c("region_code"))

water_table$longitude_imp <- left_join(water_table, group_by_longitude, c=c("region_code"))[,c("longitude_imp")]
water_table[water_table$has_bad_latOrLong==0,]$longitude_imp <- water_table[water_table$has_bad_latOrLong==0,]$longitude

water_table$latitude_imp <- left_join(water_table, group_by_latitude, c=c("region_code"))[,c("latitude_imp")]
water_table[water_table$has_bad_latOrLong==0,]$latitude_imp <- water_table[water_table$has_bad_latOrLong==0,]$latitude


water_table_test$longitude_imp <- left_join(water_table_test, group_by_longitude, c=c("region_code"))[,c("longitude_imp")]
water_table_test[water_table_test$has_bad_latOrLong==0,]$longitude_imp <- water_table_test[water_table_test$has_bad_latOrLong==0,]$longitude

water_table_test$latitude_imp <- left_join(water_table_test, group_by_latitude, c=c("region_code"))[,c("latitude_imp")]
water_table_test[water_table_test$has_bad_latOrLong==0,]$latitude_imp <- water_table_test[water_table_test$has_bad_latOrLong==0,]$latitude



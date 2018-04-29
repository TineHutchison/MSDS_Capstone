
wt2 <- data.frame(water_table$id, water_table$latitude, water_table$longitude)
nrow(wt2)
colnames(wt2) <- c("id", "latitude","longitude")
wt2$latitude <- round(wt2$latitude,5)
wt2$longitude<- round(wt2$longitude,5)

colnames(elevation) <- c("latitude","longitude","elevation")
elevation$elevation <- round(elevation$elevation)

colnames(elevation)
water_table[water_table$has_gps_height==0,]$gps_height

water_table$elevation <- wt3$elevation
water_table[water_table$has_gps_height==1,]$elevation <- water_table[water_table$has_gps_height==1,]$gps_height
sum(is.na(water_table))
nrow(water_table)
head(water_table$id, 20)
head(wt3$id, 20)

nrow(elevation)

water_table[,]$gps_height 
merge(water_table, wt3, by="id")
trim(water_table$latitude,5)
?trunc
elevation[2,]$latitude




?read.csv
elevation_file <- read.csv(paste(RootFilePath, "elevation.csv", sep=""))
elevation_file2 <- read.csv(paste(RootFilePath, "test-elevation.csv", sep=""))
rbind(elevation_file, elevation_file2)
elevation_file <- c(elevation_file, elevation_file2)
class(elevation_file)
############### Finish unknown elevations

elevation_by_region <- water_table[,c("region","gps_height")]
elevation_by_region <- rbind(elevation_by_region, water_table_test[,c("region","gps_height")])
elevation_by_region <- group_by(elevation_by_region, region)


planes <- group_by(water_table[water_table$missing_elevation==0,], region)
test <- summarize(planes, missing=mean(elevation))
print(test, n=50)


hist(water_table$elevation)
hist(water_table_test$elevation)
df.test <- data.frame(test)

water_table[water_table$missing_elevation==1,]$elevation <- nrow(merge(df.test, water_table[water_table$missing_elevation==1,], by=c("region")))
water_table_test[water_table_test$missing_elevation==1,]$elevation <- nrow(merge(df.test, water_table_test[water_table_test$missing_elevation==1,], by=c("region")))





elevation_by_region
?merge
?left_join


water_table[is.na(water_table$elevation),]$elevation <-merge(water_table[water_table$missing_elevation==1,], elevation_by_region, by=c("region"))

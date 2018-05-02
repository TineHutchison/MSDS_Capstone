source("./WaterTable_LoadAndClean_v2.R")



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
  #,"num_private"
  ,"basin"
  #,"subvillage"
  ,"region"
  #,"region_code"
  ,"district_code"
  #,"lga"
  #,"ward"
  ,"population"
  #,"public_meeting"
  #,"recorded_by"
  #,"scheme_management"
  #,"scheme_name"
  #,"permit"
  ,"construction_year"
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
  ,"logpop"
  #,"elevation"
  #,"missing_elevation"
  #,"funder_cat"
  #,"age_imp"
  #,"region_new"
)


mice_full_set <- water_table[,FieldList]


library(mice)
mice_full_set[mice_full_set$population>0,]$logpop <- log(mice_full_set[mice_full_set$population>0,]$population)
mice_full_set[mice_full_set$population==0,]$logpop <- NA
mice_full_set[mice_full_set$gps_height==0,]$gps_height <- NA
mice_full_set[mice_full_set$construction_year==0,]$construction_year <- NA
mice_full_set[mice_full_set$longitude==0,]$longitude <- NA
mice_full_set[round(mice_full_set$latitude,5)==0,]$latitude <- NA
mice_imp <- mice(mice_full_set, maxit=25, seed=500)

summary(mice_full_set)
class(mice_full_set$latitude)
str(mice_full_set)
#mice_imp <- mice(mice_full_set, m=500, seed=500)


#mice_imp$chainMean
water_table_2 <- complete(mice_imp)
water_table$logpop_mice <- water_table_2$logpop
water_table$gps_height_mice <- water_table_2$gps_height
water_table$construction_year_mice <- water_table_2$construction_year
water_table$latitude_mice <- water_table_2$latitude
water_table$longitude_mice <- water_table_2$longitude

water_table$age_mice <- 0
water_table$age_mice <- (water_table$date_recorded - as.Date(ISOdate(water_table$construction_year_mice, 7, 1)))
water_table$age_mice <- round(water_table$age_mice / 365.25)
water_table[water_table$age_mice <0,]$age_mice <- 0 

plot(water_table$age_mice, water_table$age_imp)

generateTrainingAndHoldout()

FullFieldList <<- c(
  "id"
  ,"amount_tsh"
  ,"has_amount_tsh"
  
  
  ,"date_recorded"
  ,"monthRecorded"
  
  #### funder or funder_cat. 
  ,"funder"
  ,"funder_cat"     
  
  
  ## either gps_height, elevation, gps_height_mice or elevation2
  ,"has_gps_height"    # 1 if gps_height != 0
  ,"gps_height"
  ,"elevation"
  ,"missing_elevation"    #if gps_height == 0 and it can't be imputed (elevation) based on GPS coordinates
  ,"elevation2"           # imputed elevation based on a randomForest
  
  
  ### missing latitude and longitude
  ,"has_bad_latOrLong"
  
  ###longitude or logitude_imp
  ,"longitude"
  ,"longitude_imp"        
  
  ###latitude or latitude_imp
  ,"latitude"
  ,"latitude_imp"
  
  
  ### region, region_new, region_code (they mostly overlap, although not entirely). 
  #   Region is slightly preferred since it doesn't have the potential to be interpretted as a numeric.  
  ,"region"
  ,"region_code"
  ,"region_new"
  
  
  ### Make sure this is a factor. 
  ,"district_code"
  
  ### other location based fields
  ,"basin"
  ,"subvillage"
  ,"lga"
  ,"ward"
  
  
  ### use only construction_year, age or age_imp
  ,"construction_year"
  ,"has_construction_year"
  ,"age"
  ,"age_imp"
  
  
  ### population fields. Pick population, logpop, logpop_imp
  ,"has_population"
  ,"population"
  ,"logpop"
  ,"logpop_imp"
  
  
  ,"installer"
  ,"wpt_name"
  ,"num_private"
  ,"public_meeting"
  ,"recorded_by"
  ,"scheme_management"
  ,"scheme_name"
  ,"permit"
  ,"extraction_type"
  ,"extraction_type_group"
  ,"extraction_type_class"
  ,"management"
  ,"management_group"

  #### only need payment or payment_type since they're a 1-to-1 match
  ,"payment"
  ,"payment_type"
  
  
  ,"water_quality"
  ,"quality_group"
  
  ### quantity 
  ,"quantity"
  ,"quantity_group"
  
  ,"source"
  ,"source_type"
  ,"source_class"
  ,"waterpoint_type"
  ,"waterpoint_type_group"
  
  #### whether cpg has any missing data
  ,"has_cpg_missing_data"    # missing all construction_year, population, gps_height
  ,"has_cpg_some_data"       # missing some of the fields construction_year, population, gps_height
)

loadFiles <- function() {
  water_table <<- read.csv("tanzania-X-train-v3.csv")
  water_table_test <<- read.csv("tanzania-X-test-v3.csv")
  water_table_y <<- read.csv("tanzania-Y-train.csv")
  
  water_table$date_recorded <<- as.Date(water_table$date_recorded)
  water_table_test$date_recorded <<- as.Date(water_table_test$date_recorded)
  
  water_table$region_code <<- factor(water_table$region_code)
  water_table$district_code <<- factor(water_table$district_code)
  water_table_test$region_code <<- factor(water_table_test$region_code)
  water_table_test$district_code <<- factor(water_table_test$district_code)
}

writeFiles <- function() {
  write.csv(water_table_test, "tanzania-X-test-v3.csv", row.names = FALSE)
  write.csv(water_table, "tanzania-X-train-v3.csv", row.names = FALSE)
}

fixSchemeManagement <- function() {
  water_table_test$scheme_management <<- factor(water_table_test$scheme_management, levels=c(levels(water_table$scheme_management)))
}

generateTrainingAndHoldout <- function() {
  set.seed(3)
  train_size <- .75
  training_rows <- sample(nrow(water_table), round(nrow(water_table)*train_size))
  
  water_table_train <<- water_table[training_rows,] 
  water_table_train_y <<- water_table_y[training_rows,] 
  water_table_holdout <<- water_table[-training_rows,] 
  water_table_holdout_y <<- water_table_y[-training_rows,] 
}






loadFiles()
fixSchemeManagement()
generateTrainingAndHoldout() 



















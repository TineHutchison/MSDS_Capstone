################# START: Libraries 

library("randomForest")
library("caret")
library("e1071")
library("lubridate")

################# END: Libraries


RandomForestFieldList <- c(
               #"id"
               "amount_tsh"
               ,"date_recorded"
               #,"funder"
               #,"gps_height"
               #,"installer"
               #,"longitude"
               #,"latitude"
               #,"wpt_name"
               ,"num_private"
               ,"basin"
               #,"subvillage"
               ,"region"
               #,"region_code"
               ,"district_code"
               #,"lga"
               #,"ward"
               #,"population"
               ,"public_meeting"
               #,"recorded_by"
               ,"scheme_management"
               #,"scheme_name"
               ,"permit"
               #,"construction_year"
               #,"extraction_type"
               ,"extraction_type_group"
               ,"extraction_type_class"
               ,"management"
               #,"management_group"
               ,"payment"
               #,"payment_type"
               ,"water_quality"
               ,"quality_group"
               #,"quantity"
               ,"quantity_group"
               ,"source"
               ,"source_type"
               ,"source_class"
               ,"waterpoint_type"
               ,"waterpoint_type_group"
               #,"age"
               ,"has_population"
               #,"has_amount_tsh"
               ,"has_construction_year"
               #,"has_gps_height"
               #,"has_cpg_missing_data"
               #,"has_cpg_some_data"
               ,"has_bad_latOrLong"
               ,"monthRecorded"
               #,"logpop"
               #,"elevation"
               #,"missing_elevation"
               #,"funder_cat"
               ,"age_imp"
               #,"region_new"
               ,"elevation2"
               ,"logpop_imp"
               ,"longitude_imp"
               ,"latitude_imp"
               )

randomForest_data_train <- water_table_train[,RandomForestFieldList]
randomForest_data_holdout <- water_table_holdout[,RandomForestFieldList]
randomForest_data_full <- water_table[,RandomForestFieldList]
randomForest_data_test <- water_table_test[,RandomForestFieldList]
 

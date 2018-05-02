################# START: variables and libraries for submission information

numberOfTrees <- 100
submissionName <- "Random Forest Simple with missing and imputed elevation added, funder category"

library("randomForest")
library("caret")
library("e1071")
library("lubridate")
################# END: variables and libraries for submission information


getMax <- function(test_row){
  #print(test_row) 
  max_val <- max(test_row)
  if(max_val == test_row[1])
    return("functional")
  if(max_val == test_row[2])
    return("non functional")
  return("functional needs repair")
}

library("xgboost")


add_dummies <- function(data, source)  {
  data$r1 <- 0; data[source$region_code==1,]$r1 <- 1
  data$r2 <- 0; data[source$region_code==2,]$r2 <- 1
  data$r3 <- 0; data[source$region_code==3,]$r3 <- 1
  data$r4 <- 0; data[source$region_code==4,]$r4 <- 1
  data$r5 <- 0; data[source$region_code==5,]$r5 <- 1
  data$r6 <- 0; data[source$region_code==6,]$r6 <- 1
  data$r7<- 0; data[source$region_code==7,]$r7 <- 1
  data$r8<- 0; data[source$region_code==8,]$r8 <- 1
  data$r9<- 0; data[source$region_code==9,]$r9 <- 1
  data$r10<- 0; data[source$region_code==10,]$r10 <- 1
  data$r11<- 0; data[source$region_code==11,]$r11 <- 1
  data$r12<- 0; data[source$region_code==12,]$r12 <- 1
  data$r13<- 0; data[source$region_code==13,]$r13 <- 1
  data$r14<- 0; data[source$region_code==14,]$r14 <- 1
  data$r15<- 0; data[source$region_code==15,]$r15 <- 1
  data$r16<- 0; data[source$region_code==16,]$r16 <- 1
  data$r17<- 0; data[source$region_code==17,]$r17 <- 1
  data$r18<- 0; data[source$region_code==18,]$r18 <- 1
  data$r19<- 0; data[source$region_code==19,]$r19 <- 1
  data$r20<- 0; data[source$region_code==20,]$r20 <- 1
  data$r21<- 0; data[source$region_code==21,]$r21 <- 1
  data$r24<- 0; data[source$region_code==24,]$r24 <- 1
  # data$r40 <- 0
  # data[source$region_code==40,]$r40 <- 1
  data$r60<- 0; data[source$region_code==60,]$r60 <- 1
  data$r80<- 0; data[source$region_code==80,]$r80 <- 1
  data$r90<- 0; data[source$region_code==90,]$r90 <- 1
  data$r99<- 0; data[source$region_code==99,]$r99 <- 1
  
  data$district_code0<- 0; data[source$district_code==0,]$district_code0 <- 1;
  data$district_code1<- 0; data[source$district_code==1,]$district_code1 <- 1;
  data$district_code2<- 0; data[source$district_code==2,]$district_code2 <- 1;
  data$district_code3<- 0; data[source$district_code==3,]$district_code3 <- 1;
  data$district_code4<- 0; data[source$district_code==4,]$district_code4 <- 1;
  data$district_code5<- 0; data[source$district_code==5,]$district_code5 <- 1;
  data$district_code6<- 0; data[source$district_code==6,]$district_code6 <- 1;
  data$district_code7<- 0; data[source$district_code==7,]$district_code7 <- 1;
  data$district_code8<- 0; data[source$district_code==8,]$district_code8 <- 1;
  data$district_code13<- 0; data[source$district_code==13,]$district_code13 <- 1;
  data$district_code23<- 0; data[source$district_code==23,]$district_code23 <- 1;
  data$district_code30<- 0; data[source$district_code==30,]$district_code30 <- 1;
  data$district_code33<- 0; data[source$district_code==33,]$district_code33 <- 1;
  data$district_code43<- 0; data[source$district_code==43,]$district_code43 <- 1;
  data$district_code53<- 0; data[source$district_code==53,]$district_code53 <- 1;
  data$district_code60<- 0; data[source$district_code==60,]$district_code60 <- 1;
  data$district_code62<- 0; data[source$district_code==62,]$district_code62 <- 1;
  data$district_code63<- 0; data[source$district_code==63,]$district_code63 <- 1;
  data$district_code67<- 0; data[source$district_code==67,]$district_code67 <- 1;
  #data$district_code80<- 0; data[source$district_code==80,]$district_code80 <- 1;
  
  
  # data$extraction_type_groupafridev<- 0; data[source$extraction_type_group=="afridev",]$extraction_type_groupafridev <- 1;
  # data$extraction_type_groupgravity<- 0; data[source$extraction_type_group=="gravity",]$extraction_type_groupgravity <- 1;
  # data$extraction_type_groupindia_mark_ii<- 0; data[source$extraction_type_group=="india mark ii",]$extraction_type_groupindia_mark_ii <- 1;
  # data$extraction_type_groupindia_mark_iii<- 0; data[source$extraction_type_group=="india mark iii",]$extraction_type_groupindia_mark_iii <- 1;
  # data$extraction_type_groupmono<- 0; data[source$extraction_type_group=="mono",]$extraction_type_groupmono <- 1;
  # data$extraction_type_groupniratanira<- 0; data[source$extraction_type_group=="nira/tanira",]$extraction_type_groupniratanira <- 1;
  # data$extraction_type_groupother<- 0; data[source$extraction_type_group=="other",]$extraction_type_groupother <- 1;
  # data$extraction_type_groupother_handpump<- 0; data[source$extraction_type_group=="other handpump",]$extraction_type_groupother_handpump <- 1;
  # data$extraction_type_groupother_motorpump<- 0; data[source$extraction_type_group=="other motorpump",]$extraction_type_groupother_motorpump <- 1;
  # data$extraction_type_grouprope_pump<- 0; data[source$extraction_type_group=="rope pump",]$extraction_type_grouprope_pump <- 1;
  # data$extraction_type_groupsubmersible<- 0; data[source$extraction_type_group=="submersible",]$extraction_type_groupsubmersible <- 1;
  # data$extraction_type_groupswn_80<- 0; data[source$extraction_type_group=="swn 80",]$extraction_type_groupswn_80 <- 1;
  #data$extraction_type_groupwind_powered<- 0; data[source$extraction_type_group=="wind-powered",]$extraction_type_groupwind_powered <- 1;
  
  data$extraction_type_classgravity<- 0; data[source$extraction_type_class=="gravity",]$extraction_type_classgravity <- 1;
  data$extraction_type_classhandpump<- 0; data[source$extraction_type_class=="handpump",]$extraction_type_classhandpump <- 1;
  data$extraction_type_classmotorpump<- 0; data[source$extraction_type_class=="motorpump",]$extraction_type_classmotorpump <- 1;
  data$extraction_type_classother<- 0; data[source$extraction_type_class=="other",]$extraction_type_classother <- 1;
  data$extraction_type_classrope_pump<- 0; data[source$extraction_type_class=="rope pump",]$extraction_type_classrope_pump <- 1;
  data$extraction_type_classsubmersible<- 0; data[source$extraction_type_class=="submersible",]$extraction_type_classsubmersible <- 1;
  #data$extraction_type_classwindpowered<- 0; data[source$extraction_type_class=="wind-powered",]$extraction_type_classwindpowered <- 1;
  
  data$quantitydry<- 0; data[source$quantity=="dry",]$quantitydry <- 1;	
  data$quantityenough<- 0; data[source$quantity=="enough",]$quantityenough <- 1;	
  data$quantityinsufficient<- 0; data[source$quantity=="insufficient",]$quantityinsufficient <- 1;
  data$quantityseasonal<- 0; data[source$quantity=="seasonal",]$quantityseasonal <- 1;	
  #data$quantityunknown<- 0; data[source$quantity=="unknown",]$quantityunknown <- 1;	
  
  # data$funder_catforeign_gov<- 0; data[source$funder_cat=="foreign_gov",]$funder_catforeign_gov <- 1;
  # data$funder_catlocal_community<- 0; data[source$funder_cat=="local_community",]$funder_catlocal_community <- 1;
  # data$funder_catother<- 0; data[source$funder_cat=="other",]$funder_catother <- 1;
  # data$funder_catTanzania_Gov<- 0; data[source$funder_cat=="Tanzania_Gov",]$funder_catTanzania_Gov <- 1;
  #data$funder_catUN_agencies<- 0; data[source$funder_cat=="UN_agencies",]$funder_catUN_agencies <- 1;
  
  data$paymentnever_pay<- 0; data[source$payment=="never pay",]$paymentnever_pay <- 1;
  data$paymentother<- 0; data[source$payment=="other",]$paymentother <- 1;
  data$paymentpay_annually<- 0; data[source$payment=="pay annually",]$paymentpay_annually <- 1;
  data$paymentpay_monthly<- 0; data[source$payment=="pay monthly",]$paymentpay_monthly <- 1;
  data$paymentpay_per_bucket<- 0; data[source$payment=="pay per bucket",]$paymentpay_per_bucket <- 1;
  data$paymentpay_when_scheme_fails<- 0; data[source$payment=="pay when scheme fails",]$paymentpay_when_scheme_fails <- 1;
  #data$paymentunknown<- 0; data[source$payment=="unknown",]$paymentunknown <- 1;
  
  data$waterpoint_typecattle_trough<- 0; data[source$waterpoint_type=="cattle trough",]$waterpoint_typecattle_trough <- 1;
  data$waterpoint_typecommunal_standpipe<- 0; data[source$waterpoint_type=="communal standpipe",]$waterpoint_typecommunal_standpipe <- 1;
  data$waterpoint_typecommunal_standpipe_multiple<- 0; data[source$waterpoint_type=="communal standpipe multiple",]$waterpoint_typecommunal_standpipe_multiple <- 1;
  data$waterpoint_typedam<- 0; data[source$waterpoint_type=="dam",]$waterpoint_typedam <- 1;
  data$waterpoint_typehand_pump<- 0; data[source$waterpoint_type=="hand pump",]$waterpoint_typehand_pump <- 1;
  data$waterpoint_typeimproved_spring<- 0; data[source$waterpoint_type=="improved spring",]$waterpoint_typeimproved_spring <- 1;
  #data$waterpoint_typeother<- 0; data[source$waterpoint_type=="other",]$waterpoint_typeother <- 1;
  
  
  data$basinInternal<- 0; data[source$basin=="Internal",]$basinInternal <- 1;
  data$basinLake_Nyasa<- 0; data[source$basin=="Lake Nyasa",]$basinLake_Nyasa <- 1;
  data$basinLake_Rukwa<- 0; data[source$basin=="Lake Rukwa",]$basinLake_Rukwa <- 1;
  data$basinLake_Tanganyika<- 0; data[source$basin=="Lake Tanganyika",]$basinLake_Tanganyika <- 1;
  data$basinLake_Victoria<- 0; data[source$basin=="Lake Victoria",]$basinLake_Victoria <- 1;
  data$basinPangani<- 0; data[source$basin=="Pangani",]$basinPangani <- 1;
  data$basinRufiji<- 0; data[source$basin=="Rufiji",]$basinRufiji <- 1;
  data$basinRuvuma__Southern_Coast<- 0; data[source$basin=="Ruvuma / Southern Coast",]$basinRuvuma__Southern_Coast <- 1;
#  data$basinWami__Ruvu<- 0; data[source$basin=="Wami / Ruvu",]$basinWami__Ruvu <- 1;
  
  
  
  data$managementcompany<- 0; data[source$management=="company",]$managementcompany <- 1;
  data$managementother<- 0; data[source$management=="other",]$managementother <- 1;
  data$managementother_school<- 0; data[source$management=="other - school",]$managementother_school <- 1;
  data$managementparastatal<- 0; data[source$management=="parastatal",]$managementparastatal <- 1;
  data$managementprivate_operator<- 0; data[source$management=="private operator",]$managementprivate_operator <- 1;
  data$managementtrust<- 0; data[source$management=="trust",]$managementtrust <- 1;
  data$managementunknown<- 0; data[source$management=="unknown",]$managementunknown <- 1;
  data$managementvwc<- 0; data[source$management=="vwc",]$managementvwc <- 1;
  data$managementwater_authority<- 0; data[source$management=="water authority",]$managementwater_authority <- 1;
  data$managementwater_board<- 0; data[source$management=="water board",]$managementwater_board <- 1;
  data$managementwua<- 0; data[source$management=="wua",]$managementwua <- 1;
  # data$managementwug<- 0; data[source$management=="wug",]$managementwug <- 1;
  
  data$sourcedam<- 0; data[source$source=="dam",]$sourcedam <- 1;
  data$sourcehand_dtw<- 0; data[source$source=="hand dtw",]$sourcehand_dtw <- 1;
  data$sourcelake<- 0; data[source$source=="lake",]$sourcelake <- 1;
  data$sourcemachine_dbh<- 0; data[source$source=="machine dbh",]$sourcemachine_dbh <- 1;
  data$sourceother<- 0; data[source$source=="other",]$sourceother <- 1;
  data$sourcerainwater_harvesting<- 0; data[source$source=="rainwater harvesting",]$sourcerainwater_harvesting <- 1;
  data$sourceriver<- 0; data[source$source=="river",]$sourceriver <- 1;
  data$sourceshallow_well<- 0; data[source$source=="shallow well",]$sourceshallow_well <- 1;
  data$sourcespring<- 0; data[source$source=="spring",]$sourcespring <- 1;
  #data$sourceunknown<- 0; data[source$source=="unknown",]$sourceunknown <- 1;
  # 
  # data$source_typeborehole<- 0; data[source$source_type=="borehole",]$source_typeborehole <- 1;
  # data$source_typedam<- 0; data[source$source_type=="dam",]$source_typedam <- 1;
  # data$source_typeother<- 0; data[source$source_type=="other",]$source_typeother <- 1;
  # data$source_typerainwater_harvesting<- 0; data[source$source_type=="rainwater harvesting",]$source_typerainwater_harvesting <- 1;
  # data$source_typeriverlake<- 0; data[source$source_type=="river/lake",]$source_typeriverlake <- 1;
  # data$source_typeshallow_well<- 0; data[source$source_type=="shallow well",]$source_typeshallow_well <- 1;
  # # data$source_typespring<- 0; data[source$source_type=="spring",]$source_typespring <- 1;
  # 
  # data$water_qualitycoloured<- 0; data[source$water_quality=="coloured",]$water_qualitycoloured <- 1;
  # data$water_qualityfluoride<- 0; data[source$water_quality=="fluoride",]$water_qualityfluoride <- 1;
  # data$water_qualityfluoride_abandoned<- 0; data[source$water_quality=="fluoride abandoned",]$water_qualityfluoride_abandoned <- 1;
  # data$water_qualitymilky<- 0; data[source$water_quality=="milky",]$water_qualitymilky <- 1;
  # data$water_qualitysalty<- 0; data[source$water_quality=="salty",]$water_qualitysalty <- 1;
  # data$water_qualitysalty_abandoned<- 0; data[source$water_quality=="salty abandoned",]$water_qualitysalty_abandoned <- 1;
  # data$water_qualitysoft<- 0; data[source$water_quality=="soft",]$water_qualitysoft <- 1;
  # # data$water_qualityunknown<- 0; data[source$water_quality=="unknown",]$water_qualityunknown <- 1;
  # 
  # data$public_meeting1 <-  0; data[as.numeric(source$public_meeting)==1,]$public_meeting1 <-1;  
  # data$public_meeting2 <-  0; data[as.numeric(source$public_meeting)==2,]$public_meeting2 <-1;
  # 
  # data$permit1 <-  0; data[as.numeric(source$permit)==1,]$permit1 <-1;  
  # data$permit2 <-  0; data[as.numeric(source$permit)==2,]$permit2 <-1;
  # 
  # data$monthRecorded1<- 0; data[source$monthRecorded=="1",]$monthRecorded1 <- 1;
  # data$monthRecorded2<- 0; data[source$monthRecorded=="2",]$monthRecorded2 <- 1;
  # data$monthRecorded3<- 0; data[source$monthRecorded=="3",]$monthRecorded3 <- 1;
  # data$monthRecorded4<- 0; data[source$monthRecorded=="4",]$monthRecorded4 <- 1;
  # data$monthRecorded5<- 0; data[source$monthRecorded=="5",]$monthRecorded5 <- 1;
  # data$monthRecorded6<- 0; data[source$monthRecorded=="6",]$monthRecorded6 <- 1;
  # data$monthRecorded7<- 0; data[source$monthRecorded=="7",]$monthRecorded7 <- 1;
  # data$monthRecorded8<- 0; data[source$monthRecorded=="8",]$monthRecorded8 <- 1;
  # data$monthRecorded9<- 0; data[source$monthRecorded=="9",]$monthRecorded9 <- 1;
  # data$monthRecorded10<- 0; data[source$monthRecorded=="10",]$monthRecorded10 <- 1;
  # data$monthRecorded11<- 0; data[source$monthRecorded=="11",]$monthRecorded11 <- 1;
  # 
  return(data)
  
}



target <- rep(0,nrow(water_table_train_y))
target[water_table_train_y$status_group == "non functional"] <- 1
target[water_table_train_y$status_group == "functional needs repair"] <- 2


fieldList <- c("date_recorded",
               "longitude_imp",
               "latitude_imp",
               #"basin",
               #"region_code",
               #"district_code",
               #"public_meeting",
               #"permit",
               #"extraction_type_group",
               #"extraction_type_class",
               #"management",
               #"management_group",
               #"payment",
               #"payment_type",
               #"water_quality",
               #"quality_group",
               #"quantity",
               #"quantity_group",
               #"source",
               #"source_type",
               #"waterpoint_type",
               #"waterpoint_type_group",
               #"has_amount_tsh",
               "has_construction_year",
               "monthRecorded",
               #"elevation",
               "elevation2",
               "missing_elevation",
               #"funder_cat",
               "logpop_imp", 
               "age_imp"
              #"pc1",
              #"pc2",
              #"pc3", 
              #"pc4", 
              #"pc5"
              , "amount_tsh"
               )

xgboost_train <- water_table_train[,fieldList]
xgboost_train <- add_dummies(xgboost_train, water_table_train)
#head(xgboost_train)
#str(water_table$region_code)
# 
# table(water_table$region_code)

library("xgboost")
#water_table$quantity_group
xgboost_train <- data.matrix(xgboost_train)
#head(xgboost_train)
#xgboost_train$population = log(xgboost_train$population + 1)
set.seed(45)
xgboost_target <- rep(0,nrow(water_table_train_y))
xgboost_target[water_table_train_y$status_group == "non functional"] <- 1
xgboost_target[water_table_train_y$status_group == "functional needs repair"] <- 2


table(water_table$management, water_table$payment_type)

xgboost_train_level <- xgb.DMatrix(data = xgboost_train, label = xgboost_target) 

xgboost_Training <- xgboost(data=xgboost_train_level, 
                            num_class = 3,
                            nrounds = numberOfTrees, 
                            max_depth = 16,
                            objective = "multi:softprob", 
                            print_every_n = 20)

xgboost_holdout <-water_table_holdout[,fieldList]

xgboost_holdout <- add_dummies(xgboost_holdout, water_table_holdout)
xgboost_holdout <- data.matrix(xgboost_holdout)





predictions <- predict(xgboost_Training, xgboost_holdout, type="response")
results <- data.frame(water_table_holdout$id,
                      predictions[(1:length(predictions)) %% 3 == 1],
                      predictions[(1:length(predictions)) %% 3 == 2],
                      predictions[(1:length(predictions)) %% 3 == 0])
colnames(results)[2:4] <- c("functional", "non functional", "functional needs repair")

xgboost_values <- apply(results[,2:4],1, getMax)

confusionMatrix(water_table_holdout_y$status_group, factor(xgboost_values))





source("./WaterTable_LoadAndClean_v2.R")
# age imputation which gives a slight performance boost but is REALLY, REALLY slow, so I commented it out for now...




############## BASELINE DATA
set.seed(42)
randomForest_AllData_ImputePopulationBaseline <- randomForest(water_table_train_y$status_group ~  .  
                                                - id - gps_height - recorded_by - extraction_type  
                                                - funder - construction_year - installer 
                                                - wpt_name - subvillage 
                                                - ward - lga  - scheme_name - scheme_management
                                                , data=water_table_train, ntree=500)
#randomForest_AllData_ImputedAge
confusionMatrix(water_table_holdout_y$status_group, predict(randomForest_AllData_ImputedAge, water_table_holdout))

# Prediction                functional functional needs repair non functional
# functional                    7315                     162            659
# functional needs repair        524                     363            135
# non functional                1169                      73           4450
# 
# Overall Statistics
# 
# Accuracy : 0.8167   

###############




FieldList <- c(
  #"id"
  "amount_tsh"
  #"date_recorded"
  #,"funder"
  ,"gps_height"
  #,"installer"
  ,"longitude"
  ,"latitude"
  #,"wpt_name"
  ,"num_private"
  ,"basin"
  #,"subvillage"
  #,"region"
  ,"region_code"
  ,"district_code"
  #,"lga"
  #,"ward"
  ,"population"
  ,"public_meeting"
  #,"recorded_by"
  #,"scheme_management"
  #,"scheme_name"
  ,"permit"
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
  ,"has_construction_year"
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


set.seed(42)


glm_train_set <- water_table_train[,FieldList]
glm_holdout_set <- water_table_holdout[,FieldList]

#hist(log(water_table_train[water_table_train$has_population==1,]$population))

#hasPopulation1 <- water_table_train$has_population==1 & water_table_train$population==1

#sum(water_table_train$population==1)
log(2)
glm.population.full <- glm(population>1 ~ . - logpop, data=glm_train_set[glm_train_set$population>0,], family=binomial)
glm.population.min <- glm(population>1 ~ 1, data=glm_train_set[glm_train_set$population>0,], family=binomial)
?glm
backwardSelection_glm <- step(glm.population.full)
forwardSelection_glm <- step(glm.population.min, scope=list(lower=formula(glm.population.min),upper=formula(glm.population.full)), direction="forward")
stepwiseSelection_glm <- step(glm.population.min, scope=list(lower=formula(glm.population.min),upper=formula(glm.population.full)), direction="both")


backwardSelection_glm$model
forwardSelection_glm
stepwiseSelection_glm

imputePop <- predict(backwardSelection_glm, glm_holdout_set, type="response")
hist(imputePop)
plot(glm_holdout_set$population>1, predict(backwardSelection_glm, glm_holdout_set, type="response"))

library(randomForest)

lm_logpop <- randomForest(logpop - log(2) ~ ., data=glm_train_set[glm_train_set$population>1,], ntree=1)

plot((predict(lm_logpop, glm_holdout_set)* imputePop), glm_holdout_set$logpop)

mean(abs(glm_holdout_set$logpop- (predict(lm_logpop, glm_holdout_set)* imputePop)+log(2)))

plot()
hist(water_table[water_table$logpop>0,]$logpop)
hist(imputePop)


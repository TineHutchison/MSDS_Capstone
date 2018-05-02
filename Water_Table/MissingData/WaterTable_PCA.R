source("WaterTable_LoadAndClean_v2.R")
source("WaterTable_WriteResults.R")

PCAFieldList <<- c(
  "amount_tsh"
  ,"monthRecorded"
  ,"elevation2"           # imputed elevation based on a randomForest
  ,"longitude_imp"        
  ,"latitude_imp"
  ,"age_imp"
  ,"logpop_imp"
)

PCA_data_train <- water_table_train[,PCAFieldList]
PCA_data_holdout <- water_table_holdout[,PCAFieldList]
PCA_data_full <- water_table[,PCAFieldList]

colMeans(PCA_data_full)
pca_data <- prcomp(PCA_data_full,
       center = TRUE,
       scale. = TRUE) 

pca1 <- predict(pca_data, PCA_data_holdout)
plot(pca_data, type = "l")
summary(pca_data)
pca_data$rotation
pca1 <- data.frame(pca1)

water_table$pc1 <- pca1$PC1
water_table$pc2 <- pca1$PC2
water_table$pc3 <- pca1$PC3
water_table$pc4 <- pca1$PC4
water_table$pc5 <- pca1$PC5
pca1$PC1

generateTrainingAndHoldout()

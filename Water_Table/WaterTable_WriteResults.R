library(dplyr)

writeResultsRandomForest <- function(randomForest_Model) {
  # randomForest_Model <- randomForest_Training
  filename <- "RandomForestScoring_organizedByCategory.csv"
  
  
  endTime <- proc.time()
 

  set.seed(42)
  cm <- confusionMatrix(water_table_holdout_y$status_group, predict(randomForest_Model, water_table_holdout))


  fullFieldList <- data.frame(FullFieldList)
  colnames(fullFieldList) <- c("FieldName")
  fullFieldList$FieldName <- as.character(fullFieldList$FieldName)
  importance <- data.frame(importance(randomForest_Model))
  importance$FieldName <- rownames(importance)
  importance_measures <- left_join(fullFieldList, importance, by=c("FieldName"))
  columnNames <- importance_measures$FieldName
  
  importance_measures <- t(importance_measures$MeanDecreaseGini)
  colnames(importance_measures) <- columnNames

  inputFile <- NA
  tryCatch({
    inputFile <- read.csv(filename)
    inputFile$datetime <- sapply(inputFile$datetime, toString)
  }, error=function(e) {}, warning=function(w) {}, finally=function(){})
  frametest <- NA
  frametest <- rbind(inputFile, data.frame(datetime=toString(Sys.time()), nTree=randomForest_Model$ntree, mTry=randomForest_Training$mtry, ooberror=randomForest_Model$err.rate[randomForest_Model$ntree,1], time= data.frame(t(paste(endTime - startTime,sep=""))), t(cm$overall), cmatrix_values = toString(cm$table), importance_measures, testset_submittedToDD=""))
  write.csv(frametest,filename, row.names=FALSE)
}


writeResultsFileForSubmission <- function(filename, data) {
  toSave <- data.frame(water_table_test$id, data)
  colnames(toSave) = c("id","status_group")
  if(!startsWith(filename, "SubmissionFiles"))
    filename <- paste("SubmissionFiles/",filename,sep="")
  if(!endsWith(filename, ".csv")){
    #filename <- paste(filename,Sys.time(), sep="")
    filename <- paste(filename, ".csv", sep="")
  }
  write.csv(toSave, file=filename, row.names=FALSE)
}


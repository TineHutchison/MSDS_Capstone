loadFiles <- function() {
  water_table <<- read.csv("tanzania-X-train-v3.csv")
  water_table_test <<- read.csv("tanzania-X-test-v3.csv")
  water_table_y <<- read.csv("tanzania-Y-train.csv")
  
  water_table$date_recorded <<- as.Date(water_table$date_recorded)
  water_table_test$date_recorded <<- as.Date(water_table_test$date_recorded)
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



















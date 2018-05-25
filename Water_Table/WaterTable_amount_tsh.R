

water_table$log_amount_tsh <- log(water_table$amount_tsh + 1)
water_table_test$log_amount_tsh <- log(water_table_test$amount_tsh + 1)
writeFiles()
generateTrainingAndHoldout()

head(table(water_table$funder)[order(table(water_table$funder), decreasing=TRUE)])

full_data <- rbind(water_table, water_table_test)

funder_size <- data.frame(table(full_data$funder)[order(table(full_data$funder), decreasing=TRUE)])
# head(funder_size, n=100)
# funder_size$funder_sz <- "small"
# funder_size[funder_size$Freq>1000,]$funder_sz <- "large"
# funder_size[funder_size$Freq<1000 & funder_size$Freq>100,]$funder_sz <- "medium"
# funder_size[funder_size$Var1=="",]$funder_sz <- "unknown"
# sum(funder_size$funder=="")
colnames(funder_size) <- c("funder","Freq")
water_table$funder_sz <- merge(water_table, funder_size, c("funder"))$Freq
water_table_test$funder_sz <- merge(water_table_test, funder_size, c("funder"))$Freq
#water_table$funder_sz <- factor(water_table$funder_sz)
class(water_table$funder_sz)

#table(water_table_test$funder_cat, water_table_test_y$status_group)
generateTrainingAndHoldout()

boxplot(water_table$funder_sz ~ water_table_y$status_group)


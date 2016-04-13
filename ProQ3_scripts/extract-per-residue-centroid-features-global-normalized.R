#!/usr/bin/env Rscript

# Written by Karolis Uziela in 2015

cargs <- commandArgs(trailingOnly = TRUE)

input_file <- cargs[1]
output_file <- cargs[2]
feat_len <- cargs[3]

script_name <- basename(sub(".*=", "", commandArgs()[4]))

# ---------------------- Main script ------------------------- #

#write(paste(script_name, "is running with arguments:"), stderr())
#write(paste(" ", cargs), stderr())
#write("----------------------- Output ---------------------", stderr())

scores <- read.table(input_file, head=T)

feat_len <- as.numeric(feat_len)

#scores <- scores[,3:8] # Six columns: rg co hs_pair ss_pair rsigma sheet
scores <- scores[c("rg", "co", "hs_pair", "ss_pair", "rsigma", "sheet")] # Six columns: rg co hs_pair ss_pair rsigma sheet
#scores$rf_norm <- scores$rg / feat_len^(2/5) # Seven columns

#scores_sigmoid <- scores 
#
#for (i in 1:7) {
#    scores_sigmoid[,i] <- 1/(1+exp(scores_sigmoid[,i]))
#}

#for (i in 1:7) {
#    scores[,i] <- 1 / (1 + scores[,i] / 100)
#}

#scores[,1] <- scores[,1] / 450
#scores[,2] <- scores[,2] / 300
#scores[,3] <- scores[,3] / 130
#scores[,4] <- scores[,4] / 50
#scores[,5] <- scores[,5] / 350
#scores[,6] <- scores[,6] / 250
#scores[,7] <- scores[,7] / 140

#scores_norm <- scores

scores[,1] <- scores[,1] / feat_len^0.4
scores[,2] <- scores[,2] / feat_len^0.72
for (i in 3:6) {
    scores[,i] <- scores[,i] / feat_len
}

my_sums <- rowSums(scores)       # Recalculate sums with normalized features
scores <- cbind(scores, my_sums)

for (i in 1:7) {
    scores[,i] <- 1/(1+exp(scores[,i]))  # Scale using sigmoid function
}

#scores <- cbind(scores_norm, scores_sigmoid)

for (i in 2:feat_len) {
    scores <- rbind(scores, scores[1,])
}
#head(scores)
#nrow(scores)

write.table(scores, file=output_file, quote=F, row.names=F, col.names=F)

#write(paste(script_name, "is done."), stderr())

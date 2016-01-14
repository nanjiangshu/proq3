#!/usr/bin/env Rscript

# Written by Karolis Uziela in 2015

cargs <- commandArgs(trailingOnly = TRUE)

input_file <- cargs[1]
output_file <- cargs[2]

library(zoo)
#library(plyr)

script_name <- basename(sub(".*=", "", commandArgs()[4]))


# ---------------------- Functions ------------------------- #

my_window <- function(scores_sigmoid, window_size) {
    scores_sigmoid_window <- as.data.frame(rollapply(zoo(scores_sigmoid), width = window_size, FUN = mean, align = "center", partial=TRUE))
    return(scores_sigmoid_window)
}

# ---------------------- Main script ------------------------- #

#write(paste(script_name, "is running with arguments:"), stderr())
#write(paste(" ", cargs), stderr())
#write("----------------------- Output ---------------------", stderr())

scores <- read.table(input_file, head=T, as.is=T)

#head(scores)

scores <- scores[,-c(1,2,20)] # remove SCORE:, filename and residue number columns. What is left: 16 features and `score` (total colummn number: 17)
scores$hbonds <- rowSums(scores[,c(7,8,9,10)]) 
scores$van_der_vals <- rowSums(scores[,c(1,2,4)])
scores$side_chains <- rowSums(scores[,c(6,11,14,16)])
scores$backbone <- rowSums(scores[,c(12,13,15)])
scores$score_no_sol_and_dslf_and_ref <- rowSums(scores[,c(1:2,4:10,12:15)])
scores$score_three_best <- rowSums(scores[,c(1,5,12)])
scores$score_seven_best <- rowSums(scores[,c(1,5,7,8,9,10,12)]) # Added 7 more columns. Total column number: 24

#head(scores)
scores_sigmoid <- scores

if (sum(is.na(scores)) > 0) {
    print("ERROR: the input score file contains NA")
    quit(status=1)
}

for (i in 1:24) {
    scores_sigmoid[,i] <- 1/(1+exp(scores_sigmoid[,i]))
}

#head(scores_sigmoid)

######## Window scores #########

#print(scores_sigmoid$fa_rep)

scores_sigmoid_window5 <- my_window(scores_sigmoid, 5)
scores_sigmoid_window11 <- my_window(scores_sigmoid, 11)
scores_sigmoid_window21 <- my_window(scores_sigmoid, 21)

#print(scores_sigmoid_window5$fa_rep)
scores_sigmoid <- cbind(scores_sigmoid, scores_sigmoid_window5)
scores_sigmoid <- cbind(scores_sigmoid, scores_sigmoid_window11)
scores_sigmoid <- cbind(scores_sigmoid, scores_sigmoid_window21)
#head(scores_sigmoid)

######## Global scores #########

for (i in 1:24) {
    scores_sigmoid <- cbind(scores_sigmoid, mean(scores_sigmoid[,i]))
}

#head(scores_sigmoid)
#print(ncol(scores_sigmoid))

write.table(scores_sigmoid, file=output_file, row.names=FALSE, col.names=FALSE, sep=" ")

#write(paste(script_name, "is done."), stderr())


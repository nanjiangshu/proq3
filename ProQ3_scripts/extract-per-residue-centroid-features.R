#!/usr/bin/env Rscript

# Written by Karolis Uziela in 2015

cargs <- commandArgs(trailingOnly = TRUE)

input_file <- cargs[1]
output_file <- cargs[2]

library(zoo)

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

#scores <- scores[,-c(1,2,10)] # remove SCORE:, filename and residue number columns. What is left: 4 features and `score` (total colummn number: 5)
scores <- scores[c("vdw", "cenpack", "pair", "rama", "env", "cbeta", "score")] # remove SCORE:, filename and residue number columns. What is left: 4 features and `score` (total colummn number: 5)

scores_sigmoid <- scores

for (i in 1:7) {
    scores_sigmoid[,i] <- 1/(1+exp(scores_sigmoid[,i]))
}

#head(scores_sigmoid)

######## Window scores #########

scores_sigmoid_window5 <- my_window(scores_sigmoid, 5)
scores_sigmoid_window11 <- my_window(scores_sigmoid, 11)
scores_sigmoid_window21 <- my_window(scores_sigmoid, 21)


scores_sigmoid <- cbind(scores_sigmoid, scores_sigmoid_window5)
scores_sigmoid <- cbind(scores_sigmoid, scores_sigmoid_window11)
scores_sigmoid <- cbind(scores_sigmoid, scores_sigmoid_window21)
#head(scores_sigmoid)

######### Global scores #########

for (i in 1:7) {
    scores_sigmoid <- cbind(scores_sigmoid, mean(scores_sigmoid[,i]))
}

write.table(scores_sigmoid, file=output_file, row.names=FALSE, col.names=FALSE, sep=" ")

#write(paste(script_name, "is done."), stderr())


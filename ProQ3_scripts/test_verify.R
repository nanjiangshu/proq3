#!/usr/bin/env Rscript

# Written by Karolis Uziela in 2015

cargs <- commandArgs(trailingOnly = TRUE)

input_local_file1 <- cargs[1]
input_local_file2 <- cargs[2]
input_global_file1 <- cargs[3]
input_global_file2 <- cargs[4]

THRESH <- 0.8

local1 <- read.table(input_local_file1, sep=" ", head=TRUE)
local2 <- read.table(input_local_file2, sep=" ", head=TRUE)
global1 <- read.table(input_global_file1, sep=" ", head=TRUE)
global2 <- read.table(input_global_file2, sep=" ", head=TRUE)

for (i in 1:4) {
    my_cor <- cor(local1[,i],local2[,i]) 
    if (my_cor < 0.9) {
        name1 <- colnames(local1[i])
        print(paste("WARNING: Local score correlation between sample value and calculated value for ", name1, " is only: ", my_cor, sep="")) 
    }
}

for (i in 1:4) {
    my_diff <- abs(global1[1,i] - global2[1,i])
    if (my_diff > 0.1) {
        name1 <- colnames(global1[i])
        print(paste("WARNING: Global score difference between sample value and calculated value for ", name1, " is: ", my_diff, sep=""))
    }
}

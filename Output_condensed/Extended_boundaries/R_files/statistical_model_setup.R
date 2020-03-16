################################################################

# Created by Shannon Bengtson (ARC Centre of Excellence for Climate Extremes; Climate Change Research Centre, UNSW)
# This is the set up file for reconstructing d13C from benthic foraminifera data using simple statistical models
# Run this file from R and use the associated python files for analysing the outupt

################################################################



###################################################################

# Import all the required packages

######################################################################### 

library(easyNCDF)
library(schoolmath)
library(fields)
library(sp)
library(grid)
library(RColorBrewer)
library(ncdf4)
library(ggplot2)
library(plotly)
library(data.table)
library(Deriv)
library(rPython)
library(RMThreshold)
library(Matrix)
library(doParallel)
library(abind)
library(plyr)

########################################################################33

# Set up the conditions to model

#########################################################################

# Proxy dataset should

dataset <- c('LIG')
equation <- c('quad', 'tanh')
model <- c('UVic')
period <- c('Holocene')

# Set the time bounds (time slice)
resolution <- 1 # The number of years to include in each slice
lower <- seq(126, 130, resolution)
upper <- seq(127, 131, resolution)
slice <- mapply(c, lower, upper, SIMPLIFY=FALSE)

## This needs to be configured depending on if you are running the script on a proxy dataset (use 'data') or if you are testing on a model dataset (use 'model') 
type <- c('data')

## Put here the number of times you want to repeat the testing (boostrapping). Use 1 for 'data' type, set upper bound of seq for more the number of boostraps for 'model' type
repetitions <- 1

# Compile all of these setup conditions into an input array to be fed into the model
input <- expand.grid(dataset = dataset, equation = equation, model = model, type = type, period = period, slice = slice, reps = repetitions)
input$run.no <- rownames(input)

##################################################################

# Run the model in a loop

##################################################################

# Get the function from "statistical_model_loop_function.R" file
loop.func <- dget("statistical_model_loop_function.R")

# Create functions for extracting the different outputs from foreach function 
acombstatmod <- function(...)  abind(...$statmod, along = 3)
rcombdf <- function(...) rbind(...$df)
rcombsmp <- function(...) rbind(...$samples)

# Run each row in the input array in parallel  
output <- foreach(i = 1:nrow(input)) %do% {loop.func(input[i,])} #############dopar

# Extract the results
statistical.model.results <- array(as.numeric(unlist(lapply(output, acombstatmod))), dim = c(160, 120, nrow(input))) #Mean response of the statistical models
df.results.summary <- do.call(rbind, lapply(lapply(output, rcombdf), data.frame, stringsAsFactors = FALSE)) #Summary of the statistical models
samples <- rbind.fill(lapply(output, rcombsmp)) #Dataframe of the samples used for modelling. Useful when understanding bootstrapped results

# Break down time slice column into two columns, remove old 'slice' column
time.sep<- function(...) (unlist(...))
times <- lapply(df.results.summary['slice'], time.sep)
lower <- times$slice[seq(1, length(times$slice), 2)]
upper <- times$slice[seq(2, length(times$slice), 2)]
df.results.summary$lower <- lower
df.results.summary$upper <- upper
drops <- c('slice')
df.results.summary <- df.results.summary[ , !(names(df.results.summary) %in% drops)]

# Create output files
ArrayToNc(arrays = statistical.model.results, file_path = 'Output_condensed/output.nc')
write.table(df.results.summary, file = paste("Output_condensed/", 'summary.txt', sep = '_'), row.names = FALSE, col.names = TRUE)
write.table(samples, file = paste("Output_condensed/", 'samples.txt', sep = '_'), row.names = FALSE, col.names = TRUE)

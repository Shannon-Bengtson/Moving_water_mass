###############################################################################
###############################################################################
###############################################################################

#THIS SCRIPT CANNOT BE RUN IN PARALLEL!!!!!!!!!!!!!!!!!!!!!!!!!#

###############################################################################
###############################################################################
###############################################################################


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

#########################################################################

# no_cores <- detectCores() #check that this is working/????????
# ## no_cores <- 1
# clust <- makeCluster(no_cores)#, outfile = 'log.txt')
# registerDoParallel(clust)
# # writeLines(c(""), "log.txt")

########################################################################33

dataset <- c('LIG')
equation <- c('lin', 'tanh')


model <- c('UVic')
type <- c('data')
period <- c('Holocene')

resolution <- 5

lower <- seq(2, 132, resolution)
upper <- seq(12, 142, resolution)
slice <- mapply(c, lower, upper, SIMPLIFY=FALSE)

###################################################################

repetitions <- 1

input <- expand.grid(dataset = dataset, equation = equation, model = model, type = type, period = period, slice = slice, reps = repetitions)

##################################################################

loop.func <- dget("loop_func_5.R")

input$run.no <- rownames(input)

acombstatmod <- function(...)  abind(...$statmod, along = 3)
rcombdf <- function(...) rbind(...$df)
rcombsmp <- function(...) rbind(...$samples)

output <- foreach(i = 1:nrow(input)) %do% {loop.func(input[i,])} #############dopar

statmod <- array(as.numeric(unlist(lapply(output, acombstatmod))), dim = c(100, 19, nrow(input)))

df <- do.call(rbind, lapply(lapply(output, rcombdf), data.frame, stringsAsFactors = FALSE))
samples <- rbind.fill(lapply(output, rcombsmp))

ArrayToNc(arrays = statmod, file_path = 'Output_condensed/output.nc')
write.table(df, file = paste("Output_condensed/", 'summary.txt', sep = '_'), row.names = FALSE, col.names = TRUE)
write.table(samples, file = paste("Output_condensed/", 'samples.txt', sep = '_'), row.names = FALSE, col.names = TRUE)


stopCluster(clust)

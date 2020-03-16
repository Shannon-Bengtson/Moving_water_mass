################################################################

# Created by Shannon Bengtson (ARC Centre of Excellence for Climate Extremes; Climate Change Research Centre, UNSW)
# This function is loaded by the statistical_model_setup.R file

################################################################

loop_func <- function(input) {     

    ###################################################################

    # Import all the required packages

    ######################################################################### 
    
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
    
    method <<- 'real' ### Changes these
    replace.EM <<- FALSE
    regrid <<- TRUE

    ###################################################################

    # Import all the required packages

    ######################################################################### 
    
    options(warn=-1)    
    solver <<- 'port'
    min.fact <<- 2^(-30)
    tol <<- 1e-10 ########changed this
    sigs <<- 4

    ############

    if (input[, 'equation'] == 'quad') {
       end.mem.spec <<- 'no'
    }

    if (input[, 'equation'] == 'tanh') {
       end.mem.spec <<- 'yes'
    }

    ############ put the correct date range into the txt file

    cat('From year: ', input[,'slice'][[1]][1], ', to year: ', input[,'slice'][[1]][2])

    write.table(data.frame('lower' = input[, 'slice'][[1]][1], 'upper' = input[, 'slice'][[1]][2]), file = 'Data/year_range.txt', row.names = FALSE, col.names = TRUE)

######################## Run the python file which will make the new dataframe

    system('ipython Sorting_moving_period.py')
    print('Ran ipython')
    #########################3 continue with the script as normal
    
    df <- data.frame(read.table("Data/moving_atl.csv", sep = ',', header = TRUE))

    browser()
    
    print('read in proxy data')
    
    params <<- read.table('Data/box_params.txt', header = TRUE)
    if (input[,'model'] == 'UVic') {
        dep_3 <<- params[params$para == 'dep_3_UVic', ]$value
    }
    if (input[,'model'] == 'LOVECLIM') {
        dep_3 <<- params[params$para == 'dep_3_LOVECLIM', ]$value
    }    
    lat_1 <<- params[params$para == 'lat_1', ]$value
    lat_3 <<- params[params$para == 'lat_3', ]$value

    dep <- array(read.csv('Data/depth_levels.csv', header = FALSE)$V1)
    lat <- array(read.csv('Data/latitude_levels.csv', header = FALSE)$V1)
    
    if (regrid == TRUE) {
        if (input[, 'period'] == 'Holocene' & input[, 'model'] == 'LOVECLIM') {
            d13C <- as.matrix(read.csv('Data/d13C_LOVECLIM_INTERP_hol.csv', header = FALSE)) # Should become the name of the file... needs to work for netcdf
        }
    }

    if (regrid == TRUE) {
        if (input[, 'period'] == 'Holocene' & input[, 'model'] == 'UVic') {
            d13C <- as.matrix(read.csv('Data/d13C_UVic_INTERP_hol.csv', header = FALSE))
        }
    }
    
###################################
    
    noise.std <- 0.32/2
    sink("/dev/null")
    d13C <- add.Gaussian.noise(d13C, mean = 0, stddev = noise.std, symm = FALSE)
    sink()

    print('setup complete')
    
    success = FALSE
    while (!success) {
        dget("randomising.R")(input[, 'model'], input[, 'type'], input[, 'period'], input[, 'equation'], input[, 'dataset'], input[, 'reps'], d13C, d13C.temp, lat, lon, dep, mask, df)


        print('randomised')

        if (input[, 'equation'] == 'quad' ) {
            
            attempt_rand <- try(input[, 'dep_4'] <- dget("Split_running_func.R")(input[, 'model'], input[, 'period'], input[, 'type'], d13C, lat, dep, df, input[, 'equation']))
            print('completed Split running func')
        }
        if (input[,'equation'] == 'tanh' ) {
            attempt_rand <- NA
            input[, 'dep_4'] <- NA
        }
#         input[, 'dep_4_orig'] <- input[, 'dep_4']
        if (!("try-error" %in% class(attempt_rand))) {
            print('successful split function')
            attempt_model<- try(output <- dget("strat_18.R")(input[, 'model'], input[, 'type'], input[, 'period'], input[, 'equation'], input[, 'dep_4'], input[, 'dataset'], input[, 'reps'], d13C, d13C.temp, lat, lon, dep, mask, df ))#, silent = TRUE)
#            print(input[,'dep_4'])
            if(!("try-error" %in% class(attempt_model))) {
                print('successful modelling')
                success = TRUE
            }
        }
    }

    print('modeling complete')
        
    filename <- paste(input[, 'reps'], input[, 'dataset'], input[, 'model'], input[, 'period'], input[, 'type'], input[, 'equation'], sep = '_')
        
    input[, 'filename'] <- paste(filename, "d13C.txt", sep = '_')
    input[, 'success.rate'] <- success
    
    if(!success) {
        output = list()
        output$statmod <- matrix(NA, nrow = length(lat), ncol = length(dep))
        output$samples <- data.frame(NA)
	output$stats <- data.frame(sigma = NA, N_mem = NA, A_mem = NA, a.AABW = NA, b.AABW = NA, c.AABW = NA, e.AABW = NA, a.NADW = NA, b.NADW = NA, c.NADW = NA, e.NADW = NA)}
	
    rownames(output$stats) <- NULL
    rownames(input) <- NULL
    input <- merge(input, output$stats, by = 0)
    
    output$samples$run.no <- rep(input[,'run.no'], times = nrow(output$samples))

    print('output made')
    print(' ')
    
    return(list(df = input, statmod = output$statmod, samples = output$samples))
    
}

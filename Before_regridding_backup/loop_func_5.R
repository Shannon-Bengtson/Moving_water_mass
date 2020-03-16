
loop_func <- function(input) {     

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
    
    method <<- 'real'
    replace.EM <<- FALSE
    
    options(warn=-1)    
    solver <<- 'port'
    min.fact <<- 2^(-30)
    tol <<- 1e-4 ########changed this
    sigs <<- 4

    ############

    if (input[, 'equation'] == 'lin') {
       end.mem.spec <<- 'no'
    }

    if (input[, 'equation'] == 'tanh') {
       end.mem.spec <<- 'yes'
    }

    ############ put the correct date range into the txt file

    print(input[,'slice'][[1]][2])

    write.table(data.frame('lower' = input[, 'slice'][[1]][1], 'upper' = input[, 'slice'][[1]][2]), file = '/srv/ccrc/data06/z5145948/Statistical_Model/Data/Moving_data/year_range.txt', row.names = FALSE, col.names = TRUE)
    
    ######################## Run the python file which will make the new dataframe

    system('ipython ../Updated_cores/Python/Sorting_moving_period.py')
    print(input[,'lower'][[1]][1])
    
    #########################3 continue with the script as normal
    
    LIG_hol_prox_data <<- read.table("/srv/ccrc/data06/z5145948/Statistical_Model/Data/Moving_data/moving_atl.csv", sep = ',', header = TRUE)
    
    UVic_hol_model_data <<- nc_open("/srv/ccrc/data06/z5145948/Statistical_Model/Data/d13C_lat_dep_UVic_hol.nc")
    LOVECLIM_hol_model_data <<- nc_open("/srv/ccrc/data06/z5145948/Statistical_Model/Data/d13C_lat_dep_LOVECLIM_hol.nc")
    UVic_lgm_model_data <<- nc_open("/srv/ccrc/data06/z5145948/Statistical_Model/Data/0559_95_d13C_lat_dep_UVic_lgm.nc") #new uvic file
    LOVECLIM_lgm_model_data <<- nc_open("/srv/ccrc/data06/z5145948/Statistical_Model/Data/d13C_lat_dep_LOVECLIM_lgm.nc")
    UVic_lig_model_data <<- nc_open("/srv/ccrc/data06/z5145948/Statistical_Model/Data/d13C_lat_dep_UVic_lig.nc")
    LOVECLIM_lig_model_data <<- nc_open("/srv/ccrc/data06/z5145948/Statistical_Model/Data/d13C_lat_dep_LOVECLIM_lig.nc")

    params <<- read.table('/srv/ccrc/data06/z5145948/Statistical_Model/Data/box_params.txt', header = TRUE)
    if (input[,'model'] == 'UVic') {
        dep_3 <<- params[params$para == 'dep_3_UVic', ]$value
    }
    if (input[,'model'] == 'LOVECLIM') {
        dep_3 <<- params[params$para == 'dep_3_LOVECLIM', ]$value
    }    
    lat_1 <<- params[params$para == 'lat_1', ]$value
    lat_3 <<- params[params$para == 'lat_3', ]$value
    
    df <- dget("data_read_2.R")(input[, 'period'], input[, 'model'], input[, 'dataset'])
    
    d13C <- ncvar_get(model_data.o, varid = 'd13C')
    lat <- ncvar_get(model_data.o, varid = 'Latitude')
    lon <- ncvar_get(model_data.o, varid = 'Longitude')
    dep <- ncvar_get(model_data.o, varid = 'Depth')
    mask <- ncvar_get(model_data.o, varid = 'masked')
 
    if (input[, 'model'] == "UVic") {
        d13C[d13C > 9e36] <- NA
        
        mask[mask == 0] <- 10
        mask[mask == 1] <- 0
        mask[mask == 10] <- 1
        mask[mask == 0] <- NA
        d13C <- d13C * mask
        d13C.temp <- d13C
        d13C <- apply(d13C, c(2,3), mean, na.rm=TRUE) }
    
    if (input[, 'model'] == "LOVECLIM") {
        d13C[d13C > 9e36] <- NA
        
        mask[mask  == 1] <- NA
        mask[mask  > 9e36] <- 1
        
        d13C <- d13C * mask
        d13C.temp <- d13C
        d13C <- apply(d13C, c(2,3), mean, na.rm=TRUE) }
    
    
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

            attempt_rand <- try(input[, 'dep_4'] <- dget("Split_running_func.R")(input[, 'model'], input[, 'period'], input[, 'type'], d13C, d13C.temp, lat, lon, dep, mask, df, input[, 'equation']))

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
        
    filename <- paste(input[, 'reps'], input[, 'dataset'], input[, 'model'], input[, 'period'], input[, 'type'], input[, 'end.mem.spec'], input[, 'equation'], sep = '_')
        
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

    print(input)
    print('output made')
    
    return(list(df = input, statmod = output$statmod, samples = output$samples))
    
}

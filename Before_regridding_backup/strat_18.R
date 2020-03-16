
modelling <- function(model, type, period, equation, dep_4, dataset, repetitions, d13C, d13C.temp, lat, lon, dep, mask, df) {
    if (equation == 'tanh') {
        cluster_name <<- list("Mixing")
        cluster_num <<- 1 }
    
    if (equation == 'quad') {
        cluster_name <<- list("AABW", "Mixing")
        cluster_num <<- 2 }
    
##########################################################

    ## if (type == 'model' & method == 'soln') {
    ##     df <- dget("Approx.R")(df, lat, dep, d13C, equation)}
    
##############################3 set up regions    
#    print('############ start ########')

    if (equation == 'tanh') { 
        df_c4 <- df_c #df_c[df_c[,c("Lat")] > lat_1 & df_c[,c("Lat")] < lat_3 & df_c[,c("Ocean_depth")] > dep_3, ]

        x_coord_min_4 <- which(abs(lat - lat_1) == min(abs(lat - lat_1)))
        x_coord_max_4 <- which(abs(lat - lat_3) == min(abs(lat - lat_3)))

        y_coord_min_4 <- which(abs(dep - dep_3) == min(abs(dep - dep_3)))
        y_coord_max_4 <- which(abs(dep - 6000) == min(abs(dep - 6000)))

    }
    
    if (equation == 'quad') {    

        df_c1 <- df_c[df_c[,c("Ocean_depth")] > dep_4, ]
        df_c4 <- df_c[df_c[,c("Ocean_depth")] <= dep_4, ]

        x_coord_min_1 <- which(abs(lat - lat_1) == min(abs(lat - lat_1)))
        x_coord_max_1 <- which(abs(lat - lat_3) == min(abs(lat - lat_3)))

        y_coord_min_1 <- which(abs(dep - dep_4) == min(abs(dep - dep_4)))
        y_coord_max_1 <- which(abs(dep - 6000) == min(abs(dep - 6000)))

        x_coord_min_4 <- which(abs(lat - lat_1) == min(abs(lat - lat_1)))
        x_coord_max_4 <- which(abs(lat - lat_3) == min(abs(lat - lat_3)))

        y_coord_min_4 <- which(abs(dep - dep_3) == min(abs(dep - dep_3)))
        y_coord_max_4 <- which(abs(dep - dep_4) == min(abs(dep - dep_4)))
        print(unique(df_c1$Ocean_depth))
    }
#    print(unique(df_c4$Ocean_depth))
#    print('############ stop ########')
    
#################################################
    
    topography <- d13C*0 + 1

    x_coord_min_N <- which(abs(lat - lat_3) == (min(abs(lat - lat_3))))
    x_coord_max_N <- which(abs(lat - 70) == min(abs(lat - 70)))

    y_coord_min_N <- which(abs(dep - dep_3) == min(abs(dep - dep_3)))
    y_coord_max_N <- which(abs(dep - 3000) == min(abs(dep - 3000)))

    x_coord_min_A <- which(abs(lat + 60) == min(abs(lat + 60)))
    x_coord_max_A <- which(abs(lat - lat_1) == min(abs(lat - lat_1)))

    y_coord_min_A <- which(abs(dep - dep_3) == min(abs(dep - dep_3)))
    y_coord_max_A <- which(abs(dep - 6000) == min(abs(dep - 6000)))

############################################

    
    N.data.mean <<- mean(unlist(df.N['d13C']))
    A.data.mean <<- mean(unlist(df.A['d13C']))
        
    N_mem <<- N.data.mean
    A_mem <<- A.data.mean

    lat.0.N <<- lat_3
    lat.0.A <<- lat_1
    
###########################################

    N.Mem.region <- matrix(NA, nrow = dim(lat), ncol = dim(dep))
    A.Mem.region <- matrix(NA, nrow = dim(lat), ncol = dim(dep))
    statmod_mask_4 <- matrix(NA, nrow = dim(lat), ncol = dim(dep))
    statmod_mask_N <- matrix(NA, nrow = dim(lat), ncol = dim(dep))
    statmod_mask_A <- matrix(NA, nrow = dim(lat), ncol = dim(dep))

    if (equation == 'quad') {
        statmod_mask_1 <- matrix(NA, nrow = dim(lat), ncol = dim(dep))
        statmod_mask_1[x_coord_min_1:x_coord_max_1, y_coord_min_1:y_coord_max_1] <- 1 
        statmod_mask_1 <- statmod_mask_1 * topography}
    
    statmod_mask_4[x_coord_min_4:x_coord_max_4, y_coord_min_4:y_coord_max_4] <- 1 
    statmod_mask_4 <- statmod_mask_4 * topography

    N.Mem.region[x_coord_min_N:x_coord_max_N, y_coord_min_N:y_coord_max_N] <- N.data.mean 
    N.Mem.region <<- N.Mem.region * topography

    A.Mem.region[x_coord_min_A:x_coord_max_A, y_coord_min_A:y_coord_max_A] <- A.data.mean 
    A.Mem.region <<- A.Mem.region * topography

    statmod_mask_N[x_coord_min_N:x_coord_max_N, y_coord_min_N:y_coord_max_N] <- 1 
    statmod_mask_N <<- statmod_mask_N * topography

    statmod_mask_A[x_coord_min_A:x_coord_max_A, y_coord_min_A:y_coord_max_A] <- 1 
    statmod_mask_A <<- statmod_mask_A * topography

######################################################

    ## if (method == 'rand.loc') {

    ##     dimnames(d13C.temp) <- list(lon, lat, dep)
    ##     df.mod <- as.data.frame.table(d13C.temp, as.is = 'character')
        
    ##     colnames(df.mod) <- c("Lon","Lat","Ocean_depth","d13C")

    ##     df.mod$Lat <- as.numeric(as.character(df.mod$Lat))
    ##     df.mod$Lon <- as.numeric(as.character(df.mod$Lon))
    ##     df.mod$Ocean_depth <- as.numeric(as.character(df.mod$Ocean_depth))
    ##     df.mod$d13C <- as.numeric(as.character(df.mod$d13C))
    ##     df.mod <- df.mod[complete.cases(df.mod), ]
        
    ##     if (equation == 'quad') {df.c1 <- df.mod[df.mod[,c("Lat")] > lat_1 & df.mod[,c("Lat")] < lat_3 & df.mod[,c("Ocean_depth")] > dep_4, ]
    ##         df.c4 <- df.mod[df.mod[,c("Lat")] > lat_1 & df.mod[,c("Lat")] < lat_3 & df.mod[,c("Ocean_depth")] > dep_3 & df.mod[,c("Ocean_depth")] < dep_4, ]}
    ##     if (equation == 'tanh') {df.c4 <- df.mod[df.mod[,c("Lat")] > lat_1 & df.mod[,c("Lat")] < lat_3 & df.mod[,c("Ocean_depth")] > dep_3, ] }
    ##     df.cN <- df.mod[df.mod[,c("Lat")] > lat_3 & df.mod[,c("Lat")] < 70 & df.mod[,c("Ocean_depth")] > dep_3 & df.mod[,c("Ocean_depth")] < 3000 , ]
    ##     df.cA <- df.mod[df.mod[,c("Lat")] > -60 & df.mod[,("Lat")] < lat_1 & df.mod[,c("Ocean_depth")] > dep_3 & df.mod[,c("Ocean_depth")] < 6000 , ]

    ##     if (equation == 'quad') {
    ##         df_c1 <- df.c1[sample(nrow(df.c1), nrow(df_c1), replace = TRUE), ]
    ##         df_c1 <- df_c1[!duplicated(df_c1), ]}
        
    ##     df_c4 <- df.c4[sample(nrow(df.c4), nrow(df_c4), replace = TRUE), ]
    ##     df_c4 <- df_c4[!duplicated(df_c4), ]
        
    ##     df.N <- df.cN[sample(nrow(df.cN), nrow(df.N), replace = TRUE), ]
    ##     df.N <- df.N[!duplicated(df.N), ]
        
    ##     df.A <- df.cA[sample(nrow(df.cA), nrow(df.A), replace = TRUE), ]
    ##     df.A <- df.A[!duplicated(df.A), ]
        
    ## }
    

#######################################################

    lat.1 <- which(abs(lat - lat_1) == min(abs(lat - lat_1)))
    lat.3 <- which(abs(lat - lat_3) == min(abs(lat - lat_3)))
    
    statmod_mask_Nm <- statmod_mask_N
    statmod_mask_Am <- statmod_mask_A
    if (equation == 'quad') {statmod_mask_1m <- statmod_mask_1}
    statmod_mask_4m <- statmod_mask_4

    statmod_mask_Nm[lat.3,] <- 0
    statmod_mask_Am[lat.1,] <- 0

    statmod_mask_Nm[is.na(statmod_mask_Nm)] <- 0
    statmod_mask_Am[is.na(statmod_mask_Am)] <- 0
    if (equation == 'quad') {statmod_mask_1m[is.na(statmod_mask_1m)] <- 0}
    statmod_mask_4m[is.na(statmod_mask_4m)] <- 0


    
    if (equation == 'quad') {
        dep.4 <- which(abs(dep - dep_4) == min(abs(dep - dep_4)))
        statmod_mask_4m[,dep.4] <- 0
        total <- statmod_mask_1m + statmod_mask_4m + statmod_mask_Nm + statmod_mask_Am } else { total <- statmod_mask_4m + statmod_mask_Nm + statmod_mask_Am }
    
    total[total == 0 ] <- NA

    model_reduced_area <- total * d13C

    if (as.numeric(repetitions) == 1) {write.table(model_reduced_area, file = paste('Output_condensed/', dataset, model, period, type, equation, 'model_data_reduced.txt', sep = '_'), row.names = FALSE, col.names = FALSE) }

##################3 just the model data which is used
    
    if (equation == 'quad') {df.tot <- rbind(df.N, df.A, df_c1, df_c4)} else {df.tot <- rbind(df.N, df.A, df_c4)}

#    write.table(df.tot, file = paste('Output_condensed/',repetitions, dataset, model, period, type, equation, 'model_data_sample.txt', sep = '_'), row.names = FALSE, col.names = TRUE)


######################################################

    model_clust <- function(type, df, name, mask, count) {       ##########start model_clust
        
######################## 

        if (name == "AABW" & end.mem.spec == 'no') {    
            output <- dget("form_AABW.R")}
        
        if (name == 'Mixing' & equation == 'tanh') {
            output <- dget("form_NADW_tanh.R")}

        if (name == 'Mixing' & equation == 'quad' & end.mem.spec == 'no') {
            output <- dget("form_NADW_quad.R")}

##############################
        
        if (name == "AABW" & end.mem.spec == 'no') {
            error_marker <<- 'AABW' }        
        
        if (name == 'Mixing' & end.mem.spec == 'no' & equation == 'quad') {
            error_marker <<- 'NADW'}
        
#        nlsfit <- nls(d13C ~ output(a, b, c, e, Lat, Ocean_depth), df, weights = df[, 'count'], start = list(a = -0.005, b = 0, c = 0, e = 1), control = nls.control(minFactor = min.fact, tol = tol, warnOnly = TRUE))
        nlsfit <- nls(d13C ~ output(a, b, c, e, Lat, Ocean_depth), df, start = list(a = 0, b = 0, c = 0, e = 1), control = nls.control(minFactor = min.fact, tol = tol, warnOnly = TRUE))

        
        params.to.save <- signif(data.frame(summary(nlsfit)$coeff), sigs)
        params.to.save['Std..Error'] <- params.to.save['Std..Error']/params.to.save['Estimate']
        
        a <- coef(nlsfit)['a']
        b <- coef(nlsfit)['b']
        c <- coef(nlsfit)['c']
        e <- coef(nlsfit)['e']
        
#################

        df$pred.d13C <- output(a, b, c, e , df$Lat, df$Ocean_depth)
        df$resids <- df$d13C - df$pred.d13C

        df2 <- matrix(,nrow = dim(dep), ncol = dim(lat))
        
####################
        
        for (value in seq(1,nrow(lat),1)){df2[,value] <- output(a, b, c, e, rep(lat[value], dim(dep)), dep)}
    
        df2 <- t(df2) * mask

#################### export the results

        forexport <- df2    
        forexport[ is.nan(forexport) ] <- 0
        forexport[ is.na(forexport) ] <- 0
        
        if (name == "AABW") {

            a.AABW <<- a
            b.AABW <<- b
            c.AABW <<- c
            e.AABW <<- e

	    sigma.aabw <<- summary(nlsfit)$sigma
	    n <<- nrow(df)

            AABW.region <<- forexport}
        
        if (name == 'Mixing') {

            a.NADW <<- a
            b.NADW <<- b
            c.NADW <<- c
            e.NADW <<- e
            
            N.Mem.region[ is.na(N.Mem.region) ] <- 0
            A.Mem.region[ is.na(A.Mem.region) ] <- 0
            
            NADW.region <<- forexport

            
            if (equation == 'quad') {

	        sigma.mixing <<- (sigma.aabw * (n - 2) +  summary(nlsfit)$sigma * (nrow(df) - 2)) / (n + nrow(df) - 2)

                dep.4 <- which(abs(dep - dep_4) == min(abs(dep - dep_4)))
                NADW.region[,dep.4] <- 0

                total <- NADW.region + AABW.region } else {    
		      	 	       		       sigma.mixing <<- summary(nlsfit)$sigma

                                                       lat.1 <- which(abs(lat - lat_1) == min(abs(lat - lat_1)))
                                                       lat.3 <- which(abs(lat - lat_3) == min(abs(lat - lat_3)))
                                                       
                                                       N.Mem.region[lat.3,] <- 0
                                                       A.Mem.region[lat.1,] <- 0    

                                                       total <- NADW.region + A.Mem.region + N.Mem.region }
            
            total[total == 0 ] <- NA   
        }
        return(total)
    }
    
###########3running model_clust function

    if (equation == 'tanh') {cluster_list <- list(df_c4)
        mask <- list(statmod_mask_4) }
    
    if (equation == 'quad') {cluster_list <- list(df_c1, df_c4)
        mask <- list(statmod_mask_1, statmod_mask_4) }

    for (count in seq(1, cluster_num, 1)) {            
        total <- model_clust(type, cluster_list[[count]], cluster_name[[count]], mask[[count]], count)}

    N_mem <<- N.data.mean
    A_mem <<- A.data.mean
    attempt <- try(stats <- data.frame(sigma = sigma.mixing, N_mem = N_mem, A_mem = A_mem, a.AABW = a.AABW, b.AABW = b.AABW, c.AABW = c.AABW, e.AABW = e.AABW, a.NADW = a.NADW, b.NADW = b.NADW, c.NADW = c.NADW, e.NADW = e.NADW), silent = TRUE)
    if(("try-error" %in% class(attempt))) {
    		    stats <- data.frame(sigma = sigma.mixing, N_mem = N_mem, A_mem = A_mem, a.AABW = NA, b.AABW = NA, c.AABW = NA, e.AABW = NA, a.NADW = a.NADW, b.NADW = b.NADW, c.NADW = c.NADW, e.NADW = e.NADW)}
    

    return(list(samples = df.tot, statmod = total, stats = stats))
}


modelling <- function(model, type, period, equation, dataset, repetitions, d13C, d13C.temp, lat, lon, dep, mask, df) {
        
##############################3 set up regions    
    print(dep_3)
    ######3divide into regions based on original proxy data, always. No dep_4 distinction
    
    df_c4 <- df[df[,c("Lat")] > lat_1 & df[,c("Lat")] < lat_3 & df[,c("Ocean_depth")] > dep_3, ]

    df2 <- cbind(df)

    if (replace.EM == TRUE) {
        for (i in seq(1, nrow(df2), 1)) {
            close.lat <- which(abs(lat - df2[i, 'Lat']) == min(abs(lat - df2[i, 'Lat'])))[1]
            close.dep <- which(abs(dep - df2[i, 'Dep']) == min(abs(dep - df2[i, 'Dep'])))[1]
            df2[i, 'd13C'] <- d13C[close.lat, close.dep] }

        df2 <- df2[complete.cases(df2), ]
        
        df.N <- df2[df2[,c("Lat")] > 50 & df2[,c("Lat")] < 70 & df2[,c("Ocean_depth")] > dep_3 & df2[,c("Ocean_depth")] < 3000 , ] #N EM
        df.A <- df2[df2[,c("Lat")] > -60 & df2[,("Lat")] < -40 & df2[,c("Ocean_depth")] > dep_3 & df2[,c("Ocean_depth")] < 6000 , ] } #A EM
    else {
            df.N <- df[df[,c("Lat")] > 50 & df[,c("Lat")] < 70 & df[,c("Ocean_depth")] > dep_3 & df[,c("Ocean_depth")] < 3000 , ] #N EM
            df.A <- df[df[,c("Lat")] > -60 & df[,("Lat")] < -40 & df[,c("Ocean_depth")] > dep_3 & df[,c("Ocean_depth")] < 6000 , ] } #A EM

    print(df.N)
    print(df.A)
    
######################################################

    if (method == 'rand.loc') {

        dimnames(d13C.temp) <- list(lon, lat, dep)
        df.mod <- as.data.frame.table(d13C.temp, as.is = 'character')
        
        colnames(df.mod) <- c("Lon","Lat","Ocean_depth","d13C")

        df.mod$Lat <- as.numeric(as.character(df.mod$Lat))
        df.mod$Lon <- as.numeric(as.character(df.mod$Lon))
        df.mod$Ocean_depth <- as.numeric(as.character(df.mod$Ocean_depth))
        df.mod$d13C <- as.numeric(as.character(df.mod$d13C))
        df.mod <- df.mod[complete.cases(df.mod), ]
        
        df.c4 <- df.mod[df.mod[,c("Lat")] > lat_1 & df.mod[,c("Lat")] < lat_3 & df.mod[,c("Ocean_depth")] > dep_3, ]
        df.cN <- df.mod[df.mod[,c("Lat")] > lat_3 & df.mod[,c("Lat")] < 70 & df.mod[,c("Ocean_depth")] > dep_3 & df.mod[,c("Ocean_depth")] < 3000 , ]
        df.cA <- df.mod[df.mod[,c("Lat")] > -60 & df.mod[,("Lat")] < lat_1 & df.mod[,c("Ocean_depth")] > dep_3 & df.mod[,c("Ocean_depth")] < 6000 , ]

        df_c4 <- df.c4[sample(nrow(df.c4), nrow(df_c4), replace = TRUE), ]
        df_c4 <- df_c4[!duplicated(df_c4), ]
        
        df.N <- df.cN[sample(nrow(df.cN), nrow(df.N), replace = TRUE), ]
        df.N <- df.N[!duplicated(df.N), ]
        
        df.A <- df.cA[sample(nrow(df.cA), nrow(df.A), replace = TRUE), ]
        df.A <- df.A[!duplicated(df.A), ]        
    }

    df_c <<- df_c4
    df.N <<- df.N
    df.A <<- df.A

}

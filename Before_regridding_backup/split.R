
modelling <- function(model, type, period, dep_4, d13C, d13C.temp, lat, lon, dep, mask, df, equation) {

    
##############################3 set up regions    
  
    df_c1 <- df_c[df_c[,c("Lat")] > lat_1 & df_c[,c("Lat")] < lat_3 & df_c[,c("Ocean_depth")] > dep_4, ]    
#    df_c1 <- df_c[df_c[,c("Lat")] > 20 & df_c[,c("Lat")] < lat_3 & df_c[,c("Ocean_depth")] > dep_4, ]    ##only including the north in the split depth determination

    df_c4 <- df_c[df_c[,c("Lat")] > lat_1 & df_c[,c("Lat")] < lat_3 & df_c[,c("Ocean_depth")] > dep_3 & df_c[,c("Ocean_depth")] < dep_4, ]
#    df_c4 <- df_c[df_c[,c("Lat")] > 20 & df_c[,c("Lat")] < lat_3 & df_c[,c("Ocean_depth")] > dep_3 & df_c[,c("Ocean_depth")] < dep_4, ]  ##only including the north in the split depth determination
        
#################################################    

    c1.avg <- mean(unlist(df_c1['d13C']))
    c1.tot <- sum((df_c1['d13C'] - c1.avg)**2)
    
    c4.avg <- mean(unlist(df_c4['d13C']))
    c4.tot <- sum((df_c4['d13C'] - c4.avg)**2)

    if (type == 'model') { dep.out <- dep[which(abs(dep - dep_4) == min(abs(dep - dep_4)))]} else(dep.out <- dep_4)

    ret <- c(c4.tot, c1.tot, dep.out)
    
    return(ret)}

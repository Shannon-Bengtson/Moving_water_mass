Approx <- function(df, lat, lon, dep, d13C, equation) {

    for (i in seq(1, nrow(df), 1)) {
        close.lon <- which(abs(lon - df[i, 'Lon']) == min(abs(lon - df[i, 'Lon'])))
        close.lat <- which(abs(lat - df[i, 'Lat']) == min(abs(lat - df[i, 'Lat'])))
        close.dep <- which(abs(dep - df[i, 'Dep']) == min(abs(dep - df[i, 'Dep'])))
        if (equation == 'tanh') {df[i, 'mod.d13C'] <- d13C[min(close.lat), min(close.lon), min(close.dep) ]} }
#         print(df[i, 'mod.d13C'])}
    df$d13C <- df$mod.d13C
    df <- df[complete.cases(df), ]
    return(df)
    }

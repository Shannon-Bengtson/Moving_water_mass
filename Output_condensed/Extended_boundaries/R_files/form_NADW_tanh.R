output <- function(a, b, c, e, Lat, Ocean_depth) {
#    ( (A_mem - N_mem) * tanh(a*Lat + b*Ocean_depth + c*Ocean_depth**2)  + A_mem + N_mem)/2}
    ( (A_mem - N_mem) * tanh(a*Lat + b*Ocean_depth + c*Ocean_depth**2 + e)  + A_mem + N_mem)/2}

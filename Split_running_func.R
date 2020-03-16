
split <- function(model, period, type, d13C, lat, dep, df, equation) {

    dep_4 <- dep[(dep > 2050) & (dep < 4000)] #    dep_4 <- dep[(dep > 2050) & (dep < 4000)]
   
                                        #    if (type == 'model') {dep_4 <- dep[(dep > 2000) & (dep < 4500)] }
#    if (type == 'data') {dep_4 <- seq(200, 4200, 100)}
    
    deps <- data.frame('dep_4' = dep_4)

    for (i in seq(1, nrow(deps), 1)) {

        output <- dget("split.R")(model, type, period, deps[i, 'dep_4'], d13C, lat, dep, df, equation)
        
        deps[i, 'c4'] <- matrix(output)[1,1]
        deps[i, 'c1'] <- matrix(output)[2,1]
        deps[i, 'c.tot'] <- matrix(output)[1,1] + matrix(output)[2,1]
        deps[i, 'c.min'] <- abs(matrix(output)[1,1] - matrix(output)[2,1])
        deps[i, 'dep_4.actual'] <- matrix(output)[3,1]
        
    }

    deps <- deps[!duplicated(deps['dep_4.actual']), ]

    #browser()
    
    min.loc <- deps['dep_4.actual'][deps['c.tot'] == min(unlist(deps['c.tot']))]

    min.loc <- tail(min.loc,n=1)
    #min.loc <- if (length(min.loc) %% 2 == 0) {median(head(min.loc, -1))} else {median(min.loc)}
    
    print('Dep_4: ')
    print(min.loc)
                                        # attach(mtcars)
                                        # par(mfrow=c(8,4))

                                        # line.col = 258
    
    
    ## plot(unlist(deps['dep_4.actual']), unlist(deps['c1']), col = 'red', xlim = c(min(dep_4) - 200, max(dep_4) + 200), ylim = c(0, max(deps['c.tot'])), main = paste(model, period, type, sep = ' ' ))
    ## points(unlist(deps['dep_4.actual']), unlist(deps['c4']), col = 'blue')
    ## points(unlist(deps['dep_4.actual']), unlist(deps['c.tot']))
    ## # min.loc <- deps[deps['c.tot'] == min(unlist(deps['c.tot']))]['dep_4.actual']
    ## min.loc <- deps['dep_4.actual'][deps['c.tot'] == min(unlist(deps['c.tot']))]
    ## lines(c(min.loc, min.loc), c(0, max(deps['c.tot'])), col = line.col)

    return(min.loc) }

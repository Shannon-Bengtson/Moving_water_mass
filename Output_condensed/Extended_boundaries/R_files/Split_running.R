library(schoolmath)
library(fields)
library(sp)
library(grid)
library(RColorBrewer)
library(ncdf4)
library(ggplot2)
library(plotly)
library(data.table)

options(warn=-1)


model <- c("UVic", "LOVECLIM")
type <- c('data', 'model')
period <- c('Holocene', 'LGM')
dep_4 <- seq(2000, 4200, 200)

model.r <- rep(model, times = length(type))
type.r <- rep(type, each = length(model))

period.r <- rep(period, times = length(dep_4))
dep_4.r <- rep(dep_4, each = length(period))

model.rr <- rep(model.r, each = length(dep_4.r))
type.rr <- rep(type.r, each = length(dep_4.r))
period.rr <- rep(period.r, times = length(model.r))
dep_4.rr <- rep(dep_4.r, times = length(model.r))

input <- data.frame('model' = model.rr, 'period' = period.rr, 'type' = type.rr, 'dep_4' = dep_4.rr)

for (i in seq(1, nrow(input), 1)) {

output <- dget("split.R")(input[i, 'model'], input[i, 'type'], input[i, 'period'], input[i, 'dep_4']  )

input[i, 'c4'] <- matrix(output)[1,1]
input[i, 'c1'] <- matrix(output)[2,1]
input[i, 'c.tot'] <- matrix(output)[1,1] + matrix(output)[2,1]
input[i, 'c.min'] <- abs(matrix(output)[1,1] - matrix(output)[2,1])
input[i, 'dep_4.actual'] <- matrix(output)[3,1]
    
}

## dp1 <- input[input['period'] == 'Holocene', ]
## dp1 <- dp1[dp1['model'] == 'UVic', ]
## dp1 <- dp1[dp1['type'] == 'data', ]
## plot(dp1['dep_4.actual'], dp1['c1'], col = 'red')

# plot.new()
attach(mtcars)
par(mfrow=c(3,2))

line.col = 258


dp1 <- input[input['period'] == 'Holocene', ]
dp1 <- dp1[dp1['model'] == 'UVic', ]
dp1 <- dp1[dp1['type'] == 'data', ]
dp1 <- dp1[!duplicated(dp1['dep_4.actual']), ]
plot(unlist(dp1['dep_4.actual']), unlist(dp1['c1']), col = 'red', xlim = c(min(dep_4) - 200, max(dep_4) + 200), ylim = c(0, max(dp1['c.tot'])))
points(unlist(dp1['dep_4.actual']), unlist(dp1['c4']), col = 'blue')
points(unlist(dp1['dep_4.actual']), unlist(dp1['c.tot']))
# min.loc <- dp1[dp1['c.tot'] == min(unlist(dp1['c.tot']))]['dep_4.actual']
min.loc <- dp1['dep_4.actual'][dp1['c.tot'] == min(unlist(dp1['c.tot']))]
lines(c(min.loc, min.loc), c(0, max(dp1['c.tot'])), col = line.col)

sit1 = data.frame('Holocene', 'UVic', 'data', min.loc)
names(sit1) <- c('period', 'model', 'type', 'dep_4')


dp2 <- input[input['period'] == 'LGM', ]
dp2 <- dp2[dp2['model'] == 'UVic', ]
dp2 <- dp2[dp2['type'] == 'data', ]
dp2 <- dp2[!duplicated(dp2['dep_4.actual']), ]
plot(unlist(dp2['dep_4.actual']), unlist(dp2['c1']), col = 'red', xlim = c(min(dep_4) - 200, max(dep_4) + 200), ylim = c(0, max(dp2['c.tot'])))
points(unlist(dp2['dep_4.actual']), unlist(dp2['c4']), col = 'blue')
points(unlist(dp2['dep_4.actual']), unlist(dp2['c.tot']))
min.loc <- dp2['dep_4.actual'][dp2['c.tot'] == min(unlist(dp2['c.tot']))]
lines(c(min.loc, min.loc), c(0, max(dp2['c.tot'])), col = line.col)

sit2 = c('LGM', 'UVic', 'data', min.loc)

dp3 <- input[input['period'] == 'Holocene', ]
dp3 <- dp3[dp3['model'] == 'UVic', ]
dp3 <- dp3[dp3['type'] == 'model', ]
dp3 <- dp3[!duplicated(dp3['dep_4.actual']), ]
plot(unlist(dp3['dep_4.actual']), unlist(dp3['c1']), col = 'red', xlim = c(min(dep_4) - 200, max(dep_4) + 200), ylim = c(0, max(dp3['c.tot'])))
points(unlist(dp3['dep_4.actual']), unlist(dp3['c4']), col = 'blue')
points(unlist(dp3['dep_4.actual']), unlist(dp3['c.tot']))
min.loc <- dp3['dep_4.actual'][dp3['c.tot'] == min(unlist(dp3['c.tot']))]
lines(c(min.loc, min.loc), c(0, max(dp3['c.tot'])), col = line.col)

sit3 = c('Holocene', 'UVic', 'model', min.loc)

dp4 <- input[input['period'] == 'LGM', ]
dp4 <- dp4[dp4['model'] == 'UVic', ]
dp4 <- dp4[dp4['type'] == 'model', ]
dp4 <- dp4[!duplicated(dp4['dep_4.actual']), ]
plot(unlist(dp4['dep_4.actual']), unlist(dp4['c1']), col = 'red', xlim = c(min(dep_4) - 200, max(dep_4) + 200), ylim = c(0, max(dp4['c.tot'])))
points(unlist(dp4['dep_4.actual']), unlist(dp4['c4']), col = 'blue')
points(unlist(dp4['dep_4.actual']), unlist(dp4['c.tot']))
min.loc <- dp4['dep_4.actual'][dp4['c.tot'] == min(unlist(dp4['c.tot']))]
lines(c(min.loc, min.loc), c(0, max(dp4['c.tot'])), col = line.col)

sit4 = c('LGM', 'UVic', 'model', min.loc)

dp5 <- input[input['period'] == 'Holocene', ]
dp5 <- dp5[dp5['model'] == 'LOVECLIM', ]
dp5 <- dp5[dp5['type'] == 'model', ]
dp5 <- dp5[!duplicated(dp5['dep_4.actual']), ]
plot(unlist(dp5['dep_4.actual']), unlist(dp5['c1']), col = 'red', xlim = c(min(dep_4) - 200, max(dep_4) + 200), ylim = c(0, max(dp5['c.tot'])))
points(unlist(dp5['dep_4.actual']), unlist(dp5['c4']), col = 'blue')
points(unlist(dp5['dep_4.actual']), unlist(dp5['c.tot']))
min.loc <- dp5['dep_4.actual'][dp5['c.tot'] == min(unlist(dp5['c.tot']))]
lines(c(min.loc, min.loc), c(0, max(dp5['c.tot'])), col = line.col)

sit5 = c('Holocene', 'LOVECLIM', 'model', min.loc)

dp6 <- input[input['period'] == 'LGM', ]
dp6 <- dp6[dp6['model'] == 'LOVECLIM', ]
dp6 <- dp6[dp6['type'] == 'model', ]
dp6 <- dp6[!duplicated(dp6['dep_4.actual']), ]
plot(unlist(dp6['dep_4.actual']), unlist(dp6['c1']), col = 'red', xlim = c(min(dep_4) - 200, max(dep_4) + 200), ylim = c(0, max(dp6['c.tot'])))
points(unlist(dp6['dep_4.actual']), unlist(dp6['c4']), col = 'blue')
points(unlist(dp6['dep_4.actual']), unlist(dp6['c.tot']))
min.loc <- dp6['dep_4.actual'][dp6['c.tot'] == min(unlist(dp6['c.tot']))]
lines(c(min.loc, min.loc), c(0, max(dp6['c.tot'])), col = line.col)

sit6 = c('LGM', 'LOVECLIM', 'model', min.loc)

rbind(sit1, sit2, sit3, sit4, sit5, sit6)

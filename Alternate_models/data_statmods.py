import numpy as np
from netCDF4 import Dataset
import pandas as pd
import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
import sys
sys.path.insert(0, '/srv/ccrc/data06/z5145948/Python/python_from_R/Holocene/sampled_models/plotting_files/')
from plott import plott
from Cross_section import Cross_section
from Proxy_graph_masked import Proxy_graph
import Config
from Map_plot import Map_plot
from mpl_toolkits.axes_grid1 import make_axes_locatable
from matplotlib.animation import FuncAnimation
import time
import matplotlib.animation as animation

###############333 masked bounds                                                                                                                                                                                                                                               
lmin = -60
lmax = 70

dmin = 800
dmax = 5000

rc13std = 0.0112372

xo_min = -80
xo_max = 80
yo_min = 0
yo_max = 6000

xd_min = -80
xd_max = 80
yd_min = 0
yd_max = 6000

zo_min = -1.0
zo_max = 2.0

zd_min = -1
zd_max = 1

levels_o = np.arange(zo_min, zo_max, (zo_max-(zo_min))/50)

lrgst = max(abs(zd_min), abs(zd_max))

cm1 = plt.cm.get_cmap('gist_rainbow')
cm2 = plt.cm.get_cmap('seismic')

params = pd.read_csv('../Statistical_Model/Data/box_params.txt', sep = ' ', index_col = False)

lat_1 = params.loc[params['para'] == 'lat_1'].reset_index(drop = True).loc[0]['value']
lat_3 = params.loc[params['para'] == 'lat_3'].reset_index(drop = True).loc[0]['value']

#########################################################################

fig1 = plt.figure(1)

ax2 = plt.subplot2grid((2,3), (0,0))

ax2, var, lat_U, lon_U, tim_U, dep_U, data_form_U, mask_U = plott('UVic','/srv/ccrc/data06/z5145948/UVic/PI/','O_dic13',9900,10000,'cross',fig1, ax2,0,6000,'y',zo_min,zo_max,mask='NA')
ax2, var2, lat, lon, tim, dep, data_form, mask = plott('UVic','/srv/ccrc/data06/z5145948/UVic/PI/','O_dic',9900,10000,'cross',fig1, ax2,0,6000,'y',zo_min,zo_max,mask='NA')

plt.close()

#####################################################################

fig1 = plt.figure(1)

ax1 = plt.subplot2grid((1,2), (0,0))
ax3 = plt.subplot2grid((1,2), (0,1))

# df_temp = pd.read_csv("../Statistical_Model/Data/PL_atl_hol.csv")
# ax1.scatter(df_temp['Lat'], df_temp['Dep'], c = df_temp['d13C_hol'], vmin = zo_min, vmax = zo_max, cmap = cm1, edgecolors = 'face')
    
fh = Dataset("Output_condensed/output.nc", mode = 'r')
d13C = fh.variables['var1_1'][:]

summary = pd.read_csv('Output_condensed/_summary.txt', sep = ' ')
samples = pd.read_csv('Output_condensed/_samples.txt', sep = ' ')

samples = samples[np.isfinite(samples['Ocean_depth'])]
summary = summary[np.isfinite(summary['N_mem'])]

df_1 = summary[(summary['equation'] == 'quad') & (summary['period'] == 'Holocene' )]

i = 0

plt.show()

while i < (len(df_1)):
    print(i)
    ind = df_1['run.no'].tolist()[i] - 1
    d13CX = d13C[ind,:,:]

    try:
        ax1.scatter(samples.loc[samples['run.no'] == i, 'Lat'], samples.loc[samples['run.no'] == i, 'Ocean_depth'], c = samples.loc[samples['run.no'] == i, 'd13C'], vmin = zo_min, vmax = zo_max, cmap = cm1, edgecolors = 'face')
        output = ax3.contourf(lat_U, dep_U, d13CX, vmin = zo_min, vmax = zo_max, cmap = cm1, levels = levels_o)

    except AttributeError:
        continue

    # axt = [ax1, ax3]

    # letter = ['a', 'b', 'c']
    # for i in range(len(axt)):
    #     axt[i].text(60, 4500, letter[i], fontsize=12)
    #     axt[i].set_ylim(dmax,dmin)
    #     axt[i].set_xlim(lmin,lmax)
    #     for item in ([axt[i].xaxis.label, axt[i].yaxis.label] +
    #                  axt[i].get_xticklabels() + axt[i].get_yticklabels()):
    #         item.set_fontsize(6)

    # plt.show()
    time.sleep(2)
    i += 1
    
ani = FuncAnimation(fig1, animate, interval=1000)
#####################################################


# ax_x = []

# for i in range(len(ax_x)):
#   ax_x[i].xaxis.set_ticklabels([])

# ax_y = [ax3]

# for i in range(len(ax_y)):
#   ax_y[i].yaxis.set_ticklabels([])


# ax3.set_title('Proxy $\delta^{13}$C data and statistical reconstructions', fontsize = 10)

# ax1.set_xlabel('Latitude (deg)')

# ax1.set_ylabel('Depth (m)')
# # ax1.yaxis.set_label_position("left")


# divider2 = make_axes_locatable(ax3)
# cax2 = divider2.append_axes("right",size="5%",pad=0.05)
# cbar2 = fig1.colorbar(output,cax = cax2)


# fig1.subplots_adjust(wspace = 0, hspace = 0)



# fig1.savefig("moving.png", bbox_inches = 'tight', pad_inches = 0.0, format='png', dpi=1200)

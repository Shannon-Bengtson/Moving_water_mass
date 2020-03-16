####### The weights in this file are calculated as a combination of how close they are to the time specified, and the number of points in a core

### This version has the weights in it

import time
import pandas as pd
import numpy as np
import scipy.interpolate
from IPython import embed

#######################################

def Oliver_cores(minn, maxx):
    import pandas as pd
    import numpy as np
    folder_location = '/srv/ccrc/data06/z5145948/Moving_water_mass/Data/Core_files/'
    file_mat = ['GeoB4403_2.txt',
             'GeoB1028_5.txt',
             'GeoB2109_1.txt',
             'GeoB3801_6.txt',
             'V22_38.txt',
             'V28_56.txt',
             'V27_20.txt',
             'RC12_339.txt',
             'V32_128.txt',
             'GIK16772_1.txt',
             'MD96_2080.txt',
             'MD06_3018.txt',
             'NEAP18K.txt',
             'KNR140_37JPC.txt']


    location = ['Atlantic,','Atlantic,','Atlantic,','Atlantic,','Atlantic,','Atlantic,','Atlantic,','Indian,','Pacific,','Atlantic,','Atlantic,','Pacific,','Atlantic,','Atlantic,']

    oliver_data = []

    i = 0

    while i < len(file_mat):
        with open(folder_location + file_mat[i]) as f:
            for line in f:
                oliver_data.append(location[i] + line)
        i += 1

    df = pd.DataFrame([sub.split(",") for sub in oliver_data])

    df.columns = ['Location','Core','Lat','Lon','Dep','Core depth','age','Species','pl1','pl2','d18O benthic','d13C']

    df = df[['Core','Location','Lat','Lon','Dep','d13C','age']]

    df['d13C'] = [i.rstrip() for i in df['d13C']]

    df = df[df['age'].astype(float) > float(minn)]
    df = df[df['age'].astype(float) < float(maxx)]

    ################################# other data                                                                                                                                                                                                                                  
#     folder_location = 'Data/Core_files/'
    file_mat = ['CH69_K09.txt',
    'MD03_2664.txt',
    'MD95_2042.txt',
    'U1308.txt',
    'ODP1063.txt']

    locations = ['CH69_K09\tAtlantic\t41.75\t-47.35\t4100\t',
              'MD03_2664\tAtlantic\t57.439000\t-48.605800\t3442.0\t',
              'MD95_2042\tAtlantic\t37.799833\t-10.166500\t3146.0\t',
              'U1308\tAtlantic\t49.877760\t-24.238110\t3871.0\t',
              'ODP1063\tAtlantic\t33.683333\t-57.616667\t4584\t']

    other_data = []
    i = 0

    while i < len(file_mat):
        with open(folder_location + file_mat[i]) as f:
            for line in f:
                other_data.append(locations[i]+line)
        i += 1

    df2 = pd.DataFrame([sub.split("\t") for sub in other_data])

    df2.columns = ['Core','Location','Lat','Lon','Dep','Core Depth','age','d13C']

    df2 = df2[['Core','Location','Lat','Lon','Dep','d13C','age']]

    df2['d13C'] = [i.rstrip() for i in df2['d13C']]

    df2 = df2[df2['age'].astype(float) > float(minn)]
    df2 = df2[df2['age'].astype(float) < float(maxx)]

    results = pd.concat([df, df2])

    results = results[results['d13C'] != '']

    results['d13C'] = results['d13C'].astype(float)
    results['Lat'] = results['Lat'].astype(float)
    results['Lon'] = results['Lon'].astype(float)
    results['Dep'] = results['Dep'].astype(float)

    return(results)    
    

######################################3


years = pd.read_csv('../Moving_water_mass/Data/year_range.txt', delimiter = ' ')

minn = 110#years.loc[0, 'lower']
maxx = 140#years.loc[0, 'upper']

names = ['Core', 'Location', 'Lat', 'Lon', 'Dep']

indopac = pd.read_table("../Moving_water_mass/Data/Core_files/indopac_core_data_LS16.txt", delimiter = ',', names = names)
atl = pd.read_table("../Moving_water_mass/Data/Core_files/atl_core_data_LS16.txt", delimiter = ',', names = names)
add = pd.read_table("../Moving_water_mass/Data/Core_files/Additional_core_locations.txt", delimiter = ',', usecols = [0, 1, 2, 3, 4], names = names)

df = indopac.append(atl)
df = atl.append(add)
df = df.reset_index(drop = True)

df['d18O names'] = df['Core'] + '_ageLS16.txt'
df['d13C names'] = df['Core'] + '_d13C.txt'

i = 0

results_dict = {}

while i < df.count()[0]:

    try:
        df_d18O = pd.read_table('../Moving_water_mass/Data/Core_files/' + df.loc[i]['d18O names'], delim_whitespace = True, names = ['depth', 'age'], skip_blank_lines = True, na_values = 'NAN')
    except:
        i += 1
        continue
    try:
        df_d13C = pd.read_table('../Moving_water_mass/Data/Core_files/' + df.loc[i]['d13C names'], delim_whitespace = True, names = ['depth', 'd13C'], skip_blank_lines = True, na_values = 'NAN')
    except:
        i += 1
        continue

    df_d18O = df_d18O.dropna(subset = ['age']) 
    df_d13C = df_d13C.dropna(subset = ['d13C'])

    df_d18O = df_d18O.reset_index(drop = True)
    df_d13C = df_d13C.reset_index(drop = True)

    interp = scipy.interpolate.interp1d(df_d18O['depth'], df_d18O['age'], bounds_error = True)
    try:
        df_d13C['age'] = interp(df_d13C['depth'])
    except:
        try:
            interp2 = scipy.interpolate.interp1d(df_d18O['depth'], df_d18O['age'], bounds_error = False)
            df_d13C['age'] = interp2(df_d13C['depth'])
        except:
            i += 1
            continue

    df_d13C = df_d13C.dropna(subset = ['age'])
    df_d13C = df_d13C.reset_index(drop = True)

    df_d13C = df_d13C[df_d13C['age'] > minn]
    df_d13C = df_d13C[df_d13C['age'] < maxx]

    if len(df_d13C) > 0:
        df_results = df.drop(['d18O names', 'd13C names'], axis = 1)
        df_results = df_results.loc[df_results.index.repeat(len(df_d13C))].loc[[i]]

        df_d13C = df_d13C.drop(['depth'], axis = 1)

        df_results = df_results.reset_index(drop = True).join(df_d13C.reset_index(drop = True))
        results_dict.update({
            df_results.Core[0] : df_results.drop(['Core'], axis = 1)
        })
    
    i += 1

# ##################

df_oliver = Oliver_cores(minn,maxx)

###################3

# Combine the oliver cores with the peterson & lisieki compilation

df_results = pd.concat(results_dict).reset_index()
df_results = df_results.rename(columns = {'level_0' : 'Core'})
df_results = df_results.drop(['level_1'], axis = 1)
df_results = df_results.append(df_oliver)

##### Drop cores that are present in the exclusion list

df_core_exclusion = pd.read_csv('Data/core_exclusion_list.csv')
df_results = df_results[~df_results.index.isin(df_results.reset_index().merge(df_core_exclusion, how='right')['index'].values)]
  
####################

# get just the atlantic cores

df = df_results.reset_index(drop = True)
df['Dep'] = abs(df['Dep'])

df_atl = df[df['Location'] == 'Atlantic']
df_atl = df_atl.reset_index(drop = True)
df_atl['age'] = df_atl.age.astype(float)

#####################

# create the age wightings for all core readings that are +/- 1(thousand) years

age_selected = years.loc[0, 'lower']

ages = np.abs(df_atl.age - age_selected)
ages = [1 if x>1 else x for x in ages]
ages = [1-x for x in ages]

df_atl['age_weights'] = ages
df_atl = df_atl[df_atl['age_weights'] > 0]

#####################

# Average using the new weightings for each core, and get the new age-based weightings 

results_dict = {}
for core, group in df_atl.groupby('Core'):
    age_weighted_d13C = sum(group.d13C * group.age_weights) / (sum(group.age_weights))
    age_weights = group.sum().age_weights
    group = group.mean()
    group['d13C'] = age_weighted_d13C
    group['age_weights'] = age_weights
    results_dict.update({
        core : group
    })
df_atl = pd.DataFrame.from_dict(results_dict).T
df_atl.index.name = 'Core'
df_atl = df_atl.reset_index(drop = False)

##############################

# save the file
df_moving = df_atl.rename(columns = {'Dep' : 'Ocean_depth'})

df_moving.to_csv("Data/moving_atl.csv", index = False)

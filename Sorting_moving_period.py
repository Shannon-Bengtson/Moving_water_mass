import time
import pandas as pd
import numpy as np
import scipy.interpolate
from IPython import embed

years = pd.read_csv('Data/year_range.txt', delimiter = ' ')

minn = years.loc[0, 'lower']
maxx = years.loc[0, 'upper']

names = ['Core', 'Location', 'Lat', 'Lon', 'Dep']

indopac = pd.read_table("Data/Core_files/indopac_core_data_LS16.txt", delimiter = ',', names = names)
atl = pd.read_table("Data/Core_files/atl_core_data_LS16.txt", delimiter = ',', names = names)
add = pd.read_table("Data/Core_files/Additional_core_locations.txt", delimiter = ',', usecols = [0, 1, 2, 3, 4], names = names)

df = indopac.append(atl)
df = df.append(add)
df = df.reset_index(drop = True)

df['d18O names'] = df['Core'] + '_ageLS16.txt'
df['d13C names'] = df['Core'] + '_d13C.txt'

df['stdev'] = float('nan')
df['count'] = float('nan')
df['mean'] = float('nan')

i = 0
while i < df.count()[0]:

  try:
      df_d18O = pd.read_table('Data/Core_files/' + df.loc[i]['d18O names'], delim_whitespace = True, names = ['depth', 'age'], skip_blank_lines = True, na_values = 'NAN')
  except:
      i += 1
      continue
  try:
      df_d13C = pd.read_table('Data/Core_files/' + df.loc[i]['d13C names'], delim_whitespace = True, names = ['depth', 'd13C'], skip_blank_lines = True, na_values = 'NAN')
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

  range_test = df_d13C[df_d13C['age'] > minn]
  range_test = range_test[range_test['age'] < maxx]
  try:
    if range_test.empty:
      vari = 0
      range_test = df_d13C[df_d13C['age'] > minn - vari]
      range_test = range_test[range_test['age'] < maxx + vari]
  except:
      pass
  df_d13C = range_test

  count = df_d13C['d13C'].count()
  mean = df_d13C['d13C'].mean()
  stdev = df_d13C['d13C'].std()

  df.at[i, 'count'] = count
  df.at[i, 'mean'] = mean
  df.at[i, 'stdev'] = stdev

  i += 1

df = df.dropna(subset = ['mean'])
df = df[df['Dep'] != 0 ]
df = df.reset_index(drop = True)

##### Drop cores that are present in the exclusion list
df_core_exclusion = pd.read_csv('Data/core_exclusion_list.csv')
df = df[~df.index.isin(df.reset_index().merge(df_core_exclusion, how='right')['index'].values)]
df = df.drop(['d18O names', 'd13C names'], axis = 1)

##################

from Oliver_cores import Oliver_cores

df_oliver = Oliver_cores(minn,maxx)

df_oliver_mod = df_oliver.groupby(['Core']).mean()
df_oliver_mod = df_oliver_mod.rename(index=str, columns ={'d13C':'mean'})
count = df_oliver.groupby(['Core']).count()
stdev = df_oliver.groupby(['Core']).std()

df_oliver_mod['count'] = count['d13C']
df_oliver_mod['stdev'] = stdev['d13C']

df_oliver_mod.index.name = 'Core'
df_oliver_mod.reset_index(inplace = True)

Locs = []
i = 0
while i < len(df_oliver_mod):
 Locs.append(df_oliver[df_oliver_mod.loc[i,'Core'] == df_oliver['Core']].reset_index(drop = True).loc[0,'Location'] )
 i += 1
df_oliver_mod['Location'] = Locs

Core = []
i = 0
while i < len(df_oliver_mod):
 Core.append(df_oliver[df_oliver_mod.loc[i,'Core'] == df_oliver['Core']].reset_index(drop = True).loc[0,'Core'] )
 i += 1
df_oliver_mod['Core'] = Core
  
####################

df = pd.concat([df, df_oliver_mod])
  
df = df.reset_index(drop = True)
df['Dep'] = abs(df['Dep'])

df_atl = df[df['Location'] == 'Atlantic']
df_atl = df_atl.reset_index(drop = True)

df_pac = df[df['Location'] == 'Pacific']
df_pac = df_pac.reset_index(drop = True)

df_ind = df[df['Location'] == 'Indian']
df_ind = df_ind.reset_index(drop = True)

df_moving = df_atl.loc[:, ['Core', 'Lat', 'Lon', 'Dep', 'mean', 'count', 'stdev']].rename(columns = {'Dep' : 'Ocean_depth', 'mean' : 'd13C'})

df_moving.to_csv("Data/moving_atl.csv", index = False)

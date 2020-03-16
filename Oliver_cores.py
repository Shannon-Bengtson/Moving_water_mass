def Oliver_cores(minn, maxx):
 import pandas as pd
 import numpy as np
 folder_location = 'Data/Core_files/'
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

 df.columns = ['Location','Core','Lat','Lon','Dep','Core depth','Age','Species','pl1','pl2','d18O benthic','d13C']
 
 df = df[['Core','Location','Lat','Lon','Dep','d13C','Age']]

 df['d13C'] = [i.rstrip() for i in df['d13C']]

 df = df[df['Age'].astype(float) > float(minn)]
 df = df[df['Age'].astype(float) < float(maxx)]

 ################################# other data
 folder_location = 'Data/Core_files/'
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

 df2.columns = ['Core','Location','Lat','Lon','Dep','Core Depth','Age','d13C']
 
 df2 = df2[['Core','Location','Lat','Lon','Dep','d13C','Age']]

 df2['d13C'] = [i.rstrip() for i in df2['d13C']]

 df2 = df2[df2['Age'].astype(float) > float(minn)]
 df2 = df2[df2['Age'].astype(float) < float(maxx)]

 results = pd.concat([df, df2])

 results = results[results['d13C'] != '']

 results['d13C'] = results['d13C'].astype(float)
 results['Lat'] = results['Lat'].astype(float)
 results['Lon'] = results['Lon'].astype(float)
 results['Dep'] = results['Dep'].astype(float)
 results = results.drop(['Age'], axis = 1)

 return(results)

import numpy as np
import pandas as pd

# Load the data which has been interpolated but has not been put into distinct slices
interpolated_data_Hol = pd.read_csv('Data/interpolated_Hol_Atlantic.csv')
interpolated_data_LIG = pd.read_csv('Data/interpolated_LIG_Atlantic.csv')

# Drop nan values
interpolated_data_Hol = interpolated_data_Hol.dropna()
interpolated_data_LIG = interpolated_data_LIG.dropna()

# Get the current year range to analyse
year_range = pd.read_csv('Data/year_range.txt', delimiter=' ')
year_range_hol = pd.read_csv('Data/year_range_hol.txt', delimiter=' ')

# Restrict age range required for model
# data_slice_Hol = interpolated_data_Hol[(interpolated_data_Hol.lower >= year_range_hol.lower[0]) & (interpolated_data_Hol.lower < year_range_hol.upper[0])]
data_slice_LIG = interpolated_data_LIG[(interpolated_data_LIG.lower >= year_range.lower[0]) & (interpolated_data_LIG.lower < year_range.upper[0])]

# Drop the years column

# Save the dataframe as a csv
data_slice.to_csv('Data/moving_atl.csv',index=False)
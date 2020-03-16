import numpy as np
import pandas as pd

# Load the data which has been interpolated but has not been put into distinct slices
interpolated_data = pd.read_csv('Data/interpolated_Hol_Atlantic.csv')

# Drop nan values
interpolated_data = interpolated_data.dropna()

# Get the current year range to analyse
year_range = pd.read_csv('Data/year_range.txt', delimiter=' ')

# Restrict age range required for model
data_slice = interpolated_data[(interpolated_data.lower >= year_range.lower[0]) & (interpolated_data.lower < year_range.upper[0])]

# Drop the years column
data_slice.drop(columns='lower',inplace=True)

# Save the dataframe as a csv
data_slice.to_csv('Data/moving_atl.csv',index=False)

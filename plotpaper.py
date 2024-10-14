
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Read the CSV data
data = pd.read_csv('compare_space.csv')

# Remove leading and trailing spaces from column names
data.columns = data.columns.str.strip()

# Define the width of the bars
barWidth = 0.25

# Set position of bar on X axis
r1 = np.arange(len(data['ExecTimeGProM(s)']))
r2 = [x + barWidth for x in r1]


# Make the plot
plt.bar(r1, data['ExecTimeGProM(s)'], color='b', width=barWidth, edgecolor='grey', label='GProM')
plt.bar(r2, data['ExecTimeProvSQL(s)'], color='r', width=barWidth, edgecolor='grey', label='ProvSQL')


# Adding xticks
plt.xlabel('Query sets', fontweight='bold')
plt.ylabel('Output size(in GB)', fontweight='bold')
plt.xticks([r + barWidth for r in range(len(data['ExecTimeGProM(s)']))], data['Query sets'])

plt.legend()
plt.show()


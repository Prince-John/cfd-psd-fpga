#!/usr/bin/env python3

# Importing the required module for plotting

import matplotlib.pyplot as plt

# ^^^^^^^^^^^^^^^^^^^^^^^
# Routine to read the data
# ^^^^^^^^^^^^^^^^^^^^^^^

def read_data() :

# Create blank xdata and ydata lists

    xdata = []
    ydata = []
    
    filename = "raw_data.asc"
    fid = open(filename, mode="rt")

    index = 0
    for line in fid :
        xdata.append(index)
        ydata.append(int(line))
        index = index + 1

    return xdata, ydata
    
# ^^^^^^^^^^^^^^^^^^^^^^^
# Routine to plot our adc data
# ^^^^^^^^^^^^^^^^^^^^^^^

def plot_data(x, y) :

# plotting the points

    plt.plot(x, y)

# naming the x axis

    plt.xlabel('index')

# naming the y axis

    plt.ylabel('adc value')

# giving a title to my graph

    plt.title('ADC Plot')

# function to show the plot

    plt.show()

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#        MAIN PROGRAM
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# Will read adc data from raw_data.asc

xdata, ydata = read_data()

# Plot the data

plot_data(xdata, ydata)

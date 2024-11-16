#!/usr/bin/python3

#
# Want create plot from data coming in over serial port
# Format of data is
# C, 5, 9
# D, 1, 15
#
# C is data from capacitive sensor
# D is data from distance sensor
# Followed by time, sensor value
#

import time
import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
# Routine to read the log file and plot the data
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 

def read_data():
    global fid
    global timeOS

    firstTime = True
    cnt = 0
    for line in fid :
        line_as_list = line.split(',')
        found_cap = False ;
        found_dist = False ;
        if ((line[0] == 'D') & (len(line_as_list) == 3)) :
            found_dist = True
        else:
            if ((line[0] == 'C') & (len(line_as_list) == 3)) :
                found_cap = True
        if (found_dist | found_cap) :
            cnt = cnt + 1
            t = int(line_as_list[1])
            y = int(line_as_list[2])
            if (firstTime == True):
                timeOS = t
                x = t - timeOS
                firstTime = False
            else:
                x = t - timeOS 
            if (found_dist) :
                x0data.append(x)
                y0data.append(y)
            if (found_cap) :
                x1data.append(x)
                y1data.append(y)             
    return  cnt, x0data, y0data, x1data, y1data              
                
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#  MAIN PROGRAM
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

if __name__ == '__main__':

# Plot line width

    LW = 2

# Open a file for writing (make fid a global variable)
# Append a timestamp on to filename to make it unique

    filename = "log.txt"
    fid = open(filename, mode="rt")
    
# Create some blank lists

    x0data = []
    x1data = []
    y0data = []
    y1data = []
    cnt = 0 

# Read the data from the file

    cnt, x0data, y0data, x1data, y1data = read_data() ;

# Close the file up ... we are done with it

    fid.close()

# Set the figure size (16.8 inches wide and 7.2 inches high) 1680 x 720 is resolution

    plt.rcParams.update({'figure.figsize':(16.8,7.2), 'figure.dpi':100})

# Set up the plot parameters

    fig, axes = plt.subplots(2, 1)
    

    axes[1].plot(x1data, y1data, lw=LW, color='red')
    axes[0].plot(x0data, y0data, lw=LW, color='green') 


    max_x0 = max(x0data)
    max_x1 = max(x1data)
    if (max_x0 > max_x1) :
        run_duration = max_x0
    else :
        run_duration = max_x1

# Distance reading is between 0 and 255 mm

    axes[0].set_xlim(0, run_duration)
    axes[0].set_ylim(0, 300)

# Capacitance reading

    axes[1].set_xlim(0, run_duration)
    axes[1].set_ylim(min(y1data), max(y1data))

# Add a grid

    axes[0].grid()
    axes[1].grid()
    
# Create a title, some labels and a legend

    axes[0].set_title("Distance to Target as Function of Time")
    axes[0].set_xlabel("Time (sec)")
    axes[0].set_ylabel("Distance (mm)")

    axes[1].set_title("Capacitance as Function of Time")
    axes[1].set_xlabel("Time (sec)")
    axes[1].set_ylabel("Capacitance (fF)")

# Display the plot
# Use tight layout to help make it look pretty

    fig.tight_layout()
    plt.show()

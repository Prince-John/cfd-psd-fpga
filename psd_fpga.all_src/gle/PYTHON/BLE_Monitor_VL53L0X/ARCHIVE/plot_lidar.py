#!/usr/bin/python3

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# GLE:: 27-Jan-2024
#
# Want to create plot from data coming in over serial port.
# We will plot
#       Distance (mm)
#       Proximity Status (0 = false, 1 = True)
#       Battery Voltage (mV)
#
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

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
        found_dist = False ;
        found_prox = False ;
        found_batt = False ;
        if ((line[0] == 'D') & (len(line_as_list) == 3)) :
            found_dist = True
        else :
            if ((line[0] == 'P') & (len(line_as_list) == 3)) :
                found_prox = True
            else :
                if ((line[0] == 'B') & (len(line_as_list) == 3)) :
                    found_batt = True                
        if (found_dist | found_prox | found_batt) :
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
            if (found_prox) :
                x1data.append(x)
                y1data.append(y)
            if (found_batt) :
                x2data.append(x)
                y2data.append(y)       
    return  cnt, x0data, y0data, x1data, y1data, x2data, y2data              
                
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
    x2data = []
    y0data = []
    y1data = []
    y2data = []
    cnt = 0 

# Read the data from the file

    cnt, x0data, y0data, x1data, y1data, x2data, y2data = read_data() ;

# Close the file up ... we are done with it

    fid.close()

# Set the figure size (16.8 inches wide and 7.2 inches high) 1680 x 720 is resolution

    plt.rcParams.update({'figure.figsize':(16.8,7.2), 'figure.dpi':100})

# Set up the plot parameters

    fig, axes = plt.subplots(3, 1)
    
    axes[0].plot(x1data, y0data, lw=LW, color='red')
    axes[1].plot(x0data, y1data, lw=LW, color='green') 
    axes[2].plot(x2data, y2data, lw=LW, color='blue') 

    run_duration = max(x0data)
    start_time = min(x1data)

# Distance reading is between 0 and 255 mm

    axes[0].set_xlim(start_time, run_duration)
    axes[0].set_ylim(start_time, 300)

# Proximity status

    axes[1].set_xlim(start_time, run_duration)
    axes[1].set_ylim(0, 1.5)
    
# Battery voltage

    axes[2].set_xlim(start_time, run_duration)
    axes[2].set_ylim(2850, 3000)
    
# Add a grid

    axes[0].grid()
    axes[1].grid()
    axes[2].grid()
    
# Create a title, some labels and a legend

    axes[0].set_title("Distance to Target as Function of Time")
    axes[0].set_xlabel("Time (sec)")
    axes[0].set_ylabel("Distance (mm)")

    axes[1].set_title("Proximity Status as Function of Time")
    axes[1].set_xlabel("Time (sec)")
    axes[1].set_ylabel("Proximity Status (0 = false, 1 = true)")

    axes[2].set_title("Battery Voltage as Function of Time")
    axes[2].set_xlabel("Time (sec)")
    axes[2].set_ylabel("Battery Voltage (mV)")
    
# Display the plot
# Use tight layout to help make it look pretty

    fig.tight_layout()
    plt.show()

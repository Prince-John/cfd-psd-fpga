#!/usr/bin/python3

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# GLE:: 17-Jul-2024
#
# Want to create plot from data coming in over serial port.
# Running with the VL53L0X sensor only!
#
# We will plot
#       Distance (mm)
#       Proximity Status (0 = false, 1 = True)
#       Battery Voltage (mV)
#
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

import time
import serial
import matplotlib.pyplot as plt
import numpy as np

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
# Routine to read the log file
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 

def read_sensor_data():
    global fid

    firstTime = True
    for line in fid :
        line_as_list = line.split(',')
        t = int(line_as_list[1])
        t = t * timeScale
        y = int(line_as_list[2])
        if (firstTime == True):
            timeOS = t
            x = 0
            firstTime = False
        else:
            x = t - timeOS 
        if ((line[0] == 'D') & (len(line_as_list) == 3)) :
            xDdata.append(x)
            yDdata.append(y)
        elif ((line[0] == 'P') & (len(line_as_list) == 3)) :
            xPdata.append(x)
            yPdata.append(y)
        elif ((line[0] == 'B') & (len(line_as_list) == 3)) :
            xBdata.append(x)
            yBdata.append(y)
        if ((line[0] == 'C') & (len(line_as_list) == 3)) :
            xCdata.append(x)
            yCdata.append(y)
        elif ((line[0] == 'H') & (len(line_as_list) == 3)) :
            xHdata.append(x)
            yHdata.append(y)
        elif ((line[0] == 'V') & (len(line_as_list) == 3)) :
            xVdata.append(x)
            yVdata.append(y)     

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
# Routine to plot the data
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              

def plot_sensor_data() :

# Plot line width

    LW = 2

# Set the figure size (16.8 inches wide and 7.2 inches high) 1680 x 720 is resolution

    plt.rcParams.update({'figure.figsize':(16.8,7.2), 'figure.dpi':100})

# Set up the plot parameters
# Let's have three plots
#   lidar proximity
#   lidar distance
#   lidar battery

    fig, axes = plt.subplots(3, 1)

# Lidar proximity plot

#    axes[P].step(xPdata, yPdata, color = 'red')
    axes[P].step(xPdata, yPdata, color = 'red')

# Lidar sensor data

#    axes[D].step(xDdata, yDdata, color = 'green')
    axes[D].step(xDdata, yDdata, color = 'green')
    
# Lidar battery Voltage
                 
#    axes[B].step(xBdata, yBdata, color = 'blue')
    axes[B].step(xBdata, yBdata, 'o', color = 'blue', where = 'pre')

# Find start and end times 

    run_duration = max(xPdata)
    start_time = min(xPdata)

# Distance reading is between 0 and 255 mm

    axes[D].set_xlim(start_time, run_duration)
    axes[D].set_ylim(0, 300)
    
# Proximity status for Lidar sensor

    axes[P].set_xlim(start_time, run_duration)
    axes[P].set_ylim(0, 1.5)

# Battery voltage for Lidar sensor

    axes[B].set_xlim(start_time, run_duration)
    axes[B].set_ylim(2800, 3200)

# Add a grid to each of the plots

    axes[P].grid()
    axes[D].grid()    
    axes[B].grid()
    
# Create a title and some labels

    axes[P].set_title("Proximity Status as Function of Time")
    axes[P].set_xlabel("Time (sec)")
    axes[P].set_ylabel("Proximity Status")

    axes[D].set_title("Distance as Function of Time")
    axes[D].set_xlabel("Time (sec)")
    axes[D].set_ylabel("Dist(mm)")
    
    axes[B].set_title("Battery Voltage as Function of Time")
    axes[B].set_xlabel("Time (sec)")
    axes[B].set_ylabel("Battery Voltage (mV)")
     
# Display the plot
# Use tight layout to help make it look pretty

    fig.tight_layout()
    plt.show()
                
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#  MAIN PROGRAM
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

if __name__ == '__main__':

# Some pound defines
# Used to define order of the plots in window
# 0 is at the top while 3 is at the bottom

    P = 1
    D = 0
    B = 2

# Open a file for writing (make fid a global variable)
# Append a timestamp on to filename to make it unique

    filename = "sensor.dat"
    fid = open(filename, mode="rt")
    
# Create some blank lists
# These are global variables

    xBdata = []
    xDdata = []
    xPdata = []
    xVdata = []
    xCdata = []
    xHdata = []
    
    yBdata = []
    yDdata = []
    yPdata = []
    yVdata = []
    yCdata = []
    yHdata = []

# Timescale (Each tic is 2.5 sec)

    timeScale = 2.5
    
# Read the data from the file

    read_sensor_data()

# Close the file up ... we are done with it

    fid.close()

# Plot the data

    plot_sensor_data()


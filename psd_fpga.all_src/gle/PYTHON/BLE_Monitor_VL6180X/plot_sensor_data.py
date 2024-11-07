#!/usr/bin/env python3

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# GLE:: 8-Feb-2024
#
# Want to create plot from data coming in over serial port.
# We will plot
#       Distance (mm)
#       Proximity Status (0 = false, 1 = True)
#       Battery Voltage (mV)
#
#       Capacitance (fF)
#       Human near
#       Voltage
#
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

import time
import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
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
        y = int(line_as_list[2])
        if (firstTime == True):
            timeOS = t
            x = t - timeOS
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
# Let's have four plots
#   lidar proximity
#   cap proximity
#   lidar distance
#   cap value

    fig, axes = plt.subplots(4, 1)

# Lidar proximity plot

    axes[P].step(xPdata, yPdata, color = 'red')

# Cap sensor proximity plot
                 
    axes[H].step(xHdata, yHdata, color = 'blue')

# Lidar sensor data

    axes[D].step(xDdata, yDdata, color = 'red')

# Cap sensor data
                 
    axes[C].step(xCdata, yCdata, color = 'blue')

# Find start and end times 

    run_duration = max(xPdata)
    start_time = min(xPdata)

# Distance reading is between 0 and 255 mm

    axes[D].set_xlim(start_time, run_duration)
    axes[D].set_ylim(0, 300)

# Cap value is beween 1350 fF and 1450 fF

    axes[C].set_xlim(start_time, run_duration)
    axes[C].set_ylim(1350, 1600)
    
# Proximity status for Lidar sensor

    axes[P].set_xlim(start_time, run_duration)
    axes[P].set_ylim(0, 1.5)

# Proximity status for Cap sensor

    axes[H].set_xlim(start_time, run_duration)
    axes[H].set_ylim(0, 1.5)

# Add a grid to each of the plots

    axes[P].grid()
    axes[H].grid()
    axes[C].grid()
    axes[D].grid()    

# Create a title and some labels

    axes[P].set_title("LIDAR Proximity Status as Function of Time")
    axes[P].set_xlabel("Time (sec)")
    axes[P].set_ylabel("Proximity Status")
    
    axes[H].set_title("CAP Proximity Status as Function of Time")
    axes[H].set_xlabel("Time (sec)")
    axes[H].set_ylabel("Human Nearby") 

    axes[D].set_title("Lidar Distance as Function of Time")
    axes[D].set_xlabel("Time (sec)")
    axes[D].set_ylabel("Dist(mm)")
    
    axes[C].set_title("Capacitance as Function of Time")
    axes[C].set_xlabel("Time (sec)")
    axes[C].set_ylabel("Cap (fF)")
     
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

    D = 2
    P = 0
    C = 3
    H = 1

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
    
# Read the data from the file

    read_sensor_data()

# Close the file up ... we are done with it

    fid.close()

# Plot the data

    plot_sensor_data()


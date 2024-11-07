#!/usr/bin/python3

# This version is for the experiment where both capacitance
# and distance readings are coming from Bob's board.
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

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^S^^^^^^^^^^^^^
#
# Read from serial port and parse input looking for plot data
# We will archive raw data captured from the serial port to a file
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 

def data_gen():
    global firstTime
    global timeOS
    global logData
    global printRawData

    ser.reset_input_buffer()
    while True:
        line = ser.readline().decode('utf-8')
        if (len(line) != 0):
            if (printRawData == True) :
                print(line, end = " ")
            line_as_list = line.split(',')
            found_cap = False ;
            found_dist = False ;
            found_batt = False ;
            if ((line[0] == 'D') & (len(line_as_list) == 3)) :
                found_dist = True
            else:
                if ((line[0] == 'C') & (len(line_as_list) == 3)) :
                    found_cap = True
                else :
                    if ((line[0] == 'B') & (len(line_as_list) == 3)) : 
                        found_batt = True                	
            if (found_dist | found_cap | found_batt) :
                if(logData == True) :
                    fid.write(line)
                    fid.flush()
                t = int(line_as_list[1])
                y = int(line_as_list[2])
                if (firstTime == True):
                    timeOS = t
                    x = t - timeOS
                    firstTime = False
                else:
                    x = t - timeOS
                yield x, y, found_dist, found_cap

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
# Routine to provide the line data
# Called by animation.FuncAnimation
# It gets input from the data generator
# called data_gen().
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

def run(data):
    x, y, found_dist, found_cap = data
    if (found_dist == True) :
        x0data.append(x)
        y0data.append(y)
        line0.set_data(x0data, y0data)  
    if (found_cap == True) :
        x1data.append(x)
        y1data.append(y)
        line1.set_data(x1data, y1data)
    return line0, line1

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#  MAIN PROGRAM
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

if __name__ == '__main__':

# Global variable that tells us whether or not we should log data

    global logData
    logData = True

    global printRawData
    printRawData = True

    RUN_DURATION = 3600
    MIN_CAP = 2500
    MAX_CAP = 2700

# Set the figure size

    plt.rcParams.update({'figure.figsize':(10,6), 'figure.dpi':100})

# Set up the plot parameters

    fig, axes = plt.subplots(2, 1)  
    line0, = axes[0].plot([], [], lw=2, color='red') 
    line1, = axes[1].plot([], [], lw=2, color='green')
    
# Distance reading is between 0 and 255 mm

    axes[0].set_ylim(0, 300)

# We will take data for up t0 about 1 hour (3600 sec)

    axes[0].set_xlim(0, RUN_DURATION)
    
# Capacitance reading between 2000 fF and 4000 fF

    axes[1].set_ylim(MIN_CAP, MAX_CAP)

# We will take data for up t0 about 1 hour (3600 sec)

    axes[1].set_xlim(0, RUN_DURATION)

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

# Create some blank lists

    x0data = []
    x1data = []
    y0data = []
    y1data = []
    
# Open a file for writing (make fid a global variable)
# Append a timestamp on to filename to make it unique

    timestr = time.strftime("%Y%m%d-%H%M%S")
#    filename = "log_" + timestr + ".txt"
    filename = "log.txt"
    if (logData == True) :
        fid = open(filename, mode="wt")

# Open serial port for reading data from ble observer (make ser a global variable)

    global ser
    ser = serial.Serial()
    ser.port = '/dev/ttyACM0' 
    ser.baudrate = 9600
    ser.timeout = 0 
    
    ser.open()
    if (ser.is_open)==True :
        print("\nSerial port now open. Configuration:\n")
        print(ser, "\n") 
        ser.reset_input_buffer()
    else :
        sys.exit(1)

# Boolean variable we will need to create our time offset time

    firstTime = True

# Frames: Receives the generated data from the serial connection
# Run: Provides the line data
# interval = 100 means 100 ms 
    
    ani = animation.FuncAnimation(fig, run, frames=data_gen, blit=True, interval=10, cache_frame_data=False)

# Display the plot
# Use tight layout to help make it look pretty

    fig.tight_layout()
    plt.show()

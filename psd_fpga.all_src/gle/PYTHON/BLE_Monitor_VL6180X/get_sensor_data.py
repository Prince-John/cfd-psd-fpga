#!/usr/bin/python3

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# GLE:: 08-Feb-2024
#
# In this version we are only concerned with the both lidar and cap
# readings using the Lidar sensor. Only 2 service bytes
# 
# Code, time, value 
#
# Here are the codes:
#
# B is the battery voltage in mV for Lidar sensor board
# V is the battery voltage in mV for Cap sensor board
# D is data from Lidar sensor in mm
# C is data from Cap sensor in fF (offset from 1.2 pF)
# P is either 0 or 1 (0 = no human, 1 = human nearby) for Lidar sensor
# H is either 0 or 1 (0 = no human, 1 = human nearby) for Cap sensor
#
# We will plot distance, proximity status, and battery voltage
#
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


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

def get_data():
    global printRawData

    ser.reset_input_buffer()
    while True:
        line = ser.readline().decode('utf-8')
        if (len(line) != 0):
            if (printRawData == True) :
                print(line, end = "")
            line_as_list = line.split(',')
            if ((line[0] == 'C') & (len(line_as_list) == 3)) :
                fid.write(line)
                fid.flush()
            elif ((line[0] == 'D') & (len(line_as_list) == 3)) :
                fid.write(line)
                fid.flush()
            elif ((line[0] == 'B') & (len(line_as_list) == 3)) :
                fid.write(line)
                fid.flush()
            elif ((line[0] == 'V') & (len(line_as_list) == 3)) :
                fid.write(line)
                fid.flush()
            elif ((line[0] == 'P') & (len(line_as_list) == 3)) :
                fid.write(line)
                fid.flush()
            elif ((line[0] == 'H') & (len(line_as_list) == 3)) :
                fid.write(line)
                fid.flush()
    return


# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#  MAIN PROGRAM
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

if __name__ == '__main__':

# Global variable that tells us whether or not we should print raw data

    global printRawData
    printRawData = True

# Open a file for writing (make fid a global variable)

    filename = "sensor.dat"
    fid = open(filename, mode="wt")

# Open serial port for reading data from ble observer (make ser a global variable)

    global ser
    ser = serial.Serial()
    ser.port = '/dev/ttyUSB0'
    ser.baudrate = 9600
    ser.timeout = None 
    
    ser.open()
    if (ser.is_open)==True :
        print("\nSerial port now open. Configuration:\n")
        print(ser, "\n") 
        ser.reset_input_buffer()
    else :
        sys.exit(1)

#  Get the data from the serial port!!!!

    get_data() 

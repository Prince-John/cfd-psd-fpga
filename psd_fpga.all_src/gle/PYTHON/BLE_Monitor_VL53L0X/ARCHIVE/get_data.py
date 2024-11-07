#!/usr/bin/python3

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# GLE:: 05-Feb-2024
#
# In this version we are only concerned with the distance
# readings using the Lidar sensor. Only 2 service bytes
# 
# Code, time, value is our format where code is G, C, D, P
#
# B is the battery voltabe in mV
# C is data from capacitive sensor
# D is data from distance sensor
# P is either 0 or 1 (0 = no human, 1 = human nearby)
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
    global firstTime
    global timeOS
    global logData
    global printRawData

    ser.reset_input_buffer()
    while True:
#        line = ser.readline().strip().decode('utf-8')
        line = ser.readline().decode('utf-8')
        print(line, end="")
        if (len(line) != 0):
#            if (printRawData == True) :
#                print(line, end = "")
            line_as_list = line.split(',')
            found_cap = False ;
            found_dist = False ;
            found_batt = False ;
            found_prox = False ;
            if ((line[0] == 'D') & (len(line_as_list) == 3)) :
                found_dist = True
            else:
                if ((line[0] == 'C') & (len(line_as_list) == 3)) :
                    found_cap = True
                else :
                    if ((line[0] == 'B') & (len(line_as_list) == 3)) : 
                        found_batt = True  
                    else :      
                    	if ((line[0] == 'P') & (len(line_as_list) == 3)) : 
                            found_prox = True                                                                	
            if (found_dist | found_prox | found_batt) :
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
    return


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
    ser.port = '/dev/ttyUSB0'
#    ser.port = '/dev/ttyACM0' 
    ser.baudrate = 9600
    ser.timeout = None 
    
    ser.open()
    if (ser.is_open)==True :
        print("\nSerial port now open. Configuration:\n")
        print(ser, "\n") 
        ser.reset_input_buffer()
    else :
        sys.exit(1)

# Boolean variable we will need to create our time offset time

    firstTime = True

#  Get the data

    get_data() 

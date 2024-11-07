#!/usr/bin/env python3

#
# Program to get data from FPGA over USB port
# This version is an initial pass at the event handler
# program which must run on the host computer during
# experimtents.
#
# Author:   G. Engel
# Date:     29-Oct-2024
# Version:  0.1
#

# Need ctypes library since COBS routine is writtend in C

from ctypes import *

# Need the serial library

import serial

# Import the time library

import time

# Point to object file

so_file = "./cobs.so"

# Create my_c_functions object

COBS = CDLL(so_file)

# Open the serial port

print("Opening up serial port:  /dev/ttyUSB1", flush = True)

ser = serial.Serial("/dev/ttyUSB1")
ser.baudrate = 3000000
ser.flushInput() 
ser.flushOutput() 

# Open up file to write binary data into

print("Opening up binary file:  ./raw_data.bin", flush = True)
fileName = "./raw_data.bin"
file = open(fileName, "wb")

# Get COBS encoded event packets
# All packets end with \0

while True :
   cobs_packet = ser.read_until(expected = b'\x00', size = None)
   file.write(cobs_packet)
   print("Packet received and written to disk.", flush=True)

# Close the file we wrote binary data into

file.close()

# Close up the serial port

ser.close()








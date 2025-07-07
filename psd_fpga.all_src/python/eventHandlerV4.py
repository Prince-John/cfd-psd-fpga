#!/usr/bin/env python3

# *************************************************************
# Program to get adc data from FPGA over USB port
# In Version 2.0 we are getting data from FPGA with
# PicoBlaze running nuclear program.
# Nuclear events are being sent back.
# Entire 32-bit words.  MS byte has a data tag so we
# can print exactly what kind of data it is,
#
# Author:   G. Engel
# Date:     7-Nov-2024
# Modified on 4-Feb-2025
# Version:  2.0
#
# Date: 20-Feb-2025
# Version: 3.0
# Comment:  Handles receipt of timestamp counter
#
# Date: 21-Feb-2025
# Version: 4.0
# Comment: Will loop indefinitely writing the bin and asc files
#
# *************************************************************

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Get the libraries we need
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# Need the numpy library

import numpy as np

# Need ctypes library since COBS routine is written in C

from ctypes import *
import ctypes

# Need the serial library

import serial

# So we can get environment variable info

import os

# When 'x' keep pressed we want to leave infinite loop


# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Routine to get an event packet and write the binary data out to file
# Each COBS packet ends with $00 i.e. NUL .. just like an ascii string!
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
def get_cobs_packet(ser, fid_bin) :
   global      event_count
   cobs_packet = ser.read_until(expected = b'\x00', size = None)
   fid_bin.write(cobs_packet)
   print(f"Packet #{event_count} received and written to disk.", flush=True)
   event_count = event_count + 1

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#           MAIN PROGRAM
# ^^^^^^^^^^^^^^^^^^^^^^^^^
binFilename =  "./event_data.bin"

# Open the serial port (3 MBaud)

print("Python program starting.")
print('device env set', os.environ.get('PSD_UART_0'))
print("Press <CTL-C> to exit ...\n")
      
uart = os.environ.get('PSD_UART_0')
ser = serial.Serial('/dev/ttyUSB2')
ser.baudrate = 3000000
ser.flushInput() 
ser.flushOutput() 

# Create a event counter (global variable)

event_count = 1

# Open up the binary file we will write raw packets to

print("Opening up binary file:  %s" % binFilename)
fid_bin = open(binFilename, "wb")

# Go into loop waiting for packets
# Write packet to binary file
# Exit gracefullly if <CTL-C> pressed

try:
   while (True) :
      get_cobs_packet(ser, fid_bin)
      
except KeyboardInterrupt:
   # Close the serial connection and the binary file
   ser.close()
   fid_bin.close()
   print(f"\n\nClosing serial port and  file -> {binFilename} ...")
   print("Goodbye!\n")
   

   
      






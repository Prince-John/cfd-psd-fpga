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

# Importing the required module for plotting

#import matplotlib.pyplot as plt

# So we can get environment variable info

import os

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Routine to get an event packet and write the binary data out to file
# Each COBS packet ends with $00 i.e. NUL .. just like an ascii string!
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
def get_cobs_packet(ser, fid_bin) :
   cobs_packet = ser.read_until(expected = b'\x00', size = None)
   fid_bin.write(cobs_packet)
   print("Packet received and written to disk.", flush=True)

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Routine to read in binary data and recover the original event data
# and write it out to a file
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
def get_event_packet(fid_bin, fid_asc) :

# Create my_c_functions object

   so_file = "./cobs.so"
   COBS = CDLL(so_file)

# Open up file to read binary data
# Store into an uint8 array

   data = np.fromfile(fid_bin, dtype=np.uint8)

# Convert numPy array to c type array

   c_data = (ctypes.c_uint8 * len(data)) (*data)
   
# Create maximum sized cobs and event packet arrays

   cobs_packet = (ctypes.c_uint8 * 255)()
   event_packet = (ctypes.c_uint8 * 253)()

# Go through data and extract the COBS encoded packets
# Get length of the COBS encoded packet
# Decode the COBS encoded packet to get the event packet and its length!
# The event packet is written into the .asc file
# We are NOW sending entire 32-bit word
# transfered from picoblaze to microblaze via FIFO interface

   cobs_packet_len = 0
   for i in range(len(c_data))  :
       byte = c_data[i]
       cobs_packet[cobs_packet_len] = byte
       cobs_packet_len = cobs_packet_len + 1
       if ((byte == 0)  and (cobs_packet_len > 3)) :
           event_packet_len = COBS.cobsDecode(cobs_packet, cobs_packet_len, event_packet)
##           print("Size of event packet: %d " % (event_packet_len))       
##           for j in range(event_packet_len) :
##               print("%02x " % (event_packet[j]), end="")  
##           print("")
           for k in range(0, event_packet_len, 4) :
               byte3 = event_packet[k]
               byte2 = event_packet[k + 1]
               byte1 = event_packet[k + 2]
               byte0 = event_packet[k + 3]
               data_tag = byte3
               integ = (byte3 & 0xf0) >> 4
               chan= (byte3 & 0x0f)
               board_id = byte2
               adc_value = (byte1 << 8) | byte0
               if (adc_value >= (1 << 15)) :
                   adc_value = adc_value - (1 << 16)
               print(f"Channel = {chan:d}, Integrator = {integ:d}, Board ID= {board_id:02x}, ADC = {adc_value:5d}")
               fid_asc.write(f"{byte3:02x} {byte2:02x} {byte1:02x} {byte0:02x} \n")
               cobs_packet_len = 0
   
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#           MAIN PROGRAM
# ^^^^^^^^^^^^^^^^^^^^^^^^^
binFilename =  "./event_data.bin"
ascFilename =  "./event_data.asc"

# Open the serial port (3 MBaud)

print("Python program starting.")
print('device env set', os.environ.get('PSD_UART_0'))
uart = os.environ.get('PSD_UART_0')
ser = serial.Serial(uart)
ser.baudrate = 3000000
ser.flushInput() 
ser.flushOutput() 

event_counter = 0
# Open up file to write binary data into file
# Call -->  get_cobs_packet()
try:   
    while True: 
        print("Opening up binary file:  %s" % binFilename)
        fid_bin = open(binFilename, "wb")
        get_cobs_packet(ser, fid_bin)
        fid_bin.close()
              
        # Open up a file for storing adc data in ascii format
        # Call -->  get_event_packet()

        print("Reading event_data.bin and creating event_data.asc")
        fid_bin = open(binFilename, "rb")
        fid_asc = open(ascFilename, "w")
        get_event_packet(fid_bin, fid_asc)    
        print(f"Packet # {event_counter}")
        event_counter = event_counter + 1
        fid_bin.close()
        fid_asc.close()
          

except KeyboardInterrupt:
    print(f"Exiting! {event_counter} events")
    fid_bin.close()
    fid_asc.close()




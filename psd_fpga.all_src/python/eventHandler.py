#!/usr/bin/env python3

# *************************************************************
# Program to get adc data from FPGA over USB port
# Get
#
# Author:   G. Engel
# Date:     7-Nov-2024
# Version:  1.0
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

import matplotlib.pyplot as plt

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
# We are only sending the 2 byte ADC data not entire 32-bit word
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
           for k in range(0, event_packet_len, 2) :
               byte1 = event_packet[k]
               byte0 = event_packet[k + 1]
               adc_value = (byte1 << 8) | byte0
               if (adc_value >= (1 << 15)) :
                   adc_value = adc_value - (1 << 16)
##               print(adc_value)
               fid_asc.write('%d\n' % adc_value)
               cobs_packet_len = 0

# ^^^^^^^^^^^^^^^^^^^^^^^
# Routine to read the adc data
# ^^^^^^^^^^^^^^^^^^^^^^^
def read_adc_data(fid) :

# Reference voltage
# Create blank xdata and ydata lists

   vref = 5.0
   xdata = []
   ydata = []

# Read data from file

   index = 0
   for line in fid :
      xdata.append(index)
      yval = vref * (int(line) / (1 << 15))
      ydata.append(yval)
      index = index + 1
   return xdata, ydata
    
# ^^^^^^^^^^^^^^^^^^^^^^^
# Routine to plot our adc data
# ^^^^^^^^^^^^^^^^^^^^^^^
def plot_adc_data(x, y) :
   plt.plot(x, y, color = 'red')
   plt.ylim(-2.5, 2.5)
   plt.xlabel('TIme Index')
   plt.ylabel('Voltage (V)')
   plt.title('Plot of Event ADC Packet')
   plt.annotate('1 kHz sinewave', xy = (0, 2))
   plt.grid()
   plt.show()
   
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

# Open up file to write binary data into
# Get the COBS encoded packet

print("Opening up binary file:  %s" % binFilename)
fid_bin = open(binFilename, "wb")
get_cobs_packet(ser, fid_bin)
fid_bin.close()
ser.close()
      
# Open up a file for storing adc data in ascii format

print("Reading event_data.bin and creating event_data.asc")
fid_bin = open(binFilename, "rb")
fid_asc = open(ascFilename, "w")
get_event_packet(fid_bin, fid_asc)    
fid_bin.close()
fid_asc.close()
      
# Read and plot the adc data

print("Reading and then plotting ADC data")
fid_asc = open(ascFilename, "r")      
xdata, ydata = read_adc_data(fid_asc)
plot_adc_data(xdata, ydata)  
fid_asc.close()
                                     








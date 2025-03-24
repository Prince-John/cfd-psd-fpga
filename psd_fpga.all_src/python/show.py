#!/usr/bin/env python3

# *************************************************************
# Program to get adc data from FPGA over USB port
#
# Author:   G. Engel
# Date:     7-Nov-2024
# Last modifid on 21-Mar-2025
# Comment:  Handles receipt of timestamp counter
#           In form we expect for actual experiment
#
# Byte #
#   0       Board ID (0 - 63)
#   1-3     Timestamp counter (low)
#   4-6     Timestamp counter (high)
#   7       Channel number
#   8       ADC A (low)
#   9       ADC A (high)
#   10      ADC B (low)
#   11      ADC B (high)
#   12      ADC C (low)
#   13      ADC C (high)
#   14      ADC T (low)
#   15      ADC T (high)
#   16      Channel number
#   17      ADC A (low)
#   18      ADC A (high)
#   19      ADC B (low)
#   20      ADC B (high)
#   21      ADC C (low)
#   22      ADC C (high)
#   23      ADC T (low)
#   24      ADC T (high)
#
# and so on ...
# OR (not supported yet!)
#   
#   0       Board ID = 128
#   1-3     Timestamp counter (low)
#   4-6     Timestamp counter (high)
#   7       Lower part of TDC7200 period fraction
#   8       Upper part of TDC7200 period fraction
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
# Routine to take two bytes and convert to
# ADC value (2's complement) 
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

def bytes_to_adc(lower_byte, upper_byte, tag) :
    adc_value = (upper_byte << 8) | lower_byte
    if (adc_value >= (1 << 15)) :
        adc_value = adc_value - (1 << 16)
    print(f"......... {tag} -> {adc_value}")
    return

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Routine to process an event
# and send to print_data
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

def process_event(event_packet_len, event_packet, event_counter) :

# Print out header line

    print(f"Event #{event_counter} ")

# Extract board id and timestamp!

    tstamp = 0
    for k in range(0, 7, 1) :
        byte = event_packet[k] 
        if (k == 0) :
            print(f"... Board -> {byte}")
        if ((k > 0) and (k < 7)) :
            tstamp = tstamp + pow(2, (8 * (k - 1))) * byte
            
    event_time = 100e-9 * tstamp
    print(f"... Timestamp -> {tstamp}")
    print(f"... Event time -> {event_time:8.2f} sec")
    
# Extract the ADC data (9 bytes to a channel)
            
    for k in range(7, event_packet_len, 9) :
        addr = event_packet[k]
        print(f"...... Channel -> {addr}")
        bytes_to_adc(event_packet[k+1], event_packet[k+2], 'A')
        bytes_to_adc(event_packet[k+3], event_packet[k+4], 'B')
        bytes_to_adc(event_packet[k+5], event_packet[k+6], 'C')
        bytes_to_adc(event_packet[k+7], event_packet[k+8], 'T')                 
    return

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Routine to read in binary data and recover the original event data
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

def get_event_packets(fid_bin) :

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
    len_c_data = len(c_data)
    print(f"Length of data = {len_c_data}")

# Go through the data looking for NUL terminated event records
# For each event, print out the event data

    cobs_packet_len = 0
    event_counter = 1
    for i in range(len_c_data)  :
        byte = c_data[i]
        cobs_packet[cobs_packet_len] = byte
        cobs_packet_len = cobs_packet_len + 1
        if (byte == 0) :
            event_packet_len = COBS.cobsDecode(cobs_packet, cobs_packet_len, event_packet)
            process_event(event_packet_len, event_packet, event_counter)
            event_counter = event_counter + 1   
            cobs_packet_len = 0          
    return

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#           MAIN PROGRAM
# ^^^^^^^^^^^^^^^^^^^^^^^^^

# Name of binary file where cobs encoded data is stored

binFilename =  "./event_data.bin"

# Read binary file

print("Reading event_data.bin \n")
fid_bin = open(binFilename, "rb")

# Read the binary file and display in human
# readable form each of the event packets

get_event_packets(fid_bin)    

# Close the binary file

fid_bin.close()

# Exit the program

print("\nExiting ...\n")
exit
      






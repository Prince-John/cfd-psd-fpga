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
# Routine to print an event
# data_type
#   0 = adc data
#   1 = timestamp counter
#   2 = TDC7200 TIME1 or TIME2 register
#   3 = TDC7200 CALBRATION1 or CALIBRATION2
#
# data_subtype (for adc data)
#   0 = Integator A
#   1 = Integrator B
#   2 = Integrator C
#   3 = TVC data
#
# data_subtype (for timestamp counter)
#   0 = lower 24 bits
#   1 = upper 24 bits
#
# data_subytpe (for TDC7200 data)
#   0 = TIME1 or CALIBRATION1
#   1 = TIME2 or CALIBRATION2
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

def print_data(data_bytes) :

# Some "defines" to make code easier to read

    ADC = 0
    TIMESTAMP = 1
    TIME = 2
    CAL = 3
    A = 0
    B = 1
    C = 2
    T = 3

# Get data tag, data_type, and data_subtype

    data_tag = data_bytes[3]
    data_type = (data_tag >> 6) & 0x03
    data_subtype = (data_tag >> 4) & 0x03

# Do the appropriate thing for each data type
# ADC data (16 bits wide)

    if (data_type == ADC):
        board_id = data_bytes[2]
        if (data_subtype == 0) :
            sub_chan = 'A'
        if (data_subtype == 1) :
            sub_chan = 'B'
        if (data_subtype == 2) :
            sub_chan = 'C'
        if (data_subtype == 3) :
            sub_chan = 'T'           
        channel = data_tag & 0x0F
        adc_value = (data_bytes[1] << 8) | data_bytes[0]
        if (adc_value >= (1 << 15)) :
            adc_value = adc_value - (1 << 16)
        print(f"--> Board = {board_id}, Channel = {channel}, Sub-Channel {sub_chan}, ADC = {adc_value}")

 # Timestamp counter data (24 bits wide)

    global tstamp_low
    if (data_type == TIMESTAMP) :
        if (data_subtype == 0) :
            tstamp_low = (data_bytes[2] << 16) | (data_bytes[1] << 8) | data_bytes[0]
#            print(f"--> Timestamp counter (low) = {tstamp_low}")
        else :
            tstamp_high = (data_bytes[2] << 16) | (data_bytes[1] << 8) | data_bytes[0]
            event_time = 100e-9 * ((tstamp_high << 24) + tstamp_low)
#            print(f"--> Timestamp counter (high) = {tstamp_high}")
            print(f"--> Event time = {event_time:.2f} sec")
              
# TDC7200 TIME data (24 bits wide)

    if (data_type == TIME) :
        value = (data_bytes[2] << 16) | (data_bytes[1] << 8) | data_bytes[0]
        if (data_subtype == 0) :
            time1 = value
            print(f"--> TIME1 Value = {time1}")
        else :
            time2 = value       
            print(f"--> TIME2 Value = {time2}")
            
# TDC7200 CALIBRATION data

    if (data_type == CAL) :
        value = (data_bytes[2] << 16) | (data_bytes[1] << 8) | data_bytes[0]
        if (data_subtype == 0) :
            cal1 = value
            print(f"--> CALIBRATION1 Value = {cal1}")            
        else :
            cal2 = value           
            print(f"--> CALIBRATION2 Value = {cal2}")
            
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Routine to process an event
# Turn the 32-bit word (4 bytes) into a list
# and send to print_data
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

def process_event(event_packet_len, event_packet, event_counter) :
    print(f"Event #{event_counter} ")
    for k in range(0, event_packet_len, 4) :
        byte3 = event_packet[k]
        byte2 = event_packet[k + 1]
        byte1 = event_packet[k + 2]
        byte0 = event_packet[k + 3]
        data_bytes = [byte0, byte1, byte2, byte3]
        print_data(data_bytes)
    print("")

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
#    print(f"Length of data = {len_c_data}")

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
      






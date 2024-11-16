#!/usr/bin/env python3

#
# Program read a binary file (raw_data.bin)
# Packet in bin file are COBS encoded
#
# Program decodes the packet and write out
# the packet to an ascii file (raw_date.asc)
#

import numpy as np

# Need ctypes library since COBS routine is writtend in C

from ctypes import *
import ctypes

# Point to object file

so_file = "./cobs.so"

# Create my_c_functions object

COBS = CDLL(so_file)

# Print a welcome line to console

print("Reading raw_data.bin and creating raw_data.asc")

# Open up file to read binary data
# Store into an uint8 array

with open('./raw_data.bin', 'rb') as file_bin :
   data = np.fromfile(file_bin, dtype=np.uint8)

# Convert numPy array to c type array

   c_data = (ctypes.c_uint8 * len(data)) (*data)
   
# Open up file to write decoded packets to

filename = "./raw_data.asc"
file_asc = open(filename, "w") 

# Create maximum size cobs and event packet arrays

cobs_packet = (ctypes.c_uint8 * 255)()
event_packet = (ctypes.c_uint8 * 253)()

# Go through data and extract the COBS encoded packets
# Get length of the COBS encoded packet
# Decode the COBS encoded packet to get the event packet
# and its length!
# The event packet gets printed to the screen and the
# ADC data is written into the .asc file
# Every 4 bytes is a word ... last two bytes of the four is
# the ADC data

cobs_packet_len = 0
for i in range(len(c_data))  :
    byte = c_data[i]
    cobs_packet[cobs_packet_len] = byte
    cobs_packet_len = cobs_packet_len + 1
    if ((byte == 0)  and (cobs_packet_len > 3)) :
        event_packet_len = COBS.cobsDecode(cobs_packet, cobs_packet_len, event_packet)
        print("Size of event packet: %d " % (event_packet_len))       
        for j in range(event_packet_len) :
            print("%02x " % (event_packet[j]), end="")  
        print("")
        for k in range(0, event_packet_len, 4) :
            byte3 = event_packet[k]
            byte2 = event_packet[k + 1]
            byte1 = event_packet[k + 2]
            byte0 = event_packet[k + 3]
            adc_value = (byte1 << 8) | byte0
            if (adc_value >= (1 << 15)) :
                adc_value = adc_value - (1 << 16)
            print(adc_value)
            file_asc.write('%d\n' % adc_value)
        cobs_packet_len = 0
 
# Close the ascii file

file_asc.close() 

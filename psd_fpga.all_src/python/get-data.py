#!/usr/bin/python3

#
# Program to get data from FPGA over USB port
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

print("Python program starting.", flush = True)

ser = serial.Serial("/dev/ttyUSB1")
ser.baudrate = 3000000
ser.flushInput() 
ser.flushOutput() 

# Print out what we receive
#  Break out  when we recieve an 'X' from microblaze

while True:
   line = ser.readline().decode('utf-8')
   print(line, end="")
   if (line[0] == "X") :
      break

# Open up file to write binary data into

fileName = "./raw_data.bin"
file = open(fileName, "wb")

# Send character 'S' to get things started on microblaze

print("Sending 'S' to microblaze.", flush = True)
ser.write(b'S')

# Get COBS encoded event packets
# Exit when we get a short packet (just 4 bytes)

while True :
   start = time.time()
   cobs_packet = ser.read_until(expected = b'\x00', size = None)
   end = time.time()
   cobs_packet_len = len(cobs_packet) 
   print("Size of COBS packet: %d " % (cobs_packet_len))
   delta = 1000  *  (end - start)
   print("Elapsed time: %.2f ms " % delta)
   file.write(cobs_packet)
   data =cobs_packet[:-2]
   packet_len = COBS.cobsDecode(cobs_packet, cobs_packet_len, data)
   print("Size of event packet: %d " % (packet_len))
   print("Event packet: ", end = "")
   for val in data :
      print("%02x " % (val), end="")
   print("") 
   if (cobs_packet_len == 4) :
      break

# Close the file we wrote binary data into

file.close()

# Close up the serial port

ser.close()








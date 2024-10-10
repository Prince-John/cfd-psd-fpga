#!/usr/bin/python3

#
# Program to send a few fake commands to PSD_FGPA
#
# D is command to configure delay chip
# P is command configure psd serial registers
#
# Before we can send commands, we need to put the FPGA
# into configure mode.
#
# We do this by sending a STX and waiting for it to ACK
#
# To leave config mode, we send a ETX and wait for ACK
# 
#

# Need the serial library
import os
import serial

# Import the time library

import time

STX = b'\x02'
ETX = b'\x03'
ACK = b'\x06'

# Open the serial port

print("Python program starting.", flush = True)

ser = serial.Serial(os.environ.get('PSD_UART_0'))
ser.baudrate = 3000000
ser.timeout = 0
ser.flushInput() 
ser.flushOutput()

time.sleep(1) 

# Send STX to enter configuration mode
print("Sending STX to enter configuration mode.")
ser.write(STX)

# Wait for a ACK
print("Waiting for a ACK ...") 
while True:
   byte = ser.read(1)
   if (byte == ACK) :
      break

# Send the 'D' command

print("Sending D command to configure delay chips.", flush = True)
ser.write(b'D')

# Wait for a ACK

print("Waiting for a ACK ...", flush = True) 
while True:
   byte = ser.read(1)
   if (byte == ACK) :
      break

# Send the 'P' command

print("Sending P command to configure PSD serial shift regs.", flush = True)
ser.write(b'P')

# Wait for a ACK

print("Waiting for a ACK ...", flush = True) 
while True:
   byte = ser.read(1)
   if (byte == ACK) :
      break

# Send the 'B' command

print("Sending B command to print board ID to LCD.", flush = True)
ser.write(b'B')

# Wait for a ACK

print("Waiting for a ACK ...", flush = True) 
while True:
   byte = ser.read(1)
   if (byte == ACK) :
      break

# Send the 'C' command

print("Sending C command to write to CFD chip", flush = True)
ser.write(b'C')

# Wait for a ACK

print("Waiting for a ACK ...", flush = True) 
while True:
   byte = ser.read(1)
   if (byte == ACK) :
      break


# Send ETX to leave configuration mode

print("Sending ETX to exit configuration mode.", flush = True)
ser.write(ETX)

# Wait for a ACK

print("Waiting for a ACK ...", flush = True) 
while True:
   byte = ser.read(1)
   if (byte == ACK) :
      break
   
# Print exit message

print("SUCCESS! ... end of test.", flush = True)

# Close up the serial port

ser.close()








#!/usr/bin/python3

#
# Program to send a few fake commands to PSD_FGPA
#
# Before we can send commands, we need to put the FPGA
# into configure mode.
#
# We do this by sending a STX and waiting for it to ACK
# To leave config mode, we send a ETX and wait for ACK
# 

# Need the serial library

import serial

# Import the time library

import time
import os

TEST_ALL_MUX = False
TEST_ALL_DAC = False


# -------------------------------------------------------------------
# Wait for ACK
# -------------------------------------------------------------------

def waitACK():
    print("Waiting for a ACK or NAK...", flush=True)
    while True:
        if (ser.in_waiting):
            byte = ser.read(1)
            if (byte == ACK):
                print("Received ACK ...")
                break
            if (byte == NAK):
                print("Received NAK ...")
                break


# -------------------------------------------------------------------
# Send STX to enter configuration mode
# -------------------------------------------------------------------

def sendSTX():
    print("")
    print("Sending STX to enter configuration mode.", flush=True)
    buff = [STX, NUL]
    byte_array = bytearray(buff)
    ser.write(byte_array)
    waitACK()


# -------------------------------------------------------------------
# Send ETX to enter configuration mode
# -------------------------------------------------------------------

def sendETX():
    print("")
    print("Sending ETX to exit configuration mode.", flush=True)
    buff = [ETX, NUL]
    byte_array = bytearray(buff)
    ser.write(byte_array)
    waitACK()


# -------------------------------------------------------------------
# Send configuration command
# -------------------------------------------------------------------

def sendCMD(message, cmdStr, dry_run=False):
    print("")
    print(message)

    if dry_run:
        print("dry_run is True, nothing was sent!")
        return

    byte_array = cmdStr.encode(encoding="ascii")
    ser.write(byte_array)
    waitACK()


def sendCMD_raw(message, cmdStr, raw_bytes):
    print("")
    print(message)
    # Convert command string to byte array in ASCII encoding
    byte_array = bytearray(cmdStr.encode(encoding="ascii"))

    # If raw_bytes is a single byte, append it; if it's a sequence, extend the byte array
    if isinstance(raw_bytes, (bytes, bytearray)):
        byte_array.extend(raw_bytes)
    else:
        byte_array.append(raw_bytes)

    # Append null terminator (null byte)
    byte_array.append(0)

    # Pretty print the byte array in hexadecimal and ASCII format
    print("Byte array (hex):", ' '.join(f'{byte:02X}' for byte in byte_array))
    print("Byte array (ASCII):", ''.join(chr(byte) if 32 <= byte < 127 else '.' for byte in byte_array))

    # Send byte array over serial
    ser.write(byte_array)

    # Wait for acknowledgment
    waitACK()


def generate_dac_word(channel: int, voltage: float):
    max_voltage = 5.0
    min_voltage = 0.0

    if voltage < min_voltage or voltage > max_voltage:
        raise ValueError("DAC voltage must be between 5.0 - 0.0V")
        return

    if channel < 1 or channel > 8:
        raise ValueError("DAC channel must be between 1 - 8")
        return

    k = (int)((voltage / 5.0) * 1024)

    #print(f'k is {k}, vol/5.0 {voltage/5.0}')
    data_word = (channel << 12) | (k << 2) | 0x1  # making the dont care bits 0b01.

    return data_word


# -------------------------------------------------------------------
# *** MAIN PROGRAM ***
# -------------------------------------------------------------------

NUL = 0
STX = 2
ETX = 3

ACK = b'\x06'
NAK = b'\x15'

print("Python program starting.", flush=True)
print('device env set', os.environ.get('PSD_UART_0'))
uart = os.environ.get('PSD_UART_0')
ser = serial.Serial(uart)
# ser = serial.Serial('/dev/ttyUSB0')
ser.baudrate = 3000000
ser.timeout = 0
ser.flushInput()
ser.flushOutput()
time.sleep(1)

# Enter config mode

sendSTX()

# Send some config commands
# We have 6 delays chips ... each has three channels
# So a full configuration is 18 bytes of data!
# Six triplets (R G B)
# Make sure that yo don't try to load a value > $1F .. that's
# the largest possible delay!!!

message = "Sending config Delay Chip command"
command = "DLY:000102000102000102000102000102000102\0"
sendCMD(message, command)

message = "Sending get board id command"
command = "BID:\0"
sendCMD(message, command)

message = "Sending config CFD command"
command = "CFD:0D6F\0"
sendCMD(message, command)

message = "Sending config PSD command"
command = "PSD:000102030405000102030405\0"
sendCMD(message, command)

message = "\n\nSending config MUX commands"
print(message)
command = "MUX:1D\0"
message = f"The command string sent is: {command}"
sendCMD(message, command)

if TEST_ALL_MUX:
    for ch in range(0, 15):
        data = (ch << 1) | 1
        command = f"MUX:{data:02X}\0"
        message = f"The command string sent is: {command}"
        print(f"\n\nChannel {ch} turned on")
        sendCMD(message, command, False)
        print(f"\n\nChannel {ch} turned off")
        data = (ch << 1) & 254
        command = f"MUX:{data:02X}\0"
        message = f"The command string sent is: {command}"
        sendCMD(message, command, False)

#######################################
#
#	DAC config
#
#######################################


data = generate_dac_word(5, 2.5)

command = f"DAC:{data:04X}\0"
message = f"testing DAC command with command string: {command}, data word is : {data:016b}"
sendCMD(message, command, dry_run=False)

# Automate write to all channels and all 10 voltages for the dac
if TEST_ALL_DAC:
    for channel in range(1, 8):

        for k in range(0, 10):
            voltage = ((2 ** k) / 1024) * 5.0

            data = generate_dac_word(channel, voltage)

            command = f"DAC:{data:04X}\0"
            message = f"testing DAC command with command string: {command}, data word is : {data:016b}"
            sendCMD(message, command, dry_run=False)

# Exit from config mode

sendETX()

# That's all folks

print("")
print("SUCCESS! ... end of test.", flush=True)

# Close up the serial port

ser.close()

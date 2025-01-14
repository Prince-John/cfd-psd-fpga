#!/usr/bin/env python3

"""

lsserial.py

This script lists the serial devices connected in verbose and summarized lists.
It is tested on Python3 only.
If you prefer a single line command, there are some alternatives below.

# Prerequisites
pip install pyserial

# Create alias in ~/.bash_profile or ~/.zshrc
alias lsserial='python3 ~/lsserial.py'

# If you only need the summary, you just need to run this command in bash
python3 -m serial.tools.list_ports

# Alternate solution in pure bash for macOS
alias lsserial_b='ls -1 /dev/tty.* | grep -v -e Bluetooth -e Jabra'

# Alternate solution in pure bash for Raspberry Pi OS
alias lsserial_b='ls -1 /dev/tty* | grep tty[A-Z] | grep -v -e Bluetooth -e Jabra'

# Ubuntu & Raspberry Pi OS serial diagnostic with this command
dmesg

"""

import serial.tools.list_ports


EXCLUDED_PORTS = [
    "Bluetooth",
    "Jabra",
]


def filter_out_excluded_ports():
    """ ___ """
    ports = []
    for port in serial.tools.list_ports.comports():
        excluded_found = False
        for excluded_port in EXCLUDED_PORTS:
            if port.device.find(excluded_port) > -1:
                excluded_found = True
                break
        if excluded_found:
            continue
        ports.append(port)
    return ports


def lsserial_verbosity_1(ports):
    """ ___ """
    print("\n\n# SERIAL PORTS DETAILS")
    for counter, port in enumerate(ports):
        print("")
        print("- ID:                    %d" % (counter))
        print("  port.device:           %s" % (port.device))
        print("  port.name:             %s" % (port.name))
        print("  port.description:      %s" % (port.description))
        print("  port.hwid:             %s" % (port.hwid))
        print("  port.vid:              %s" % (port.vid))
        print("  port.pid:              %s" % (port.pid))
        print("  port.serial_number:    %s" % (port.serial_number))
        print("  port.location:         %s" % (port.location))
        print("  port.manufacturer:     %s" % (port.manufacturer))
        print("  port.product:          %s" % (port.product))
        print("  port.interface:        %s" % (port.interface))


def lsserial_verbosity_0(ports):
    """ ___ """
    print("\n\n# SERIAL PORTS SUMMARY\n")
    for counter, port in enumerate(ports):
        print("- %s. port.device: %s" % (counter, port.device))


def main():
    """ ___ """
    ports = filter_out_excluded_ports()
    if len(ports) == 0:
        print("\n\n# NO SERIAL PORT FOUND")
    else:
        lsserial_verbosity_1(ports)
        lsserial_verbosity_0(ports)


if __name__ == "__main__":
    main()

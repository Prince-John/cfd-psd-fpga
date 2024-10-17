#!/usr/bin/env tclsh
# 
# Script to switch the psd_fpga_trenz.csv between csv for chipboard and 705 carrier
# 
# Author: Prince
# Date: Oct 13th, 2024


set VERSION_TAG [exec git describe --tags]

set	timestamp	[clock format [clock seconds]]


set 705_target "xdc/master_csv_for_trenz/psd_fpga_trenz_705.csv"
set chipboard_target "xdc/master_csv_for_trenz/psd_fpga_trenz_chipboard.csv"

set linkName "xdc/psd_fpga_trenz.csv"





puts $fileId "// Automatically generated version file at $timestamp, DO NOT MODIFY!!!"
puts $fileId "#ifndef VERSION_H"
puts $fileId "#define VERSION_H"
puts $fileId "#define PROJECT_VERSION \"$VERSION_TAG\""
puts $fileId "#endif // VERSION_H"

close $fileId

puts "New version.h generated with tag $VERSION_TAG"

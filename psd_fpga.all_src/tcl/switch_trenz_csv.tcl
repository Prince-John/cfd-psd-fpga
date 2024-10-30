#!/usr/bin/env tclsh
# 
# Script to switch the psd_fpga_trenz.csv between csv for chipboard and 705 carrier
# 
# Author: Prince
# Date: Oct 13th, 2024


set VERSION_TAG [exec git describe --tags]

set	timestamp	[clock format [clock seconds]]


set xdc_dir  "xdc"
set trenz_csv_dir  "master_csv_for_trenz"

set 705_target "psd_fpga_trenz_705.csv"
set chipboard_target "psd_fpga_trenz_chipboard.csv"

set current_target_msg "CHIPBOARD"


# Default target is 705 board
set target $705_target
set target_msg "705 CARRIER"

set link_name "psd_fpga_trenz.csv"

set current_target [file readlink $xdc_dir/$link_name]


if {$current_target == "$trenz_csv_dir/$705_target"} {
	set target $chipboard_target
	set current_target_msg "705 CARRIER" 
	set target_msg "CHIPBOARD"
} 

puts "Time: $timestamp"
puts ""
puts "Trenz CSV is set to $current_target_msg ($current_target) "
#puts ""
#puts  -nonewline "Switch CSV file to $target_msg ? (y/n) <CR>  "
#flush stdout
#set 	answer		[gets stdin]
#if { $answer != "y" } {
#	puts ""
#	puts "Exiting ... "
#	return
#} 
puts ""
file delete -force "$xdc_dir/$link_name"
puts "Old symbolic link removed. Creating a new link..."
puts ""
file link -symbolic "$xdc_dir/$link_name" "$trenz_csv_dir/$target"
#puts "$xdc_dir/$trenz_csv_dir/$target"
puts "CSV file changed to $target_msg ([file readlink $xdc_dir/$link_name]) "
puts ""


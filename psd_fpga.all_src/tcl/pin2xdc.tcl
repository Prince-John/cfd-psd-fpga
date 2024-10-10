#!/usr/bin/env tclsh

# 
# Tcl script to convert csv file containing PSD FPGA pinout to xdc file
# GLE:: 10 Aug 2024
#
# Only handle pin related xdc info
# We will have another xdc file for timing constraints
#

#
# Version
# Keep this up to date so we know which build of pin2xdc.tcl was used
#

set		version		"26-Sep-2024 --> Handles Trenz reset (D9) pin"

#
# Check to see which development board we are using
#

set		fpga_board			$env(FPGA_BOARD)

# Query the environment to find out if tab or comma delimited csv file

# Not enough testing for comma version
# Force us of tab version
# GLE: 26-SEP-2024
#set		csv_delimiter		$env(CSV_DELIMITER)
set		csv_delimiter		"tab"


# Place timestamp in files!!!!!!!!!!!!!

set		timestamp			[clock format [clock seconds]]

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#	Procedure to handle some "special" FPGA pins for Digilent board
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc  cmod_a7_special_pins_sdcs {fp} {
	puts $fp ""
	puts $fp {# *********************************************************}
	puts $fp {# Handle a few special FPGA pins for CMOD-A7 board         }                    
	puts $fp {# *********************************************************}
	puts $fp ""
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Procedure to handle some "special" FPGA pins for Trenz TE705 board
# DO NOT puts Trenz reset stuff in here
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc  trenz_special_pins_sdcs {fp} {

	puts $fp	{# *********************************************************}
	puts $fp	{# Handle a few special FPGA pins for Trenz board           }                           
	puts $fp	{# *********************************************************}
	puts $fp	""

# Set drive strength on the LEDs

	puts $fp	{set_property DRIVE 12 [get_ports {led[1]}]}
	puts $fp	{set_property SLEW SLOW [get_ports {led[1]}]}
	puts $fp	{set_property DRIVE 12 [get_ports {led[0]}]}
	puts $fp	{set_property SLEW SLOW [get_ports {led[0]}]}
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#	Procedure to write out common sdc lines
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc  common_sdcs {fp} {
	puts $fp 	""
	puts $fp 	{# *********************************************************}
	puts $fp 	{# Default common settings that do not depend assembly variant}
	puts $fp 	{# **********************************************************}
	puts $fp 	""
	puts $fp 	{set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]}
	puts $fp 	{set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]}
	puts $fp 	{set_property CONFIG_VOLTAGE 3.3 [current_design]}
	puts $fp 	{set_property CFGBVS VCCO [current_design]}
	puts $fp 	{set_property CONFIG_MODE SPIx4 [current_design]}
	puts $fp 	{set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]}
	puts $fp 	{set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]}
	puts $fp 	{set_property BITSTREAM.CONFIG.M1PIN PULLNONE [current_design]}
	puts $fp 	{set_property BITSTREAM.CONFIG.M2PIN PULLNONE [current_design]}
	puts $fp 	{set_property BITSTREAM.CONFIG.M0PIN PULLNONE [current_design]}
	puts $fp 	{set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]}
	puts $fp 	{set_property BITSTREAM.CONFIG.UNUSEDPIN PULLDOWN [current_design]}
	puts $fp 	""		
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Procedure to get signals and relates info.
# The global variable "signals" is an associative array.
# A list is stored at each location in the array.
# A signal's name is used to index into the array!
#
# The list contains:
# 0 -> direction or port type so input, output, or inout
# 1 -> conn
# 2 -> jconn
# 3 -> first index
# 4 -> first pin loc
# 5 - end --> a list of (index, dir, pin, conn, jconn) for buses
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc get_signals { fp } {
	global	signals	
	global	fpw_log	
	global	csv_delimiter

# Need to treat signals and elements of a bus quite differently

	set 	signalPattern		{[a-z]{1}[a-z|0-9|_]*}
	set		busPattern			{([a-z]{1}[a-z|0-9|_]*)[\[]{1}([\d]+)[\]]{1}}
	
# Start reading the csv file

	while { [gets  $fp  line]  >=  0 } {

# Get the 5 fields

		switch $csv_delimiter {
			"tab"	{ set	fields		[regexp  -inline -all -- {\S+} $line] }
			"comma"	{ set	fields		[split	$line	","] }
			default { puts "CSV  delimiter must be either comma or tab ... aborting!" ; exit }
		}
			
		if { [llength $fields] == 5 } {

# Get the signal name and direction fields
# Ensure signal names are lowercase	
	
        	set 	field0	[lindex $fields 0]
        	set		field0	[string tolower $field0]
        	set 	field1	[lindex $fields 1]
         	switch  $field1 {
        		"Input"		{set  dir  "input"}
        		"Output"	{set  dir  "output"}
        		"BiDir"		{set  dir  "inout"}
        		default		{puts $fpw_log "Illegal port ($dir) direction in $line ... aborting" 
        					 puts  "Illegal port ($dir) direction in $line ... aborting"
        					 exit
        					}
        	} ; # end switch
        	
 # Remaining fields needed for xdc file
 
        	set 	pin		[lindex $fields 2]
        	set 	conn	[lindex $fields 3]
       	 	set		jconn	[lindex $fields 4]

# Check to see if simple signal or element of a bus

			set		isSimple	"false"
			set		isBus		"false"
	
			set  	result		[regexp $signalPattern $field0 name]
			if { $result == 1 } { 
				set		isSimple 	"true"
			}	; # end if
			set		index	"-1"
			set  	result		[regexp $busPattern $field0 bus name index]		
			if { $result == 1 } {
				set 	isBus 		"true"
				set		isSimple 	"false"
			} ; # end if
			
# Act accordingly for a "simple" signal

			if { $isSimple == "true" }	 {
				set 		signals($name)	$dir 
				lappend		signals($name)	$conn $jconn $index $pin
			} ; # end if

# A bus element requires a bit more work!!!
			
			if { $isBus == "true" }	 {			
				set		signal_names	[array names signals]
				if { $signal_names == "" } {
					set	signals($name) 	$dir	; # port type
				} else {
					set found_name 	"false"
					foreach item $signal_names {
						if {$name == $item} {
							lappend	 signals($name) $dir	
							set	found_name	"true"
						} ; # end if
					}	; # end foreach loop	
					if { $found_name == "false" } {				
						set	signals($name) 	$dir
					}
				} ; # end if-then-else
				lappend		signals($name)	$conn $jconn $index $pin																				
			} ; # end if for isBus	

# Didn't have 5 fields so ignore the line!!!
				     	
    	} else {
    		if { $line != "" } {
    			puts $fpw_log "Ignoring line ==> $line"
    			puts  "Ignoring line ==> $line"
    		}
    	}
    } ; # end while loop
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Procedure sort signal names
# to group inputs, outputs, inouts
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc sort_signal_names { } {
	global	signals
	
	set		signal_names	[array names signals]
	set		inputs 		""
	set		outputs		""
	set		inouts		""
	
	foreach  name  $signal_names {
		set	 	dir 		[lindex  $signals($name)    0]
		if { $dir == "input" } 	{ lappend  inputs	$name }
		if { $dir == "output" } { lappend  outputs	$name }
		if { $dir == "inout" } 	{ lappend  inouts	$name }	
	}	
	
	set		inputs			[lsort $inputs]
	set		outputs			[lsort $outputs]
	set		inouts			[lsort $inouts]
	set		sorted_names	[list {*}$inputs {*}$outputs {*}$inouts]	
	
	return	$sorted_names
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Procedure to write out pin assignments
# The Trenz board "reset" signal special!!!!
# Need to treat it in special way!!!
# Handle the Trenz reset pin
#	puts $fp	{set_property BOARD_PART_PIN dummy_rst [get_ports reset]}
#	puts $fp	{set_property IOSTANDARD LVCMOS18 [get_ports reset]}
#	puts $fp 	""
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc pin_assign_sdcs { fp } {
	global	signals
	global	version
	global	timestamp
	global	fpga_board

	puts $fp ""
	puts $fp {# ************************************}
	puts $fp {# Pin location constraints!!!!   }
	puts $fp  "# Timestamp:  $timestamp"	
	puts $fp  "# Version:  $version"
	puts $fp  "# FPGA development board: $fpga_board"
	puts $fp {# ************************************}
	puts $fp ""
       
# Do a fancy sort to group inputs, outputs, and inouts

	set		signal_names	[sort_signal_names]	
	
	foreach thisSignal $signal_names {
		set		name		$thisSignal
		set	 	dir 		[lindex $signals($thisSignal) 0]
		set	 	conn 		[lindex $signals($thisSignal) 1]
		set	 	jconn 		[lindex $signals($thisSignal) 2]
		set		firstIdx	[lindex $signals($thisSignal) 3]
		set	 	firstPin 	[lindex $signals($thisSignal) 4]
		
		if { $firstIdx == "-1" } {
    		puts $fp	"\n### Signal: \t$name can be found on board connector $conn"
			puts $fp	"### Signal: \t$name can be found on breakout connector $jconn"  
			set	 signal	"\[get_ports \{$name\}\]"      
			puts $fp	"\nset_property\tPACKAGE_PIN	$firstPin  	 $signal"

# If we are using the Trenz board need to treat the "reset" in a special way

			if { ($fpga_board == "trenz") && ($name == "dummy_reset") } {
				puts $fp	"set_property\tIOSTANDARD	LVCMOS18 $signal"
				puts $fp	"set_property\tPULLDOWN\ttrue\t\[get_ports \{ dummy_reset \} \]"	
			} else {			
				puts $fp	"set_property\tIOSTANDARD	LVCMOS33 $signal"	
			}	
			
		} else {
			foreach {dir conn jconn index pin} $signals($thisSignal)  {
				set	 signal	"\[get_ports \{$name\[$index\]\}\]" 
				set	 sname	"$name\[$index\]"
   				puts $fp	"\n### Signal: \t$sname can be found on board connector $conn"
				puts $fp	"### Signal: \t$sname can be found on breakout connector $jconn"    
				puts $fp	"\nset_property\tPACKAGE_PIN	$pin  	 $signal"
				puts $fp	"set_property\tIOSTANDARD	LVCMOS33 $signal"				
			} ; # end of foreach loop
		} ; # end of if-then-else
	}  ; # end of outer foreach loop
	puts $fp ""
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Procedure to write out psd_fpga_top.vh
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc write_verilog_file { fp } {
	global	signals
	global	version
	global	timestamp
	global	fpga_board

# Write out file header

	puts $fp {// *************************************************************}
	puts $fp {// Verilog module declaration for top cell      }
	puts $fp "// Timestamp:  $timestamp"	
	puts $fp "// Version:  $version"
	puts $fp  "// FPGA development board: $fpga_board"
	puts $fp {// *************************************************************}
	puts $fp ""

# Do a fancy sort to group inputs, outputs, and inouts

	set		signal_names	[sort_signal_names]	
		
# Signal declarations

	set	firstTime	"true"
	foreach thisSignal $signal_names {	
		set		name	$thisSignal
		if { $firstTime == "true" } {
			puts	-nonewline	$fp		"\t$name "
			set		firstTime	"false"
		} else {
			puts	-nonewline 	$fp		","
			puts	-nonewline	$fp		"\n\t$name "
		} ; # end if-then-else			
	} ; # end foreach loop
	
	puts $fp "\t\n) ;\n"
	puts $fp "// *** I/O and bus declarations *** \n" 
	
# Now we have to tag signals as input, output, or inout
# Also need to identify buses

	foreach thisSignal $signal_names {	
		set		name		$thisSignal
		set		type		[lindex $signals($thisSignal) 0] 		; # dir i.e. signal direction 
		set		firstIndex	[lindex $signals($thisSignal) 3]		; # first index 

		if { $firstIndex == "-1" } { ; # Simple signal
			puts	$fp			"\t$type\t$name ;"
		} else {		; 		# 	We have a bus to contend with

# Create a list of indices .. then compute min and max index values

			set	indices ""
			foreach {dir conn jconn index pin} $signals($thisSignal)  {
				lappend indices $index
			} ; # end foreach	
			set 	max [tcl::mathfunc::max {*}$indices]
			set		min [tcl::mathfunc::min {*}$indices]
			puts	$fp			"\t$dir\t\[$max:$min\] $name ;"
		} ; # end if-then-else
	} ; # end foreach outer loop
	puts	$fp		"\n"
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Procedure to dump the contents of the
# signals associative array to the screen.
# Very useful when debugging.
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc signalArrayDump { } {
	global	signals
	
	puts 	""
	puts 	"*** Associative array signal info dump ***"
	set		signal_names	[array names signals]
	set		signal_names	[lsort $signal_names]

	foreach thisSignal $signal_names {
		puts "Name is $thisSignal => $signals($thisSignal)"
	}
	puts ""
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#	MAIN program
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


# Command line arguments need to be looked at

if {$argc != 1} {
    puts "Usage:  pin2xdc  <csv filename>"
    exit
}

# We should have a log file

set		log_filename	"psd_fpga_xdc.log"
set		fpw_log			[open	$log_filename w]

puts	$fpw_log		"Timestamp: $timestamp"

# Print version

puts	"Version: $version"
puts	$fpw_log	"Version: $version"
puts	$fpw_log	"FPGA Development Board: $fpga_board"

# Filenames

set     filename     	[lindex $argv  0]
puts    "\nProcessing file: $filename"
puts	$fpw_log 	"\nProcessing file: $filename"

set		xdc_filename	"psd_fpga.xdc"
puts    "Creating file: $xdc_filename"
puts    $fpw_log	"Creating file: $xdc_filename"

set		vlog_filename	"psd_fpga_top.vh"
puts    "Creating file in verilog directory: $vlog_filename"
puts    $fpw_log	"Creating file in verilog directory: $vlog_filename"
puts 	""


# Open files
# One for reading csv and one for writing xdc
# Also one for verilog file

set     fpr_csv      [open  $filename r]
set     fpw_xdc      [open  $xdc_filename w]
set		fpw_vlog	 [open  $vlog_filename w]

# Read and extract information from csv file

get_signals  $fpr_csv 

# Following is very useful when debugging

# signalArrayDump

# Close up the csv file

close   $fpr_csv

# Write out the verilog file

write_verilog_file $fpw_vlog

# Close the verilog file

close   $fpw_vlog

# Write out the pin assignment constraints

pin_assign_sdcs  $fpw_xdc

# Write out the common sdc settings 

common_sdcs $fpw_xdc

# Write out the sdcs for special pins 
# This depends on development board

switch	$fpga_board {
	"cmod-a7" 	{ cmod_a7_special_pins_sdcs $fpw_xdc }
	"trenz"		{ trenz_special_pins_sdcs $fpw_xdc }
}

# Close up the xdc file

close   $fpw_xdc

# Quit

puts "File creation successful!!! ... Exiting ...\n"
puts $fpw_log	"File creation successful!!! ... Exiting ...\n"

# Close up the log file

close	$fpw_log
exit




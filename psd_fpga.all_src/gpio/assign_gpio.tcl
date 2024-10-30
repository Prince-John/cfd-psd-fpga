#!/usr/bin/env tclsh
# 
# GLE:: 23-SEP-2024
#
# Tcl script to convert csv file containing gpio assignments
# into 3 files
#
# Version
# Keep this up to date so we know which version of assign_gpio.tcl was used
# *********************************************
# Now automated. Just update a patch tag with git, this script should automatically find the latest global version. 


# Get the latest tag
set latest_tag [exec git describe --tags --abbrev=0]
set last_tag_date [exec git log -1 --format=%cd --date=format:%Y-%m-%d\ %H:%M:%S $latest_tag]

set		version		"$latest_tag released at\t$last_tag_date"


# Place timestamp in files!!!!!!!!!!!!!

set		timestamp		[clock format [clock seconds]]

# We should have a log file

set		log_file		"gpio.log"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Procedure to get signals and related info.
# The global variable "signals" is an associative array.
# A list is stored at each location in the array.
#
# The 6 comma delimited fields are as follows:
#
# 0		gpio number
# 1		direction --> in or out
# 2		bit number --> 0 to 31
# 3		nickaname for bit number -->  all caps else we uppercase name
# 4		verilog signal name
# 5		a one line comment of your choosing
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc get_signals { fp } {
	global	signals	
	global	fp_log

# Need to treat signals and elements of a bus quite differently

	set 	signalPattern		{[a-z]{1}[a-z|0-9|_]*}
	set		busPattern			{([a-z]{1}[a-z|0-9|_]*)[\[]{1}([\d]+)[\]]{1}}
	
# We'll use a number to index into the signals arra

	set		index		0
	
# Start reading the csv file

	while { [gets  $fp  line]  >=  0 } {
		
# Split the line up into fields

		set	fields		[split	$line	","]
		
# There must be EXACTLY 6 fields else we ABORT!
			
		set num_fields [llength $fields] 
		if { $num_fields != 6 } {
    		puts "Number of fields is $numfields; must be 6; aborting!"
    		puts $fp_log "Number of fields is $num_fields; must be 6; aborting!"
    		exit
    	} ; # end if

# Get the 6 fields
			
        set field0	[lindex $fields 0] ; # GPIO  number
        set field1	[lindex $fields 1] ; # Signal direction (in or out)
        set field2	[lindex $fields 2] ; # Bit number
        set field3	[lindex $fields 3] ; # Nickname for the bit
        set field4	[lindex $fields 4] ; # Verilog signal name
        set field5	[lindex $fields 5] ; # User comment
 			
# First line is special ... we want to ignore it

		set	ignore_line  "false"	
			
		set substring "GPIO"
		if { [string first $substring $field0] != -1 } { 
			set ignore_line	"true"
		}

# If the line was blank in spreadsheet file then the csv file will contain 5 commas

		if { $line == ",,,,," } { set ignore_line "true" }
		
# If field 3 (nickname) and field 4 (singal) contains a ? then ignore the line

		if { ($field3 == "?") && ($field4 == "?") } { set ingore_line "true" }		

# Some lines we just ignore and notify user
				
		if { ($ignore_line == "true")  } {
			puts "IGNORING LINE --> $line"
			puts  $fp_log "IGNORING LINE --> $line"	
			continue	
		}
					
# GPIO number field

		set	gpio_num  $field0
  		if { ($gpio_num < 0) || ($gpio_num > 3) } { 
			puts "GPIO number out of range in $line ... aborting"
       		puts $fp_log "GPIO number out of range in $line ... aborting"
       		exit 
       	} 		
      	
# Bit number field
			
		set	bit	$field2
		if { $bit < 0  || $bit > 31 } {
			puts $fplog "ERROR in $line"
			puts $fplog "Bit numbers must be in range \[0 to 31\] ... aborting"
			puts "ERROR in $line"
			puts "Bit numbers must be in range \[0 to 31\] ... aborting"	
			exit
		} ; # end if		

# Bit nickname field

		set	nickname $field3

# Verilog signal name

		set	signal	$field4
		
# The "> "is a special case where user wants us to use the signal name to create nickname

		if { $nickname == ">" } {
			if { ($signal == "") || ($signal == "?") } {
				puts $fplog "ERROR in $line"
				puts $fplog "If nickname is > the signal field must contain a name .. aborting"
				puts "ERROR in $line"
				puts $fplog "If nickname is > the signal field must contain a name .. aborting"	
				exit
			}
			
# Check to see if simple signal or element of a bus

			set		isSimple	"false"
			set		isBus		"false"
	
			set  	result		[regexp $signalPattern $signal name]
			if { $result == 1 } { 
				set		isSimple 	"true"
			}	; # end if
			set  	result		[regexp $busPattern $signal bus name idx]		
			if { $result == 1 } {
				set 	isBus 		"true"
				set		isSimple 	"false"
			} ; 
			if { ($isBus == "false") && ($isSimple == "false") } {
				puts $fplog "ERROR in $line ... aborting"
				puts "ERROR in $line ... aborting"	
				exit
			}
			if { $isSimple == "true" } {
				set nickname [string toupper $signal] 
			} else {
				set name		[string toupper $name] 
				set nickname	"${name}_$idx"
			} ; # end if-the-else
		} else {
			set nickname [string toupper $nickname]
		}
			
# Comment field

		set	comment	$field5

# Direction field

		 set   use_nickname   "true"
		 if  { $nickname == "?" } {
		  	set use_nickname "false"
		 }
		 
         switch  $field1 {
        	"in"	{	set dir "INPUT"
        				if { $use_nickname } {
        					set gpio_name  "gpio${gpio_num}_in\[$nickname\]"
        				} else {
        					set gpio_name  "gpio${gpio_num}_in\[$bit\]"
        				}
        			}
        	"out"	{	set dir "OUTPUT"	
        				if { $use_nickname } {
        					set gpio_name  "gpio${gpio_num}_out\[$nickname\]"
        				} else {
        					set gpio_name  "gpio${gpio_num}_out\[$bit\]"
        				}       				  				
        			}
        	default	{	puts $fp_log "Illegal port ($dir) direction in $line ... aborting" 
        			 	puts  "Illegal port ($dir) direction in $line ... aborting"
        				exit
        			}
         } ; # end switch
			
# Use the index as the key into hash
# Save list of field values 
# {gpio_num dir bit nickname signal comment gpio)name}
# 
		set	signals($index)  [list $gpio_num $dir $bit $nickname $signal $comment $gpio_name]			      		
		incr index
		
    } ; # end while loop
}; # end proc

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# This routine will write out the verilog header file
# which contains the localparams definitions for the 
# gpio bits.
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc write_verilog_local_params { fp } {
	global	signals
	global	version
	global	timestamp
	global  fp_log
	
	puts $fp ""
	puts $fp {// *************************************************}
	puts $fp {// localparams definitions for the gpio bits   }
	puts $fp {// The file is AUTO-GENERATED, DO NOT MODIFY!!!   }
	puts $fp  "// Timestamp:           $timestamp"	
	puts $fp  "// TCL Code Version:    $version"
	puts $fp {// *************************************************}
	puts $fp ""
		
# Get the gpio_names
	
	set		indices		[array names signals]
	set		indices		[lsort -integer $indices]
	
# {gpio_num dir bit nickname signal comment gpio_name}

# Write out the localparams

	foreach index $indices {	
		set		myList		$signals($index)
		set		gpio_num	[lindex $myList 0]
		set		dir			[lindex $myList 1]
		set		bit			[lindex $myList 2]
		set		nickname	[lindex $myList 3]
		set		signal		[lindex $myList 4]
		set		comment		[lindex $myList 5]
		set		gpio_name	[lindex $myList 6]
		
		if { $nickname != "?" } {
			set	 str	"// GPIO $dir Port $gpio_num -> $comment"
			puts $fp	$str
			puts $fp 	"localparam\t$nickname = $bit ;"	
			puts $fp 	""
		} ; # end if
	} ; # end foreach loop
	puts $fp ""


	return
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# This routine will write out the verilog localparams
# as defines for the c-code.  HW and SW must agree.
# This will make sure they do.
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc write_c_code_local_params { fp } {
	global	signals
	global	version
	global	timestamp
	global	fp_log

	puts $fp ""
	puts $fp {// *******************************************************}
	puts $fp {// This header files creates defines for the gpio bits   }
	puts $fp {// The file is AUTO-GENERATED, DO NOT MODIFY!!!   }
	puts $fp  "// Timestamp:  			$timestamp"	
	puts $fp  "// TCL Code Version:    	$version"
	puts $fp {// *******************************************************}
	puts $fp ""

# Get the gpio_names
	
	set		indices		[array names signals]
	set		indices		[lsort -integer $indices]
	
# {gpio_num dir bit nickname signal comment gpio_name}

# Write out the #define lines

	foreach index $indices {	
		set		myList		$signals($index)
		set		gpio_num	[lindex $myList 0]
		set		dir			[lindex $myList 1]
		set		bit			[lindex $myList 2]
		set		nickname	[lindex $myList 3]
		set		signal		[lindex $myList 4]
		set		comment		[lindex $myList 5]
		set		gpio_name	[lindex $myList 6]
		
		if { $nickname != "?" } {
			set	 str	"// GPIO $dir Port $gpio_num -> $comment"
			puts $fp	$str
			puts $fp 	"#define\t$nickname\t$bit"
			puts $fp 	""	
		} ; # end if
	} ; # end foreach loop
	puts $fp ""

  	return	
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# This routine will write out the verilog assign statements
# for the port bits and how they are connected to verilog
# signals at the highest level (or "top" level).
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc write_verilog_assigns { fp } {
	global	signals
	global	version
	global	timestamp
	global  fp_log

	puts $fp ""
	puts $fp {// ********************************************************}
	puts $fp {// This header file creates wires and assigns for gpio bits}
	puts $fp {// The file is AUTO-GENERATED, DO NOT MODIFY!!!   }
	puts $fp "// Timestamp:  		  $timestamp"	
	puts $fp "// TCL Code Version:    $version"
	puts $fp {// ********************************************************}
	puts $fp ""
	
	set		indices		[array names signals]
	set		indices		[lsort -integer $indices]
	
# {gpio_num dir bit nickname signal comment gpio_name}

# Write out the verilog assign statements

	foreach index $indices {	
		set		myList		$signals($index)
		set		gpio_num	[lindex $myList 0]
		set		dir			[lindex $myList 1]
		set		bit			[lindex $myList 2]
		set		nickname	[lindex $myList 3]
		set		signal		[lindex $myList 4]
		set		comment		[lindex $myList 5]
		set		gpio_name	[lindex $myList 6]
		
		if { ($signal != "?") && ($dir == "INPUT") } {
			puts $fp "\tassign\t$gpio_name = $signal ;"	
		} ; # end if
		
		if { ($signal != "?") && ($dir == "OUTPUT") } {
			puts $fp "\tassign\t$signal = $gpio_name ;"	
		} ; # end if
		
	} ; # end foreach loop
	puts $fp ""
	return	
}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#	MAIN program
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

# Command line arguments need to be looked at

puts ""
if {$argc != 1} {
    puts "Usage:  assign_gpio.tcl  <csv filename>"
    exit
}

# Open the log file

set		fp_log			[open $log_file w]

# Print version and timestamp

puts	"Version: $version"
puts	$fp_log	"Version: $version"
puts	$fp_log	"Timestamp: $timestamp"


# Filenames

set     filename     	[lindex $argv  0]
puts    "\nProcessing file --> $filename"
puts	$fp_log 	"\nProcessing file -->  $filename"

set		parms_vh		"gpio_defines.vh"
set		parms_h			"gpio_defines.h"
set		assigns_vh		"gpio_assigns.vh"

# File identifiers

puts    "Creating file --> $parms_vh"
puts    $fp_log		"Creating file -->  $parms_vh"

puts    "Creating file --> $parms_h"
puts    $fp_log		"Creating file -->  $parms_h"

puts    "Creating file --> $assigns_vh"
puts    $fp_log		"Creating file -->  $assigns_vh"
puts ""

# Open files
# One for reading csv and one for writing xdc
# Also one for verilog file

set     fpr_csv      		[open  $filename r]
set     fpw_parms_vh      	[open  $parms_vh w]
set     fpw_parms_h      	[open  $parms_h w]
set     fpw_assigns_vh      [open  $assigns_vh w]

# Read and extract information from csv file

get_signals  $fpr_csv 

# Useful for debugging this script
#parray signals

# Write out the local params verilog file

write_verilog_local_params $fpw_parms_vh 

# Write out the local params c header file

write_c_code_local_params  $fpw_parms_h 

# Write out the assigns

write_verilog_assigns $fpw_assigns_vh

# Close up the files

close   $fpr_csv
close   $fpw_parms_vh
close   $fpw_parms_h
close   $fpw_assigns_vh
close	$fp_log

# That's all folks!

puts ""

exit




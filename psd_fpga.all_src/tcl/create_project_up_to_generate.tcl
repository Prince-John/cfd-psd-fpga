#
# Script which is run on vivado startup when creating a new project
#

set	num_jobs  6

# Query environment 

set	fpga_board		$env(FPGA_BOARD)
set	project			$env(VIVADO_PROJECT)
set	project_root	$env(VIVADO_PROJECTS)

proc pause {{message "IMPORTANT:  Hit Enter to continue ==> "}} {
    puts -nonewline $message
    flush stdout
    gets stdin
}

# Set part based on board

switch	$fpga_board {
	 "trenz" { 
	 		set  fpga_part		"xc7a35tcsg324-2"
	 		set	 ublaze_file	"psd_ublaze_trenz.tcl"
	  }
	 "cmod-a7" 	{  
	 		set  fpga_part 		"xc7a35tcpg236-1" 
	 		set	 ublaze_file	"psd_ublaze_cmod-a7.tcl"	 		
	 } 
	 default {
		puts "Unknown FPGA develpment board: $fpga_board)"
		puts "Aborting!"
		exit
	}
}

# Create new project

create_project $project . -force -part $fpga_part

# Start the gui

start_gui

# Build the microblaze

puts ""
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts "Creating microblaze using $ublaze_file"
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts ""

source ./tcl/$ublaze_file

# Attach our design files

puts ""
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts "Attaching our design files (verilog and xdc)  "
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts ""

source ./tcl/attach_design_files.tcl

# Generate target

update_compile_order -fileset sources_1


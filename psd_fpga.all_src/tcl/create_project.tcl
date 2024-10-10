#
# Script which is run on vivado startup when creating a new project
#

set	num_jobs  $env(FPGA_NUM_JOBS)

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

# Generate target

update_compile_order -fileset sources_1

puts ""
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts "Generating output products for the microblaze"
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts ""

generate_target all [get_files ./psd_fpga.srcs/sources_1/bd/psd_ublaze/psd_ublaze.bd]

# Attach our design files

puts ""
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts "Attaching our design files (verilog and xdc)  "
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts ""

source ./tcl/attach_design_files.tcl

# Implement the design through the bitstream step

puts ""
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts "Implementing the design through the bitstream step  "
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts ""

launch_runs impl_1 -to_step write_bitstream -jobs 	$num_jobs

puts ""
puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts "WAIT FOR THE BITSTREAM TO BE COMPLETED!!!!"
puts "Then in tcl console type: source ./tcl/xsa.tcl"
puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"




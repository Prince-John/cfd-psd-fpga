#!/usr/bin/env tclsh

# We will store our variables in an assoiciative array
# We can then access them easily from within a procedure 

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Project related stuff
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set vars(PROJECT_ROOT) 		$env(VIVADO_PROJECTS)
set varsMsg(PROJECT_ROOT) 	"Root directory for projects:\t$vars(PROJECT_ROOT)"	

set	vars(PROJECT)			$env(VIVADO_PROJECT)
set	varsMsg(PROJECT)		"Project:\t\t\t$vars(PROJECT)"

set	vars(PROJECT_DIR)		"$vars(PROJECT_ROOT)/$vars(PROJECT)"
set	varsMsg(PROJECT_DIR)	"Project directory:\t\t$vars(PROJECT_DIR)"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# You choose which create file you want
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set	vars(CREATE_PROJECT_FILE)		"create_project.tcl"
#set	vars(CREATE_PROJECT_FILE)			"create_project_up_to_implementation.tcl"
set		varsMsg(CREATE_PROJECT_FILE)	"Create project file:\t\t$vars(CREATE_PROJECT_FILE)"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Create a list of soft links which you would like to install
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set	vars(LINK_LIST)  { \
"./$project.all_src/vitis_project" "./$vars(PROJECT).sw"
"./$project.all_src/vitis_project" "./workspace"
"./$project.all_src" "./source"
"./$project.all_src/gpio" "./gpio"
"./$project.all_src/picoblaze" "./$vars(PROJECT).asm" 
"./$project.all_src/picoblaze" "./asm"	
"./$project.all_src/tcl" "./tcl" 
"./$project.all_src/doc" "./doc" 
"./$project.all_src/python/config" "./config" 
"./$project.all_src/python" "./python"	
"./$project.all_src/verilog" "./verilog"
"./$project.all_src/microblaze" "./c-code"
"./$project.all_src/xdc" "./xdc"
"./$project.all_src/csh"  "./csh" }

set varsMsg(LINK_LIST)	"List of links:\t\t\tSee tcl code!"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# FPGA board
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# See which board we are using

set	vars(FPGA_BOARD)	$env(FPGA_BOARD)
set	varsMsg(FPGA_BOARD)	"FPGA development board:\t\t$vars(FPGA_BOARD)"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# FPGA part number
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set		fpga_board  	$vars(FPGA_BOARD)
switch	$fpga_board {
	 "trenz"	{ set	 vars(FPGA_PART)	"xc7a35tcsg324-2" }
	 "cmod-a7" 	{ set  vars(FPGA_PART) 		"xc7a35tcpg236-1" } 
	default {
		puts "Unknown FPGA develpment board: $fpga_board)"
		puts "Aborting!"
		exit
	}
}
set	 varsMsg(FPGA_PART)		"FPGA part number:\t\t$vars(FPGA_PART)"		

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# CSV file for xdc pin location contraints
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

switch	$fpga_board {
	"trenz"	{
		set		vars(CSV_FILE)						"psd_fpga_trenz.csv"
		set		vars(CONSTRAINT_GENERATOR) 			"pin2xdc.tcl"		
	 }
	 "cmod-a7" {
		set 	vars(CSV_FILE) 						"psd_fpga_cmod-a7.csv"
		set		vars(CONSTRAINT_GENERATOR) 			"pin2xdc.tcl"
	} 
	default {
		puts "Unknown csv file or constraint generator ... aborting\n"	
		exit
	}
}
	set varsMsg(CSV_FILE)				"Pin location csv file:\t\t$vars(CSV_FILE)"
	set	varsMsg(CONSTRAINT_GENERATOR)	"XDC constraint generator:\t$vars(CONSTRAINT_GENERATOR)"	

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Name of assembly file for picoblaze
# along with the ROM template file we wish to use.
#
# ROM_form takes the bram and assigns memory locations for the 8bit pico for Artix FPGA.
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set	vars(PSM_FILE)			"pico_program.psm"
set	varsMsg(PSM_FILE)		"Picoblaze psm file:\t\t$vars(PSM_FILE)"

set	vars(TEMPLATE_FILE)		"ROM_form.v"
set	varsMsg(TEMPLATE_FILE)	"Picoblaze ROM template file:\t$vars(TEMPLATE_FILE)"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Name of the gpio csv file
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set vars(GPIO_CSV_FILE)		"gpio.csv"
set varsMsg(GPIO_CSV_FILE)	"GPIO ssign csv file:\t\t$vars(GPIO_CSV_FILE)"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Point to software workspace
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set	vars(WORKSPACE)			"./$vars(PROJECT).sw"
set	varsMsg(WORKSPACE)		"Vitis workspace:\t\t$vars(WORKSPACE)"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Startup file for vivado
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set	vars(VIVADO_STARTUP_FILE)		"vivado_startup.tcl"
set	varsMsg(VIVADO_STARTUP_FILE)	"Vivado startup file:\t\t$vars(VIVADO_STARTUP_FILE)"	

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Preferred editor
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set	vars(EDITOR)	$env(EDITOR)
set	varsMsg(EDITOR)	"Editor to use:\t\t\t$vars(EDITOR)"	

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Hostname
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# See which machine we are running on

set vars(HOSTNAME) 		[exec hostname]
set varsMsg(HOSTNAME) 	"Running on host:\t\t$vars(HOSTNAME)"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Name of tcl build script for ublaze
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

switch	$fpga_board {
	"trenz"	{
		set		vars(UBLAZE_TCL_SCRIPT)		"psd_ublaze_trenz.tcl"	
	 }
	 "cmod-a7" {
		set		vars(UBLAZE_TCL_SCRIPT)		"psd_ublaze_cmod-a7.tcl"	
	} 
	default {
		puts "Unknown fpga board ($fpga_board) ... aborting\n"	
		exit
	}
}

set	varsMsg(UBLAZE_TCL_SCRIPT)	"Microblaze tcl build script:\t$vars(UBLAZE_TCL_SCRIPT)"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Csv file delimiter
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set	vars(CSV_DELIMITER)		$env(CSV_DELIMITER)
set varsMsg(CSV_DELIMITER)	"CSV file delimiter:\t\t$vars(CSV_DELIMITER)"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Number of jobs value for Vivado
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set	vars(FPGA_NUM_JOBS)		$env(FPGA_NUM_JOBS)
set varsMsg(FPGA_NUM_JOBS)	"Vivado number of jobs:\t\t$vars(FPGA_NUM_JOBS)"


# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#	Useful subroutines
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Sleep for N seconds
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc sleep N {
    after [expr {int($N * 1000)}]
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Displays the README file which decribes the developemt flow
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc readme_proc {} {
	global	vars

	set		project_dir	$vars(PROJECT_DIR)
	set		editor		$vars(EDITOR)
	
	switch $editor {
		"gedit"	 { set	cmd	 [list exec gedit $project_dir/README] }
		"vim"	 { set  cmd [list exec vim <@ stdin >@ stdout 2>@ stderr $project_dir/README] }
		default  { puts "Don't recognize $editor ... aborting" ; return }
	}
	{*}$cmd		
	return
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Print usage message
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 
proc print_usage_msg {} {
	global  cmdListHelp
	
	puts	""
	puts	"Usage: run < command >"
	puts	""
	puts	"List of commands:"
	foreach	item $cmdListHelp {
		puts $item
	}
	puts   	""
	puts	"Make sure following environment variables are set!!!"
	puts	"--> VIVADO_PROJECT (project name)"
	puts	"--> VIVADO_PROJECTS (root directory for projects)"
	puts	"--> FPGA_BOARD (cmod-a7 or trenz)"
	puts	"--> EDITOR (gedit or vim)"
#	puts	"--> CSV_DELIMITER (tab or comma)"
	puts	"--> FPGA_NUM_JOBS (vivado number of jobs)"
	puts	"--> FHOME (project directory)"
	puts	""
	return
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Prints out information about the project
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc info_proc {} {
	global	vars 
	global	varsMsg
	
	set		varNames	[array names vars]
	puts ""
	foreach name $varNames {
		puts	$varsMsg($name)
	}
	puts ""
	return
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Handles creating the xdc for pin locations
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc xdc_proc {} {
	global	vars
	
	set		project			$vars(PROJECT)
	set		xdc_dir			$vars(PROJECT_DIR)/$project.all_src/xdc

# Move to the xdc directory
	
	cd 		$xdc_dir
	
# Display the csv file we chose to drive the contraint generator

	set		editor		$vars(EDITOR)
	switch $editor {
		"gedit"	 { set	cmd	[list exec gedit $vars(CSV_FILE)] }
		"vim"	 { set  cmd [list exec vim <@ stdin >@ stdout 2>@ stderr $vars(CSV_FILE)] }
		default  { puts "Don't recognize $editor ... aborting" ; return }
	}
	{*}$cmd	
	
# Run the contraint generator

	set		cmd		[list exec $vars(CONSTRAINT_GENERATOR) $vars(CSV_FILE)]	
	{*}$cmd	

# Sleep for a second to avoid giving the user "whiplash"

	sleep {1}

# Display the log file created by the contraint generator

	set 	xdc_log_file	"$xdc_dir/${project}_xdc.log"	
	switch $editor {
		"gedit"	 { set	cmd	[list exec gedit $xdc_log_file] }
		"vim"	 { set  cmd [list exec vim <@ stdin >@ stdout 2>@ stderr $xdc_log_file] }
		default  { puts "Don't recognize $editor ... aborting" ; return }
	}
	{*}$cmd	
	return		
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Helps with GPIO assignments
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc gpio_proc {} {

	global	vars
	
	set		project			$vars(PROJECT)
	set		gpio_dir		$vars(PROJECT_DIR)/$project.all_src/gpio

# Move to the gpio directory
	
	cd 		$gpio_dir
	
# Display the csv file we chose to drive the contraint generator

	set		editor		$vars(EDITOR)
	switch $editor {
		"gedit"	 { set	cmd	[list exec gedit $vars(GPIO_CSV_FILE)] }
		"vim"	 { set  cmd [list exec vim <@ stdin >@ stdout 2>@ stderr $vars(GOIO_CSV_FILE)] }
		default  { puts "Don't recognize $editor ... aborting" ; return }
	}
	{*}$cmd	
	
# Run the contraint generator

	set		gpio_assign_tcl		"assign_gpio.tcl"
	set		cmd		[list exec $gpio_assign_tcl $vars(GPIO_CSV_FILE)]	
	{*}$cmd	

# Sleep for a second to avoid giving the user "whiplash"

	sleep {1}

# Display the log file created by the contraint generator

	set 	gpio_log_file	"gpio.log"	
	switch $editor {
		"gedit"	 { set	cmd	[list exec gedit $gpio_log_file] }
		"vim"	 { set  cmd [list exec vim <@ stdin >@ stdout 2>@ stderr $gpio_log_file] }
		default  { puts "Don't recognize $editor ... aborting" ; return }
	}
	{*}$cmd	
	return

}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Handles creating links
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc links_proc {} {

	global 	vars
	
	cd 		$vars(PROJECT_DIR)
	
	set		project		$vars(PROJECT)
	set		linkList 	$vars(LINK_LIST)

# Create a bunch of links in a very easy way!!!!
	
	puts	""
	foreach {path linkName} $linkList {
		set 	cmd 	"file link -symbolic $linkName $path"
		if { [catch $cmd] } {
			puts "Failed to make link (probably because it exists!): $linkName -> $path"
		} else {
			puts "Making link: $linkName -> $path"
		}
	}
	puts 	""
	return
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Handles deleting links
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc rm_links_proc { } {
	global  vars ;

# Get list of links

	set	linkList	$vars(LINK_LIST)
	
# Delete the links

	foreach {path linkName} $linkList {
		set 	cmd 	"file delete -force $linkName"
		if { [catch $cmd] } {
			puts "Failed to remove the link: $linkName"
		} else {
			puts "Removing link: $linkName"
		}
	}
	return
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Procedure to "clean" the directory
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc clean_proc {} {
	global vars
	
	set	project		$vars(PROJECT)
	set	project_dir	$vars(PROJECT_DIR)
	
# Move to the project directory
	
	cd 	$project_dir

# Remove the links in the project directory
	rm_links_proc
	
# Delete vivado generated directories (but NOT the .all_src directory)

	set delList [glob -nocomplain  $project*.*]	

# Take the .all_src directory out of the list!!!!

	set delList [lsearch -all -inline -not -exact $delList "$project.all_src"]

	foreach dirName $delList {
		set 	cmd 	"file delete -force $dirName"
		if { [catch $cmd] } {
			puts "Failed to remove the directory: $dirName"
		} else {
			puts "Removing: $dirName"
		}
	}

# Some more deletions
	
	set		files1 		[glob -nocomplain  vivad*]
	set		files2		[glob -nocomplain  *.log]
	set		files3		[glob -nocomplain  *.xsa]
	set		files4		[glob -nocomplain  .Xil]
	set		files5		[glob -nocomplain  create_project.tcl]
	set		files		[list {*}$files1 {*}$files2 {*}$files3 {*}$files4 {*}$files5]	
	lappend files "logs"

	set		files_len	[llength 	$files]		
	if { $files_len != 0 } {
		foreach item $files {
			puts	"Removing $item"
			file 	delete -force $item
		}
	}
	return
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Create a new project
# Invoke vivado with a tcl script that
# sets the fpga part number
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc new_proc {} {
	global	vars
	
# Clean 
	
	puts  -nonewline "This action will clean current project. Is this oK? (y/n) <CR> "
	flush stdout
	set 	answer		[gets stdin]
	if { $answer != "y" } {
		puts ""
		puts "Exiting ... "
		return
	} 
	puts ""

# Call the procedure that does the cleaning
	
	clean_proc
	
# Make sure the links are in place

	puts 	"Creating our symbolic links"
	
	links_proc
	
# Need to make sure xdc file is up to date

	puts	"Execute the xdc procedure"
	
	sleep {1}

# Call the routine that handles the contraints
	
	xdc_proc

	puts -nonewline	"Ready to launch vivado. Is this oK? (y/n) <CR> "
	flush stdout
	set 	answer		[gets stdin]
	
	if { $answer != "y" } {
		puts ""
		puts "Exiting ... "
		exit
	}	
	
	set		project_dir 			$vars(PROJECT_DIR)
	cd 		$project_dir
	
	set		create_project_file		$vars(CREATE_PROJECT_FILE)
	set		tcl_dir					"$project_dir/tcl"
	
	set		cmd		[list exec vivado -mode batch -source $tcl_dir/$create_project_file]	
	{*}$cmd
	return
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Invoke picoblaze assembler
# Must activate opbasm-venv beforehand
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc asm_proc {} {
	global	vars
	
	set		project			$vars(PROJECT)
	set		project_dir		$vars(PROJECT_DIR)
	set		asm_dir			$project_dir/$project.asm

# Move to the asm directory

	cd 		"$vars(PROJECT_DIR)/$vars(PROJECT).asm"
	
# Open the psm file with the editor
	
	set		editor		$vars(EDITOR)
	switch $editor {
		"gedit"	 { set	cmd	 [list exec gedit $vars(PSM_FILE)] }
		"vim"	 { set  cmd [list exec vim <@ stdin >@ stdout 2>@ stderr $vars(PSM_FILE)] }
		default  { puts "Don't recognize $editor ... aborting" ; return }
	}
	{*}$cmd		
	
# Sleep for a second to avoid giving the user "whiplash"

	sleep {1}
		
# Assemble the file

	set		cmd		[list exec opbasm --pb6 --m4 --color-log --template ./templates/$vars(TEMPLATE_FILE) --input $vars(PSM_FILE)]	
	if { [catch $cmd result] } {
		puts ""
		puts "Assembly of $vars(PSM_FILE) failed !!!"
		puts ""
		puts "$result"
		puts ""
	} else {
		puts ""
		puts "Assembly of $vars(PSM_FILE) successful!!!\n"
		puts ""
	}
	return
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Invoke vivado with the current project name
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc vivado_proc {} {
	global vars
	
	set		project_dir		$vars(PROJECT_DIR)
	set		project			$vars(PROJECT)
	set		startup_file	$vars(VIVADO_STARTUP_FILE)
	set		tcl_dir			$project_dir/tcl
	
	cd 		$project_dir
		
	set cmd		[list exec vivado -source $tcl_dir/$startup_file $project.xpr]
	{*}$cmd	
}
	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Invoke classic vitis
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc vitis_proc {} {
	global vars
	global env
	
#	set result  [exec /usr/local/bin/fix-vitis]
#	puts $result
	
	sleep {1}
	
# Now start classic vitis

	set		project_dir		$vars(PROJECT_DIR)	
	set		workspace		$vars(WORKSPACE)
	
	cd 	$project_dir
	set	cmd	  	[list exec vitis --classic --workspace $workspace]
	{*}$cmd	
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Recreates the vitis workspace 
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc new_ws_proc {} {
	global vars
	
	puts ""
	puts "Type 'new_ws.csh' from the shell!"
	puts "Why? It was much easier to do this with c shell script!"
	puts ""
	return	
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Launches vivado in batch mode and creates xsa file
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

proc xsa_proc {} {
	global vars
	
	set		project_dir		$vars(PROJECT_DIR)
	set		project			$vars(PROJECT)
	set		startup_file	$vars(VIVADO_STARTUP_FILE)
	set		tcl_dir			$project_dir/tcl
	
	cd 		$project_dir
		
	puts	"Creating xsa file ... please be patient!!!"
	sleep {3}
	
	set cmd		[list exec vivado -mode batch -source $tcl_dir/xsa.tcl $project.xpr]
	if { [catch $cmd result] } {
		puts
		puts "ERROR!!!!!!!!!!!!!"
		puts $result
		puts ""
	} else {
		puts $result
	}
	return	
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Main program
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# List of all of the commands we understand

set	cmdList		{"vivado" "vitis" "asm" "new" "new_ws" "rm_links" "links" "clean" "xdc" "gpio" "xsa" "readme" "info" }

set	cmdListHelp	 \
{"\tvivado		--> Launches vivado and opens the project"
 "\tvitis		--> Launches classic vitis and opens the workspace"
 "\tasm 		--> Runs picoblaze opbasm with project psm file\n\t\t\t    User must activate opbasm-venv"
 "\tnew    		--> Creates new project with project's fpga part"
 "\tnew_ws		--> Recreates the vitis workspace"
 "\trm_links	--> Removes links"
 "\tlinks  		--> Creates a series of helpful symbolic links"
 "\tclean  		--> Cleans the project directory"
 "\txdc    		--> Runs xdc contraint generator on xdc csv file"
 "\tgpio    	--> Runs gpio generator on gpio csv file"
 "\txsa    		--> Runs vivado in batch mode and creates xsa file"
 "\treadme 		--> Displays README file which decribes the flow"
 "\tinfo   		--> Displays all of the project related settings" } 

# Make sure we have a single argument

if {$argc != 1} { 
	print_usage_msg
	exit
}

# Get command line arguments

set	argument [lindex $argv 0]

# Call appropriate subroutine based on the command line argument

set result 	"false"
foreach cmd $cmdList {
	if { $argument == $cmd } {
#		puts "Command is $cmd"
		${cmd}_proc
		set result "true"
	}
}

puts "Run script finished successfully"

# If none of the arguments match anything we know, then print message

if { $result == "false" } { print_usage_msg  }

# That's it ... leave

exit

	


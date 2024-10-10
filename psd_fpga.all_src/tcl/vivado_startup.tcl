#
# Gets executed when you launch Vivado
#

proc suppress_warnings {} {

# set_msg_config -suppress  -severity {INFO}

	set myList 	{"{Vivado 12-7989}" \
				"{Common 17-349}" \
				"{Board 49-26}"	 }
	
	foreach item $myList {
		set		cmd 	"set_msg_config -suppress -id $item"
#		puts $cmd
		{*}$cmd
	}

}

set 	project	 		$env(VIVADO_PROJECT)
set		project_root	$env(VIVADO_PROJECTS)

puts	"Your project is $project"

# Suppress warnings

puts	"Suppress some warnings"

suppress_warnings 

# Source the attach_design_files script

source ./tcl/attach_design_files.tcl

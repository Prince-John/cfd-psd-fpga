#
# Tcl script to export the xsa file
#

# Root for the vivado projects 

set		vivado_projects	$env(VIVADO_PROJECTS)

# Project name

set		project			$env(VIVADO_PROJECT)

# Project directory

set		project_dir			"$vivado_projects/$project"

write_hw_platform -fixed -include_bit -force -file $project_dir/${project}_top.xsa

exit

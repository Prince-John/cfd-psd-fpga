#
# Tcl script to build the project in Vivado
#

set		project				$env(VIVADO_PROJECT)
set		proj_dir			$env(VIVADO_PROJECTS)
set		fpga_board			$env(FPGA_BOARD)
set		ublaze				"psd_ublaze"
set		pico_program		"pico_program"

# Create a wrapper for the microblaze

puts "Creating $ublaze wrapper"

make_wrapper -files [get_files $proj_dir/$project/$project.srcs/sources_1/bd/$ublaze/$ublaze.bd] -top

# Don't forget to add the ublaze wrapper

puts "Attaching $ublaze wrapper"

add_files -quiet -norecurse $proj_dir/$project/$project.gen/sources_1/bd/$ublaze/hdl/${ublaze}_wrapper.v

# Add verilog source code

puts "Attaching verilog source code"
set	vlog_path	"$proj_dir/$project/$project.all_src/verilog"
set	vlog_files	[glob -dir $vlog_path  *]
foreach file $vlog_files {
	puts "Adding --> $file"
	add_files  -quiet -norecurse $file
}

# And don't forget to add the ROM for picoblaze

puts "Attaching $pico_program ROM"

add_files -quiet -norecurse $proj_dir/$project/$project.all_src/picoblaze/$pico_program.v

update_compile_order -fileset sources_1

# Need some contraint files

puts "Attaching pin contraint file $project.xdc"

add_files -quiet -fileset constrs_1 -norecurse $proj_dir/$project/$project.all_src/xdc/$project.xdc

puts "Attaching timing contraint file ${project}_timing.xdc"

add_files -quiet -fileset constrs_1 -norecurse $proj_dir/$project/$project.all_src/xdc/${project}_timing.xdc



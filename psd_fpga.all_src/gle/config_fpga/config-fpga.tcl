#
# xsct tcl file to program fpga
#

set		root		~/bin/config_fpga/files/
set 	bit_file	$root/psd_fpga_top.bit
set		xsa_file	$root/psd_fpga_top.xsa	
set 	elf_file	$root/psd_fpga_app.elf	

set		jtag_cable	{jtag_cable_name =~ "Digilent Cmod A7 - 35T 210328BB17EDA" && level==0 && jtag_device_ctx=="jsn-Cmod A7 - 35T-210328BB17EDA-0362d093-0"}
set		url			"tcp:127.0.0.1:3121"
set		targets		{name =~ "*microblaze*#0" && bscan=="USER2" }	

connect -url $url
targets -set -filter $jtag_cable
fpga -file $bit_file
targets -set -nocase -filter $targets
loadhw -hw $xsa_file -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter $targets
rst -system
after 3000
targets -set -nocase -filter $targets
dow $elf_file
targets -set -nocase -filter $targets
con

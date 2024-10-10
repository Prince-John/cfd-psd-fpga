# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct /home/gle/VIVADO_FPGA/Cmod-A7-Projects/psd_fpga/psd_fpga.all_src/microblaze/psd_fpga_platform/platform.tcl
# 
# OR launch xsct and run below command.
# source /home/gle/VIVADO_FPGA/Cmod-A7-Projects/psd_fpga/psd_fpga.all_src/microblaze/psd_fpga_platform/platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.
#platform create -name {psd_fpga_platform} -hw {./psd_fpga_top.xsa} -proc {microblaze_0} -os {standalone} -out {./psd_fpga.all_src/vitis_project}

#
# Set the workspace
#

# We should be in the vit_project directory (i.e. workspace) when 
# xsct is launched and this script is used by xsct

puts "Setting the workspace to vitis_project"

setws ./

# The xsa file is up 2 levels in the hierarchy!!!!

puts "Creating the psd_fpga platform"

platform create -name {psd_fpga_platform} -hw {../../psd_fpga_top.xsa} -proc {microblaze_0} -os {standalone}
platform write
platform generate -domains 
platform active {psd_fpga_platform}

# 
# Create the psd_fpga_app
#

puts "Creating the psd_fpga_app"

#app create -name psd_fpga_app -lang C -template {Hello World} 

app create -name psd_fpga_app -lang C


#
# This is a tcl scipt which is to be executed with xcst
# It is used to update the hw i.e. the platform
# with the current xsa file. Builds the platform
# It also cleans and builds the psd_fpga_app
#

puts "Setting the workspace to vitis_project"

setws ./

puts "Making psd_fpga_platform active ..."

platform active {psd_fpga_platform}

# The xsa file is up 2 levels in the hierarchy!!!!
# Update it

puts "Updatin psd_fpga_platform with current xsa file ..."

platform config -updatehw {../../psd_fpga_top.xsa}

puts "Cleaning psd_fpga_platform ..."

platform clean

puts "Building psd_fpga_platform"

platform generate -domains 

#platform create -name {psd_fpga_platform} -hw {../../psd_fpga_top.xsa} -proc {microblaze_0} -os {standalone}
#platform write
#platform generate -domains 
#platform active {psd_fpga_platform}

#
# Build the psd_fpga_app
#

puts "Building psd_fpga_app ..."

app build -name psd_fpga_app


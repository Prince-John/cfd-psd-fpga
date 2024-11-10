#
# Script to copy fpga config files to local directory in ~/bin
# After files are in place then call xsct to configure the fpga
#

set		fhome = $FHOME
set 	bit_file = $FHOME/workspace/psd_fpga_app/_ide/bitstream/psd_fpga_top.bit
set		xsa_file = $FHOME/workspace/psd_fpga_platform/export/psd_fpga_platform/hw/psd_fpga_top.xsa	
set 	elf_file = $FHOME/workspace/psd_fpga_app/Debug/psd_fpga_app.elf	

# Copy the fpga bit file

echo ""
echo "Fetching fpga bit file"
gsync $bit_file ~/bin/config_fpga/files/

# Copy the fpga xsa file

echo ""
echo "Fetching fpga xsa file"
gsync $xsa_file ~/bin/config_fpga/files/

# Copy the elf file 

echo ""
echo "Fetching fpga elf file"
gsync $elf_file ~/bin/config_fpga/files/

echo "Launching xsct ..."
xsct ~/bin/config_fpga/config-fpga.tcl

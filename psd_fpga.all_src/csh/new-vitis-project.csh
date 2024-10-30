#!/usr/bin/env	tcsh

#
# Shell script to create a new vitis project
# or fix a broken existing project
#

echo ""
echo "Creating new vitis psd_fpga project"

#
# Moving to project directory
#

echo "Moving to project directory"
cd $FHOME 
pwd

#
# Remove existing vitis workspace
#

if (-d ./psd_fpga.all_src/vitis_project) then
	echo "Deleting vitis workspace"
	rm -rf ./psd_fpga.all_src/vitis_project
endif

#
# Creating the workspace
#

echo "Creating vitis workspace"
mkdir ./psd_fpga.all_src/vitis_project

#
# Moving to workspace directory
#

if (-d $FHOME/workspace) then
	echo "Deleting vitis workspace link"
	rm $FHOME/workspace
	
ls -s $FHOME/psd_fpga.all_src/vitis_project $FHOME/workspace

echo "Moving to vitis workspace directory"
cd 	$FHOME/workspace
pwd

#
# Launch xsct tool and run tcl script
# tcl directory is up one level in hierarchy
#

echo "Launching xsct ..."
xsct ../tcl/make_vitis_project.tcl

# 
# We need to remove the src directory
# and replace it with a link to our
# actual source code
#

echo "Removing the psd_fpga_app/src dir"

rm -rf ./psd_fpga_app/src

echo "Adding a tcl link in workspace"

ln -s ../../tcl ./tcl

echo "Linking to microblaze directory where c code resides."

ln -s ../../microblaze ./psd_fpga_app/src

echo ""
echo "-----------------------------------------------------"
echo "You can launch classic vitis with 'run vitis'"
echo "In vitis do the following:"
echo "--> Minimize (upper right corner) splash screen"
echo "--> Goto Project tab at top and select Build All"
echo "--> Do what you normally do in Vitis ... "
echo "-----------------------------------------------------"
echo ""


#
# This is an example README file
# 

Author: 	gle
Date:		18-Sep-2024
Version:	26-Sep-2024
Current version: `v0.0.0`  # The `run` script will update this line automatically


*****************************************************************

Here is a description of links:

- c-code		-->	C source code for MicroBlaze
- verilog		-->	Verilog source code
- python		-->	Python code for UART communication
- tcl			-->	All of the various Tcl scripts
- doc			-->	Documentation, for example, data sheets
- config		--> Links to python config program
- asm			-->	Assembly language code for the PicoBlaze
- xdc			-->	XDC file creation
- gpio		-->	Creation of GPIO bit assignments
- workspace 	-->	Vitis project

******************************************************************

gpio directory description

Here is a description of how to use assign "nicknames" for the
various bits in our GPIO registers.

gpio0_in[31:0], gpio1_in[31:0], gpio2_in[31:0], gpio3_in[31:0]
gpio0_out[31:0], gpio1_out[31:0], gpio2_out[31:0],gpio3_out[31:0]

Note: The custom logic block ONLY has access to GPIO ports 0 and 1!!!
Ports 0 and 1 should be used for signals that have to be manipluated
by both the MicroBlaze and the custom block

Signals used only by MicroBlaze as part of the configuration process
belong in Ports 2 and 3.

In the gpio.ods (excel file), the '>' says use the signal field to
to auto-generate the "nickname".  The '?' means no assignment.
There must be EXACTLY 6 fields, else the line is ignored!!!!

Signal names should be ALL LOWER CASE!
Nicknames should be ALL UPPER CASE!

For example, I have a verilog signal callled 'example' and I want the
signal to be connected to gpio0_in[24] then when the > is used my
scripts will produce

local_param  EXAMPLE = 24 ;
assign  gpio0_in[24] = example ;

For the uBlaze C code, I create

#define  EXAMPLE  24


You don't have to assign a signal. If you do, then a wire and
an assign statement is generated for the verilog code but
the localparam statements is always created.

Hence, do the following to create gpio assignments

->	Goto gpio directory and edit the excel sheet assign_gpio.ods

->	Create assign_gpio.csv (MUST BE COMMA DELIMITED)

->	Issue the command: assign_gpio.tcl

	This will produce the following files:
		gpio_defines.vh -> Contains localparam definitions
		gpio_defines.h 	-> Same info as .vh file but for C code #defines
		gpio_assigns.vh	-> Verilog wire assign lines
		
******************************************************************	
	
You can run the Python config program just by typing 

config

from the $FHOME directory

To test the delay chip stuff ... trigger off of DELAY_CLK
and then also look at the enables ... 


******************************************************************

Date: Oct 10
Author: Prince

## Semantic Versioning. 

I have now implemented version control and semantic versioning for tracking stable builds of this project. 

Only the `psd_fpga.all_src` folder is tracked with some exclusions put in for vitis metadata and build files. Every time this project is pulled to a new machine the `run` script must be executed from a `tcsh` shell to generate the complete project files. 

### Verison Numbers: 

Semantic versioning uses the format MAJOR.MINOR.PATCH:

- MAJOR: Increment for incompatible API changes, would require a project rebuild. - Changes to FPGA chipboard - will result in breaking the configration commands.
- MINOR: Increment for new features that are backward-compatible, require the xsa to be updated in vitis. - changes to the microblaze design or configuration
- PATCH: Increment for backward-compatible bug fixes, no hardware changes just firmware bugfixes. - changes to firmware - microblaze C code - provided it does not require a change of verilog code. 

The `git tag` command is used to tag every version on the master branch which we want to increment into new release versions. 
 
UNDER construction still, at some point all generated scripts will pull last version tag and current datetime and include it into the logs.




	
	
	
	
	
	
			

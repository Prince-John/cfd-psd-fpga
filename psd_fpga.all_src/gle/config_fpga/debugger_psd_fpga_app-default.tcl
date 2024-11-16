# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: /home/gle/VIVADO_FPGA/Cmod-A7-Projects/cfd-psd-fpga/psd_fpga.all_src/vitis_project/psd_fpga_app_system/_ide/scripts/debugger_psd_fpga_app-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source /home/gle/VIVADO_FPGA/Cmod-A7-Projects/cfd-psd-fpga/psd_fpga.all_src/vitis_project/psd_fpga_app_system/_ide/scripts/debugger_psd_fpga_app-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Cmod A7 - 35T 210328BB17EDA" && level==0 && jtag_device_ctx=="jsn-Cmod A7 - 35T-210328BB17EDA-0362d093-0"}
fpga -file /home/gle/VIVADO_FPGA/Cmod-A7-Projects/cfd-psd-fpga/psd_fpga.all_src/vitis_project/psd_fpga_app/_ide/bitstream/psd_fpga_top.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw /home/gle/VIVADO_FPGA/Cmod-A7-Projects/cfd-psd-fpga/psd_fpga.all_src/vitis_project/psd_fpga_platform/export/psd_fpga_platform/hw/psd_fpga_top.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow /home/gle/VIVADO_FPGA/Cmod-A7-Projects/cfd-psd-fpga/psd_fpga.all_src/vitis_project/psd_fpga_app/Debug/psd_fpga_app.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con

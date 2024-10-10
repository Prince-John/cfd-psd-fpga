# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: /home/prince/Vivado_projects/Trenz-Projects/psd_fpga_gle_2_oct_2024/psd_fpga.all_src/vitis_project/psd_fpga_app_system/_ide/scripts/debugger_psd_fpga_app-default_6.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source /home/prince/Vivado_projects/Trenz-Projects/psd_fpga_gle_2_oct_2024/psd_fpga.all_src/vitis_project/psd_fpga_app_system/_ide/scripts/debugger_psd_fpga_app-default_6.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "JTAG-ONB4 2516330067A9A" && level==0 && jtag_device_ctx=="jsn-JTAG-ONB4-2516330067A9A-0362d093-0"}
fpga -file /home/prince/Vivado_projects/Trenz-Projects/psd_fpga_gle_2_oct_2024/psd_fpga.all_src/vitis_project/psd_fpga_app/_ide/bitstream/psd_fpga_top.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw /home/prince/Vivado_projects/Trenz-Projects/psd_fpga_gle_2_oct_2024/psd_fpga.all_src/vitis_project/psd_fpga_platform/export/psd_fpga_platform/hw/psd_fpga_top.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow /home/prince/Vivado_projects/Trenz-Projects/psd_fpga_gle_2_oct_2024/psd_fpga.all_src/vitis_project/psd_fpga_app/Debug/psd_fpga_app.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con

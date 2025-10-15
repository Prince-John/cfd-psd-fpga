#
# Timing constraints for psd_fpga
#







set_property DRIVE 12 [get_ports intx_out]
set_property PULLTYPE PULLDOWN [get_ports intx_out]



create_waiver -type METHODOLOGY -id {TIMING-17} -user "prince" -desc "adc_parallel_to_serial_reg" -objects [get_pins { u1/adc_interface_0/adc_0_reg_a_reg[0]/C }] -timestamp "Tue Oct 14 19:40:11 GMT 2025"

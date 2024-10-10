#
# Timing constraints for psd_fpga
#

# Clocks


# create_clock -add -name sys_clk_pin -period 83.33 -waveform {0 41.66} [get_ports {sys_clk}];

#create_generated_clock -name {u1/proc0/P1_out_reg[7]_0[0]} -source [get_pins u0/psd_ublaze_i/clk_wiz_1/inst/mmcm_adv_inst/CLKOUT0] -divide_by 4 [get_pins {u1/proc0/P1_out_reg[0]/Q}]
#create_clock -period 40.000 -name {VIRTUAL_u1/proc0/P1_out_reg[7]_0[0]} -waveform {0.000 20.000}

## Input delays

#set_input_delay -clock [get_clocks sys_clk] -min -add_delay 2.000 [get_ports {board_id[*]}]
#set_input_delay -clock [get_clocks sys_clk] -max -add_delay 4.000 [get_ports {board_id[*]}]
#set_input_delay -clock [get_clocks sys_clk] -min -add_delay 2.000 [get_ports {btn[*]}]
#set_input_delay -clock [get_clocks sys_clk] -max -add_delay 4.000 [get_ports {btn[*]}]
#set_input_delay -clock [get_clocks {VIRTUAL_u1/proc0/P1_out_reg[7]_0[0]}] -clock_fall -min -add_delay 2.000 [get_ports adc_0_sdo_a]
#set_input_delay -clock [get_clocks {VIRTUAL_u1/proc0/P1_out_reg[7]_0[0]}] -clock_fall -max -add_delay 4.000 [get_ports adc_0_sdo_a]
#set_input_delay -clock [get_clocks sys_clk] -min -add_delay 2.000 [get_ports scl]
#set_input_delay -clock [get_clocks sys_clk] -max -add_delay 4.000 [get_ports scl]
#set_input_delay -clock [get_clocks sys_clk] -min -add_delay 2.000 [get_ports sda]
#set_input_delay -clock [get_clocks sys_clk] -max -add_delay 4.000 [get_ports sda]
#set_input_delay -clock [get_clocks sys_clk] -min -add_delay 2.000 [get_ports uart_rx]
#set_input_delay -clock [get_clocks sys_clk] -max -add_delay 4.000 [get_ports uart_rx]

## Output delays

#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports {dly_sen[*]}]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports {dly_sen[*]}]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports {led[*]}]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports {led[*]}]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports adc_0_conv]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports adc_0_conv]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports adc_0_sclk]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports adc_0_sclk]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports dly_sclk]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports dly_sclk]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports dly_sin]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports dly_sin]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports led0_b]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports led0_b]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports led0_g]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports led0_g]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports led0_r]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports led0_r]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports psd_sclk]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports psd_sclk]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports psd_sin]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports psd_sin]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports scl]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports scl]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports sda]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports sda]
#set_output_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports uart_tx]
#set_output_delay -clock [get_clocks sys_clk] -max -add_delay 3.000 [get_ports uart_tx]

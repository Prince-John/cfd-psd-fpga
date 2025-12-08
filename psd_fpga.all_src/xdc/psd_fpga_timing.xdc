#
# Timing constraints for psd_fpga
#
# set_property DRIVE 12 [get_ports intx_out]
# set_property PULLTYPE PULLDOWN [get_ports intx_out]

# Virtual clock for set_input_delay and set_output_delay commans


# Setup min and max delays to some small values
# since not sure if it would like 0


# Master clock for register bit that generates the tdc_clk


# The actual tdc_clk pin (divided down clock)
# This clock is used to communicate with tdc72000


# tdc clock divide down number


# Master clock for register bit that generates the adc0_clk


# The actual adc0_clk pin (divided down clock)


# adc0 clock divide down number


# Master clock for register bit that generates the adc1_clk


# The actual adc1_clk pin (divided down clock)


# adc1 clock divide down number


# Create the tdc_register clock

create_generated_clock -name tdc_clk -source [get_pins {u1/proc0/P4_out_reg[5]/C}] -divide_by 10 [get_pins {u1/proc0/P4_out_reg[5]/Q}]

# Create a 10 MHz timestamp clock and apply it to the tstamp_clk pin

create_clock -period 100.000 -name tstamp_clk -waveform {0.000 50.000} [get_ports tstamp_clk]

# Create the adc0 resgister clock

create_generated_clock -name adc0_clk -source [get_pins {u1/proc0/P1_out_reg[0]/C}] -divide_by 10 [get_pins {u1/proc0/P1_out_reg[0]/Q}]

# Create the adc1 resgister clock

create_generated_clock -name adc1_clk -source [get_pins {u1/proc0/P1_out_reg[1]/C}] -divide_by 10 [get_pins {u1/proc0/P1_out_reg[1]/Q}]

# We need to tell tool about unrelated clocks
# We only have two clock domains: sys_clk and tstamp_clk
# If we use the internal 10 MHz clock for the tstamp_clk then
# only one domain actually

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks sys_clk] -group [get_clocks -include_generated_clocks tstamp_clk]
#
# Create 100 MHz virtual clock .. Used by the our set_input_delay and set_output_delay statements
# It's way you set up delay contraints for things without a clock reference ... in this
# case for things we consider asynchronous
# All we are asking the tool to so is to make sure that no delay from input or output pin exceed 10 ns
#
# Here is our virtual clock declaration ...

create_clock -period 10.000 -name virtual_clk -waveform {0.000 5.000}

# Create input pin list


# Create output pin list


# IO pin list


# Input pin contraints

set_input_delay -clock [get_clocks virtual_clk] -min -add_delay 0.100 [get_ports {{board_id[*]} common_stop dummy_reset event_ena force_reset glob_ena psd_sout sdo_a_0 sdo_b_0 sdo_c_0 sdo_t_0 sdo_a_1 sdo_b_1 sdo_c_1 sdo_t_1 {cfd_ad[*]} take_event tdc_dout uart_rx tstamp_rst tdc_intb debug_uart_rx psd_acq_ack_0 psd_acq_ack_1 psd_or_out_0 psd_or_out_1 psd_token_out_0 psd_token_out_1 cfd_or}]

set_input_delay -clock [get_clocks virtual_clk] -max -add_delay 0.200 [get_ports {{board_id[*]} common_stop dummy_reset event_ena force_reset glob_ena psd_sout sdo_a_0 sdo_b_0 sdo_c_0 sdo_t_0 sdo_a_1 sdo_b_1 sdo_c_1 sdo_t_1 {cfd_ad[*]} take_event tdc_dout uart_rx tstamp_rst tdc_intb debug_uart_rx psd_acq_ack_0 psd_acq_ack_1 psd_or_out_0 psd_or_out_1 psd_token_out_0 psd_token_out_1 cfd_or}]

# Output pin contraints

set_output_delay -clock [get_clocks virtual_clk] -min -add_delay 0.100 [get_ports {adc_sclk_0 adc_sclk_1 busy_out_l cfd_global_ena cfd_neg_pol cfd_reset cfd_write conv_0 conv_1 delay_clk delay_data {led[*]} or_connect psd_sclk psd_sel_ext_addr_0 psd_sel_ext_addr_1 psd_sin tdc_csb tdc_din tdc_enable tdc_sclk tdc_start tdc_stop uart_tx {psd_chan_addr_0[3]} {psd_chan_addr_0[4]} {psd_chan_addr_1[3]} {psd_chan_addr_1[4]} {cfd_ad[*]} cfd_out cfd_stb dac_din dac_ld dac_sclk {debug_gpio[*]} debug_uart_tx {delay_en_l[*]} psd_dac_stb_0 psd_dac_stb_1 psd_force_rst psd_glob_ena psd_reset psd_sc0_0 psd_sc0_1 psd_sc1_0 psd_sc1_1 psd_test_mode_int_0 psd_test_mode_int_1 psd_token_in_0 psd_token_in_1 psd_veto_reset delay_x2 intx_out mux_en {mux_sel[*]} psd_acq_all psd_acq_clk_0 psd_acq_clk_1 psd_cfd_bypass tdc_clock}]

set_output_delay -clock [get_clocks virtual_clk] -max -add_delay 0.200 [get_ports {adc_sclk_0 adc_sclk_1 busy_out_l cfd_global_ena cfd_neg_pol cfd_reset cfd_write conv_0 conv_1 delay_clk delay_data {led[*]} or_connect psd_sclk psd_sel_ext_addr_0 psd_sel_ext_addr_1 psd_sin tdc_csb tdc_din tdc_enable tdc_sclk tdc_start tdc_stop uart_tx {psd_chan_addr_0[3]} {psd_chan_addr_0[4]} {psd_chan_addr_1[3]} {psd_chan_addr_1[4]} {cfd_ad[*]} cfd_out cfd_stb dac_din dac_ld dac_sclk {debug_gpio[*]} debug_uart_tx {delay_en_l[*]} psd_dac_stb_0 psd_dac_stb_1 psd_force_rst psd_glob_ena psd_reset psd_sc0_0 psd_sc0_1 psd_sc1_0 psd_sc1_1 psd_test_mode_int_0 psd_test_mode_int_1 psd_token_in_0 psd_token_in_1 psd_veto_reset delay_x2 intx_out mux_en {mux_sel[*]} psd_acq_all psd_acq_clk_0 psd_acq_clk_1 psd_cfd_bypass tdc_clock}]

# IO pin contraints

set_input_delay -clock [get_clocks virtual_clk] -min -add_delay 0.100 [get_ports {i2c_scl i2c_sda {psd_chan_addr_0[0]} {psd_chan_addr_0[1]} {psd_chan_addr_0[2]} {psd_chan_addr_1[0]} {psd_chan_addr_1[1]} {psd_chan_addr_1[2]}}]

set_input_delay -clock [get_clocks virtual_clk] -max -add_delay 0.200 [get_ports {i2c_scl i2c_sda {psd_chan_addr_0[0]} {psd_chan_addr_0[1]} {psd_chan_addr_0[2]} {psd_chan_addr_1[0]} {psd_chan_addr_1[1]} {psd_chan_addr_1[2]}}]

set_output_delay -clock [get_clocks virtual_clk] -min -add_delay 0.100 [get_ports {i2c_scl i2c_sda {psd_chan_addr_0[0]} {psd_chan_addr_0[1]} {psd_chan_addr_0[2]} {psd_chan_addr_1[0]} {psd_chan_addr_1[1]} {psd_chan_addr_1[2]}}]

set_output_delay -clock [get_clocks virtual_clk] -max -add_delay 0.200 [get_ports {i2c_scl i2c_sda {psd_chan_addr_0[0]} {psd_chan_addr_0[1]} {psd_chan_addr_0[2]} {psd_chan_addr_1[0]} {psd_chan_addr_1[1]} {psd_chan_addr_1[2]}}]

# Remove some warnings that we know don't pose a problem

set_false_path -to [get_pins {u1/proc0/program_rom/kcpsm6_rom/DIBDI[*]}]
set_false_path -to [get_pins {u1/proc0/program_rom/kcpsm6_rom/DIPBDIP[*]}]


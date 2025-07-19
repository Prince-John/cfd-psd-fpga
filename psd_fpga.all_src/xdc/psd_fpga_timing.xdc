#
# Timing constraints for psd_fpga
#

# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tdc_stop_OBUF]


# False path clock

set     CLK     false_path_clk

# Setup min and max delays

set     MIN_DELAY     0.1
set     MAX_DELAY     0.2

# Master clock for register bit that generates the tdc_clk

set     tdc_mclk_pin     {u1/proc0/P4_out_reg[5]/C}

# The actual tdc_clk pin (divided down clock)

set     tdc_dclk_pin     {u1/proc0/P4_out_reg[5]/Q}

# tdc clock divide down number

set     tdc_clk_div_by  10

# Master clock for register bit that generates the adc0_clk

set     adc0_mclk_pin     {u1/proc0/P1_out_reg[0]/C}

# The actual adc0_clk pin (divided down clock)

set     adc0_dclk_pin    {u1/proc0/P1_out_reg[0]/Q}

# adc0 clock divide down number

set     adc0_clk_div_by  10

# Master clock for register bit that generates the adc1_clk

set     adc1_mclk_pin     {u1/proc0/P1_out_reg[1]/C}

# The actual adc1_clk pin (divided down clock)

set     adc1_dclk_pin    {u1/proc0/P1_out_reg[1]/Q}

# adc1 clock divide down number

set     adc1_clk_div_by  10

# Create a 10 MHz timestamp clock

create_clock -period 100.000 -name tstamp_clk -waveform {0 50.0} [get_ports {tstamp_clk}]

# Create the tdc_register clock

create_generated_clock -name tdc_clk \
                    -source [get_pins ${tdc_mclk_pin}] \
                    -divide_by $tdc_clk_div_by \
                    [get_pins ${tdc_dclk_pin}]

# Create the adc0 resgister clock

create_generated_clock -name adc0_clk \
                     -source [get_pins ${adc0_mclk_pin}] \
                      -divide_by $adc0_clk_div_by \
                      [get_pins  ${adc0_dclk_pin}]

# Create the adc1 resgister clock

create_generated_clock -name adc1_clk \
                     -source [get_pins ${adc1_mclk_pin}] \
                      -divide_by $adc1_clk_div_by \
                      [get_pins  ${adc1_dclk_pin}]


# We need to tell tool about unrelated clocks 

set_clock_groups -asynchronous \
                -group  [get_clocks -include_generated_clocks {sys_clk}] \
                -group  [get_clocks -include_generated_clocks {tstamp_clk}]   
#
# Create 100 MHz virtual clock .. Used by the our set_input_delay and set_output_delay statements
# It's way you set up delay contraints for things without a clock reference ... in this
# case for things we consider asynchronous
#

create_clock -period 10.0 -name $CLK -waveform {0  5} 

# Create input pin list
# False path contraint will be applied to these pins

set false_path_input_pin_list {
board_id[*] 
common_stop 
dummy_reset 
event_ena 
force_reset 
glob_ena 
psd_sout 
sdo_a_0
sdo_b_0
sdo_c_0
sdo_t_0 
sdo_a_1
sdo_b_1
sdo_c_1
sdo_t_1 
cfd_ad[*]
take_event 
tdc_dout 
uart_rx
tstamp_rst
tdc_intb
debug_uart_rx
psd_acq_ack_0
psd_acq_ack_1
psd_or_out_0
psd_or_out_1
psd_token_out_0
psd_token_out_1
}

# Create output pin list
# False path contraint will be applied to these pins

set false_path_output_pin_list {
adc_sclk_0 
adc_sclk_1
busy_out_l 
cfd_global_ena 
cfd_neg_pol 
cfd_reset 
cfd_write 
conv_0 
conv_1
delay_clk 
delay_data 
led[*]
or_connect 
psd_sclk 
psd_sel_ext_addr_0 
psd_sel_ext_addr_1
psd_sin 
tdc_csb
tdc_din
tdc_enable
tdc_sclk
tdc_start
tdc_stop
uart_tx
psd_chan_addr_0[3] 
psd_chan_addr_0[4] 
psd_chan_addr_1[3] 
psd_chan_addr_1[4]  
cfd_ad[*]
cfd_out
cfd_stb
dac_din
dac_ld
dac_sclk
debug_gpio[*]
debug_uart_tx
delay_en_l[*]
psd_dac_stb_0
psd_dac_stb_1
psd_force_rst
psd_glob_ena
psd_reset
psd_sc0_0
psd_sc0_1
psd_sc1_0
psd_sc1_1
psd_test_mode_int_0
psd_test_mode_int_1
psd_token_in_0
psd_token_in_1
psd_veto_reset
delay_x2
intx_out
mux_en
mux_sel[*]
psd_acq_all
psd_acq_clk_0
psd_acq_clk_1
psd_cfd_bypass
}

# IO pin list
# False path contraint will be applied to these pins

set false_path_io_pin_list {
i2c_scl 
i2c_sda 
psd_chan_addr_0[0] 
psd_chan_addr_0[1] 
psd_chan_addr_0[2] 
psd_chan_addr_1[0] 
psd_chan_addr_1[1] 
psd_chan_addr_1[2] 
}

# False path input pin contraints

set_input_delay     -clock [get_clocks $CLK] \
                    -min -add_delay $MIN_DELAY \
                    [get_ports ${false_path_input_pin_list}]
                
set_input_delay     -clock [get_clocks $CLK] \
                    -max -add_delay $MAX_DELAY \
                    [get_ports ${false_path_input_pin_list}]
                                                                
set_false_path  -from [get_ports ${false_path_input_pin_list}]

# False path output pin contraints

set_output_delay    -clock [get_clocks $CLK]  \
                    -min -add_delay $MIN_DELAY \
                    [get_ports ${false_path_output_pin_list}]
                    
set_output_delay    -clock [get_clocks $CLK]  \
                    -max -add_delay $MAX_DELAY \
                    [get_ports ${false_path_output_pin_list}]
                    
set_false_path -to [get_ports ${false_path_output_pin_list}]

# False path IO pin contraints

set_input_delay     -clock [get_clocks $CLK] \
                    -min -add_delay $MIN_DELAY \
                    [get_ports ${false_path_io_pin_list}]
                
set_input_delay     -clock [get_clocks $CLK] \
                    -max -add_delay $MAX_DELAY \
                    [get_ports ${false_path_io_pin_list}]
                
set_output_delay    -clock [get_clocks $CLK]  \
                    -min -add_delay $MIN_DELAY \
                    [get_ports ${false_path_io_pin_list}]
                
set_output_delay    -clock [get_clocks $CLK] \
                    -max -add_delay $MAX_DELAY \
                    [get_ports ${false_path_io_pin_list}]
                 
set_false_path -to [get_ports ${false_path_io_pin_list}]

# Remove some warnings that we know don't pose a problem

set_false_path -to [get_pins {u1/proc0/program_rom/kcpsm6_rom/DIBDI[*]}]
set_false_path -to [get_pins {u1/proc0/program_rom/kcpsm6_rom/DIPBDIP[*]}]
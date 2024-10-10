
# ************************************
# Pin location constraints!!!!   
# Timestamp:  Thu Oct 10 12:40:10 CDT 2024
# Version:  26-Sep-2024 --> Handles Trenz reset (D9) pin
# FPGA development board: trenz
# ************************************


### Signal: 	board_id[0] can be found on board connector JB1-46
### Signal: 	board_id[0] can be found on breakout connector J11-17

set_property	PACKAGE_PIN	B17  	 [get_ports {board_id[0]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {board_id[0]}]

### Signal: 	board_id[1] can be found on board connector JB1-42
### Signal: 	board_id[1] can be found on breakout connector J11-18

set_property	PACKAGE_PIN	B18  	 [get_ports {board_id[1]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {board_id[1]}]

### Signal: 	board_id[2] can be found on board connector JB2-14
### Signal: 	board_id[2] can be found on breakout connector J11-19

set_property	PACKAGE_PIN	V12  	 [get_ports {board_id[2]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {board_id[2]}]

### Signal: 	board_id[3] can be found on board connector JB2-16
### Signal: 	board_id[3] can be found on breakout connector J11-20

set_property	PACKAGE_PIN	N14  	 [get_ports {board_id[3]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {board_id[3]}]

### Signal: 	board_id[4] can be found on board connector JB2-32
### Signal: 	board_id[4] can be found on breakout connector J11-21

set_property	PACKAGE_PIN	T11  	 [get_ports {board_id[4]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {board_id[4]}]

### Signal: 	board_id[5] can be found on board connector JB2-36
### Signal: 	board_id[5] can be found on breakout connector J11-22

set_property	PACKAGE_PIN	T10  	 [get_ports {board_id[5]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {board_id[5]}]

### Signal: 	common_stop can be found on board connector JB2-48
### Signal: 	common_stop can be found on breakout connector J11-23

set_property	PACKAGE_PIN	H4  	 [get_ports {common_stop}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {common_stop}]

### Signal: 	dummy_reset can be found on board connector dummy_reset
### Signal: 	dummy_reset can be found on breakout connector *****

set_property	PACKAGE_PIN	D9  	 [get_ports {dummy_reset}]
set_property	IOSTANDARD	LVCMOS18 [get_ports {dummy_reset}]
set_property	PULLDOWN	true	[get_ports { dummy_reset } ]

### Signal: 	event_ena can be found on board connector JB2-64
### Signal: 	event_ena can be found on breakout connector J11-25

set_property	PACKAGE_PIN	G2  	 [get_ports {event_ena}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {event_ena}]

### Signal: 	force_reset can be found on board connector JB2-66
### Signal: 	force_reset can be found on breakout connector J11-26

set_property	PACKAGE_PIN	G6  	 [get_ports {force_reset}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {force_reset}]

### Signal: 	glob_ena can be found on board connector JB2-52
### Signal: 	glob_ena can be found on breakout connector J11-24

set_property	PACKAGE_PIN	E2  	 [get_ports {glob_ena}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {glob_ena}]

### Signal: 	psd_sout can be found on board connector JB1-44
### Signal: 	psd_sout can be found on breakout connector J11-06

set_property	PACKAGE_PIN	A18  	 [get_ports {psd_sout}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {psd_sout}]

### Signal: 	sdo_t_0 can be found on board connector JB1-49
### Signal: 	sdo_t_0 can be found on breakout connector J13-14

set_property	PACKAGE_PIN	J14  	 [get_ports {sdo_t_0}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {sdo_t_0}]

### Signal: 	sys_clk can be found on board connector sys_clk
### Signal: 	sys_clk can be found on breakout connector *****

set_property	PACKAGE_PIN	P17  	 [get_ports {sys_clk}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {sys_clk}]

### Signal: 	take_event can be found on board connector JB1-99
### Signal: 	take_event can be found on breakout connector J11-05

set_property	PACKAGE_PIN	B12  	 [get_ports {take_event}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {take_event}]

### Signal: 	uart_rx can be found on board connector uart_rx
### Signal: 	uart_rx can be found on breakout connector *****

set_property	PACKAGE_PIN	R11  	 [get_ports {uart_rx}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {uart_rx}]

### Signal: 	adc_sclk_0 can be found on board connector JB1-41
### Signal: 	adc_sclk_0 can be found on breakout connector J13-15

set_property	PACKAGE_PIN	J17  	 [get_ports {adc_sclk_0}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {adc_sclk_0}]

### Signal: 	busy_out can be found on board connector JB2-62
### Signal: 	busy_out can be found on breakout connector J11-27

set_property	PACKAGE_PIN	H2  	 [get_ports {busy_out}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {busy_out}]

### Signal: 	cfd_ad[0] can be found on board connector JB1-93
### Signal: 	cfd_ad[0] can be found on breakout connector J13-05

set_property	PACKAGE_PIN	B14  	 [get_ports {cfd_ad[0]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_ad[0]}]

### Signal: 	cfd_ad[1] can be found on board connector JB1-95
### Signal: 	cfd_ad[1] can be found on breakout connector J13-06

set_property	PACKAGE_PIN	B13  	 [get_ports {cfd_ad[1]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_ad[1]}]

### Signal: 	cfd_ad[2] can be found on board connector JB1-70
### Signal: 	cfd_ad[2] can be found on breakout connector J13-07

set_property	PACKAGE_PIN	A14  	 [get_ports {cfd_ad[2]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_ad[2]}]

### Signal: 	cfd_ad[3] can be found on board connector JB1-79
### Signal: 	cfd_ad[3] can be found on breakout connector J13-08

set_property	PACKAGE_PIN	C17  	 [get_ports {cfd_ad[3]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_ad[3]}]

### Signal: 	cfd_ad[4] can be found on board connector JB1-77
### Signal: 	cfd_ad[4] can be found on breakout connector J13-09

set_property	PACKAGE_PIN	D17  	 [get_ports {cfd_ad[4]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_ad[4]}]

### Signal: 	cfd_ad[5] can be found on board connector JB1-75
### Signal: 	cfd_ad[5] can be found on breakout connector J13-10

set_property	PACKAGE_PIN	E17  	 [get_ports {cfd_ad[5]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_ad[5]}]

### Signal: 	cfd_ad[6] can be found on board connector JB1-61
### Signal: 	cfd_ad[6] can be found on breakout connector J13-11

set_property	PACKAGE_PIN	J15  	 [get_ports {cfd_ad[6]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_ad[6]}]

### Signal: 	cfd_ad[7] can be found on board connector JB1-59
### Signal: 	cfd_ad[7] can be found on breakout connector J13-12

set_property	PACKAGE_PIN	K15  	 [get_ports {cfd_ad[7]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_ad[7]}]

### Signal: 	cfd_global_ena can be found on board connector JB2-63
### Signal: 	cfd_global_ena can be found on breakout connector J11-40

set_property	PACKAGE_PIN	G1  	 [get_ports {cfd_global_ena}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_global_ena}]

### Signal: 	cfd_neg_pol can be found on board connector JB2-71
### Signal: 	cfd_neg_pol can be found on breakout connector J11-38

set_property	PACKAGE_PIN	C1  	 [get_ports {cfd_neg_pol}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_neg_pol}]

### Signal: 	cfd_reset can be found on board connector JB2-61
### Signal: 	cfd_reset can be found on breakout connector J11-39

set_property	PACKAGE_PIN	H1  	 [get_ports {cfd_reset}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_reset}]

### Signal: 	cfd_stb can be found on board connector JB2-77
### Signal: 	cfd_stb can be found on breakout connector J11-36

set_property	PACKAGE_PIN	A1  	 [get_ports {cfd_stb}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_stb}]

### Signal: 	cfd_write can be found on board connector JB2-67
### Signal: 	cfd_write can be found on breakout connector J11-37

set_property	PACKAGE_PIN	E1  	 [get_ports {cfd_write}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {cfd_write}]

### Signal: 	conv_0 can be found on board connector JB1-51
### Signal: 	conv_0 can be found on breakout connector J13-13

set_property	PACKAGE_PIN	H15  	 [get_ports {conv_0}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {conv_0}]

### Signal: 	dac_din can be found on board connector JB2-81
### Signal: 	dac_din can be found on breakout connector J11-35

set_property	PACKAGE_PIN	B2  	 [get_ports {dac_din}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {dac_din}]

### Signal: 	dac_ld can be found on board connector JB2-87
### Signal: 	dac_ld can be found on breakout connector J11-33

set_property	PACKAGE_PIN	A4  	 [get_ports {dac_ld}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {dac_ld}]

### Signal: 	dac_sclk can be found on board connector JB2-85
### Signal: 	dac_sclk can be found on breakout connector J11-34

set_property	PACKAGE_PIN	A3  	 [get_ports {dac_sclk}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {dac_sclk}]

### Signal: 	delay_clk can be found on board connector JB1-69
### Signal: 	delay_clk can be found on breakout connector J11-10

set_property	PACKAGE_PIN	H17  	 [get_ports {delay_clk}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {delay_clk}]

### Signal: 	delay_data can be found on board connector JB1-71
### Signal: 	delay_data can be found on breakout connector J11-09

set_property	PACKAGE_PIN	G17  	 [get_ports {delay_data}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {delay_data}]

### Signal: 	delay_en_l[0] can be found on board connector JB1-57
### Signal: 	delay_en_l[0] can be found on breakout connector J11-11

set_property	PACKAGE_PIN	J13  	 [get_ports {delay_en_l[0]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {delay_en_l[0]}]

### Signal: 	delay_en_l[1] can be found on board connector JB1-55
### Signal: 	delay_en_l[1] can be found on breakout connector J11-12

set_property	PACKAGE_PIN	K13  	 [get_ports {delay_en_l[1]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {delay_en_l[1]}]

### Signal: 	delay_en_l[2] can be found on board connector JB1-47
### Signal: 	delay_en_l[2] can be found on breakout connector J11-13

set_property	PACKAGE_PIN	F18  	 [get_ports {delay_en_l[2]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {delay_en_l[2]}]

### Signal: 	delay_en_l[3] can be found on board connector JB1-45
### Signal: 	delay_en_l[3] can be found on breakout connector J11-14

set_property	PACKAGE_PIN	G18  	 [get_ports {delay_en_l[3]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {delay_en_l[3]}]

### Signal: 	delay_en_l[4] can be found on board connector JB1-37
### Signal: 	delay_en_l[4] can be found on breakout connector J11-15

set_property	PACKAGE_PIN	D18  	 [get_ports {delay_en_l[4]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {delay_en_l[4]}]

### Signal: 	delay_en_l[5] can be found on board connector JB1-35
### Signal: 	delay_en_l[5] can be found on breakout connector J11-16

set_property	PACKAGE_PIN	E18  	 [get_ports {delay_en_l[5]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {delay_en_l[5]}]

### Signal: 	led[0] can be found on board connector LEDS[1]
### Signal: 	led[0] can be found on breakout connector *****

set_property	PACKAGE_PIN	L15  	 [get_ports {led[0]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {led[0]}]

### Signal: 	led[1] can be found on board connector LEDS[2]
### Signal: 	led[1] can be found on breakout connector *****

set_property	PACKAGE_PIN	R17  	 [get_ports {led[1]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {led[1]}]

### Signal: 	mux_en can be found on board connector JB2-74
### Signal: 	mux_en can be found on breakout connector J11-28

set_property	PACKAGE_PIN	D7  	 [get_ports {mux_en}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {mux_en}]

### Signal: 	mux_sel[0] can be found on board connector JB2-46
### Signal: 	mux_sel[0] can be found on breakout connector J11-29

set_property	PACKAGE_PIN	J4  	 [get_ports {mux_sel[0]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {mux_sel[0]}]

### Signal: 	mux_sel[1] can be found on board connector JB2-54
### Signal: 	mux_sel[1] can be found on breakout connector J11-30

set_property	PACKAGE_PIN	D2  	 [get_ports {mux_sel[1]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {mux_sel[1]}]

### Signal: 	mux_sel[2] can be found on board connector JB2-99
### Signal: 	mux_sel[2] can be found on breakout connector J11-31

set_property	PACKAGE_PIN	J5  	 [get_ports {mux_sel[2]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {mux_sel[2]}]

### Signal: 	mux_sel[3] can be found on board connector JB2-95
### Signal: 	mux_sel[3] can be found on breakout connector J11-32

set_property	PACKAGE_PIN	B6  	 [get_ports {mux_sel[3]}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {mux_sel[3]}]

### Signal: 	psd_sclk can be found on board connector JB1-81
### Signal: 	psd_sclk can be found on breakout connector J11-08

set_property	PACKAGE_PIN	C16  	 [get_ports {psd_sclk}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {psd_sclk}]

### Signal: 	psd_sin can be found on board connector JB1-87
### Signal: 	psd_sin can be found on breakout connector J11-07

set_property	PACKAGE_PIN	C14  	 [get_ports {psd_sin}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {psd_sin}]

### Signal: 	uart_tx can be found on board connector uart_tx
### Signal: 	uart_tx can be found on breakout connector *****

set_property	PACKAGE_PIN	L16  	 [get_ports {uart_tx}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {uart_tx}]

### Signal: 	i2c_scl can be found on board connector JB1-39
### Signal: 	i2c_scl can be found on breakout connector J13-16

set_property	PACKAGE_PIN	J18  	 [get_ports {i2c_scl}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {i2c_scl}]

### Signal: 	i2c_sda can be found on board connector JB1-58
### Signal: 	i2c_sda can be found on breakout connector J13-17

set_property	PACKAGE_PIN	A15  	 [get_ports {i2c_sda}]
set_property	IOSTANDARD	LVCMOS33 [get_ports {i2c_sda}]


# *********************************************************
# Default common settings that do not depend assembly variant
# **********************************************************

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.M1PIN PULLNONE [current_design]
set_property BITSTREAM.CONFIG.M2PIN PULLNONE [current_design]
set_property BITSTREAM.CONFIG.M0PIN PULLNONE [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLDOWN [current_design]

# *********************************************************
# Handle a few special FPGA pins for Trenz board           
# *********************************************************

set_property DRIVE 12 [get_ports {led[1]}]
set_property SLEW SLOW [get_ports {led[1]}]
set_property DRIVE 12 [get_ports {led[0]}]
set_property SLEW SLOW [get_ports {led[0]}]

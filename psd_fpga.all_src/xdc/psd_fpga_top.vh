// *************************************************************
// Verilog module declaration for top cell      
// Timestamp:  Thu Oct 10 12:40:10 CDT 2024
// Version:  26-Sep-2024 --> Handles Trenz reset (D9) pin
// FPGA development board: trenz
// *************************************************************

	board_id ,
	common_stop ,
	dummy_reset ,
	event_ena ,
	force_reset ,
	glob_ena ,
	psd_sout ,
	sdo_t_0 ,
	sys_clk ,
	take_event ,
	uart_rx ,
	adc_sclk_0 ,
	busy_out ,
	cfd_ad ,
	cfd_global_ena ,
	cfd_neg_pol ,
	cfd_reset ,
	cfd_stb ,
	cfd_write ,
	conv_0 ,
	dac_din ,
	dac_ld ,
	dac_sclk ,
	delay_clk ,
	delay_data ,
	delay_en_l ,
	led ,
	mux_en ,
	mux_sel ,
	psd_sclk ,
	psd_sin ,
	uart_tx ,
	i2c_scl ,
	i2c_sda 	
) ;

// *** I/O and bus declarations *** 

	input	[5:0] board_id ;
	input	common_stop ;
	input	dummy_reset ;
	input	event_ena ;
	input	force_reset ;
	input	glob_ena ;
	input	psd_sout ;
	input	sdo_t_0 ;
	input	sys_clk ;
	input	take_event ;
	input	uart_rx ;
	output	adc_sclk_0 ;
	output	busy_out ;
	output	[7:0] cfd_ad ;
	output	cfd_global_ena ;
	output	cfd_neg_pol ;
	output	cfd_reset ;
	output	cfd_stb ;
	output	cfd_write ;
	output	conv_0 ;
	output	dac_din ;
	output	dac_ld ;
	output	dac_sclk ;
	output	delay_clk ;
	output	delay_data ;
	output	[5:0] delay_en_l ;
	output	[1:0] led ;
	output	mux_en ;
	output	[3:0] mux_sel ;
	output	psd_sclk ;
	output	psd_sin ;
	output	uart_tx ;
	inout	i2c_scl ;
	inout	i2c_sda ;



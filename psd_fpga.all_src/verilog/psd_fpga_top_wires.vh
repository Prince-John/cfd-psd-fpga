// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// This file is NOT auto-generated
// Add new wires as the need arises
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// ****************************************************
// Declare the gpio buses
// ****************************************************

    wire    [31:0] gpio0_in ;
    wire    [31:0] gpio1_in ;   
    wire    [31:0] gpio2_in ;    
    wire    [31:0] gpio3_in ;    

    wire    [31:0] gpio0_out ;
    wire    [31:0] gpio1_out ;   
    wire    [31:0] gpio2_out ;    
    wire    [31:0] gpio3_out ; 

// **************************************************************
// Wires related to reset
// ************************************************************

    wire    ublaze_reset ;
    wire    custom_block_reset ;
    
// *************************************************************    
// Wires needed for the UART interface
// *************************************************************
    
    wire    baudout ;       //output
    wire    cts ;           // input
    wire    dcd ;           // input
    wire    ddis ;          // output
    wire    dsr ;           // input 
    wire    dtr ;           // output
    wire    out1 ;          // output
    wire    out2 ;          // output
    wire    ri ;            // input    
    wire    rts ;           // output
    wire    rdy ;           // output
    wire    txrdy ;         // output

// *************************************************************  
// mclk is buffered 100 MHz clock out of the ublaze system
// We will use it to clock our custom block  
// *************************************************************  

    wire    mclk ; 
    
// *************************************************************     
// FIFO signals
    
    wire    [31:0] fifo_data ;
    wire    tvalid, tlast, tready ;
// ************************************************************* 
    
// ************************************************************* 
// ADC related signals
// ************************************************************* 

    wire    [7:0] adc_sdo ;     // Input to the 8 ADC registers
    wire    [1:0] adc_sclk ;    // A pair of clocks (PSD 0 and PSD 1 ADCs)
    wire    [1:0] adc_conv ;    // A pair of conversion signals (PSD 0 and PSD 1 ADCs)
 
// **************************************************
// Declare PSD buses
// ***************************************************

//    wire    [4:0] psd0_chan_addr_in ;
//    wire    [4:0] psd1_chan_addr_in ;
     
    wire    [4:0] psd0_chan_addr_out ;
    wire    [4:0] psd1_chan_addr_out ;

// **************************************************
// Declare CFD buses
// Need to combine these two buses into 1 bi-dir bus
// ***************************************************

    wire    [7:0] cfd_ad_in ;
    wire    [7:0] cfd_ad_out ;

// ********************************************
// CFD OR 

    wire cfd_or_connect ;
  
// Doesn't hurt to put inputs and outputs  here
// This allows me to easily swap out what gets connected to pins
  
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


	
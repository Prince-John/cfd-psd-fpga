// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// This file is NOT auto-generated
// Add new wires as the need arises
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Let's define wires for all of the FPGA input pins
// IO is automatically a wire but doesn't hurt to add
// This allows me to develop verilog code on Digilent board
// even though it has many fewer IOs than our actual FPGA
// board has
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Let's define wires for all of the FPGA input pins
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    wire    [5:0] board_id ;    // 6-bit board ID
    wire    cfd_or ;            // OR out of the CFD chip
    wire    common_stop ;       // TVC stop signal from host
    wire    dummy_reset ;	    // Dummy reset pin
    wire    event_ena ;         // Event enable signal from host
    wire    force_reset ;       // Host request to force an anlog reset of PSD chips
    wire    glob_ena ;          // Host asserting global enable
    wire    psd_acq_ack_0 ;     // Aquisition ack from PSD 0
    wire    psd_acq_ack_1 ;     // Aquisition ack from PSD 1
    wire    psd_cfd_out_0 ;
    wire    psd_cfd_out_1 ;
    wire    psd_intx_out_0 ;
    wire    psd_intx_out_1 ;
    wire    psd_or_out_0 ;
    wire    psd_or_out_1 ;
    wire    psd_sout ;
    wire    psd_token_out_0 ;
    wire    psd_token_out_1 ;
    wire    sdo_a_0 ;
    wire    sdo_a_1 ;
    wire    sdo_b_0 ;
    wire    sdo_b_1 ;
    wire    sdo_c_0 ;
    wire    sdo_c_1 ;
    wire    sdo_t_0 ;
    wire    sdo_t_1 ;
    wire    sys_clk ;
    wire    take_event ;
    wire    tdc_dout ;
    wire    tdc_intb ;
    wire    tstamp_clk ;
    wire    tstamp_rst ;
    wire    uart_rx ;
    
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Let's define wires for all of the FPGA output pins
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    wire    adc_sclk_0 ;
    wire    adc_sclk_1 ;
    wire    busy_out_l ;
    wire    cfd_global_ena ;
    wire    cfd_neg_pol ;
    wire    cfd_out ;
    wire    cfd_reset ;
    wire    cfd_stb ;
    wire    cfd_write ;
    wire    conv_0 ;
    wire    conv_1 ;
    wire    dac_din ;
    wire    dac_ld ;
    wire    dac_sclk ;
    wire    delay_sclk ;
    wire    delay_data ;
    wire    [5:0] delay_en_l ;
    wire    delay_x2 ;
    wire    intx_out ;
    wire    [1:0] led ;
    wire    [5:0] debug_flags_from_pico; // March 30, Prince
    wire    mux_en ;
    wire    [3:0] mux_sel ;
    wire    or_connect ;
    wire    psd_acq_all ;
    wire    psd_acq_clk_0 ;
    wire    psd_acq_clk_1 ;
    wire    psd_cfd_bypass ;
    wire    psd_dac_stb_0 ;
    wire    psd_dac_stb_1 ;
    wire    psd_force_rst ;
    wire    psd_global_ena ;
    wire    psd_reset ;
    wire    psd_sc0_0 ;
    wire    psd_sc0_1 ;
    wire    psd_sc1_0 ;
    wire    psd_sc1_1 ;
    wire    psd_sclk ;
    wire    psd_sel_ext_addr_0 ;
    wire    psd_sel_ex_addr_1 ;
    wire    psd_sin ;
    wire    psd_test_mode_int_0 ;
    wire    psd_test_mode_int_1 ;
    wire    psd_token_in_0 ;
    wire    psd_token_in_1 ;
    wire    psd_veto_reset ;
    wire    tdc_csb ;
    wire    tdc_din ;
    wire    tdc_enable ;
    wire    tdc_sclk ;
    wire    tdc_start ;
    wire    tdc_stop ;
    wire    uart_tx ;

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Let's define wires for all of the FPGA inout pins
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    wire    [7:0] cfd_ad ;
//  wire    [7:0] debug_gpio ;
//    wire    [7:4] debug_gpio ;
    wire    i2c_scl ;
    wire    i2c_sda ;
    
    wire    [4:0] psd_chan_addr_0 ;
    wire    [4:0] psd_chan_addr_1 ;
    
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
// *************************************************************   
    
    wire    [31:0] fifo_data ;
    wire    tvalid, tlast, tready ;

// ************************************************************* 
// ADC related signals
// ************************************************************* 

    wire    [7:0] adc_sdo ;     // Input to the 8 ADC registers
    wire    [1:0] adc_sclk ;    // A pair of clocks (PSD 0 and PSD 1 ADCs)
    wire    [1:0] adc_conv ;    // A pair of conversion signals (PSD 0 and PSD 1 ADCs)
 
// **************************************************
// Declare PSD and CFD buses
// ***************************************************

    wire    [4:0] psd0_chan_addr_in ;
    wire    [4:0] psd1_chan_addr_in ;
     
    wire    [4:0] psd0_chan_addr_out ;
    wire    [4:0] psd1_chan_addr_out ;
 
    wire    [7:0] cfd_ad_in ;
    wire    [7:0] cfd_ad_out ;

// **************************************************
// Buses we need to connect to PicoBlaze input ports
// ***************************************************

    wire    [7:0] pico_status_port ;    // input port 0
    wire    [7:0] pico_board_id_port ;  // input port 1
    wire    [7:0] pico_psd0_iport ;     // input port 2
    wire    [7:0] pico_psd1_iport ;     // input port 3
    
// **************************************************
// Buses from PicoBlaze output ports
// ***************************************************

    wire    [7:0] pico_psd0_oport ;     // output port 5
    wire    [7:0] pico_psd1_oport ;     // output port 6
    
// **************************
// CFD OR 
// *************************
    wire    cfd_or_connect ;

// **************************    
// PSD address lines from the micro
// **************************
    wire    [4:0] psd_addr_in_0_from_micro ;
    wire    [4:0] psd_addr_in_1_from_micro ;
 
// **************************   
// PSD select ext address control from micro
// **************************

    wire    psd_sel_ext_addr_0_from_micro ;   
	wire    psd_sel_ext_addr_1_from_micro  ;

// **************************	
// PSD sub-channel addresses from micro
// **************************

	wire	[1:0] psd_sc_addr_0_from_micro ;
	wire	[1:0] psd_sc_addr_1_from_micro ;
	
// Selects for some misc stuff

	wire   [1:0] or_sel ;
	wire   cfd_out_sel  ;
	wire   psd_intx_out_sel  ;
	wire   force_reset_from_micro ;
	wire   psd_veto_reset_from_pico ;
  
// Similar wires but for picoblaze
  
    wire    psd_sel_ext_addr_0_from_pico ;
    wire    psd_sel_ext_addr_1_from_pico ;   
    wire    pico_in_control ;   
    wire    [4:0] psd_addr_in_0_from_pico ;
    wire    [4:0] psd_addr_in_1_from_pico ;  
    wire    [1:0] psd_sc_addr_0_from_pico ;
    wire    [1:0] psd_sc_addr_1_from_pico ; 
    wire    force_reset_from_pico ; 
    wire    psd_glob_ena_from_pico ; // Added by GLE: 18-Feb-2025

// ******************************************************	
// Decided not to directly connect these signals from
// GPIOs to pins. Useful for initial debugging
// GLE: 7-Feb-2025
// ******************************************************

    wire    glob_ena_micro ;
    wire    event_ena_micro ;
    wire    force_reset_micro ;
    wire    take_event_micro ;

    wire tdc_dout_from_micro;
    wire tdc_intb_from_micro;
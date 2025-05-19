`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2024 04:32:57 PM
// Design Name: 
// Module Name: psd_custom_block
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////
//
// 29-Jan-2025
// Very close to being able to do readout from PSD chips!!!
//
// 18-Feb-2025
// Close to being able to support timestamp creation circuits
/////////////////////////////////////////////////////

module psd_custom_block(

// Master clock and reset

    input   mclk ,
    input   mrst ,
    
// Two diagnostic LEDs (led[1] is also the busy bit)

    output  [1:0] led ,
 
// PSD ADC related signals

    input   [7:0] adc_sdo ,
    output  [1:0] adc_sclk ,
    output  [1:0] adc_conv ,
    
// Streaming FIFO related signals
    
    output  [31:0] fifo_data ,
    output  tlast ,
    output  tvalid ,
    
// Output port that goes off to PSD 0 chip

    output  [7:0] psd0_oport ,

// Output port that goes off to PSD 1 chip

    output  [7:0] psd1_oport ,
    
// Status input port

    input   [7:0] status_port ,
    
// Board id port

    input   [7:0] board_id_port ,
    
//  PSD 0 input port to picoblaze

    input   [7:0] psd0_iport,
    
//  PSD1 input port to picoblaze

    input   [7:0] psd1_iport,
    
// Force psd reset (Output port 7, bit 0)
    
    output  force_psd_reset,
    
// PSD veto_reset (Output port 7, bit 1)    

    output  veto_reset,
    
// PSD global enable

    output  psd_glob_ena,

// TDC related signals

    input   common_stop,
    input   tdc_dout,
    input   tdc_intb,
    input   tstamp_clk,
    input   tstamp_rst,
    
    output  tdc_csb,
    output  tdc_din,
    output  tdc_enable,
    output  tdc_sclk,
    output  tdc_start,
    output  tdc_stop,
    
 // PICO Debug Flags
    
    output  [5:0]   pico_flag
    
   ) ;   
  
// ***************************    
// Wire up the input ports
// ***************************

    wire    [7:0] p0_in ;
    wire    [7:0] p1_in ;    
    wire    [7:0] p2_in ;    
    wire    [7:0] p3_in ;  
    wire    [7:0] p4_in ;
    wire    [7:0] p5_in ;    
    wire    [7:0] p6_in ;    
    wire    [7:0] p7_in ; 
  
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
// Picoblaze input port #0
// Called STATUS_IPORT in picoblaze code
//
// Bit 0 : tready FIFO signal
// Bit 1 : take_event signal
// Bit 3 : tdc_intb
// Ground the other bits
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  assign    p0_in = status_port ;
    
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
// Picoblaze input port #1
// Called BOARD_ID_PORT in picoblaze code
//
// Bit 0 - 5 : board[5:0]
// Ground the other bits
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^   
    
   assign   p1_in = board_id_port ;
    
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
// Picoblaze input port #2
// Called PSD0_PORT in picoblaze code
//
// Bit 0 : psd0_or
// Bit 1 : psd0_token_out
// Bit 2 : psd0_acq_ack
// Bit 3:  psd0_addr_out[0]
// Bit 4:  psd0_addr_out[1]
// Bit 5:  psd0_addr_out[2]
// Bit 6:  0 since it is PSD #0
// Bit 7:  0
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^   
        
    assign  p2_in = psd0_iport ; 
    
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
// Picoblaze input port #3
// Called PSD1_PORT in picoblaze code
//
// Bit 0 : psd1_or
// Bit 1 : psd1_token_out
// Bit 2 : psd1_acq_ack
// Bit 3:  psd1_addr_out[0]
// Bit 4:  psd1_addr_out[1]
// Bit 5:  psd1_addr_out[2]
// Bit 6:  1 since it is PSD #1
// Bit 7:  0
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^     
    
    assign  p3_in = psd1_iport ;  
    
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
// Ports 4, 5, 6, 7 currently unused so ground the input lines
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
      
    assign  p4_in[7:0] = 8'd0 ;     
    assign  p5_in[7:0] = 8'd0 ;     
    assign  p6_in[7:0] = 8'd0 ;     
    assign  p7_in[7:0] = 8'd0 ;     
        
// *******************************
// Wire up the output ports
// *******************************
      
    wire    [7:0] p0_out ;
    wire    [7:0] p1_out ;    
    wire    [7:0] p2_out ;
    wire    [7:0] p3_out ;
    wire    [7:0] p4_out ;
    wire    [7:0] p5_out ;    
    wire    [7:0] p6_out ;
    wire    [7:0] p7_out ;  
     
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
//  Picoblaze output port #0
//  Called LED_PORT in picoblaze code
//  Bit 0 : LED[0]
//  Bit 1 : LED[1] (also the busy bit!)
//  Bit 2 : PICO_FLAG[0] 
//  Bit 3 : PICO_FLAG[1]
//      .
//      .
//  Bit 7 : PICO_FLAG[5] 
//  Prince, Mar 30: Using the unused bits to bring out debug flags from picoblaze.
//  Other bits of port currently UNUSED
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    assign  led[0] = p0_out[0] ;
    assign  led[1] = p0_out[1] ;
    assign  pico_flag[5:0] = p0_out[7:2];
    
    
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
//  Picoblaze output port #1
//  Called ADC_CTL_PORT in picoblaze code
//  Assign adc clocks and conv signals to port bits!!!
//
//  Bit 0 : ADC sclk for PSD 0
//  Bit 1 : ADC clock for PSD 1
//  Bit 2 : ADC convert signal for PSD 0
//  Bit 3 : ADC convert signal for PSD 1
//  Bit 4 : adc_mux_sel bit 0
//  Bit 5 : adc_mux_sel bit 1
//  Bit 6 : adc_mux_sel bit 2
//  Bit 7 : adc regesters reset
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 
    assign  adc_sclk[0] = p1_out[0] ;
    assign  adc_sclk[1] = p1_out[1] ;
    assign  adc_conv[0] = p1_out[2] ; 
    assign  adc_conv[1] = p1_out[3] ;

    wire    [2:0] adc_mux_sel ;
    wire    adc_reg_reset ;
    
    assign  adc_mux_sel = p1_out[6:4] ; 
    assign  adc_reg_reset = p1_out[7] ;

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
//  OUTPUT PORT 2
//  Called DATA_TAG_PORT in the picoblaze code
//  Use output port 2 to put out data type identifier
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   
    wire    [7:0] data_tag ;
    assign  data_tag = p2_out ;
    
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
//  OUTPUT PORT 3
//  Called TDC_DATA_PORT
//  Byte going out to tdc_reg
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^    
    
    wire    [7:0] tdc_byte ;
    assign  tdc_byte = p3_out ;
    
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
//  OUTPUT PORT 4
//  Called TDC_CTL_PORT in picoblaze code
//  Byte going out to control the tdc_reg
//
// Bit 0 : tdc_reg_ld[0]
// Bit 1 : tdc_reg_ld[1]
// Bit 2 : tdc_reg_ld[2]
// Bit 3 : tdc_reg_rst
// Bit 4 : tdc_reg_shift
// Bit 5 : tdc_reg_sclk
// Bit 6 : tdc_csb
// Bit 7 : tdc_enable
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 
    
    wire    [2:0] tdc_reg_ld ;
    wire    tdc_reg_rst  ;
    wire    tdc_reg_shift ;
    
    assign  tdc_reg_ld = p4_out[2:0] ;    
    assign  tdc_reg_rst = p4_out[3] ;
    assign  tdc_reg_shift = p4_out[4] ;
    assign  tdc_sclk = p4_out[5] ;
    assign  tdc_csb = p4_out[6] ;
    assign  tdc_enable = p4_out[7] ;
    
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
//  OUTPUT PORT 5
//  Called PSD0_OPORT in picoblaze code
//  These signals will go off to the PSD 0 chip
//
// Bit 0 : psd0_addr_in[0]
// Bit 1 : psd0_addr_in[1]
// Bit 2 : psd0_addr_in[2]
// Bit 3 : psd0_acq_clk
// Bit 4 : psd0_sc0
// Bit 5 : psd1_sc1
// Bit 6 : psd1_token_in
// Bit 7 : psd1_sel_ext_addr
//
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 

    assign  psd0_oport[7:0] = p5_out[7:0] ;
      
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
//  OUTPUT PORT 6
//  Called PSD1_OPORT in picoblaze code
//
// Bit 0 : psd0_addr_in[0]
// Bit 1 : psd0_addr_in[1]
// Bit 2 : psd0_addr_in[2]
// Bit 3 : psd0_acq_clk
// Bit 4 : psd0_sc0
// Bit 5 : psd1_sc1
// Bit 6 : psd1_token_in
// Bit 7 : psd1_sel_ext_addr
//
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^   
 
    assign  psd1_oport[7:0] = p6_out[7:0] ;  
      
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
//  OUTPUT PORT 7
//  Called MISC_OPORT in picoblaze code
//
// Bit 0 : force_reset
// Bit 1 : veto_reset
// Bit 2:  fifo_mux_sel[0]
// Bit 3:  fifo_mux_sel[1]
// Bit 4:  psd_glob_ena
//
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^   
    
    assign  force_psd_reset = p7_out[0] ;
    assign  veto_reset = p7_out[1] ;
    
    wire    [1:0] fifo_mux_sel ;
    assign  fifo_mux_sel[1:0] = p7_out[3:2] ;
    
    assign  psd_glob_ena = p7_out[4] ;
    
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// Instantiate our Picoblaze 6 microcontroller
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  
     
    picoblaze_controller  proc0 (
            .clk(mclk),
            .reset(mrst),
            .P0_in(p0_in),
            .P1_in(p1_in),
            .P2_in(p2_in),
            .P3_in(p3_in),  
            .P4_in(p4_in),
            .P5_in(p5_in),
            .P6_in(p6_in),
            .P7_in(p7_in),                             
            .P0_out(p0_out),
            .P1_out(p1_out),
            .P2_out(p2_out),
            .P3_out(p3_out),
            .P4_out(p4_out),
            .P5_out(p5_out),
            .P6_out(p6_out),
            .P7_out(p7_out),                        
            .tvalid(tvalid),
            .tlast(tlast)        
    ) ;

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// Instantiate the timestamp circuit
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  

    wire    [23:0] tdc_reg ;
    wire    [47:0] tstamp_counter ;

    timestamp_interface tstamp_0(
            .tstamp_clk(tstamp_clk),
            .tstamp_rst(tstamp_rst),
            .common_stop(common_stop),
            .tdc_sclk(tdc_sclk),   
            .tdc_reg_rst(tdc_reg_rst),
            .tdc_reg_ld(tdc_reg_ld),
            .tdc_reg_shift(tdc_reg_shift),
            .tdc_reg_byte(tdc_byte),
            .tdc_intb(tdc_intb),
            .tdc_dout(tdc_dout),
            .tdc_din(tdc_din),   
            .tstamp(tstamp_counter),
            .tdc_reg(tdc_reg) 
    ) ;

//  Use the tstamp_clk to stop the TDC7200 

    assign  tdc_stop = tstamp_clk ;
    
// Use the common_stop to start the TDC

    assign  tdc_start = common_stop ;
    
// TDC data that we need to route to FIFO

    wire    [31:0] tdc_data ;
    assign  tdc_data = {data_tag, tdc_reg} ; 
    
// Also need tto route the timestamp counter (upper and lower) to FIFO

    wire    [31:0] tstamp_lower_data ;
    wire    [31:0] tstamp_upper_data ;
    
    assign  tstamp_lower_data = {data_tag, tstamp_counter[23:0]} ;
    assign  tstamp_upper_data = {data_tag, tstamp_counter[47:24]} ;
                
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
// Instantiate our adc interface module
//
// Bank of 8 ADC registers along with a MUX
// The mux select which of the 8 registers gets
// to drive the streaming FIFO
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  
     
    wire    [15:0] adc_reg ;
    adc_interface   adc_interface_0(.adc_sclk(adc_sclk),
                                    .adc_sdo(adc_sdo),
                                    .adc_reg_reset(adc_reg_reset),
                                    .adc_mux_sel(adc_mux_sel),
                                    .adc_reg(adc_reg)
                                    ) ;

// ADC data that we need to route to FIFO
           
    wire    [31:0] adc_data ;                       
    assign  adc_data = {data_tag, board_id_port, adc_reg} ;
                                                                        
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
// Output of the FIFO MUX drives the FIFO
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 

    reg     [31:0] fifo_data_reg  ;   
    always @(*) begin   
        case (fifo_mux_sel)
            2'd0:   fifo_data_reg = adc_data ;
            2'd1:   fifo_data_reg = tdc_data ;       
            2'd2:   fifo_data_reg = tstamp_lower_data ;        
            2'd3:   fifo_data_reg = tstamp_upper_data ;
        endcase
    end   
    assign  fifo_data = fifo_data_reg ;
     
endmodule
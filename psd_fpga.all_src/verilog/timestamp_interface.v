`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21-Jul-2025
// Design Name: 
// Module Name: timestamp_interface
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

module timestamp_interface(

// Master clock and master reset

    input       mclk,
    input       mrst,
    
// Timestamp clock and reset

    input       tstamp_clk,
    input       tstamp_rst,
    
// TDC7200 interupt signal

    input       tdc_intb,

// Common stop signal

    input       common_stop,
  
// tdc_reg serial clock
  
    input       tdc_sclk,
    
// tdc_reg reset signal
    
    input       tdc_reg_rst,
    
// tdc_reg byte load signals

    input       [2:0] tdc_reg_ld,

// tdc_reg shift left control

    input       tdc_reg_shift,

// A byte we want to load into tdc_reg

    input       [7:0] tdc_reg_byte,
    
// Serial output from TDC7200

    input       tdc_dout,
    
// Serial input into TDC7200 
 
    output      tdc_din,   
    
 // Latched timestamp counter value
 
    output      [47:0] tstamp,
    
// TDC register

    output      reg   [23:0] tdc_reg,
    
//  Let picoblaze know that [47:0]tstamp is ready

    output      tstamp_rdy,
    
// GLE: 14-Nov-2025 ... added signal to tell us if we are board 0

    input       board0,
// Pico in control flag to indicate when an event readout is done, included to signal the FSM for non-zero board tstamp_rdy output that was going low before the picoblaze would poll. - Prince Dec, 11   
    input       pico_in_control 
) ;

// ********************************************************************************  
// Implement the timestamp counter
// We can reset the counter (synchronous reset)
// Count changes on posedge of tstamp_clk
// ********************************************************************************  

    reg     [47:0] tstamp_counter ;
    always @(posedge tstamp_clk) begin
        if (tstamp_rst == 1'b1) tstamp_counter <= 48'd0 ;
        else tstamp_counter <= tstamp_counter + 48'd1 ;
    end
    
// ********************************************************************************   
// Instantiate the timestamp counter and related logic for boards whose ID is NOT 0
// ********************************************************************************   

    wire    [47:0] tstamp_not_board_0 ;
    wire    tstamp_rdy_not_board_0 ;
    
    tstamp_nonzero  u0(
            .mclk(mclk),
            .mrst(mrst),
            .common_stop(common_stop),
            .pico_in_control(pico_in_control),
            .tstamp_counter(tstamp_counter),
            .tstamp(tstamp_not_board_0),
            .tstamp_rdy(tstamp_rdy_not_board_0)
    );  
    
// ****************************************************************************   
// Instantiate the timestamp counter and related logic for boards whose ID IS 0
// ****************************************************************************   

    wire    [47:0] tstamp_board_0 ;
    wire    tstamp_rdy_board_0 ;
    
    tstamp_zero u1(
            .mclk(mclk),
            .mrst(mrst),
            .tdc_intb(tdc_intb),
            .tstamp_counter(tstamp_counter),
            .tstamp(tstamp_board_0),
            .tstamp_rdy(tstamp_rdy_board_0)
    );  
 
 // ****************************************************************************     
 // The board0 signal will be used as a multiplexer select
 // ****************************************************************************  
 
    assign tstamp_rdy = (board0 == 1'b1) ? tstamp_rdy_board_0 : tstamp_rdy_not_board_0 ;
    assign tstamp = (board0 == 1'b1) ? tstamp_board_0 : tstamp_not_board_0 ;
    
// ******************************************************************
// Support for TDC7200
// So we can communicate serially with it
// Implement the tdc register (24 bits)
// Any of the three bytes can be parallel loaded"
// We can also reset the entire register!
// We want to shift data out on the negedge of the tdc sclk
// tdc_dout gets shifted into least significant bit
// *********************************************************************

    always @(negedge tdc_sclk) begin
        if (tdc_reg_rst) tdc_reg <= 24'd0 ;
        else if (tdc_reg_ld[0]) tdc_reg[7:0] <= tdc_reg_byte ;
        else if (tdc_reg_ld[1]) tdc_reg[15:8] <= tdc_reg_byte ;
        else if (tdc_reg_ld[2]) tdc_reg[23:16] <= tdc_reg_byte ;
        else if (tdc_reg_shift) tdc_reg[23:0] <= {tdc_reg[22:0], tdc_dout} ;
    end
    
// We want to shift the most significant bit into the TDC7200 first!

    assign  tdc_din = tdc_reg[23] ;
     
endmodule

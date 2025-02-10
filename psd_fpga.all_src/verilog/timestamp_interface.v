`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07-Feb-2025
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

// Clock and reset

    input       tstamp_clk,
    input       tstamp_rst,
  
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
    
 // Timestamp counter
 
    output      reg   [43:0] tstamp_counter ,
    
// TDC register

    output      reg   [23:0] tdc_reg 
    
) ;
    
// Implement the timestamp counter
// We can reset the counter!
// Count changes on posedge of tstamp_clk

    always @(posedge tstamp_clk) begin
        if (tstamp_rst) tstamp_counter <= 44'd0 ;
        else tstamp_counter <= 44'd1 ;
    end

// Implement the tdc register (24 bits)
// Any of the three bytes can be parallel loaded"
// We can also reset the entire register!
// We want to shift data out on the negedge of the tdc sclk
// tdc_dout gets shifted into least significant bit

    always @(negedge tdc_sclk) begin
        if (tdc_reg_rst) tdc_reg <= 24'd0 ;
        else if (tdc_reg_ld[0]) tdc_reg[7:0] <= tdc_reg_byte ;
        else if (tdc_reg_ld[1]) tdc_reg[15:8] <= tdc_reg_byte ;
        else if (tdc_reg_ld[2]) tdc_reg[23:0] <= tdc_reg_byte ;
        else if (tdc_reg_shift) tdc_reg[23:0] <= {tdc_reg[22:0], tdc_dout} ;
    end
    
// We want to shift the most significant bit into the TDC7200 first!

    assign  tdc_din = tdc_reg[23] ;
     
endmodule

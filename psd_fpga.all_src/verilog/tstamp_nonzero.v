`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2025 12:38:10 PM
// Design Name: 
// Module Name: tstamp_counter
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

// This module is for boards whose ID is NOT 0

module tstamp_nonzero(

// Master clock and master reset

    input       mclk,
    input       mrst,

// Common stop signal

    input       common_stop,
    
// Timestamp counter

    input       [47:0] tstamp_counter,
  
// Latched timestamp counter valueds
 
    output      [47:0] tstamp,

//  Let picoblaze know that [47:0]tstamp is ready

    output      tstamp_rdy   
);
    
// Synchronize the timestamp counter to master clock

    wire    [47:0] tstamp_counter_sync ;
    genvar i ;    
    generate
        for (i = 0; i < 48; i = i + 1) begin 
            synchronizer sync(.async_in(tstamp_counter[i]), .sync_out(tstamp_counter_sync[i]), .clk(mclk)) ;
        end
    endgenerate
 
// Synchronize the common_stop signal to the master clock

    wire    common_stop_sync ;
    synchronizer sync_stop(.async_in(common_stop), .sync_out(common_stop_sync), .clk(mclk)) ;

// For boards other than 0, use this for the tstamp register

    reg     [47:0] tstamp_reg ;
    always @(posedge mclk) begin
        if (mrst == 1'b1) tstamp_reg <= 48'd0 ;
        else if (common_stop_sync == 1'b1) tstamp_reg <= tstamp_counter_sync ;
    end
    
    assign tstamp = tstamp_reg ;
    assign tstamp_rdy = common_stop_sync ;
    
endmodule

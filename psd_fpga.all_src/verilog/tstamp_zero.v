`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2025 03:25:31 PM
// Design Name: 
// Module Name: tstamp_counter_board_0
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

// This module is for boards whose ID IS 0

module tstamp_zero(

// Master clock and master reset

    input       mclk,
    input       mrst,
    
// TDC7200 interupt signal

    input       tdc_intb,
    
// 48-bit timestamp counter

    input       [47:0] tstamp_counter,
  
// Latched timestamp counter valueds
 
    output      [47:0] tstamp,

//  Let picoblaze know that [47:0]tstamp is ready

    output      tstamp_rdy   
);
    
// Synchronize the tdc_intb signal to mclk
// FSM runs off of mclk

    wire        tdc_intb_sync ;
    synchronizer sync0(.async_in(tdc_intb), .sync_out(tdc_intb_sync), .clk(mclk)) ;
    
// We want to make sure that intb_ena be active for just one clock cycle
// Use a small FSM to handle this
   
    parameter   WAIT_INTB_LOW = 2'd0 ;
    parameter   ISSUE_ENA = 2'd1 ;
    parameter   ASSERT_RDY = 2'd2 ;
    parameter   WAIT_INTB_HIGH = 2'd3 ;

    reg         [1:0] present_state ;
    reg         [1:0] next_state ;
       
// Present state register       

    always @(posedge mclk) begin
        if (mrst == 1'b1) present_state <= 2'd0 ;
        else present_state <= next_state ;
    end

// FSM combinational logic

    reg     intb_ena ;
    reg     tstamp_rdy_reg ;
    
    always @(*) begin
        intb_ena = 1'b0 ;
        tstamp_rdy_reg = 1'b0 ;
        case (present_state) 
            WAIT_INTB_LOW: begin
                                if (tdc_intb_sync == 1'b1) next_state = WAIT_INTB_LOW ;
                                else next_state = ISSUE_ENA ;
                            end
            ISSUE_ENA:      begin
                                intb_ena = 1'b1 ;
                                next_state = ASSERT_RDY ;
                            end
            ASSERT_RDY:     begin
                                tstamp_rdy_reg = 1'b1 ;
                                next_state = WAIT_INTB_HIGH ;
                            end 
            WAIT_INTB_HIGH: begin
                                if (tdc_intb_sync == 1'b0) begin
                                    next_state = WAIT_INTB_HIGH ;
                                    tstamp_rdy_reg = 1'b1 ;
                                end else begin
                                    next_state = WAIT_INTB_LOW ;
                                end 
                            end    
           default:         next_state = WAIT_INTB_LOW ;         
        endcase
    end               
                              
// When intb_ena goes high, let's transfer the counter value to tstamp_reg
// FSM guarantees that intb_ena stays high for only one tstamp_clk period!
                         
    reg     [47:0] tstamp_reg ;
    always @(posedge mclk) begin
        if (mrst == 1'b1) tstamp_reg <= 48'd0 ;
        else if (intb_ena == 1'b1) tstamp_reg <= tstamp_counter ;
    end
    
    assign tstamp = tstamp_reg ;
    assign tstamp_rdy = tstamp_rdy_reg ;
    
endmodule
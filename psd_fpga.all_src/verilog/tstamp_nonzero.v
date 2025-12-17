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
    
// Pico in control signal, stays high until event is completely read out. goes high once per event. 
    input       pico_in_control,
    
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

// We want to make sure that intb_ena be active for just one clock cycle
// Use a small FSM to handle this
   
    parameter   WAIT_STOP_HIGH = 2'd0 ;
    parameter   ISSUE_ENA = 2'd1 ;
    parameter   ASSERT_RDY = 2'd2 ;
    parameter   WAIT_STOP_LOW = 2'd3 ;

    reg         [1:0] present_state ;
    reg         [1:0] next_state ;
       
// Present state register       

    always @(posedge mclk) begin
        if (mrst == 1'b1) present_state <= 2'd0 ;
        else present_state <= next_state ;
    end

// FSM combinational logic

    reg     stop_ena ;
    reg     tstamp_rdy_reg ;
    
    always @(*) begin
        stop_ena = 1'b0 ;
        tstamp_rdy_reg = 1'b0 ;
        case (present_state) 
            WAIT_STOP_HIGH: begin
                                if (common_stop_sync == 1'b0) next_state = WAIT_STOP_HIGH ;
                                else next_state = ISSUE_ENA ;
                            end
            ISSUE_ENA:      begin
                                stop_ena = 1'b1 ;
                                next_state = ASSERT_RDY ;
                            end
            ASSERT_RDY:     begin
                                tstamp_rdy_reg = 1'b1 ;
                                next_state = WAIT_STOP_LOW ;
                            end 
            WAIT_STOP_LOW:  begin
                                if (pico_in_control == 1'b1) begin
                                    next_state = WAIT_STOP_LOW ;
                                    tstamp_rdy_reg = 1'b1 ;
                                end else begin
                                    next_state = WAIT_STOP_HIGH ;
                                end 
                            end    
            default:        next_state = WAIT_STOP_HIGH ;         
        endcase
    end               

// When intb_ena goes high, let's transfer the counter value to tstamp_reg
// FSM guarantees that intb_ena stays high for only one tstamp_clk period!
                         
    reg     [47:0] tstamp_reg ;
    always @(posedge mclk) begin
        if (mrst == 1'b1) tstamp_reg <= 48'd0 ;
        else if (stop_ena == 1'b1) tstamp_reg <= tstamp_counter_sync ;
    end
        
    assign tstamp = tstamp_reg ;
    assign tstamp_rdy = tstamp_rdy_reg ;
    
endmodule

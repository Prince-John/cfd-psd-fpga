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

    output      reg     tstamp_rdy 
    
) ;
    
// Implement the timestamp counter
// We can reset the counter (synchronous reset)
// Count changes on posedge of tstamp_clk

    reg     [47:0] tstamp_counter ;
    always @(posedge tstamp_clk) begin
        if (tstamp_rst == 1'b1) tstamp_counter <= 48'd0 ;
        else tstamp_counter <= tstamp_counter + 48'd1 ;
    end
   
// We want to make sure that intb_ena be active for just one clock cycle
// Use a small FSM to handle this

    reg         [1:0] present_state ;
    reg         [1:0] next_state ;
    
    parameter   WAIT_INTB_LOW = 2'd0 ;
    parameter   ISSUE_ENA = 2'd1 ;
    parameter   ASSERT_RDY = 2'd2 ;
    parameter   WAIT_INTB_HIGH = 2'd3 ;
 
// Synchronize the tdc_intb signal to mclk
// FSM runs off of mclk

    wire    tdc_intb_sync ;
    synchronizer sync0(.async_in(tdc_intb), .sync_out(tdc_intb_sync), .clk(mclk)) ;
    
// Present state register       

    always @(posedge mclk) begin
        if (mrst == 1'b1) present_state <= 2'd0 ;
        else present_state <= next_state ;
    end

// FSM combinational logic

    reg     intb_ena ;
    always @(*) begin
        intb_ena = 1'b0 ;
        tstamp_rdy = 1'b0 ;
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
                                tstamp_rdy = 1'b1 ;
                                next_state = WAIT_INTB_HIGH ;
                            end 
            WAIT_INTB_HIGH: begin
                                if (tdc_intb_sync == 1'b0) begin
                                    next_state = WAIT_INTB_HIGH ;
                                    tstamp_rdy = 1'b1 ;
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
    assign  tstamp = tstamp_reg ;

// Implement the tdc register (24 bits)
// Any of the three bytes can be parallel loaded"
// We can also reset the entire register!
// We want to shift data out on the negedge of the tdc sclk
// tdc_dout gets shifted into least significant bit

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


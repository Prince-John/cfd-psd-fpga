`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2024 08:41:00 AM
// Design Name: 
// Module Name: adc_interface
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


module adc_interface(
    input   [1:0] adc_sclk,
    input   [7:0] adc_sdo,
    input   adc_reg_reset,
    input   [2:0] adc_mux_sel,
    output  reg  [15:0] adc_reg   
) ;

// **************************************************************
// Insert a bank of 4 ADC registers for PSD chip 0
// They perform serial-to-parallel conversion
// Has asynchronous reset that picoblaze can use to clear register
// ************************************************************

    reg    [15:0] adc_0_reg_a ;
    reg    [15:0] adc_0_reg_b ;    
    reg    [15:0] adc_0_reg_c ;
    reg    [15:0] adc_0_reg_t ;
    
    always @(negedge adc_sclk[0] or posedge adc_reg_reset) begin
        if (adc_reg_reset) begin
            adc_0_reg_a <= 16'd0 ;
            adc_0_reg_b <= 16'd0 ;
            adc_0_reg_c <= 16'd0 ;
            adc_0_reg_t <= 16'd0 ;            
        end else begin
            adc_0_reg_a <= {adc_0_reg_a[14:0], adc_sdo[0]} ;
            adc_0_reg_b <= {adc_0_reg_b[14:0], adc_sdo[1]} ;           
            adc_0_reg_c <= {adc_0_reg_c[14:0], adc_sdo[2]} ;            
            adc_0_reg_t <= {adc_0_reg_t[14:0], adc_sdo[3]} ;            
        end        
	end
    
// *********************************************************
// Insert a bank of 4 ADC registers for PSD chip 1
// They perform serial-to-parallel conversion
// *********************************************************

    reg    [15:0] adc_1_reg_a ;
    reg    [15:0] adc_1_reg_b ;    
    reg    [15:0] adc_1_reg_c ;
    reg    [15:0] adc_1_reg_t ;  
    
    always @(negedge adc_sclk[1] or posedge adc_reg_reset) begin
        if (adc_reg_reset) begin
            adc_1_reg_a <= 16'd0 ;
            adc_1_reg_b <= 16'd0 ;
            adc_1_reg_c <= 16'd0 ;
            adc_1_reg_t <= 16'd0 ;            
        end else begin
            adc_1_reg_a <= {adc_1_reg_a[14:0], adc_sdo[4]} ;
            adc_1_reg_b <= {adc_1_reg_b[14:0], adc_sdo[5]} ;           
            adc_1_reg_c <= {adc_1_reg_c[14:0], adc_sdo[6]} ;            
            adc_1_reg_t <= {adc_1_reg_t[14:0], adc_sdo[7]} ;            
        end        
	end   
	
// **************************************************************
// Implement a MUX to pick what drives the fifo data bus
// Bits 2-4 will select which ADC reg drive fifo
// Port 2 will be the data tag identifier
// **************************************************************

    always @(*) begin   
        case (adc_mux_sel)
            3'd0:   adc_reg = adc_0_reg_a ;
            3'd1:   adc_reg = adc_0_reg_b ;       
            3'd2:   adc_reg = adc_0_reg_c ;        
            3'd3:   adc_reg = adc_0_reg_t ;
            3'd4:   adc_reg = adc_1_reg_a ;
            3'd5:   adc_reg = adc_1_reg_b ;       
            3'd6:   adc_reg = adc_1_reg_c ;        
            3'd7:   adc_reg = adc_1_reg_t ;
        endcase
    end   
     
endmodule

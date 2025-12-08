`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2025 08:17:45 AM
// Design Name: 
// Module Name: synchronizer
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


module synchronizer #(
  parameter NUM_STAGES = 2
) (
  output    sync_out,
  input     async_in,
  input     clk
);
 
 (* ASYNC_REG = "TRUE" *) reg   [NUM_STAGES:1]    sync_reg;
 
  always @ (posedge clk) begin
    sync_reg <= {sync_reg[NUM_STAGES-1:1], async_in};
  end
 
  assign sync_out = sync_reg[NUM_STAGES];
 
endmodule


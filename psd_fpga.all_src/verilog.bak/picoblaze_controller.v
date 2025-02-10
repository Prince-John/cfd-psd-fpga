// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Combines picoblaze with 8 input and 8 output ports
// There are also 2 "special" output ports used to generate
// the FIFO tvalid and tlast signals.
//
// Currently, no use of interrupts and no "sleep"
//
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

module picoblaze_controller  (

// Clock and reset

        input    clk,
        input    reset,
 
 // 8 input ports
        
        input    [7:0] P0_in,
        input    [7:0] P1_in,
        input    [7:0] P2_in,
        input    [7:0] P3_in,  
        input    [7:0] P4_in,
        input    [7:0] P5_in,
        input    [7:0] P6_in,
        input    [7:0] P7_in,  


// 8 output ports
               
        output   reg [7:0] P0_out,
        output   reg [7:0] P1_out,
        output   reg [7:0] P2_out,
        output   reg [7:0] P3_out,
        output   reg [7:0] P4_out,
        output   reg [7:0] P5_out,
        output   reg [7:0] P6_out,
        output   reg [7:0] P7_out,
   
 // FIFO control signals
 
        output   tvalid,
        output   tlast        
    );

// **************************
// PicoBlaze signals
// **************************

    wire	[11:0] address ;
    wire	[17:0]	instruction ;
    wire	bram_enable ;
    wire	[7:0] port_id ;
    wire	[7:0] out_port ;
    reg	    [7:0] in_port ;
    wire	write_strobe ;
    wire	k_write_strobe ;
    wire	read_strobe ;
    wire	interrupt ;          
    wire	interrupt_ack ;
    wire	kcpsm6_sleep ;       
    wire    kcpsm6_reset ;      

// ***********************************************************************************
// When interrupt is to be used then the recommended circuit included below requires 
// the following signal to represent the request made from your system.
//
// wire			int_request;
//
// **********************************************************************************

  assign kcpsm6_sleep = 1'b0 ;
  assign interrupt = 1'b0 ;
 
// ****************************************
// Instantiate the PicoBlaze processor
// *****************************************

    kcpsm6 #(.interrupt_vector(12'h3FF),.scratch_pad_memory_size(64),.hwbuild(8'h00))  processor (
	       .address(address),
	       .instruction(instruction),
	       .bram_enable(bram_enable),
	       .port_id(port_id),
	       .write_strobe(write_strobe),
	       .k_write_strobe(k_write_strobe),
	       .out_port(out_port),
	       .read_strobe(read_strobe),
	       .in_port(in_port),
	       .interrupt(interrupt),
	       .interrupt_ack(interrupt_ack),
	       .reset(reset),
	       .sleep(kcpsm6_sleep),
	       .clk(clk)
    ); 
    
// ****************************************************
// Instantiate the 1024 x 18 bit instruction memory
// ****************************************************

    pico_program program_rom (    				
        .enable(bram_enable),
        .address(address),
        .instruction(instruction),
        .clk(clk)
    );
    
/////////////////////////////////////////////////////////////////////////////////////////
// 8 General Purpose Input Ports. 
/////////////////////////////////////////////////////////////////////////////////////////

    always @ (posedge clk) begin
        case (port_id[2:0]) 
            3'd0 : in_port <= P0_in ;
            3'd1 : in_port <= P1_in ;
            3'd2 : in_port <= P2_in ;
            3'd3:  in_port <= P3_in ;
            3'd4 : in_port <= P4_in ;
            3'd5 : in_port <= P5_in ;
            3'd6 : in_port <= P6_in ;
            3'd7:  in_port <= P7_in ;                 
            default : in_port <= 8'bXXXXXXXX ;  
        endcase
    end
      	
// **************************************
// 8 General Purpose Output Ports
// **************************************

    always @ (posedge clk) begin
        if (write_strobe == 1'b1) begin
            case (port_id[2:0]) 
                3'd0:   P0_out <= out_port ;
                3'd1:   P1_out <= out_port ;
                3'd2:   P2_out <= out_port ;
                3'd3:   P3_out <= out_port ;
                3'd4:   P4_out <= out_port ;
                3'd5:   P5_out <= out_port ;
                3'd6:   P6_out <= out_port ;
                3'd7:   P7_out <= out_port ;                           
                default: P0_out <= out_port ;
            endcase
        end
    end

// *********************************************************************
// Ports 254 and 255 are not really ports
// It's just the writing (regardless of value) that will generate the control
// signals we need
// ***********************************************************************

    wire    port_is_254 ;
    assign  port_is_254 = (port_id[7:0] == 8'd254) ? 1'b1 : 1'b0 ;
    
    wire    port_is_255 ;
    assign  port_is_255 = (port_id[7:0] == 8'd255) ? 1'b1 : 1'b0 ;
 
// *********************************************************************   
// When we write to port 254 we want to generate just tvalid 
// When we write to port 25 we want to genrate tvalid and tlast
// ********************************************************************

    assign  tvalid = (port_is_254 | port_is_255) & write_strobe ;
    assign  tlast = port_is_255 & write_strobe ;
     
endmodule



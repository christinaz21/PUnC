//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Add more ports here
	// SKIPPED DOING DEBUG STUFF

	output PC_data_sel, //PROBABLY CHANGE LENGTH OF SELECTS
	output PC_add_sel,
	output PC_ld,
	output PC_clr,
	output PC_inc,
	output IR_ld,
	output [1:0] addr_MEM_sel,
	output w_en_MEM, //CHECK
	output [1:0] w_RF_sel,
	output rst_MEM,
	output wire [2:0] r_addr_0_RF,
	output wire [2:0] r_addr_1_RF,
	output wire [2:0] r_addr_2_RF,
	output wire [2:0] w_addr_RF,
	output w_en_RF,
	output rst_RF,
	input sext_data,
	input A_sel,
	input B_sel,
	input ALU_sel,
	input NZP_sel, 
	input N_ld,
	input Z_ld,
	input P_ld,
	input store_ld, //DIDN'T CAPITALIZE
);

	// FSM States
	// Add your FSM State values as localparams here
	localparam STATE_FETCH     = 3'd0;
	localparam STATE_DECODE		= 3'd1;
	localparam STATE_EXECUTE_1	= 3'd2;
	localparam STATE_EXECUTE_2 	= 3'd3;
	localparam STAET_HALT		= 3'd4; // is it supposed to be 2'd3 idk how decimal works
	
	// fetch, decode, execute, halt

	// State, Next State
	reg [2:0] state, next_state;
	// ir[`OC]
	// Output Combinational Logic
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)

		// Add your output logic here
		case (state)
			STATE_FETCH: begin
				
			end
			STATE_DECODE: begin

			end
			STATE_EXECUTE: begin

			end
			STATE_HALT: begin

			end
		endcase
		//
		//	end
		//	STATE_EXECUTE: begin
		//		case()

		//endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Set default value for next state here
		next_state = state;

		// Add your next-state logic here
		case (state)
			STATE_FETCH: begin
				next_state = STATE_DECODE; 
			end
			STATE_DECODE: begin
				next_state = STATE_EXECUTE_1; 
				// check if opcode is halt then go to halt
			end
			STATE_EXECUTE_1: begin
				next_state = STATE_FETCH; 
				//in execute see if second stage or back to fetch
			end
			STATE_EXECUTE_2: begin
				next_state = STATE_FETCH;
			end
			// Do you even need to have this
			STATE_HALT: begin
				next_state = state;
			end
		endcase
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			// Add your initial state here
			state <= STATE_FETCH;
		end
		else begin
			// Add your next state here
			state <= next_state;
		end
	end

endmodule

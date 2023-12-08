//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Add more ports here

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

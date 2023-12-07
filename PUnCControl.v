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
	// localparam STATE_FETCH     = X'd0;
	
	// fetch, decode, execute, halt

	// State, Next State
	// reg [X:0] state, next_state;
	ir[`OC]
	// Output Combinational Logic
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)

		// Add your output logic here
		//case (state)
		//	STATE_FETCH: begin
		//
		//	end
			STATE_EXECUTE: begin
				case()

		//endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Set default value for next state here
		// next_state = state;

		// Add your next-state logic here
		//case (state)
		//	STATE_FETCH: begin
		//		next_state = decode; 
		//	end
		//in decode decide whether execute or halt
		//in execute see if second stage or back to fetch
		//second execute go back to fetch
		//endcase
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

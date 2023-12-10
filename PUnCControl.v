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

	output reg PC_data_sel, //PROBABLY CHANGE LENGTH OF SELECTS
	output reg PC_add_sel,
	output reg PC_ld,
	output reg PC_clr,
	output reg PC_inc,
	output reg IR_ld,
	output reg [1:0] addr_MEM_sel,
	output reg w_en_MEM, //CHECK
	output reg [1:0] w_RF_sel,
	output reg rst_MEM,
	output reg  [2:0] r_addr_0_RF,
	output reg  [2:0] r_addr_1_RF,
	output reg  [2:0] r_addr_2_RF,
	output reg  [2:0] w_addr_RF,
	output reg w_en_RF,
	output reg rst_RF,
	output reg sext_data,
	output reg A_sel,
	output reg B_sel,
	output reg ALU_sel,
	output reg NZP_sel, 
	output reg N_ld,
	output reg Z_ld,
	output reg P_ld,
	output reg store_ld, //DIDN'T CAPITALIZE

	input [15:0] IR, // WHY IS THIS LOCAL AND NOT AN OUTPUT
	input [15:0] RF_data,//IS TYPE RIGHT
	input n,
	input z,
	input p
);

	// FSM States
	// Add your FSM State values as localparams here
	localparam STATE_FETCH     = 3'd0;
	localparam STATE_DECODE		= 3'd1;
	localparam STATE_EXECUTE_1	= 3'd2;
	localparam STATE_EXECUTE_2 	= 3'd3;
	localparam STATE_HALT		= 3'd4; // is it supposed to be 2'd3 idk how decimal works
	
	// Opcode defs
	`define ADD 4'b0001
	`define AND 4'b0101
	`define BR	4'b0000
	`define JMP 4'b1100
	`define JSR 4'b0100
	`define LD	4'b0010
	`define LDI	4'b1010	// do i have to have state 1 and 2 for this
	`define LDR 4'b0110
	`define LEA 4'b1110
	`define NOT 4'b1001
	`define RET 4'b1100
	`define ST 	4'b0011
	`define STI 4'b1011	// same for this
	`define STR	4'b0111	
	`define HALT 4'b1111

	// MUX defs
	`define PC_ADD	1'b0
	`define BASE_R	1'b1
	
	`define PC_addr 2'b00
	`define PC_ALU_addr 2'b01
	`define PC_store_addr 2'b10

	`define PC_DATA 2'b00
	`define MEM_DATA 2'b01
	`define ALU_DATA 2'b10

	`define PCoffset11 1'b0
	`define PCoffset9  1'b1

	`define ALU_PC 1'b0
	`define ALU_RF_0_DATA 1'b1

	`define ALU_RF_1_DATA 1'b0
	`define ALU_sext 1'b1

	`define NZP_ALU_RESULT 1'b0
	`define NZP_MEM_DATA   1'b1

	`define ADD_op 2'b00
	`define AND_op 2'b01
	`define PASS_A_op 2'b10
	`define NOT_op 2'b11
	// fetch, decode, execute, halt

	
	// State, Next State
	reg [2:0] state, next_state;
	wire [3:0] op;
	wire [15:0] sext5;
	wire [15:0] sext9;
	wire [15:0] sext6;
	
	assign op = IR[15:12];
	assign sext5 = {{7{IR[4]}},  IR[4:0] };
	assign sext9 = {{3{IR[8]}},  IR[8:0] };
	assign sext6 = {{6{IR[5]}},  IR[5:0] };
	
	// ir[`OC]
	// Output Combinational Logic
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)
		w_en_MEM = 0;
		addr_MEM_sel = 0; //X 
		rst_MEM = 0;
		w_RF_sel = 0; //X
		w_en_RF = 0;
		w_addr_RF = 0; //X
		// r_addr_2_RF = // THIS IS JUST DEBUG DATA, ALWAYS SAME, DON"T INCLUDE
		r_addr_0_RF = 0; //X
		r_addr_1_RF = 0; //X
		rst_RF = 0;
		sext_data = 0; //X
		A_sel = 0; //X
		B_sel = 0; //X
		ALU_sel = 0; //X
		IR_ld = 0;
		PC_inc = 0; 
		PC_clr = 0;
		PC_ld = 0; 
		PC_add_sel = 0; //X
		PC_data_sel = 0; //X
		store_ld = 0; 
		NZP_sel = 0; //x
		N_ld = 0; //x
		Z_ld = 0; //x
		P_ld = 0; //x

		// Add your output logic here
		case (state)
			STATE_FETCH: begin
				IR_ld = 1;
				PC_inc = 1; 
			end
			STATE_DECODE: begin
				// ARE TEHRE ANY CHNAGES HERE?
			end
			STATE_EXECUTE_1: begin
				case(op)
					`ADD: begin
						w_RF_sel = `ALU_DATA;
						w_en_RF = 1;
						w_addr_RF = IR[11:9];
						r_addr_0_RF = IR[8:6];
						r_addr_1_RF = IR[2:0];
						sext_data = sext5;
						A_sel = `ALU_RF_0_DATA;
						B_sel = IR[5];
						ALU_sel = `ADD_op;
						NZP_sel = `NZP_ALU_RESULT;
					end
					`AND: begin
						w_RF_sel = `ALU_DATA;
						w_en_RF = 1;
						w_addr_RF = IR[11:9];
						r_addr_0_RF = IR[8:6];
						r_addr_1_RF = IR[2:0];
						sext_data = sext5;
						A_sel = `ALU_RF_0_DATA;
						B_sel = IR[5];
						ALU_sel = `AND_op;
						NZP_sel = `NZP_ALU_RESULT;
					end
					`BR: begin
						PC_ld = (IR[11] & n) | (IR[10] & z) | (IR[9] & p);
						PC_add_sel = `PCoffset9;
						PC_data_sel = `PC_ADD;
					end
					`JMP: begin
						r_addr_0_RF = IR[8:6];
						A_sel = `ALU_RF_0_DATA;
						ALU_sel = `PASS_A_op;
						PC_ld = 1;
						PC_data_sel = `BASE_R;
					end
					`JSR: begin
						w_RF_sel = `PC_DATA;
						w_en_RF = 1;
						w_addr_RF = 111;
						r_addr_0_RF = IR[8:6];
						A_sel = `ALU_RF_0_DATA;
						ALU_sel = `PASS_A_op;
						PC_ld = 1;
						PC_add_sel = `PCoffset11;
						if (IR[11]) begin
							PC_data_sel = `PC_ADD;
						end
						else begin
							PC_data_sel = `BASE_R;
						end
					end
					`LD: begin
						addr_MEM_sel = `PC_ALU_addr;
						w_RF_sel = `MEM_DATA;
						w_en_RF = 1;
						w_addr_RF = IR[11:9];
						sext_data = sext9;
						A_sel = `ALU_PC;
						B_sel = 1;
						ALU_sel = `ADD_op;
						store_ld = 1;
						NZP_sel = `NZP_MEM_DATA;
					end
					`LDI: begin
						addr_MEM_sel = `PC_ALU_addr;
						sext_data = sext9;
						A_sel = `ALU_PC;
						B_sel = 1;
						ALU_sel = `ADD_op;
						store_ld = 1;
					end
					`LDR: begin
						addr_MEM_sel = `PC_ALU_addr;
						w_RF_sel = `MEM_DATA;
						w_en_RF = 1;
						w_addr_RF = IR[11:9];
						r_addr_0_RF = IR[8:6];
						sext_data = sext6;
						A_sel = `ALU_RF_0_DATA;
						B_sel = 1;
						ALU_sel = `ADD_op;
						NZP_sel = `NZP_MEM_DATA;
					end
					`LEA: begin
						w_RF_sel = `ALU_DATA;
						w_en_RF = 1;
						w_addr_RF = IR[11:9];
						sext_data = sext9;
						A_sel = `ALU_PC;
						B_sel = 1;
						ALU_sel = `ADD_op;
						NZP_sel = `NZP_ALU_RESULT;
					end
					`NOT: begin
						w_RF_sel = `ALU_DATA;
						w_en_RF = 1;
						w_addr_RF = IR[11:9];
						r_addr_0_RF = IR[8:6];
						A_sel = `ALU_RF_0_DATA;
						ALU_sel = `NOT_op;
						NZP_sel = `NZP_ALU_RESULT;
					end
					`RET: begin
						r_addr_0_RF = IR[8:6];
						A_sel = `ALU_RF_0_DATA;
						ALU_sel = `PASS_A_op;
						PC_ld = 1;
						PC_data_sel = `BASE_R;
					end
					`ST: begin
						w_en_MEM = 1;
						addr_MEM_sel = `PC_ALU_addr;
						r_addr_1_RF = IR[11:9];
						sext_data = sext9;
						A_sel = `ALU_PC;
						B_sel = 1;
						ALU_sel = `ADD_op;
					end
					`STI: begin
						addr_MEM_sel = `PC_ALU_addr;
						sext_data = sext9;
						A_sel = `ALU_PC;
						B_sel = 1; 
						ALU_sel = `ADD_op;
						store_ld = 1;
					end
				endcase
			end
			STATE_EXECUTE_2: begin

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

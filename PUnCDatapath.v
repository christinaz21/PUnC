//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================

`include "Memory.v"
`include "RegisterFile.v"
`include "Defines.v"

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

module PUnCDatapath(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// DEBUG Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data,

	// Add more ports here
	input PC_data_sel, //PROBABLY CHANGE LENGTH OF SELECTS
	input PC_add_sel,
	input PC_ld,
	input PC_clr,
	input PC_inc,
	input IR_ld,
	input [1:0] addr_MEM_sel,
	input w_en_MEM, //CHECK
	input [1:0] w_RF_sel,
	input rst_MEM,
	input wire [2:0] r_addr_0_RF,
	input wire [2:0] r_addr_1_RF,
	input wire [2:0] r_addr_2_RF,
	input wire [2:0] w_addr_RF,
	input w_en_RF,
	input rst_RF,
	input sext_data,
	input A_sel,
	input B_sel,
	input ALU_sel,
	input NZP_sel, 
	input N_ld,
	input Z_ld,
	input P_ld,
	input store_ld, //DIDN'T CAPITALIZE

	// output PC, // WHY IS THIS LOCAL AND NOT AN OUTPUT
	// output IR, // WHY IS THIS LOCAL AND NOT AN OUTPUT
	output reg [15:0] RF_data //IS TYPE RIGHT
);

	// Local Registers
	reg  [15:0] pc;
	reg  [15:0] ir;

	// Declare other local wires and registers here
	reg  [15:0] memAddrMux;
	wire [15:0] rd1RF;
	wire [15:0] rd0RF;
	reg  [15:0] RFdataMux;
	reg  [15:0] add_output;
	reg  [15:0] store;
	reg  [15:0] ALU_A;
	reg  [15:0] ALU_B;
	reg  [15:0] cmp_input;
	// Assign PC debug net
	assign pc_debug_data = pc;


	//----------------------------------------------------------------------
	// Memory Module
	//----------------------------------------------------------------------

	// 1024-entry 16-bit memory (connect other ports)
	Memory mem(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (memAddrMux),
		.r_addr_1 (mem_debug_addr),
		.w_addr   (memAddrMux),
		.w_data   (rd1RF),
		.w_en     (w_en_MEM),
		.r_data_0 (mem_debug_addr),
		.r_data_1 (mem_debug_data)
	);

	//----------------------------------------------------------------------
	// Register File Module
	//----------------------------------------------------------------------

	// 8-entry 16-bit register file (connect other ports)
	RegisterFile rfile(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (r_addr_0_RF),
		.r_addr_1 (r_addr_1_RF),
		.r_addr_2 (rf_debug_addr),
		.w_addr   (w_addr_RF),
		.w_data   (RFdataMux),
		.w_en     (w_en_RF),
		.r_data_0 (rd0RF),
		.r_data_1 (rd1RF),
		.r_data_2 (rf_debug_data)
	);

	//----------------------------------------------------------------------
	// Add all other datapath logic here
	//----------------------------------------------------------------------
	wire  [15:0] pc_ld_data;
	assign pc_ld_data = (PC_data_sel == `PC_ADD) ? add_output :
				       (PC_data_sel == `BASE_R) ? RF_data;

	/* case (PC_data_sel)
			`PC_ADD: begin
				pc = add_output;
			end
			`BASE_R: begin
				pc = RF_data;
			end
		endcase */
	// use non-blockinh assignment in here
	always @(posedge clk) begin // check over what is clk triggered, whats not
		// PC data select mux
		case (PC_data_sel)
			`PC_ADD: begin
				pc <= add_output;
			end
			`BASE_R: begin
				pc <= RF_data;
			end
		endcase

		// Calculating PC_ADD
		case(PC_add_sel)
			`PCoffset11: begin
				add_output = pc + IR[10:0] - 1; //SEXT THIS
			end
			`PCoffset9: begin
				add_output = pc + IR[8:0] - 1; //SEXT THIS
			end
		endcase

		// Mem read/write address
		if (PC_ld == 1) begin
			case (addr_MEM_sel)
				`PC_addr: begin
					memAddrMux = pc;
				end
				`PC_ALU_addr: begin
					memAddrMux = RF_data;
				end
				`PC_store_addr: begin	
					memAddrMux = store;
				end
			endcase
		end
		
		// RF w data selector mux
		case (w_RF_sel)
			`PC_DATA: begin
				RFdataMux = pc;
			end
			`MEM_DATA: begin
				RFdataMux = memAddrMux;
			end
			`ALU_DATA: begin
				RFdataMux = RF_data;
			end
		endcase

		// ALU A mux 
		case (A_sel)
			`ALU_PC: begin
				ALU_A = pc;
			end
			`ALU_RF_0_DATA: begin
				ALU_A = rd0RF;
			end
		endcase

		// ALU B mux
		case (B_sel)
			`ALU_RF_1_DATA: begin
				ALU_B = rd1RF;
			end
			`ALU_sext: begin
				ALU_B = sext_data; //SEXT THE DATA?
			end
		endcase
		
		// NZP mux
		case (NZP_sel)
			`NZP_ALU_RESULT: begin
				cmp_input = RF_data;
			end
			`NZP_MEM_DATA: begin
				cmp_input = rd0RF;
			end
		endcase

		// NZP comparator
		if(cmp_input < 0 && N_ld) begin //is the signededness right?
			//IS THIS SUPPOSED TO BE SETTING AN OUTPUT
		end
		if(cmp_input == 0 && Z_ld) begin //is the signededness right?
			//IS THIS SUPPOSED TO BE SETTING AN OUTPUT
		end
		if(cmp_input > 0 && P_ld) begin //is the signededness right?
			//IS THIS SUPPOSED TO BE SETTING AN OUTPUT
		end

		// ALU
		case (ALU_sel)
			`AND_op: begin
				RF_data = ALU_A & ALU_B;
			end
			`ADD_op: begin
				RF_data = ALU_A + ALU_B;
			end
			`PASS_A_op: begin
				RF_data = ALU_A;
			end
			`NOT_op: begin
				RF_data = !(ALU_A);
			end
		endcase

		if(store_ld == 1) begin
			store = RF_data;
		end

		// PC incrementing
		if(PC_inc == 1) begin
			pc <= pc + 1;
		end
		if(PC_clr == 1) begin
			pc <= 0;
		end
		
		if(IR_ld) begin
			
		end

	end

	always @(*) begin //do the muxes go here or in the other
		
	end

endmodule

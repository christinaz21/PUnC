//==============================================================================
// Module for PUnC LC3 Processor
//==============================================================================

`include "PUnCDatapath.v"
`include "PUnCControl.v"

module PUnC(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Debug Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data
);

	wire PC_data_sel; //PROBABLY CHANGE LENGTH OF SELECTS
	wire PC_add_sel;
	wire PC_ld;
	wire PC_clr;
	wire PC_inc;
	wire IR_ld;
	wire [1:0] addr_MEM_sel;
	wire w_en_MEM;
	wire [1:0] w_RF_sel;
	wire rst_MEM;
	wire  [2:0] r_addr_0_RF;
	wire  [2:0] r_addr_1_RF;
	wire  [2:0] r_addr_2_RF;
	wire  [2:0] w_addr_RF;
	wire w_en_RF;
	wire rst_RF;
	wire [15:0] sext_data;
	wire A_sel;
	wire B_sel;
	wire [1:0] ALU_sel;
	wire NZP_sel; 
	wire N_ld;
	wire Z_ld;
	wire P_ld;
	wire store_ld;

	wire [15:0] IR; // WHY IS THIS LOCAL AND NOT AN OUTPUT
	wire [15:0] RF_data;
	wire n;
	wire z;
	wire p;
	//----------------------------------------------------------------------
	// Interconnect Wires
	//----------------------------------------------------------------------

	// Declare your wires for connecting the datapath to the controller here

	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl ctrl(
		.clk             (clk),
		.rst             (rst),

		// Add more ports here
		.PC_data_sel(PC_data_sel),
		.PC_add_sel(PC_add_sel),
		.PC_ld(PC_ld),
		.PC_clr(PC_clr),
		.PC_inc(PC_inc),
		.IR_ld(IR_ld),
		.addr_MEM_sel(addr_MEM_sel),
		.w_en_MEM(w_en_MEM),
		.w_RF_sel(w_RF_sel),
		.rst_MEM(rst_MEM),
		.r_addr_0_RF(r_addr_0_RF),
		.r_addr_1_RF(r_addr_1_RF),
		.r_addr_2_RF(r_addr_2_RF),
		.w_addr_RF(w_addr_RF),
		.w_en_RF(w_en_RF),
		.rst_RF(rst_RF),
		.sext_data(sext_data),
		.A_sel(A_sel),
		.B_sel(B_sel),
		.ALU_sel(ALU_sel),
		.NZP_sel(NZP_sel), 
		.N_ld(N_ld),
		.Z_ld(Z_ld),
		.P_ld(P_ld),
		.store_ld(store_ld), //DIDN'T CAPITALIZE

		.IR(IR), // WHY IS THIS LOCAL AND NOT AN OUTPUT
		.RF_data(RF_data),//IS TYPE RIGHT
		.n(n),
		.z(z),
		.p(p)
	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath dpath(
		.clk             (clk),
		.rst             (rst),

		.mem_debug_addr   (mem_debug_addr),
		.rf_debug_addr    (rf_debug_addr),
		.mem_debug_data   (mem_debug_data),
		.rf_debug_data    (rf_debug_data),
		.pc_debug_data    (pc_debug_data),

		// Add more ports here
		.PC_data_sel(PC_data_sel),
		.PC_add_sel(PC_add_sel),
		.PC_ld(PC_ld),
		.PC_clr(PC_clr),
		.PC_inc(PC_inc),
		.IR_ld(IR_ld),
		.addr_MEM_sel(addr_MEM_sel),
		.w_en_MEM(w_en_MEM),
		.w_RF_sel(w_RF_sel),
		.rst_MEM(rst_MEM),
		.r_addr_0_RF(r_addr_0_RF),
		.r_addr_1_RF(r_addr_1_RF),
		.r_addr_2_RF(r_addr_2_RF),
		.w_addr_RF(w_addr_RF),
		.w_en_RF(w_en_RF),
		.rst_RF(rst_RF),
		.sext_data(sext_data),
		.A_sel(A_sel),
		.B_sel(B_sel),
		.ALU_sel(ALU_sel),
		.NZP_sel(NZP_sel), 
		.N_ld(N_ld),
		.Z_ld(Z_ld),
		.P_ld(P_ld),
		.store_ld(store_ld), //DIDN'T CAPITALIZE

		.IR(IR), // WHY IS THIS LOCAL AND NOT AN OUTPUT
		.RF_data(RF_data),//IS TYPE RIGHT
		.n(n),
		.z(z),
		.p(p)
	);

endmodule

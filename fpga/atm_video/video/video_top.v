// Pentevo project (c) NedoPC 2010
//
// top module for video output.

module video_top(

	input  wire        clk, // 28 MHz clock


	// external video outputs
	output wire [ 1:0] vred,
	output wire [ 1:0] vgrn,
	output wire [ 1:0] vblu,
	output wire        vhsync,
	output wire        vvsync,
	output wire        vcsync,


	// aux video inputs
	input  wire [ 5:0] border, // border color, RrGgBb


	// config inputs
	input  wire [ 1:0] pent_vmode, // 2'b00 - standard ZX
	                               // 2'b01 - hardware multicolor
	                               // 2'b10 - pentagon 16 colors
	                               // 2'b11 - not defined yet

	input  wire [ 2:0] atm_vmode,  // 3'b011 - zx modes (pent_vmode is active)
	                               // 3'b010 - 640x200 hardware multicolor
	                               // 3'b000 - 320x200 16 colors
	                               // 3'b110 - 80x25 text mode
	                               // 3'b??? (others) - not defined yet

	input  wire        scr_page,   // screen page (bit 3 of 7FFD)

	input  wire        vga_on,     // vga mode ON - scandoubler activated


	// memory synchronization inputs
	input  wire        cend,
	input  wire        pre_cend,


	// memory arbiter video port connection
	input  wire        varb_strobe,
	input  wire        varb_next,
	input  wire [20:0] varb_addr,
	input  wire [15:0] varb_data,
	output wire [ 1:0] varb_bw,
	output wire        varb_go
);



endmodule


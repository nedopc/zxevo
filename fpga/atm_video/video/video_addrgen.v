`include "../include/tune.v"

// Pentevo project (c) NedoPC 2011
//
// address generation module for video data fetching

module video_addrgen(

	input  wire        clk, // 28 MHz clock


	output reg  [20:0] video_addr, // DRAM arbiter signals
	input  wire        video_next, //


	input  wire        fetch_start, // some sync signals as well
	input  wire        line_start,  //
	input  wire        int_start,   //


	input  wire        scr_page, // which screen to use


	input  wire        mode_atm_n_pent, // decoded modes
	input  wire        mode_zx,         //
	input  wire        mode_p_16c,      //
	input  wire        mode_p_hmclr,    //
	                                    //
	input  wire        mode_a_hmclr,    //
	input  wire        mode_a_16c,      //
	input  wire        mode_a_text      //

);




	wire line_init, frame_init;

	wire next_addr, next_count;


	assign next_addr = video_next | fetch_start;
	assign next_count = video_next;// | fetch_start; // to let addresses propagate from counter to video_addr register

	assign line_init  = line_start;
	assign frame_init = int_start;




	reg [15:0] ctr;



	// currently only single videomode is supported - just to test the
	// idea and make everything work before adding modes


	always @(posedge clk)
	if( frame_init )
	begin
		ctr <= 1;
	end
	else if( next_count )
	begin
		ctr <= ctr + 1;
	end
// zx mode:
// [0] - attr or pix
// [4:1] - horiz pos 0..15 (words)
// [12:5] - vert pos



	wire [20:0] addr_zx;
	wire [11:0] addr_zx_pix;
	wire [11:0] addr_zx_attr;


	assign addr_zx_pix  = { ctr[12:11], ctr[7:5], ctr[10:8], ctr[4:1] };
	assign addr_zx_attr = { 3'b110, ctr[12:8], ctr[4:1] };

	assign addr_zx = { 6'b000001, scr_page, 2'b10, ( ctr[0] ? addr_zx_attr : addr_zx_pix ) };


	always @(posedge clk) if( next_addr )
	begin
		video_addr <= addr_zx;
	end


endmodule


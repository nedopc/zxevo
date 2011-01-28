`include "../include/tune.v"

// Pentevo project (c) NedoPC 2011
//
// address generation module for video data fetching

module video_addrgen(

	input  wire        clk, // 28 MHz clock


	output reg  [20:0] video_addr, // DRAM arbiter signals
	input  wire        video_next, //

	input  wire        fetch_start, // some sync signal as well


	input  wire        mode_atm_n_pent, // decoded modes
	input  wire        mode_zx,         //
	input  wire        mode_p_16c,      //
	input  wire        mode_p_hmclr,    //
	input  wire        mode_a_hmclr,    //
	input  wire        mode_a_16c,      //
	input  wire        mode_a_text,     //

	forgot something else here ...

);











endmodule


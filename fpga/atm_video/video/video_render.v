`include "../include/tune.v"

// Pentevo project (c) NedoPC 2011
//
// renders fetched video data to the pixels

module video_render(

	input  wire        clk, // 28 MHz clock


	input  wire [63:0] pic_bits, // video data from fetcher

	input  wire        fetch_sync, // synchronizes pixel rendering


	output wire [ 3:0] zxcolor, // output pixel


	input  wire        mode_atm_n_pent, // decoded modes
	input  wire        mode_zx,         //
	input  wire        mode_p_16c,      //
	input  wire        mode_p_hmclr,    //
	                                    //
	input  wire        mode_a_hmclr,    //
	input  wire        mode_a_16c,      //
	input  wire        mode_a_text      //
);

	// fetched data divided in bytes
	wire [7:0] bits [0:7];

	assign bits[0] = pic_bits[ 7:0 ];
	assign bits[1] = pic_bits[15:8 ];
	assign bits[2] = pic_bits[23:16];
	assign bits[3] = pic_bits[31:24];
	assign bits[4] = pic_bits[39:32];
	assign bits[5] = pic_bits[47:40];
	assign bits[6] = pic_bits[55:48];
	assign bits[7] = pic_bits[63:56];



	// !!WARNING!! - currently for 7mhz pixels only
	reg [3:0] pixnum;

	always @(posedge clk) if( cend )
		if( fetch_sync )
			pixnum <= 0;
		else
			pixnum <= pixnum + 1;


	// currently only zx-6912 mode is supported!
	wire [3:0] pix0, pix1, zxcolor;
	wire [7:0] pixbyte, attrbyte;

	assign attrbyte = bits[ { 2'b01, pixnum[3] } ];

	assign pix0 = { attrbyte[6], attrbyte[5:3] };
	assign pix1 = { attrbyte[6], attrbyte[2:0] };

	assign pixbyte = bits[ { 2'b00, pixnum[3] } ];

	assign zxcolor = ( pixbyte[~pixnum[2:0]] ^ (flash & attrbyte[7]) ) ? pix1 : pix0;



endmodule


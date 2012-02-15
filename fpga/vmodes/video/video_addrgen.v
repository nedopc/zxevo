`include "../include/tune.v"

// Pentevo project (c) NedoPC 2011-2012
//
// address generation module for video data fetching

module video_addrgen(

	input  wire        clk, // 28 MHz clock


	output reg  [20:0] video_addr,   // DRAM arbiter signals
	input  wire        video_next,   //
	input  wire        video_strobe, //
	input  wire [15:0] video_data,   //
	
	input  wire [ 1:0] decoded_bw, // decoded BW comes from video_modedecode
	output reg  [ 1:0] video_bw,   // resulting BW, which will vary in new videomode (mode #4)

	input  wire        line_start, // some video sync signals
	input  wire        int_start,  //
	input  wire        vpix,       //

	input  wire        scr_page, // which screen page to use


	input  wire        mode_atm_n_pent, // decoded modes
	input  wire        mode_zx,         //
	input  wire        mode_p_16c,      //
	input  wire        mode_p_hmclr,    //
	                                    //
	input  wire        mode_a_hmclr,    //
	input  wire        mode_a_16c,      //
	input  wire        mode_a_text,     //
	input  wire        mode_a_txt_1page,//
	                                    //
	input  wire        mode_new,        //
	
	output wire [ 2:0] typos, // Y position in text mode symbols
	
	
);

	wire   mode_ag;
	assign mode_ag = mode_a_16c | mode_a_hmclr;

	
	wire [20:0] video_addr_unreg;
	reg  [20:0] video_addr;
	reg         video_addr14;

	

	wire line_init, frame_init;

	wire gnext,tnext,ldaddr;

	reg line_start_r;
	reg frame_init_r;
	reg line_init_r;

	always @(posedge clk)
		line_start_r <= line_start;

	assign line_init  = line_start_r & vpix;
	assign frame_init = int_start;

	reg [13:0] gctr;

	reg [7:0] tyctr; // text Y counter
	reg [6:0] txctr; // text X counter


	
	wire [20:0] addr_zx;   // standard zx mode
	wire [20:0] addr_phm;  // pentagon hardware multicolor
	wire [20:0] addr_p16c; // pentagon 16c

	wire [20:0] addr_ag; // atm gfx: 16c (x320) or hard multicolor (x640) - same sequence!

	wire [20:0] addr_at; // atm text

	wire [11:0] addr_zx_pix;
	wire [11:0] addr_zx_attr;
	wire [11:0] addr_zx_p16c;




	

	// below are new mode related stuff definition

	localparam LMODE_320_64C = 2'b00; // do not change!
	localparam LMODE_320_DPF = 2'b10; // bit-dependency:
	localparam LMODE_640_TXT = 2'b11; //  bit0 - 320 or 640
	localparam LMODE_640_16C = 2'b01; //  bit1 - 1 or 2 planes


	reg [12:0] nyptr0; // Y pointer for plane 0
	reg [12:0] nyptr1; // Y pointer for plane 1

	reg [ 7:0] nxctr0; // X counter for plane 0
	reg [ 7:0] nxctr1; // X counter for plane 1

	reg [ 1:0] lmode; // line mode

	reg [ 1:0] pal54; // bits 5:4 into palette

	reg [ 2:0] scrleft; // scroll to the left

	reg [ 1:0] plane1_lag; // 0..3 pixels lag for plane 1 over plane 0 in DPF

	wire [20:0] addr_nfetch; // addr for fetching palette data and line descriptors
	wire [20:0] addr_plane0; // addr for fetching plane 0 data
	wire [20:0] addr_plane1; // addr for fetching plane 1 data

	reg [10:0] nfetch_ptr; // pointer for fetching palette and line descriptors:
	                       // we need 256 palette words and 4*200 line descr words,
	                       // total 800+256 = 1056 words

	reg naddr_fetch;  // when appropriate addresses are fetched by new videomode
	reg naddr_plane0; //
	reg naddr_plane1; //

	
	
	
	
	

	always @(posedge clk)
		frame_init_r <= frame_init;

	always @(posedge clk)
		line_init_r <= line_init;


	assign gnext = video_next | frame_init_r;
	assign tnext = video_next | line_init_r;
	assign ldaddr = mode_a_text ? tnext : gnext;

	// gfx counter
	//
	initial gctr <= 0;
	//
	always @(posedge clk)
	if( frame_init )
		gctr <= 0;
	else if( gnext )
		gctr <= gctr + 1;


	// text counters
	always @(posedge clk)
	if( frame_init )
		tyctr <= 8'b0011_0111;
	else if( line_init )
		tyctr <= tyctr + 1;

	always @(posedge clk)
	if( line_init )
		txctr <= 7'b000_0000;
	else if( tnext )
		txctr <= txctr + 1;


	assign typos = tyctr[2:0];


// zx mode:
// [0] - attr or pix
// [4:1] - horiz pos 0..15 (words)
// [12:5] - vert pos

	assign addr_zx_pix  = { gctr[12:11], gctr[7:5], gctr[10:8], gctr[4:1] };

	assign addr_zx_attr = { 3'b110, gctr[12:8], gctr[4:1] };

	assign addr_zx_p16c = { gctr[13:12], gctr[8:6], gctr[11:9], gctr[5:2] };


	assign addr_zx =   { 6'b000001, scr_page, 2'b10, ( gctr[0] ? addr_zx_attr : addr_zx_pix ) };

	assign addr_phm =  { 6'b000001, scr_page, 1'b1, gctr[0], addr_zx_pix };

	assign addr_p16c = { 6'b000001, scr_page, ~gctr[0], gctr[1], addr_zx_p16c };


	assign addr_ag = { 5'b00000, ~gctr[0], scr_page, 1'b1, gctr[1], gctr[13:2] };

	//                           5 or 1     +0 or +2  ~4,0  +0k or +2k
//	assign addr_at = { 5'b00000, ~txctr[0], scr_page, 1'b1, txctr[1], 2'b00, tyctr[7:3], txctr[6:2] };
//	assign addt_et = { 5'b00001,  1'b0    , scr_page, 1'b0, txctr[0], txctr[1], 0, --//00           };

	assign addr_at = { 4'b0000,
	                   mode_a_txt_1page, // if 1page, 8 and 10 pages instead of 5,1 and 7,3
	                   mode_a_txt_1page ? 1'b0 : ~txctr[0], // 5 or 1 pages for usual mode
	                   scr_page,         // actually not used
	                   ~mode_a_txt_1page, // 5,1 (not 4,0) pages for usual mode
	                   mode_a_txt_1page ? txctr[0] : txctr[1], // 0,+2 interleave for even-odd or 0,+1 for 1page
	                   mode_a_txt_1page ? txctr[1] : 1'b0, // sym/attr interleave 0,+1 for 1page
	                   1'b0,
	                   tyctr[7:3],
	                   txctr[6:2]
	                   };




	// addresses for new mode fetches

	assign addr_fetch = { 6'b000010, scr_page, 3'b000, nfetch_ptr }; // page #08 or #0A

	assign addr_plane0 = { nyptr0, nxctr0 };
	assign addr_plane1 = { nyptr1, nxctr1 };


	assign video_addr_unreg =
	                        ( {21{mode_zx     }} & addr_zx     )  |
	                        ( {21{mode_p_16c  }} & addr_p16c   )  |
	                        ( {21{mode_p_hmclr}} & addr_phm    )  |
	                        ( {21{mode_ag     }} & addr_ag     )  |
	                        ( {21{mode_a_text }} & addr_at     )  |
	                        ( {21{naddr_fetch }} & addr_nfetch )  |
	                        ( {21{naddr_plane0}} & addr_plane0 )  |
	                        ( {21{naddr_plane1}} & addr_plane1 )  ;

	initial video_addr <= 0;
	//
	always @(posedge clk) if( ldaddr )
	begin
		{ video_addr[20:15], video_addr14, video_addr[13:0] } <= video_addr_unreg;
	end

	always @(posedge clk)
	if( naddr_plane0 || naddr_plane1 )
	begin
		video_addr[14] <= video_addr14; // 1 cycle lag -- not important (????)
	end
	else
	begin
		video_addr[14] <= scr_page;
	end

endmodule


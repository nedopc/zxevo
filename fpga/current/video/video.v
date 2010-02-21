`include "../include/tune.v"

// PentEvo project (c) NedoPC 2008-2010

module video(

	input clk,

	input init, // one-pulse strobe read at cend==1, initializes phase
				// this is mainly for phasing with CPU clock 3.5/7 MHz

	input cend, // working strobes (7MHz)
	input pre_cend,

	input [5:0] pixel,	// this data has format: { red[1:0], green[1:0], blue[1:0] }
	input [5:0] border, // this data has format: { red[1:0], green[1:0], blue[1:0] }

	output reg vpix, // vertical picture marker: active when there is line with pixels in it,
					 // not just a border. changes with hsync edge
	output reg line_start, // 1 video cycle prior to actual start of visible line
	output reg int_start, // one-shot positive pulse marking beginning of INT for Z80

	input cfg_vga_on,
	input cfg_border320x240,  // border limit 320x240 (640x480 in VGAmode)
	input cfg_border_edge,	  // frame on border edge
	input cfg_hsync_polarity, // H.Sync polarity (0==positive)
	input cfg_vsync_polarity, // V.Sync polarity (0==positive)

	output reg out_hsync,
	output reg out_vsync,
	output reg out_csync,
	output reg [1:0] out_video_r, // to
	output reg [1:0] out_video_g, //   the	   DAC
	output reg [1:0] out_video_b  //	  video

);

//----------------------------------------------------------------------------

//	  localparam HBLNK_BEG	= 9'd00;
	localparam HSYNC_BEG  = 9'd12;
	localparam HSYNC_END  = 9'd45;
	localparam LINE_START = 9'd88;
	localparam SCANIN_BEG = 9'd88;	// when scan-doubler starts pixel storing
//	  localparam HBLNK_END	= 9'd88;
	localparam HMARK1A	  = 9'd89;	// 88+1
	localparam HBL320_END = 9'd108;
	localparam HMARK2A	  = 9'd109; // 108+1
	localparam HPIX_BEG   = 9'd140; // 52 cycles from line_start to pixels beginning
	localparam HPIX_END   = 9'd396;
	localparam HINT_BEG   = 9'd443;
	localparam CSYNC_CUT  = 9'd427;
	localparam HMARK2B	  = 9'd428; // 427+1
	localparam HBL320_BEG = 9'd428;
	localparam HMARK1B	  = 9'd0;	// 447+1
	localparam HPERIOD	  = 9'd448;

	localparam VBLNK_BEG  = 9'd0;
	localparam INT_BEG	  = 9'd0;
	localparam VSYNC_BEG  = 9'd09;	// 8 + задержка изображения на одну строку
	localparam VSYNC_END  = 9'd11;
	localparam VBLNK_END  = 9'd32;
	localparam VMARK1A	  = 9'd33;	// 32+1
	localparam VBL240_END = 9'd56;
	localparam VMARK2A	  = 9'd57;	// 56+1
	localparam VPIX_BEG   = 9'd80;
	localparam VPIX_END   = 9'd272;
	localparam VMARK2B	  = 9'd296; // 295+1
	localparam VBL240_BEG = 9'd296;
	localparam VMARK1B	  = 9'd0;	// 319+1
	localparam VPERIOD	  = 9'd320; // pentagono foreva!

// для АААшного панаса
//	 localparam VSYNC_BEG  = 9'd39;  // 38 + задержка изображения на одну строку
//	 localparam VSYNC_END  = 9'd41;


//	localparam VGA_HSYNC_BEG   = 10'd0;
	localparam VGA_HSYNC_END   = 10'd106;
	localparam VGA_SCANOUT_BEG = 10'd157; // real out on 159 tick
	localparam VGA_HPERIOD	   = 10'd896;

	reg [8:0] hcount;
	reg [8:0] vcount;
	wire [5:0] color;
	reg [9:0] vga_hcount;
	reg [9:0] ptr_in;  // count up from 48 to 786
	reg [9:0] ptr_out; // count up from 48 to 786
	reg pages; // swapping of pages
	reg wr_stb;
	reg [5:0] data_out;
	reg hblank;
	reg vblank;
	reg hsync;
	reg vsync;
	reg csync;
	reg vga_hsync;
	reg scanout_start;
	reg hsync_start; // 1 cycle prior to beginning of hsync: used in frame sync/blank generation
					 // these signals coincide with cend
	reg hint_start; // horizontal position of INT start, for fine tuning
	reg scanin_start;
	reg hpix; // marks gate during which pixels are outting

	reg dysplaying;
	wire mark;

	wire [10:0] wraddr;
	wire [10:0] rdaddr;
	reg [5:0] mem [0:1535];

//----------------------------------------------------------------------------

	always @ (posedge clk)
	begin

		if ( cend )
		begin
			if ( init || (hcount==(HPERIOD-9'd1)) )
				hcount <= 9'd0;
			else
				hcount <= hcount + 9'd1;

			if ( cfg_border320x240 && (hcount==HBL320_BEG) )
				hblank <= 1'b1;
			else if ( hcount==HBL320_END )
				hblank <= 1'b0;

			if ( hcount==HSYNC_BEG )
			begin
				hsync <= 1'b1;
				csync <= 1'b1;
			end
			else if ( hcount==HSYNC_END )
			begin
				hsync <= 1'b0;
				if ( !vsync ) csync <= 1'b0;
			end
			else if ( hcount==CSYNC_CUT )
				csync <= 1'b0;

			if ( hcount==HPIX_BEG )
				hpix <= 1'b1;
			else if ( hcount==HPIX_END )
				hpix <= 1'b0;
		end

		if ( pre_cend )
		begin
			if ( hcount==HSYNC_BEG )  hsync_start  <= 1'b1;
			if ( hcount==LINE_START ) line_start   <= 1'b1;
			if ( hcount==SCANIN_BEG ) scanin_start <= 1'b1;
		end
		else
		begin
			hsync_start  <= 1'b0;
			line_start	 <= 1'b0;
			scanin_start <= 1'b0;
		end

		if ( pre_cend && (hcount==HINT_BEG) )
			hint_start <= 1'b1;
		else
			hint_start <= 1'b0;

		if ( hsync_start )
		begin
			if ( vcount==(VPERIOD-9'd1) )
				vcount <= 9'd0;
			else
				vcount <= vcount + 9'd1;

			if ( vcount==VBLNK_BEG )
				vblank <= 1'b1;
			else if ( cfg_border320x240 && (vcount==VBL240_BEG) )
				vblank <= 1'b1;
			else if ( !cfg_border320x240 && (vcount==VBLNK_END) )
				vblank <= 1'b0;
			else if ( vcount==VBL240_END )
				vblank <= 1'b0;

			if ( vcount==VPIX_BEG )
				vpix <= 1'b1;
			else if ( vcount==VPIX_END )
				vpix <= 1'b0;

			pages <= ~pages;
		end

		if ( (vcount==INT_BEG) && hint_start )
			int_start <= 1'b1;
		else
			int_start <= 1'b0;

		if ( hsync_start )
		begin
			vga_hcount <= 10'd0;
			if ( vcount==VSYNC_BEG )
				vsync <= 1'b1;
			else if ( vcount==VSYNC_END  )
				vsync <= 1'b0;
		end
		else if ( vga_hcount==(VGA_HPERIOD-9'd1) )
			vga_hcount <= 10'd0;
		else
			vga_hcount <= vga_hcount + 9'd1;

		if ( !vga_hcount )
			vga_hsync <= 1'b1;
		else if ( vga_hcount==VGA_HSYNC_END )
			vga_hsync <= 1'b0;

		if ( vga_hcount==VGA_SCANOUT_BEG )
			scanout_start <= 1'b1;
		else
			scanout_start <= 1'b0;

		// write ptr and strobe
		if ( scanin_start )
		begin
			ptr_in[9:8] <= 2'b00;
			ptr_in[5:4] <= 2'b11;
			wr_stb <= 1'b0;
		end
		else
		begin
			if ( ptr_in[9:8]!=2'b11 )
			begin
				wr_stb <= ~wr_stb;
				if ( wr_stb )
					ptr_in <= ptr_in + 10'd1;
			end
		end

		// read ptr
		if ( scanout_start )
		begin
			ptr_out[9:8] <= 2'b00;
			ptr_out[5:4] <= 2'b11;
		end
		else
		begin
			if ( ptr_out[9:8]!=2'b11 )
				ptr_out <= ptr_out + 10'd1;
		end

		dysplaying <= ( cfg_vga_on && ( ptr_out[9:8]!=2'b11 ) ) || ( (~cfg_vga_on) && ( ptr_in[9:8]!=2'b11 ) );

		// read data
		if ( dysplaying )
		begin
			out_video_r[1:0] <= data_out[5:4];
			out_video_g[1:0] <= data_out[3:2];
			out_video_b[1:0] <= data_out[1:0];
		end
		else
		begin
			out_video_r[1:0] <= 2'd0;
			out_video_g[1:0] <= 2'd0;
			out_video_b[1:0] <= 2'd0;
		end

		out_hsync <= cfg_hsync_polarity ^ (cfg_vga_on ? vga_hsync : hsync);
		out_vsync <= cfg_vsync_polarity ^ vsync;
		out_csync <= ~csync;


		if ( wr_stb )
			mem[wraddr] <= color;
		data_out <= mem[rdaddr];

	end // of always@(posedge clk)

	assign color = (hblank | vblank) ? 6'd0 : (  (hpix & vpix) ? pixel : ( mark ? 6'b010101 : border)  );

	assign mark = cfg_border_edge && (border==6'd0) &&
				 (
				   cfg_border320x240
				 ? ( (hcount==HMARK2A) || (hcount==HMARK2B) || (vcount==VMARK2A) || (vcount==VMARK2B) )
				 : ( (hcount==HMARK1A) || (hcount==HMARK1B) || (vcount==VMARK1A) || (vcount==VMARK1B) )
				 );
	assign wraddr = {ptr_in[9:8], pages, ptr_in[7:0]};
	assign rdaddr = { (cfg_vga_on ? ptr_out[9:8] : ptr_in[9:8]), (~pages), (cfg_vga_on ? ptr_out[7:0] : ptr_in[7:0]) };

endmodule

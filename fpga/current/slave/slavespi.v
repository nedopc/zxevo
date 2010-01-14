// (c) 2010 NedoPC
//
// fpga SPI slave device.


`include "../include/tune.v"

module slavespi(

	input  wire fclk,
	input  wire rst_n,

	input  wire spics_n, // avr SPI iface
	output wire spidi,   //
	input  wire spido,   //
	input  wire spick,   //

	input  wire [ 7:0] status_in, // status bits to be shown to avr


	output wire [39:0] kbd_out,
	output wire        kbd_stb,

	output wire [ 7:0] mus_out,
	output wire        mus_xstb,
	output wire        mus_ystb,
	output wire        mus_btnstb,


	output wire       genrst, // positive pulse, causes Z80 reset
	output wire [1:0] rstrom  // number of ROM page to reset to
);

	// re-synchronize SPI
	//
	reg [2:0] spics_n_sync;
	reg [1:0] spido_sync;
	reg [2:0] spick_sync;
	//
	always @(posedge fclk)
	begin
		spics_n_sync[2:0] <= { spics_n_sync[1:0], spics_n };
		spido_sync  [1:0] <= { spido_sync    [0], spido   };
		spick_sync  [2:0] <= { spick_sync  [1:0], spick   };
	end
	//
	wire scs_n = spics_n_sync[1]; // scs_n - synchronized CS_N
	wire sdo   = spido_sync[1];
	wire sck   = spick_sync[1];
	//
	wire scs_n_01 = (~spics_n_sync[2]) &   spics_n_sync[1] ;
	wire scs_n_10 =   spics_n_sync[2]  & (~spics_n_sync[1]);
	//
    wire sck_01 = (~spick_sync[2]) &   spick_sync[1] ;
    wire sck_10 =   spick_sync[2]  & (~spick_sync[1]);


	reg [7:0] regnum; // register number holder

	reg [7:0] shift_out;

	wire [7:0] data_in;



	// register selectors
	wire sel_kbdreg, sel_kbdstb, sel_musxcr, sel_musycr, sel_musbtn, sel_rstreg;

	// keyboard register
	reg [39:0] kbd_reg;

	// mouse register
	reg [7:0] mouse_buf;

	// reset register
	reg [7:0] rst_reg;






`ifdef SIMULATE
	initial
	begin
		rstrom = 2'b00;
		genrst = 1'b0;
	end
`endif


	// register number
	//
	always @(posedge fclk)
	begin
		if( scs_n_01 )
		begin
			regnum <= 8'd0;
		end
		else if( !scs_n && sck_01 )
		begin
			regnum[7:0] <= { sdo, regnum[7:1] };
		end
	end


	// send data to avr
	//
	always @(posedge fclk)
	begin
		if( scs_n_01 || scs_n_10 ) // both edges
		begin
			shift_out <= scs_n ? status_in : data_in;
		end
		else if( sck_01 )
		begin
			shift_out[7:0] <= { 1'b0, shift_out[7:1] };
		end
	end
	//
	assign spidi = shift_out[0];


	// reg number decoding
	//
	assign sel_kbdreg = ( regnum[7] && !regnum[0] ); // $80
	assign sel_kbdstb = ( regnum[7] &&  regnum[0] ); // $81
	//
	assign sel_musxcr = ( regnum[6] && !regnum[1] && !regnum[0] ); // $40
	assign sel_musycr = ( regnum[6] && !regnum[1] &&  regnum[0] ); // $41
	assign sel_musbtn = ( regnum[6] &&  regnum[1]               ); // $42
	//
	assign sel_rstreg = ( regnum[5] ) ; // $20


	// registers data-in
	//
	always @(posedge fclk)
	begin
		if( !scs_n && sel_kbdreg )
			kbd_reg[39:0] <= { sdo, kbd_reg[39:1] };

		if( !scs_n && (sel_musxcr || sel_musycr || sel_musbtn) )
            mouse_buf[7:0] <= { sdo, mouse_buf[7:1] };

		if( !scs_n && sel_rstreg )
			rst_reg[7:0] <= { sdo, rst_reg[7:1] };
	end


	// output data
	assign kbd_out = kbd_reg;
	assign kbd_stb = sel_kbdreg && scs_n_01;

	assign mus_out    = mouse_buf;
	assign mus_xstb   = sel_musxcr && scs_n_01;
	assign mus_ystb   = sel_musycr && scs_n_01;
	assign mus_btnstb = sel_musbtn && scs_n_01;

	assign genrst = sel_rstreg && scs_n_01;
	assign rstrom = rst_reg[5:4];

/*
////////////////// OLDE SHITTE ///////////////////////////////////////
	always @(posedge spick, negedge spics_n)
	begin
		if( !spics_n )
			reset_reg[7:0] <= 8'd0;
		else // posedge spick
			reset_reg[7:0] <= { spido, reset_reg[7:1] };
	end

	always @(negedge spick)
	begin
		if( genrst ) rstrom <= reset_reg[5:4];
	end

	assign genrst = reset_reg[1];



	reg [39:0] kym;  //
	wire [4:0] keys [0:7]; // key matrix
	reg [4:0] keyreg [0:7];

	reg ksync1,ksync2,ksync3;


	always @(posedge spick) if( ~spics_n )
	begin
		kym[39:0] <= { spido, kym[39:1] };
	end

	assign keys[0][4:0] = { kym[00],kym[08],kym[16],kym[24],kym[32] };
	assign keys[1][4:0] = { kym[01],kym[09],kym[17],kym[25],kym[33] };
	assign keys[2][4:0] = { kym[02],kym[10],kym[18],kym[26],kym[34] };
	assign keys[3][4:0] = { kym[03],kym[11],kym[19],kym[27],kym[35] };
	assign keys[4][4:0] = { kym[04],kym[12],kym[20],kym[28],kym[36] };
	assign keys[5][4:0] = { kym[05],kym[13],kym[21],kym[29],kym[37] };
	assign keys[6][4:0] = { kym[06],kym[14],kym[22],kym[30],kym[38] };
	assign keys[7][4:0] = { kym[07],kym[15],kym[23],kym[31],kym[39] };

	always @(posedge fclk)
	begin
		ksync1 <= spics_n;
		ksync2 <= ksync1;
		ksync3 <= ksync2;

		if( ksync2 && (~ksync3) )
		begin
			keyreg[0] <= keys[0];
			keyreg[1] <= keys[1];
			keyreg[2] <= keys[2];
			keyreg[3] <= keys[3];
			keyreg[4] <= keys[4];
			keyreg[5] <= keys[5];
			keyreg[6] <= keys[6];
			keyreg[7] <= keys[7];
		end
	end



	always @*
	begin
		keyout = 5'b11111;

		if( ~a[8] )
			keyout = keyout & (~keyreg[0]);

		if( ~a[9] )
			keyout = keyout & (~keyreg[1]);

		if( ~a[10] )
			keyout = keyout & (~keyreg[2]);

		if( ~a[11] )
			keyout = keyout & (~keyreg[3]);

		if( ~a[12] )
			keyout = keyout & (~keyreg[4]);

		if( ~a[13] )
			keyout = keyout & (~keyreg[5]);

		if( ~a[14] )
			keyout = keyout & (~keyreg[6]);

		if( ~a[15] )
			keyout = keyout & (~keyreg[7]);
	end
*/



endmodule


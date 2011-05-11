// Pentevo project (c) NedoPC 2011
//
// frame INT generation

`include "../include/tune.v"

module zint
(
	input  wire zclk,
	input  wire fclk,

	input  wire int_start,

	input  wire iorq_n,
	input  wire m1_n,


	output wire int_start_zclk,

	output reg int_n
);


	reg ibeg;
	reg ibg1,ibg2,ibg3;

	wire intend;

	reg [6:0] intctr;



`ifdef SIMULATE
	initial
	begin
		ibeg = 0;
		intctr = 7'b0100000;
	//	int_n = 1'b1;

	//	force int_n = 1'b1;
	end
`endif



	always @(posedge fclk)
	begin
		if( int_start )
			ibeg <= ~ibeg;
	end

	always @(posedge zclk)
	begin
		ibg1 <= ibeg;
		ibg2 <= ibg1;
		ibg3 <= ibg2;
	end


	assign int_start_zclk = (ibg3!=ibg2);


	always @(posedge zclk)
	begin
		if( int_start_zclk )
			intctr <= 7'd0;
		else if( ~intctr[5] )
			intctr <= intctr + 7'd1;
	end


	assign intend = intctr[5] | ( ~(iorq_n|m1_n) );


	always @(posedge zclk)
	begin
		if( int_start_zclk )
			int_n <= 1'b0;
		else if( intend )
			int_n <= 1'b1;
	end





endmodule


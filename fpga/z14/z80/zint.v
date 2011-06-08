// Pentevo project (c) NedoPC 2011
//
// frame INT generation

`include "../include/tune.v"

module zint
(
	input  wire fclk,

	input  wire zpos,
	input  wire zneg,

	input  wire int_start,

	input  wire iorq_n,
	input  wire m1_n,

	output reg  int_n
);

	wire intend;

	reg [7:0] intctr;



`ifdef SIMULATE
	initial
	begin
		intctr = 8'b10000000;
	end
`endif


	always @(posedge fclk)
	begin
		if( int_start )
			intctr <= 8'd0;
		else if( !intctr[7] )
			intctr <= intctr + 8'd1;
	end


	assign intend = intctr[7] || ( (!iorq_n) && (!m1_n) && zneg );


	always @(posedge fclk)
	begin
		if( int_start )
			int_n <= 1'b0;
		else if( intend )
			int_n <= 1'bZ;
	end





endmodule


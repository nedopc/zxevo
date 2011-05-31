// visualize ZX picture
//
// here we build picture and send it sometimes to C program

module pixer
(
	input  wire clk,
	
	input  wire vsync,
	input  wire hsync,

	input  wire [1:0] red,
	input  wire [1:0] grn,
	input  wire [1:0] blu
);


	reg r_vsync;
	reg r_hsync;

	wire vbeg,hbeg;


	integer hcount;
	integer hperiod;
	integer hper1,hper2;

	integer vcount;
	integer vperiod;


	always @(posedge clk)
		r_vsync <= vsync;

	always @(posedge clk)
		r_hsync <= hsync;

	assign vbeg = ( (!r_vsync) && vsync );
	assign hbeg = ( (!r_hsync) && hsync );



	always @(posedge clk)
	if( hbeg )
		hcount <= 0;
	else
		hcount <= hcount + 1;

	always @(posedge clk)
	if( hbeg )
	begin
		hper2 <= hper1;
		hper1 <= hcount+1;
	end

	always @*
	if( hper2===hper1 )
		hperiod = hper2;



endmodule


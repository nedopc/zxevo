// ZX-Evo Base Configuration (c) NedoPC 2014
//
// CMOS emulator: cmos is needed for zxevo.rom to function correctly

/*
    This file is part of ZX-Evo Base Configuration firmware.

    ZX-Evo Base Configuration firmware is free software:
    you can redistribute it and/or modify it under the terms of
    the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ZX-Evo Base Configuration firmware is distributed in the hope that
    it will be useful, but WITHOUT ANY WARRANTY; without even
    the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ZX-Evo Base Configuration firmware.
    If not, see <http://www.gnu.org/licenses/>.
*/

module cmosemu
(
	input  wire       zclk,

	input  wire       cmos_req,
	input  wire [7:0] cmos_addr,
	input  wire       cmos_rnw,
	output reg  [7:0] cmos_read,
	input  wire [7:0] cmos_write
);

	reg [7:0] mem [0:239];

	reg req_r;

	function [7:0] cmos_rd
	(
		input [7:0] addr
	);

		if( addr<8'd240 )
			cmos_rd = mem[addr];
		else
			cmos_rd = 8'hFF;
	endfunction

	task cmos_wr
	(
		input [7:0] addr,
		input [7:0] data
	);
		if( addr<8'd240 )
			mem[addr] <= data;
	endtask



	initial
	begin
		int i;
		for(i=0;i<256;i=i+1)
			mem[i] <= 8'd0;
	end


	always @(posedge zclk)
		req_r <= cmos_req;

	always @(posedge zclk)
	begin
		cmos_read <= cmos_rd(cmos_addr);

		if( req_r && !cmos_rnw )
			cmos_wr(cmos_addr,cmos_write);
	end



endmodule


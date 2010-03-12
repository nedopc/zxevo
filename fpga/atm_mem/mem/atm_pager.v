// ATM-like memory pager (pages specific 16kb region)
//  with additions to support 4m addressable memory
//  and pent1m mode.
//
// contain ports 3FF7,7FF7,BFF7,FFF7 as well as 37F7, 77F7, B7F7, F7F7

module atm_pager(

	input  wire rst_n,

	input  wire fclk,
	input  wire zpos,
	input  wire zneg,


	input  wire [15:0] za, // Z80 address bus

	input  wire [ 7:0] zd, // Z80 data bus - for latching port data

	input  wire        iorq_n,mreq_n,rd_n,wr_n,m1_n,rfsh_n; // to track DOS turn on/turn off


	input  wire        pager_off, // PEN as in ATM2: turns off memory paging, service ROM is everywhere


	input  wire        pent1m_ROM,    // for memory maps switching: d4 of 7ffd
	input  wire [ 5:0] pent1m_page,   // 1 megabyte from pentagon1024 addressing, from 7FFD port
	input  wire        pent1m_ram0_0, // RAM0 to the window 0 from pentagon1024 mode
	input  wire        pent1m_1m_on,  // 1 meg addressing of pent1m mode on


	input  wire        atm_xxF7_wr, // write strobe for the xxF7 ATM port


	input  wire        dos, // indicates state of computer: also determines ROM mapping


	output wire        dos_turn_on,  // turns on or off DOS signal
	output wire        dos_turn_off, //

	output wire        zclk_stall, // stall Z80 clock during DOS turning on

	output reg  [ 7:0] page,
	output reg         romnram
);
	parameter ADDR = 2'b00;


	reg [ 7:0] pages [0:1]; // 2 pages for each map - switched by pent1m_ROM

	reg [ 1:0] ramnrom; // ram(=1) or rom(=0)
	reg [ 1:0] dos_7ffd; // =1 7ffd bits (ram) or DOS enter mode (rom) for given page

	reg iorq_n_reg, mreq_n_reg, rd_n_reg, wr_n_reg, m1_n_reg, rfsh_n_reg;

	wire dos_exec_stb, ram_exec_stb;


	reg [2:0] stall_count;


	// paging function, does not set pages, ramnrom, dos_7ffd
	//
	always @(posedge fclk)
	begin
		if( pager_off )
		begin // atm no pager mode - each window has same ROM
			romnram <= 1'b1;
			page    <= 8'hFF;
		end
		else // pager on
		begin
			if( pent1m_ram0_0 && (ADDR==2'b00) ) // shortcut for pentagon ram0
			begin
				romnram <= 1'b0;
				page    <= 8'd0;
			end
			else
			begin
				romnram <= ~ramnrom[ pent1m_ROM ];

				if( dos_7ffd[ pent1m_ROM ] ) // 7ffd memmap switching
				begin
					if( ramnrom[ pent1m_ROM ] )
					begin // ram map
						if( pent1m_1m_on )
						begin // map whole Mb from 7ffd to atm pages
							page <= { pages[ pent1m_ROM ][7:6], pent1m_page[5:0] };
						end
						else //128k like in atm2
						begin
							page <= { pages[ pent1m_ROM ][7:3], pent1m_page[2:0] };
						end
					end
					else // rom map with dos
					begin
						page <= { pages[ pent1m_ROM ][7:1], dos };
					end
				end
				else // no 7ffd impact
				begin
					page <= pages[ pent1m_ROM ];
				end
			end
		end
	end


	// port reading: sets pages, ramnrom, dos_7ffd
	//
	always @(posedge fclk, negedge arst_n)
	if( !arst_n )
	begin
		// default mode must be pent1m
		case( ADDR )

		2'b00: begin // ROM pages
			ramnrom[0] = 1'b0;
			ramnrom[1] = 1'b0;

			dos_7ffd[0] = 1'b1;
			dos_7ffd[1] = 1'b1;

			pages[0] = 8'hFE; // basic128 page
			pages[1] = 8'hFC; // basic48 page
		end

		2'b01: begin // 4000-7fff ram page 5
			ramnrom[0] = 1'b1;
			ramnrom[1] = 1'b1;

			dos_7ffd[0] = 1'b0;
			dos_7ffd[1] = 1'b0;

			pages[0] = 8'h05; // pent1m 5 page
			pages[1] = 8'h05; // pent1m 5 page
		end

		2'b10: begin // 8000-bfff ram page 2
			ramnrom[0] = 1'b1;
			ramnrom[1] = 1'b1;

			dos_7ffd[0] = 1'b0;
			dos_7ffd[1] = 1'b0;

			pages[0] = 8'h02; // pent1m 2 page
			pages[1] = 8'h02; // pent1m 2 page
		end

		2'b11: begin // c000-ffff
			ramnrom[0] = 1'b1;
			ramnrom[1] = 1'b1;

			dos_7ffd[0] = 1'b1;
			dos_7ffd[1] = 1'b1;

			pages[0] = 8'h00; // pent1m 0 page
			pages[1] = 8'h00; // pent1m 0 page
		end

		endcase
	end
	else if( atm_xxF7_wr )
	begin
		if( za[15:14]==ADDR )
		begin
			if( za[11] ) // xff7 ports - 1 meg
			begin
				pages   [ pent1m_ROM ] <= ~{ 2'b00, zd[5:0] };
				ramnrom [ pent1m_ROM ] <= zd[6];
				dos_7ffd[ pent1m_ROM ] <= zd[7];
			end
			else // x7f7 ports - 4 meg ram
			begin
				pages   [ pent1m_ROM ] <= ~zd;
				ramnrom [ pent1m_ROM ] <= 1'b1; // RAM on
				// dos_7ffd - UNCHANGED!!! (possibility to use 7ffd 1m and 128k addressing in the whole 4m!)
			end
		end
	end


	// DOS turn on/turn off
	//

	always @(posedge fclk) if( zpos )
	begin
		m1_n_reg <= m1_n;
	end

	always @(posedge fclk) if( zneg )
	begin
		mreq_n_reg <= mreq_n;
	end



	assign dos_exec_stb = zneg &&
	                      (!m1_n_reg) && (!mreq_n) && mreq_n_reg &&
	                      (za[13:8]==6'h3D) &&
	                      dos_7ffd[1'b1] && (!ramnrom[1'b1]) && pent1m_ROM;

	assign ram_exec_stb = zneg &&
	                      (!m1_n_reg) && (!mreq_n) && mreq_n_reg &&
	                      ramnrom[1'b1];

	assign dos_turn_on  = dos_exec_stb;
	assign dos_turn_off = ram_exec_stb;


	// stall Z80 for some time when dos turning on to allow ROM chip to supply new data
	// this can be important at 7 or even 14 mhz
	always @(posedge fclk)
	begin
	end


endmodule


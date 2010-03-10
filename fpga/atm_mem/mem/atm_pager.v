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
		инициализация, чтоб по дефолту был пент1м
	end
	else if( atm_xxF7_wr )
	begin
	end






endmodule


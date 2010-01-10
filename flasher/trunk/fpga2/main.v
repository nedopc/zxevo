module main(

    // clocks
    input fclk,
    output clkz_out,
    input clkz_in,

    // z80
    input iorq_n,
    input mreq_n,
    input rd_n,
    input wr_n,
    input m1_n,
    input rfsh_n,
    input int_n,
    input nmi_n,
    input wait_n,
    output res,

    inout [7:0] d,
    output [15:0] a,

    // zxbus and related
    output csrom,
    output romoe_n,
    output romwe_n,

    output rompg0_n,
    output dos_n, // aka rompg1
    output rompg2,
    output rompg3,
    output rompg4,

    input iorqge1,
    input iorqge2,
    output iorq1_n,
    output iorq2_n,

    // DRAM
    input [15:0] rd,
    input [9:0] ra,
    output rwe_n,
    output rucas_n,
    output rlcas_n,
    output rras0_n,
    output rras1_n,

    // video
    output reg [1:0] vred,
    output reg [1:0] vgrn,
    output reg [1:0] vblu,

    output vhsync,
    output vvsync,
    output vcsync,

    // AY control and audio/tape
    input ay_clk,
    output ay_bdir,
    output ay_bc1,

//    output beep,
    output reg beep,

    // IDE
    input [2:0] ide_a,
    input [15:0] ide_d,

    output ide_dir,

    input ide_rdy,

    output ide_cs0_n,
    output ide_cs1_n,
    output ide_rs_n,
    output ide_rd_n,
    output ide_wr_n,

    // VG93 and diskdrive
    input vg_clk,

    output vg_cs_n,
    output vg_res_n,

    input vg_hrdy,
    input vg_rclk,
    input vg_rawr,
    input [1:0] vg_a, // disk drive selection
    input vg_wrd,
    input vg_side,

    input step,
    input vg_sl,
    input vg_sr,
    input vg_tr43,
    input rdat_b_n,
    input vg_wf_de,
    input vg_drq,
    input vg_irq,
    input vg_wd,

    // serial links (atmega-fpga, sdcard)
    output sdcs_n,
    output sddo,
    output sdclk,
    input sddi,

    input spics_n,
    input spick,
    input spido,
    output spidi,
    input spiint_n
);

//--Dummy----------------------------------------------------------------------

    assign iorq1_n = 1'b1;
    assign iorq2_n = 1'b1;

    assign res= 1'b1;

    assign rwe_n   = 1'b1;
    assign rucas_n = 1'b1;
    assign rlcas_n = 1'b1;
    assign rras0_n = 1'b1;
    assign rras1_n = 1'b1;

    assign ay_bdir = 1'b0;
    assign ay_bc1  = 1'b0;

    assign vg_cs_n  = 1'b1;
    assign vg_res_n = 1'b0;

    assign ide_dir=1'b1;
    assign ide_rs_n = 1'b0;
    assign ide_cs0_n = 1'b1;
    assign ide_cs1_n = 1'b1;
    assign ide_rd_n = 1'b1;
    assign ide_wr_n = 1'b1;

 assign a[15:14] = 2'b00;

//-----------------------------------------------------------------------------

 reg [7:0] main_osc;

 always @(posedge fclk)
  begin
   main_osc <= main_osc + 7'h1;
   if ( main_osc < covox )
    beep <= 1'b1;
   else
    beep <= 1'b0;
  end

 assign clkz_out = main_osc[2]; // 3.5 MHz
// assign ay_clk = main_osc[3]; // 1.75 MHz
// assign beep = ( main_osc < covox ) ? 1'b1 : 1'b0;

//--Video----------------------------------------------------------------------

 localparam HBLNK_BEG = 9'd384;
 localparam CSYNC_CUT = 9'd415;
 localparam HSYNC_BEG = 9'd0;
 localparam HSYNC_END = 9'd33;
 localparam HBLNK_END = 9'd128;
 localparam HMAX      = 9'd447;
 localparam VBLNK_BEG = 9'd256;
 localparam VSYNC_BEG = 9'd0;
 localparam VSYNC_END = 9'd3;
 localparam VBLNK_END = 9'd64;
 localparam VMAX      = 9'd311; // 9'd319; // pentagon

 reg [8:0] hcount;
 reg [8:0] vcount;
 reg [5:0] hcharcount;
 reg [2:0] vcharline;
 reg [6:0] voffset;
 reg hsync, hblank, vsync, vblank, csync;
 wire [9:0] video_addr;
 wire [7:0] charcode;
 wire [7:0] charpix;
 wire pixel;
 wire [5:0] fcolor;
 wire [5:0] bcolor;
 wire [5:0] color;

 always @(posedge fclk)
  begin
   //
   if( main_osc[1:0]==2'h0 )
    begin

     if ( hcount[2:0]==3'h0 )
      begin
       if ( hblank )
        hcharcount <= 6'h00;
       else
        hcharcount <= hcharcount + 6'h01;
      end

     if( hcount==HMAX )
      hcount <= 9'd0;
     else
      hcount <= hcount + 9'd1;

     if( hcount==HBLNK_BEG )
      hblank <= 1'b1;
     else if( hcount==HBLNK_END )
      hblank <= 1'b0;

     if( hcount==HSYNC_BEG )
      begin
       hsync <= 1'b1;
       csync <= 1'b1;
      end
     else if( hcount==HSYNC_END )
      begin
       hsync <= 1'b0;
       if( !vsync )
        csync <= 1'b0;
      end

     if( hcount==CSYNC_CUT )
      csync <= 1'b0;

     vgrn[1] <= color[5];
     vgrn[0] <= color[4];
     vred[1] <= color[3];
     vred[0] <= color[2];
     vblu[1] <= color[1];
     vblu[0] <= color[0];

    end
   //
   if( (main_osc[1:0]==2'h3) && (hcount==HSYNC_BEG) )
    begin

     if ( vblank )
      begin
       voffset <= 7'd0;
       vcharline <= 3'h0;
      end
     else
      begin
       if ( vcharline==3'h7 )
        voffset <= voffset + 7'd4;  //  32 / 8 = 4
       vcharline <= vcharline + 3'h1;
      end

     if( vcount==VMAX )
      vcount <= 9'd0;
     else
      vcount <= vcount + 9'd1;

     if( vcount==VBLNK_BEG )
      vblank <= 1'b1;
     else if( vcount==VBLNK_END )
      vblank <= 1'b0;

     if( vcount==VSYNC_BEG )
      vsync <= 1'b1;
     else if( vcount==VSYNC_END )
      vsync <= 1'b0;

    end
   //
  end

 assign video_addr = { voffset[6:0], 3'h0 } + { 4'h0, hcharcount[5:0] };
 lpm_ram_dp0 scr_mem  ( .data(scr_char), .rdaddress(video_addr), .wraddress(scr_addr), .wren(scr_wren_c), .q(charcode) );
 lpm_rom0 chargen ( .address({ charcode, vcharline[2:0] }), .q(charpix) );

 assign fcolor = 6'b111111;
 assign bcolor = 6'b000001;
 assign pixel = charpix[~(hcount[2:0]-3'h1)];
 assign color = (hblank | vblank) ? 6'h00 : ( pixel ? fcolor : bcolor ) ;

 assign vhsync = hsync;
 assign vvsync = vsync;
 assign vcsync = ~csync;

//--AVRSPI--FlashROM-----------------------------------------------------------

 localparam SD_DATA       = 8'h57;
 localparam FLASH_LOADDR  = 8'hf0;
 localparam FLASH_MIDADDR = 8'hf1;
 localparam FLASH_HIADDR  = 8'hf2;
 localparam FLASH_DATA    = 8'hf3;
 localparam FLASH_CTRL    = 8'hf4;
 localparam SCR_LOADDR    = 8'h40;
 localparam SCR_HIADDR    = 8'h41;
 localparam SCR_SET_ATTR  = 8'h42;
 localparam SCR_FILL      = 8'h43;
 localparam SCR_CHAR      = 8'h44;
 localparam COVOX         = 8'hfb;

 reg [7:0] number;
 reg [7:0] indata;
 reg [7:0] outdata;
 reg [2:0] bitptr;
 reg sd_cs;
 reg [1:0] spick_resync;
 reg [1:0] spicsn_resync;
 reg [18:0] flash_a;
 reg flash_cs;
 reg flash_oe;
 reg flash_we;
 reg [7:0] flash_data_out;
 reg [9:0] scr_addr;
 reg [7:0] scr_char;
 reg scr_wren_c;
 reg [7:0] covox;
 wire spicsn_rising;
 wire spicsn_falling;

 always @(posedge spick)
  begin
   if ( spics_n )
    number <= { number[6:0], spido };
   else
    indata <= { indata[6:0], spido };
  end

 always @(negedge spick or posedge spics_n)
  begin
   if ( spics_n )
    bitptr <= 3'b111;
   else
    bitptr <= bitptr - 3'b001;
  end

 always @(posedge fclk)
  begin

   spicsn_resync <= { spicsn_resync[0], spics_n };

   if ( spicsn_rising )
    case ( number )
     FLASH_LOADDR:  flash_a[7:0] <= indata;
     FLASH_MIDADDR: flash_a[15:8] <= indata;
     FLASH_HIADDR:  flash_a[18:16] <= indata[2:0];
     FLASH_DATA:    flash_data_out <= indata;
     FLASH_CTRL:    begin
                     flash_cs <= indata[0];
                     flash_oe <= indata[1];
                     flash_we <= indata[2];
                    end
     SCR_LOADDR:    scr_addr[7:0] <= indata;
     SCR_HIADDR:    scr_addr[9:8] <= indata[1:0];
     SCR_CHAR:      begin
                     scr_char <= indata;
                     scr_wren_c <= 1'b1;
                    end
     COVOX:         covox <= indata;
    endcase

   if ( spicsn_falling )
    begin
     scr_wren_c <= 1'b0;
     if ( ( number==SCR_FILL ) || ( number==SCR_CHAR ) )
      scr_addr <= scr_addr + 10'd1;
     if ( number==FLASH_DATA )
      outdata <= d;
     else
      if ( number==COVOX )
       outdata <= covox;
      else
       outdata <= 8'hff;
    end

  end


 always @*
  begin
   if ( ( number[7:0] == SD_DATA ) && ( !spics_n ) )
    sd_cs <= 1'b1;
   else
    sd_cs <= 1'b0;
  end


 assign spicsn_rising  = (spicsn_resync==2'b01);
 assign spicsn_falling = (spicsn_resync==2'b10);

 assign sdcs_n = ~sd_cs;
 assign spidi = sd_cs ? sddi : outdata[bitptr];
 assign sddo = sd_cs ? spido : 1'b0;
 assign sdclk = sd_cs ? spick : 1'b0;

 assign a[13:0]  =  flash_a[13:0];
 assign rompg0_n = ~flash_a[14];
 assign { rompg4, rompg3, rompg2, dos_n } = flash_a[18:15];
 assign csrom   =  flash_cs;
 assign romoe_n = ~flash_oe;
 assign romwe_n = ~flash_we;
 assign d = flash_oe ? 8'bZZZZZZZZ : flash_data_out;

//-----------------------------------------------------------------------------

endmodule

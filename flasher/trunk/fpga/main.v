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
    input [1:0] vred,
    input [1:0] vgrn,
    input [1:0] vblu,

    input vhsync,
    input vvsync,
    input vcsync,

    // AY control and audio/tape
    input ay_clk,
    output ay_bdir,
    output ay_bc1,

    output beep,

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

//-----------------------------------------------------------------------------

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

 // make clock for Z80 to ensure its correct reset
 reg [2:0] z80_simple_clk;
 always @(posedge fclk)
  z80_simple_clk <= z80_simple_clk + 3'h1;
 assign clkz_out = z80_simple_clk[2];

 localparam SD_DATA       = 8'h57;
 localparam FLASH_LOADDR  = 8'hf0;
 localparam FLASH_MIDADDR = 8'hf1;
 localparam FLASH_HIADDR  = 8'hf2;
 localparam FLASH_DATA    = 8'hf3;
 localparam FLASH_CTRL    = 8'hf4;

 reg [7:0] number;
 reg [7:0] indata;
 reg [7:0] outdata;
 reg [2:0] bitptr;
 reg sd_do;
 reg sd_cs;
 reg sd_clk;
 reg spi_di;
 reg [18:0] flash_a;
 reg flash_cs;
 reg flash_oe;
 reg flash_we;
 reg [7:0] flash_data_out;

 always @(posedge spick)
  begin
   if ( spics_n )
    number[7:0] <= { number[6:0], spido };
   else
    indata[7:0] <= { indata[6:0], spido };
  end

 always @(negedge spick or posedge spics_n)
  begin
   if ( spics_n )
    bitptr <= 3'b111;
   else
    bitptr <= bitptr - 3'b001;
  end

 always @(posedge spics_n)
  begin
   case ( number[7:0] )
    FLASH_LOADDR:  flash_a[7:0] <= indata[7:0];
    FLASH_MIDADDR: flash_a[15:8] <= indata[7:0];
    FLASH_HIADDR:  flash_a[18:16] <= indata[2:0];
    FLASH_DATA:    flash_data_out[7:0] <= indata[7:0];
    FLASH_CTRL:    begin
                    flash_cs <= indata[0];
                    flash_oe <= indata[1];
                    flash_we <= indata[2];
                   end
   endcase
  end

 always @(negedge spics_n)
  begin
   case ( number[7:0] )
    FLASH_DATA: outdata[7:0] <= d[7:0];
    default     outdata[7:0] <= 8'hff;
   endcase
  end

 always @*
  begin
   if ( ( number[7:0] == SD_DATA ) && ( !spics_n ) )
    begin
     sd_cs <= 1'b1;
     spi_di <= sddi;
     sd_do <= spido;
     sd_clk <= spick;
    end
   else
    begin
     sd_cs <= 1'b0;
     spi_di <= outdata[bitptr];
     sd_do <= 1'b0;
     sd_clk <= 1'b0;
    end
  end

 assign spidi = spi_di;
 assign sdclk = sd_clk;
 assign sdcs_n = ~sd_cs;
 assign sddo = sd_do;

 assign a[13:0]  =  flash_a[13:0];
 assign rompg0_n = ~flash_a[14];
 assign { rompg4, rompg3, rompg2, dos_n } = flash_a[18:15];
 assign csrom   =  flash_cs;
 assign romoe_n = ~flash_oe;
 assign romwe_n = ~flash_we;

 assign d[7:0] = flash_oe ? 8'bZZZZZZZZ : flash_data_out[7:0];

 assign beep = spiint_n;

endmodule

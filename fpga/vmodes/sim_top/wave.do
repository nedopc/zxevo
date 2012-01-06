onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb/fclk
add wave -noupdate -format Logic /tb/clkz_out
add wave -noupdate -format Logic /tb/zrst_n
add wave -noupdate -format Logic /tb/clkz_in
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/DUT/zclock/clk14_src
add wave -noupdate -format Logic /tb/DUT/zclock/zclk_stall
add wave -noupdate -format Logic /tb/DUT/zclock/pre_zpos_35
add wave -noupdate -format Logic /tb/DUT/zclock/pre_zneg_35
add wave -noupdate -format Logic /tb/DUT/zclock/pre_zpos_70
add wave -noupdate -format Logic /tb/DUT/zclock/pre_zneg_70
add wave -noupdate -format Logic /tb/DUT/zclock/pre_zpos_140
add wave -noupdate -format Logic /tb/DUT/zclock/pre_zneg_140
add wave -noupdate -format Logic /tb/DUT/zclock/pre_zpos
add wave -noupdate -format Logic /tb/DUT/zclock/pre_zneg
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/DUT/zclock/zpos
add wave -noupdate -format Logic /tb/DUT/zclock/zneg
add wave -noupdate -format Logic /tb/z80/busrq_n
add wave -noupdate -format Logic /tb/z80/busak_n
add wave -noupdate -format Logic /tb/DUT/z80mem/r_mreq_n
add wave -noupdate -format Logic /tb/clkz_in
add wave -noupdate -format Logic /tb/DUT/external_port
add wave -noupdate -format Logic /tb/iorq_n
add wave -noupdate -format Logic /tb/mreq_n
add wave -noupdate -format Logic /tb/rd_n
add wave -noupdate -format Logic /tb/wr_n
add wave -noupdate -format Logic /tb/m1_n
add wave -noupdate -format Logic /tb/rfsh_n
add wave -noupdate -format Logic /tb/int_n
add wave -noupdate -format Logic /tb/nmi_n
add wave -noupdate -format Logic /tb/wait_n
add wave -noupdate -format Literal -radix hexadecimal /tb/za
add wave -noupdate -format Literal -radix hexadecimal /tb/zd
add wave -noupdate -format Literal -radix hexadecimal /tb/zd_dut_to_z80
add wave -noupdate -format Logic /tb/csrom
add wave -noupdate -format Logic /tb/romoe_n
add wave -noupdate -format Logic /tb/romwe_n
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix hexadecimal /tb/z80/u0/ir
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/DUT/z80mem/memrd
add wave -noupdate -format Logic /tb/DUT/z80mem/memwr
add wave -noupdate -format Logic /tb/DUT/z80mem/opfetch
add wave -noupdate -format Logic /tb/DUT/z80mem/dram_beg
add wave -noupdate -format Logic /tb/DUT/z80mem/stall14_ini
add wave -noupdate -format Logic /tb/DUT/z80mem/stall14_cyc
add wave -noupdate -format Logic /tb/DUT/z80mem/stall14_fin
add wave -noupdate -format Logic /tb/DUT/z80mem/stall14_cycrd
add wave -noupdate -format Logic /tb/DUT/z80mem/cpu_next
add wave -noupdate -format Logic /tb/DUT/z80mem/cpu_stall
add wave -noupdate -format Logic /tb/DUT/z80mem/cpu_req
add wave -noupdate -format Logic /tb/DUT/z80mem/pending_cpu_req
add wave -noupdate -format Logic /tb/DUT/z80mem/cpu_strobe
add wave -noupdate -format Logic /tb/DUT/z80mem/cpu_rnw
add wave -noupdate -format Logic /tb/DUT/z80mem/cpu_rnw_r
add wave -noupdate -format Logic /tb/DUT/z80mem/cend
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix hexadecimal /tb/z80/u0/ir
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/DUT/dram/rras0_n
add wave -noupdate -format Logic /tb/DUT/dram/rras1_n
add wave -noupdate -format Logic /tb/DUT/dram/rucas_n
add wave -noupdate -format Logic /tb/DUT/dram/rlcas_n
add wave -noupdate -format Logic /tb/DUT/dram/rwe_n
add wave -noupdate -format Literal -radix hexadecimal /tb/DUT/dram/ra
add wave -noupdate -format Literal -radix hexadecimal /tb/DUT/dram/rd
add wave -noupdate -format Logic /tb/DUT/dram/cbeg
add wave -noupdate -format Literal -radix hexadecimal /tb/DUT/dram/int_addr
add wave -noupdate -format Literal -radix hexadecimal /tb/DUT/dram/int_wrdata
add wave -noupdate -format Literal /tb/DUT/dram/int_bsel
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix hexadecimal {/tb/DUT/instantiate_atm_pagers[0]/atm_pager/page}
add wave -noupdate -format Logic {/tb/DUT/instantiate_atm_pagers[0]/atm_pager/romnram}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/z80/reset_n
add wave -noupdate -format Logic /tb/z80/clk_n
add wave -noupdate -format Logic /tb/z80/rfsh_n
add wave -noupdate -format Logic /tb/z80/m1_n
add wave -noupdate -format Logic /tb/z80/mreq_n
add wave -noupdate -format Logic /tb/z80/rd_n
add wave -noupdate -format Logic /tb/z80/wr_n
add wave -noupdate -format Literal -radix hexadecimal /tb/z80/a
add wave -noupdate -format Literal -radix hexadecimal /tb/z80/d
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/DUT/video_top/clk
add wave -noupdate -format Logic /tb/DUT/video_top/cbeg
add wave -noupdate -format Logic /tb/DUT/video_top/post_cbeg
add wave -noupdate -format Logic /tb/DUT/video_top/pre_cend
add wave -noupdate -format Logic /tb/DUT/video_top/cend
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/DUT/video_top/int_start
add wave -noupdate -format Logic /tb/DUT/video_top/line_start
add wave -noupdate -format Logic /tb/DUT/video_top/hpix
add wave -noupdate -format Logic /tb/DUT/video_top/vpix
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/DUT/video_top/fetch_start
add wave -noupdate -format Logic /tb/DUT/video_top/fetch_end
add wave -noupdate -format Logic /tb/DUT/video_top/fetch_sync
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/DUT/video_top/video_go
add wave -noupdate -format Literal -radix hexadecimal /tb/DUT/video_top/video_addr
add wave -noupdate -format Logic /tb/DUT/video_top/video_next
add wave -noupdate -format Literal -radix hexadecimal /tb/DUT/video_top/video_data
add wave -noupdate -format Logic /tb/DUT/video_top/video_strobe
add wave -noupdate -format Literal /tb/DUT/video_top/video_bw
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/DUT/video_top/video_addrgen/frame_init
add wave -noupdate -format Logic /tb/DUT/video_top/video_addrgen/gnext
add wave -noupdate -format Literal -radix hexadecimal /tb/DUT/video_top/video_addrgen/gctr
add wave -noupdate -format Logic /tb/DUT/video_top/video_addrgen/ldaddr
add wave -noupdate -format Literal -radix hexadecimal /tb/DUT/video_top/video_addrgen/video_addr
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix hexadecimal /tb/DUT/video_top/pic_bits
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix unsigned /tb/DUT/video_top/vred
add wave -noupdate -format Literal -radix unsigned /tb/DUT/video_top/vgrn
add wave -noupdate -format Literal -radix unsigned /tb/DUT/video_top/vblu
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {447762029900 ps} 0} {{Cursor 2} {45952747000 ps} 0} {{Cursor 3} {45950183800 ps} 0}
configure wave -namecolwidth 348
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 17800
configure wave -gridperiod 35600
configure wave -griddelta 8
configure wave -timeline 0
update
WaveRestoreZoom {45946214078 ps} {46048826015 ps}

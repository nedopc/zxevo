onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/fclk
add wave -noupdate /tb/clkz_out
add wave -noupdate /tb/zrst_n
add wave -noupdate /tb/clkz_in
add wave -noupdate -divider <NULL>
add wave -noupdate /tb/DUT/zclock/clk14_src
add wave -noupdate /tb/DUT/zclock/zclk_stall
add wave -noupdate /tb/DUT/zclock/pre_zpos_35
add wave -noupdate /tb/DUT/zclock/pre_zneg_35
add wave -noupdate /tb/DUT/zclock/pre_zpos_70
add wave -noupdate /tb/DUT/zclock/pre_zneg_70
add wave -noupdate /tb/DUT/zclock/pre_zpos_140
add wave -noupdate /tb/DUT/zclock/pre_zneg_140
add wave -noupdate /tb/DUT/zclock/pre_zpos
add wave -noupdate /tb/DUT/zclock/pre_zneg
add wave -noupdate /tb/DUT/contend
add wave -noupdate /tb/DUT/zclock/contend_io
add wave -noupdate /tb/DUT/zclock/contend_mem
add wave -noupdate /tb/DUT/zclock/contend_wait
add wave -noupdate /tb/DUT/zclock/stall
add wave -noupdate -radix hexadecimal /tb/DUT/zclock/a
add wave -noupdate /tb/DUT/zclock/r_mreq_n
add wave -noupdate -divider <NULL>
add wave -noupdate /tb/DUT/zclock/zpos
add wave -noupdate /tb/DUT/zclock/zneg
add wave -noupdate /tb/z80/BUSRQ_n
add wave -noupdate /tb/z80/BUSAK_n
add wave -noupdate /tb/DUT/z80mem/r_mreq_n
add wave -noupdate /tb/DUT/external_port
add wave -noupdate /tb/clkz_in
add wave -noupdate /tb/iorq_n
add wave -noupdate /tb/mreq_n
add wave -noupdate /tb/rd_n
add wave -noupdate /tb/wr_n
add wave -noupdate /tb/m1_n
add wave -noupdate /tb/rfsh_n
add wave -noupdate /tb/int_n
add wave -noupdate /tb/nmi_n
add wave -noupdate /tb/wait_n
add wave -noupdate -radix hexadecimal /tb/za
add wave -noupdate -radix hexadecimal /tb/zd
add wave -noupdate -radix hexadecimal /tb/zd_dut_to_z80
add wave -noupdate /tb/csrom
add wave -noupdate /tb/romoe_n
add wave -noupdate /tb/romwe_n
add wave -noupdate -radix hexadecimal /tb/z80/u0/IR
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
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate /tb/z80/RESET_n
add wave -noupdate /tb/z80/CLK_n
add wave -noupdate /tb/z80/RFSH_n
add wave -noupdate /tb/z80/M1_n
add wave -noupdate /tb/z80/MREQ_n
add wave -noupdate /tb/z80/RD_n
add wave -noupdate /tb/z80/WR_n
add wave -noupdate -radix hexadecimal /tb/z80/A
add wave -noupdate -radix hexadecimal /tb/z80/D
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
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate /tb/DUT/contend
add wave -noupdate /tb/DUT/video_top/hpix
add wave -noupdate /tb/DUT/video_top/vpix
add wave -noupdate /tb/DUT/vvsync
add wave -noupdate /tb/DUT/vhsync
add wave -noupdate /tb/DUT/vcsync
add wave -noupdate /tb/DUT/vred
add wave -noupdate /tb/DUT/vgrn
add wave -noupdate /tb/DUT/vblu
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2824635 ps} 0} {{Cursor 2} {1652460038129 ps} 0}
configure wave -namecolwidth 416
configure wave -valuecolwidth 149
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
configure wave -timelineunits ns
update
WaveRestoreZoom {2455234397435 ps} {2455300267966 ps}

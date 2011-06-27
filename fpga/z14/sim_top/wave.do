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
add wave -noupdate -divider <NULL>
add wave -noupdate /tb/DUT/zclock/zpos
add wave -noupdate /tb/DUT/zclock/zneg
add wave -noupdate /tb/z80/busrq_n
add wave -noupdate /tb/z80/busak_n
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
add wave -noupdate /tb/csrom
add wave -noupdate /tb/romoe_n
add wave -noupdate /tb/romwe_n
add wave -noupdate -divider <NULL>
add wave -noupdate /tb/DUT/z80mem/memrd
add wave -noupdate /tb/DUT/z80mem/memwr
add wave -noupdate /tb/DUT/z80mem/opfetch
add wave -noupdate /tb/DUT/z80mem/dram_beg
add wave -noupdate /tb/DUT/z80mem/stall14_ini
add wave -noupdate /tb/DUT/z80mem/stall14_cyc
add wave -noupdate /tb/DUT/z80mem/stall14_fin
add wave -noupdate /tb/DUT/z80mem/stall14_cycrd
add wave -noupdate /tb/DUT/z80mem/cpu_next
add wave -noupdate /tb/DUT/z80mem/cpu_stall
add wave -noupdate -divider <NULL>
add wave -noupdate /tb/DUT/z80mem/cpu_req
add wave -noupdate /tb/DUT/z80mem/pending_cpu_req
add wave -noupdate /tb/DUT/z80mem/cpu_strobe
add wave -noupdate /tb/DUT/z80mem/cpu_rnw
add wave -noupdate /tb/DUT/z80mem/cpu_rnw_r
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /tb/z80/u0/ir
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal {/tb/DUT/instantiate_atm_pagers[0]/atm_pager/page}
add wave -noupdate {/tb/DUT/instantiate_atm_pagers[0]/atm_pager/romnram}
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {267699653665 ps} 0} {{Cursor 2} {8068901 ps} 0}
configure wave -namecolwidth 353
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 178
configure wave -gridperiod 356
configure wave -griddelta 8
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {7503927 ps} {8699607 ps}

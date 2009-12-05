onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb/fclk
add wave -noupdate -format Logic /tb/clkz_out
add wave -noupdate -format Logic /tb/zrst_n
add wave -noupdate -format Logic /tb/clkz_in
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /tb/z80/busrq_n
add wave -noupdate -format Logic /tb/z80/busak_n
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
add wave -noupdate -format Logic /tb/csrom
add wave -noupdate -format Logic /tb/romoe_n
add wave -noupdate -format Logic /tb/romwe_n
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix hexadecimal /tb/z80/u0/dinst
add wave -noupdate -format Literal -radix hexadecimal /tb/z80/u0/ir
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix hexadecimal /tb/DUT/ra
add wave -noupdate -format Logic /tb/DUT/rwe_n
add wave -noupdate -format Logic /tb/DUT/rucas_n
add wave -noupdate -format Logic /tb/DUT/rlcas_n
add wave -noupdate -format Logic /tb/DUT/rras0_n
add wave -noupdate -format Logic /tb/DUT/rras1_n
add wave -noupdate -format Literal -radix hexadecimal /tb/DUT/rd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {142349500 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
update
WaveRestoreZoom {141892900 ps} {144112900 ps}

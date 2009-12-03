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
add wave -noupdate -format Logic /tb/z80/u0/halt_ff
add wave -noupdate -format Logic /tb/z80/u0/intcycle
add wave -noupdate -format Logic /tb/z80/u0/nmicycle
add wave -noupdate -format Literal /tb/z80/u0/istatus
add wave -noupdate -format Literal -radix unsigned /tb/z80/u0/mcycle
add wave -noupdate -format Literal -radix unsigned /tb/z80/u0/tstate
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2367400 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 40
configure wave -gridperiod 80
configure wave -griddelta 10
configure wave -timeline 0
update
WaveRestoreZoom {10416900 ps} {20504400 ps}

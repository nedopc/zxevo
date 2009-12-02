onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb/fclk
add wave -noupdate -format Logic /tb/clkz_out
add wave -noupdate -format Logic /tb/zrst_n
add wave -noupdate -format Logic /tb/clkz_in
add wave -noupdate -divider <NULL>
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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2513800 ps} 0}
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
WaveRestoreZoom {0 ps} {18268800 ps}

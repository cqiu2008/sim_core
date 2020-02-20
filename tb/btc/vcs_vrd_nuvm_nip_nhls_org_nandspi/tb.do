vlog -novopt tb_spi.v nand_model_spi.v nand_spi.v +define+SHORT_RESET
vsim -novopt tb_spi 
add wave -p uut/*
run -all


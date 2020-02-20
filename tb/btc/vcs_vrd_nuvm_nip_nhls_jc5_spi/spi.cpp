int main() {
// This function sets the SSI_EN bit to logic ‘0’ in the SSIENR register
// of each device on the serial bus
disable_all_serial_devices();
// This function initializes the master device for the serial transfer
// 1. Write CTRLR0 to match the required transfer
// 2. If transfer is receive only write number of frames into CTRLR1
// 3. Write BAUDR to set the transfer baud rate.
// 4. Write TXFTLR and RXFTLR to set FIFO threshold levels
// 5. Write IMR register to set interrupt masks
// 6. Write SER register bit[0] to logic '1'
// 7. Write SSIENR register bit[0] to logic '1' to enable the master.

initialize_mst(ssi_mst_1);

// This function initializes the target slave device (slave 1 in this example)
// for the serial transfer.
// 1. Write CTRLR0 to match the required transfer
// 2. Write TXFTLR and RXFTLR to set FIFO threshold levels
// 3. Write IMR register to set interrupt masks
// 4. Write SSIENR register bit[0] to logic '1' to enable the slave.
// 5. If the slave is to transmit data, write data into TX FIFO
// Now the slave is enabled and awaiting an active level on its
// ss_in_n input port. Note all other serial slaves are disabled (SSI_EN=0)
// and therefore will not respond to an active level on their ss_in_n port.

initialize_slv(ssi_slv_1);
// This function begins the serial transfer by writing transmit data into
// the master's TX FIFO.

start_serial_xfer(ssi_mst_1);

// User can poll the busy status with a function or use an ISR to determine
// when the serial transfer has completed.
} 

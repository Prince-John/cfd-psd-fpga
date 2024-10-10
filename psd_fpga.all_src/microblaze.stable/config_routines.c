// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Configuration routines
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#include	"main.h"

// ****************************************************
// isConfigMode()
// Check if STX has come in from host
// ***************************************************

bool	isConfigMode() {
	if (uart_byte_ready()) {
		if (uart_get_byte()  == STX) {
			return true ;
		} else {
			return false ;
		}
	}
	return false ;
}

// ****************************************************
// configHandler()
//
// Is called when host wants us to configure something.
// Reception of STX is what initiates the call to this
// handler. First thing the handler MUST do is ACK the
// reception of the STX from host.  THis will cause host
// to start sending configuration commands.
//
// ****************************************************

// For time being just print to LCD screen

void	configHandler() {

	int chip_num ;
	u8 	byte ;

// Some fake data ... just for testing purposes
// Least significant to most significant byte in {  } assign

	u8  config_data[12] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05} ;
	u8  delay_data = 0x4f ;

// Send ACK to having received the STX

    uart_send_byte(ACK);

// Wait for configuration commands from the host
// Exit the do-loop when we receive a ETX from Host
// ETX says leave configuration mode

    do {

// Waiting for a byte from host

    	while ( !uart_byte_ready() )   {
    		usleep(100) ;
    	}

// Something came in so get it!

    	byte = uart_get_byte() ;

// If we recognize the command, then do it and send ACK to host
// DO NOT ack until you have carried out the command and are then
// guaranteed to be ready to receive another config command from host
//
// If command not recognized or some error occurred then send NACK
// Host sends ETX when it wants us to exit from config mode

    	switch (byte) {

// Configure delay ICs

    		case 'D' :	for (chip_num = 0; chip_num < 6; chip_num++) {
    						configure_delay_chips(chip_num, delay_data) ;
    					} // end for loop
    					uart_send_byte(ACK) ;
    					break;

// Configure PSD serial register

    		case 'P':	configure_psd_chips(config_data) ;
						uart_send_byte(ACK) ;
						break ;

// Get board id and print to LCD

       		case 'B':	if (useLCD) {
       	    				lcd_clear();
       	    				lite_sprintf(LCDstr, "Board ID: %d", get_board_id() ) ;
       	    				lcd_print_str(LCDstr) ;
        					sleep(2) ;
       	    			}
    					uart_send_byte(ACK) ;
    					break ;
    					// Write a value to CFD (addr/mode, data)

// Write to CFD register

       		case 'C':	write_cfd_reg(0x55, 0xaa) ;
						uart_send_byte(ACK) ;
						break ;

// Control byte letting us know that host wants to exit config mode

    		case ETX :	uart_send_byte(ACK) ;
    					break ;

// Couldn't understand or do command
// Send back negative acknowledge

    		default:	uart_send_byte(NAK) ;
    					break ;
    	} // end switch
    } while (byte != ETX) ;

	return ;
}


// ***********************************
// Load the two PSD chips
// Each psd register is 48 bits wide
// 96 serial clocks
// Least significant bit goes in first
// Put data out on falling edge of clock
// PSD chip latches data on rising edge
// *********************************

void  configure_psd_chips(u8 *psd_config_data) {
    int     i ;
    int     j ;
    u32     byte ;
    u32		value ;
    u32		psd_sclk ;
    u32		psd_sin ;

// 2-bit field {psd_sclk, psd_sin}
// (1 << j) is mask to pick of the jth bit

    for (i = 0; i < 12 ; i++) {
        byte = (u32) psd_config_data[i] ;
        for (j = 0 ; j < 8 ; j++) {
        	psd_sin = (byte & (1 << j)) >> j ;
        	psd_sclk = LOW ;
           	value = (psd_sclk << 1) | psd_sin ;
            write_gpio_port(PSD_SERIAL_CONFIG_OUT_PORT, 2, PSD_SIN, value) ;
        	psd_sclk = HIGH ;
           	value = (psd_sclk << 1) | psd_sin ;
            write_gpio_port(PSD_SERIAL_CONFIG_OUT_PORT, 2, PSD_SIN, value) ;
        }
    }
    return ;

// It would be nice if returned an 8 byte array of sdo data rather than void!!!

}

// *****************************************************************S
// Configure the delay chips
// chip_num :  delay chip (0 - 5)
// delay_data : 0 a b v w x y z (see datasheet)
// *****************************************************************

void configure_delay_chips(int chip_num, u8 delay_data) {
    u32     ena_val ;
    u32		clk_val ;
    u32		data_val ;
    u32		value ;
    int     j ;

// Assumption is that clock is low when we enter routine
// Make sure it's low when we exit routine
// Only one enable should be active LOW!

// Bring serial enable low (active)
// Serial clock should be low
// 8 bit field --> ena [6], delay_clk [1], delay_data[1]

   ena_val = (1 << chip_num) ;
   ena_val = ~ena_val ;
   ena_val = ena_val & 0x003f ;

// Put data out on rising edge of clock

    for (j = 7; j >= 0 ; j--) {
    	data_val = delay_data & (1 << j) ;
    	data_val = (data_val >> j) ;

    	clk_val = HIGH ;
    	value = data_val | (clk_val << 1) | (ena_val << 2) ;
    	write_gpio_port(DELAY_CHIP_PORT, 8, DELAY_DATA, value) ;

    	clk_val = LOW ;
    	value = data_val | (clk_val << 1) | (ena_val << 2) ;
    	write_gpio_port(DELAY_CHIP_PORT, 8, DELAY_DATA, value) ;
    }
        
// Bring serial enable high (i.e. NOT active)

    ena_val = 0x003f ;
    clk_val = 0 ;
    data_val = 0 ;
	value = data_val | (clk_val << 1) | (ena_val << 2) ;
	write_gpio_port(DELAY_CHIP_PORT, 8, DELAY_DATA, value) ;

    return ;
}

// ******************************************************************************
// Routine to get the board ID (6 bits) and save to global variable board_id
// ******************************************************************************

u8	get_board_id() {
	u32		board_id ;
	board_id = (u8) read_gpio_port(BOARD_ID_PORT, 6, BOARD_ID_0) ;
	return board_id ;
}

// ***************************************************
// Routine to control the cfd_write line
// We really have no need to read from CFD
// Call this routine from main() and set line HIGH
// Just leave it high!
// *****************************************************

void  	cfd_write(u8 value) {
	write_gpio_port(CFD_PORT, 1, CFD_WRITE, value) ;
	return ;
}

// ***************************************************
// Routine to control the cfd strobe line
// Value should be either LOW or HIGH
// *****************************************************

void	cfd_strobe(u8 value) {
	write_gpio_port(CFD_PORT, 1, CFD_STB, value) ;
}

// ******************************************************************************
// Write to CFD chip internal registers
// ******************************************************************************

void	write_cfd_reg(u8 addr_mode, u8 data) {

// Makse sure strobe is LOW

	cfd_strobe(LOW) ;

// Write out address/mode info

	write_gpio_port(CFD_PORT, 8, CFD_AD_OUT_0, addr_mode) ;

// Bring strobe high

	cfd_strobe(HIGH) ;

// Write out address/mode info

	write_gpio_port(CFD_PORT, 8, CFD_AD_OUT_0, data) ;

// Bring strobe back low

	cfd_strobe(LOW) ;
	return ;
}


#include	"main.h"
// Changes begin now.
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Configuration routines
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^


/*
 * *******************************************************************
 * 	 Command Tables that define commands supported by our ChipBoard
 * *******************************************************************
 * -The commands should be entered in each table in order of most frequently used to least frequently used.
 *  Not required but will allow for early exits.
 */

/* **************************
 *  Top level Command  table
 * **************************
 */
static const Command cmd_command_table[] = {
	{"DLY:", CONFIG_DELAY},
	{"PSD:", CONFIG_PSD},
	{"BID:", GET_BOARD_ID},
	{"CFD:", CFD},
	{"MUX:", CONFIG_MUX},
	{"DAC:", CONFIG_DAC},
	{"RST:", RESET},
};

/* **************************
 *  CFD Sub command  table
 * **************************
 */
static const CFDCommand cfd_command_table[] = {
    {"WRT:", WRITE_REG},
    {"RST:", RESET_CFD},
	{"GEN:", CFD_GLOBAL_ENABLE},
};


/* **************************
 * PSD Sub command  table
 * **************************
 */
static const PSDCommand psd_command_table[] = {
    {"SER:", SERIAL_REG},
    {"OD0:", OFFSET_DAC_0},
    {"OD1:", OFFSET_DAC_1},
    {"RST:", RESET_PSD},
    {"TRG:", TRIGGER_MODE},
	{"TS0:", TEST_MODE_0},
	{"TS1:", TEST_MODE_1},
	{"SEL:", CHANNEL_SELECT},
	{"GEN:", PSD_GLOBAL_ENABLE_TKN}
};

const int num_cmd_commands = sizeof(cmd_command_table) / sizeof(Command);
const int num_cfd_commands = sizeof(cfd_command_table) / sizeof(CFDCommand);
const int num_psd_commands = sizeof(psd_command_table) / sizeof(PSDCommand);
const int command_length = 4; // Commands are 4 characters long


bool	isConfigMode() {
	if (!uart_byte_ready()) return false ;
//
// Might be special command
// If it is, STX then send ACK
// If ETX then NAK
//
	if (uart_get_str() == 2 ) {
		if (uartStr[0] == STX) {
			DEBUG_LCD_PRINT_LOCATION("CONFIG MODE!")
			uart_send_byte(ACK) ;
			return true ;
		}
		if (uartStr[0] == ETX) {
			DEBUG_LCD_PRINT_LOCATION("EXIT !")
			uart_send_byte(NAK) ;
			return false ;
		}
	}
	return false ;
}

// ****************************************************
// configHandler()
//
// Routine called when host wants us to configure something.
// Reception of STX is what initiates the call to this
// handler.
// ****************************************************

void	configHandler() {

// Number of bytes returned from str_to_bytes()

	int		numBytes ;

// Pointer to u8 data

	u8		*buff ;

// Value (a byte) we want to transmit to delay chip
// delay_data : 0 a b v w x y z (see datasheet)
// Host sends us a byte with v w x y z
// We'll tack on the channel info i.e. (a b) here
// in command handler

	u8 		dlyVal ;

// Token representing which command was received

	enum	cmd_tokens token ;
	enum	psd_tokens psd_token ;
	enum	cfd_tokens cfd_token ;

// Use when we configure the delay chips

	u8	chip_num ;

// Wait for configuration commands from the host
// Exit the do-loop when we receive a ETX from Host
// ETX says leave configuration mode

    do {
    	numBytes = uart_get_str() ;

// Handle some "special" cases (2 byte strings are special, second byte is NULL)

    	if ( (numBytes == 2) || (numBytes == 1) ){
    		switch (uartStr[0]) {
    			case STX : 	uart_send_byte(NAK) ; // Shouldn't see another STX so NAK
    						return ;
    			case ETX :  uart_send_byte(ACK) ;  // Leave config mode
    						DEBUG_LCD_PRINT_LOCATION("Stand by for event!")
    						return ;
    			default :	uart_send_byte(NAK) ;  // ???? so send NAK
    						DEBUG_LCD_PRINT_LOCATION("Invalid Command")
    						break ;
    		} // end switch
    	} // end if

// So we think we have a configuration command from the host!
// Analyze string and get a token telling us what we need to do

    	token = get_token() ;

// When we return, data field (if any) starts at uartStr[4]

    	switch (token) {

// Configure delay ICs
// Configure the delay chips (For each chip we need to load the 3 channels: R G B
// chip_num :  delay chip (0 - 5)
// delay_data : 0 a b v w x y z (see datasheet)
// Host is sending us the 5-bit value {v w x y z}

    		case CONFIG_DELAY :	buff = &uartStr[4] ;			// string past the :
    			    			numBytes = str_to_bytes(buff) ;		// number of hex bytes
    			    			if (numBytes == 18) {				// Need 18 bytes to configure delay ICs
    	   							for (chip_num = 0; chip_num < 6; chip_num++) {
    	   								dlyVal = buff[(3 * chip_num)] | (1 << 5 );			// Red channel i.e. channel 1
    	    							configure_delay_chips(chip_num, dlyVal) ;
    	   								dlyVal = buff[(3 * chip_num) + 1] | (2 << 5) ;    	// Green channel i.e. channel 2
    	    							configure_delay_chips(chip_num, dlyVal) ;
    	   								dlyVal = buff[(3 * chip_num) + 2] | (3 << 5 );    	// Blue channel i.e. channel 3
    	    							configure_delay_chips(chip_num, dlyVal) ;
    			    				} // end for-loop
    	    						uart_send_byte(ACK) ;
    			    			} else {
    			    				uart_send_byte(NAK) ;
    			    			} // end if-then-else
    							break ;

// Configure PSD serial register

    		case CONFIG_PSD :	buff = &uartStr[8] ;  			// 2x 3 ascii character command plus the :

    							psd_token = get_psd_token();

    							DEBUG_LCD_PRINT_STR("In PSD ctrl", buff)

    							switch  (psd_token){

									case SERIAL_REG :	numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
														if (numBytes == 12) {				// Takes 12 bytes to configure both PSD chips
															configure_psd_chips(buff) ;
															uart_send_byte(ACK) ;
															break;
														} else {
															uart_send_byte(NAK) ;
															break;
														}

									case OFFSET_DAC_0 : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return

														if (numBytes == 2) {				// Takes 2 bytes to configure offset DAC
															configure_psd_0_dac(buff[0], buff[1]) ;
															uart_send_byte(ACK) ;
															break;
														} else {
															uart_send_byte(NAK) ;
															break;
														}
									case OFFSET_DAC_1 : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
														if (numBytes == 2) {				// Takes 2 bytes to configure offset DAC
															configure_psd_1_dac(buff[0], buff[1]) ;
															uart_send_byte(ACK) ;
															break;
														} else {
															uart_send_byte(NAK) ;
															break;
														}
									case TEST_MODE_0 : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
									DEBUG_LCD_PRINT_LOCATION("In Test Mode PSD 0");
														if (numBytes == 2) {				// Takes 2 byte to configure test mode
															configure_psd_0_test_mode(buff[0], buff[1]);
															uart_send_byte(ACK) ;
															break;
														} else {
															uart_send_byte(NAK) ;
															break;
														}
									case TEST_MODE_1 : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
									DEBUG_LCD_PRINT_LOCATION("In Test Mode PSD 1");
														if (numBytes == 2) {				// Takes 2 byte to configure test mode
															configure_psd_1_test_mode(buff[0], buff[1]);
															uart_send_byte(ACK) ;
															break;
														} else {
															uart_send_byte(NAK) ;
															break;
														}
									case TRIGGER_MODE : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return

														if (numBytes == 1) {				// Takes 1 byte to configure trigger mode
															configure_psd_trigger_mode(buff[0]);
															uart_send_byte(ACK) ;
															break;
														} else {
															uart_send_byte(NAK) ;
															break;
														}
									case PSD_GLOBAL_ENABLE_TKN : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
									DEBUG_LCD_PRINT_LOCATION("PSD GLOBAL ENABLE");
														if (numBytes == 1) {				// 1 bit in 1 byte high or low
															psd_global_enable(buff[0]);
															uart_send_byte(ACK) ;
															break;
														} else {
															uart_send_byte(NAK) ;
															break;
														}

									default:	uart_send_byte(NAK) ;
    								    		break ;
    							}
    							break ;

			// Get board ID

       		case GET_BOARD_ID :	if (useLCD) {

       	    						lcd_set_cursor(0,0) ;
       	    						lite_sprintf(LCDstr, "Board ID: %d", get_board_id() ) ;
       	    						lcd_print_str(LCDstr) ;
       	    					}
    							uart_send_byte(ACK) ;
    							break ;

// Write to CFD register

       		case CFD :	buff = &uartStr[8] ;  			// 2x 3 ascii character command plus the :

						cfd_token = get_cfd_token();

						DEBUG_LCD_PRINT_STR("In CFD ctrl", buff)

						switch  (cfd_token){

							case WRITE_REG :  	numBytes = str_to_bytes(buff) ;			// number of hex bytes it should return
												DEBUG_LCD_PRINT_CONFIG("In WRT REG, ", numBytes)
												if (numBytes == 2) {					// 2 bytes {addr/mode, data}
													write_cfd_reg(buff[0], buff[1]) ;
													uart_send_byte(ACK) ;
												} else {
													uart_send_byte(NAK) ;
												} // end if-then-else
												break ;

							case RESET_CFD :  	numBytes = str_to_bytes(buff) ;			// number of hex bytes it should return
												DEBUG_LCD_PRINT_STR("In RESET CFD", buff)
												if (numBytes == 0) {					// 2 bytes {addr/mode, data}
												cfd_reset();
												DEBUG_LCD_PRINT_STR("CFD RESET", buff)
												uart_send_byte(ACK) ;
												} else {
												uart_send_byte(NAK) ;
												} // end if-then-else
												break ;

							case CFD_GLOBAL_ENABLE :  	numBytes = str_to_bytes(buff) ;			// number of hex bytes it should return
												DEBUG_LCD_PRINT_STR("In GLOBAL_EN CFD", buff)
												if (numBytes == 1) {					// 1 bit in 1 byte high or low
												cfd_global_enable(buff[0]);
												uart_send_byte(ACK) ;
												} else {
												uart_send_byte(NAK) ;
												} // end if-then-else
												break ;

							default:	uart_send_byte(NAK) ;
										break ;
						}
						break ;

// Configure AMUX Channel

       		case CONFIG_MUX : buff = &uartStr[4] ;			// string past the :
       						  numBytes = str_to_bytes(buff) ;		// number of hex bytes

       						  DEBUG_LCD_PRINT_CONFIG("Config MUX command:", numBytes);
       						  if (numBytes == 1) {					// 1 byte really 5 bit config data

       							  	write_mux(buff[0]);
									uart_send_byte(ACK) ;

       						  } else {
       							  uart_send_byte(NAK) ;
       						  } // end if-then-else
       						  break ;

       		case CONFIG_DAC : buff = &uartStr[4] ;
       						  numBytes = str_to_bytes(buff) ;		// number of hex bytes
       						  u16 data = buff[0]<<8 | buff[1];

							  DEBUG_LCD_PRINT_CONFIG("Config DAC command:", numBytes);

							  if (numBytes == 2) {					// 2 byte config word

									write_dac(data);
									uart_send_byte(ACK) ;
									 break ;
							  } else {
									  uart_send_byte(NAK) ;
							  } // end if-then-else
								  break ;
							// Couldn't understand or cannot do command
							// Send back negative acknowledge

    		default :			uart_send_byte(NAK) ;
    							break ;

    	} // end switch

    } while (true) ; // end do-while loop

// Not really an infinite loop, we exit when ETX comes in

	return ;
}

// ****************************************************
// isConfigMode()
// Check if STX as a string has come in from host
// uartStr is a global
// ***************************************************



// *****************************************************************
// get_token() takes the global string, uartStr, and returns a token
// ******************************************************************
enum cmd_tokens get_token() {
	int		i ;

	for (i = 0; i < num_cmd_commands; i++) {
		// Compare the command string with the corresponding section of uartStr
		if (compare_strings((const char *)&uartStr[0], cmd_command_table[i].command, command_length)) {
			return cmd_command_table[i].token;
		}
	}

	return ERROR;
}


/*
 * Processes the next three characters to return the PSD config sub type
 */
enum psd_tokens get_psd_token() {
	int		i ;

	for (i = 0; i < num_psd_commands; i++) {
		// Compare the command string with the corresponding section of uartStr
		if (compare_strings((const char *)&uartStr[4], psd_command_table[i].command, command_length)) {
			return psd_command_table[i].token;
		}
	}
	return ERROR_PSD;
}


/*
 * Processes the next three characters to return the CFD config sub type
 */
enum cfd_tokens get_cfd_token() {

	int		i ;

	for (i = 0; i < num_cfd_commands; i++) {
		// Compare the command string with the corresponding section of uartStr
		if (compare_strings((const char *)&uartStr[4], cfd_command_table[i].command, command_length)) {
			return cfd_command_table[i].token;
		}
	}
	return ERROR_CFD;

}



// ******************************************************************************
// Routine to get the board ID (6 bits) and save to global variable board_id
// ******************************************************************************

u8	get_board_id() {
	u8		board_id ;
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
// Routine to control the global_enable line
// Value should be either LOW or HIGH
// *****************************************************
void	cfd_global_enable(u8 value) {
	write_gpio_port(CFD_PORT, 1, CFD_GLOBAL_ENA, value) ;
}

// ***************************************************
// Routine to control the cfd strobe line
// Value should be either LOW or HIGH
// *****************************************************
void	cfd_strobe(u8 value) {
	write_gpio_port(CFD_PORT, 1, CFD_STB, value) ;
}

// ***************************************************
// Routine to reset and hold the cfd reset in correct state.
// CFD_rese is low active reset
// *****************************************************
void 	cfd_reset(){
	write_gpio_port(CFD_PORT, 1, CFD_RESET, HIGH) ;
	usleep(1) ;
	write_gpio_port(CFD_PORT, 1, CFD_RESET, LOW) ;
	usleep(100) ;
	write_gpio_port(CFD_PORT, 1, CFD_RESET, HIGH) ;
	return;
}








// ******************************************************************************
// Write to CFD chip internal registers
// ******************************************************************************
void	write_cfd_reg(u8 addr_mode, u8 data) {
	DEBUG_LCD_PRINT_LOCATION("In CFD write")
// Make sure strobe is LOW

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


// ***********************************
// Load the two PSD chips
// Each psd register is 48 bits wide
// 96 serial clocks
// Least significant bit goes in first
// Put data out on falling edge of clock
// PSD chip latches data on rising edge
// *********************************

void  configure_psd_chips(u8 *psd_config_data) {
	DEBUG_LCD_PRINT_LOCATION("In PSD serial")
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

// It would be nice if returned an array of sdo data rather than void!!!

}


// ***************************************************
// Routine to control the PSD DAC strobe line
// Value should be either LOW or HIGH
// psd_chip_number must be 0 or 1
// *****************************************************
void	psd_strobe(u8 value, u8 psd_chip_number) {
	if (psd_chip_number){
		write_gpio_port(PSD_MISC_PORT, 1, PSD_DAC_STB_1, value) ;
	}else{
		write_gpio_port(PSD_MISC_PORT, 1, PSD_DAC_STB_0, value) ;
	}
}



/*
// **********************************************
 * 	PSD 0 Offset DAC config
 * **********************************************
 *
 * 	This function takes in the data words (5 bit sign/mag DAC value) and address [channel(5 bits) | sub channel(2 LSB)] and loads it into
 * 	the internal channel registers of PSD 0 chip.
 *
 * 	Steps:
 * 		- Ensure sel_ext_addr is high
 * 		- Ensure dac_stb is low
 * 		- Set channel address bits on pins a4 - a0, sub channel bits sc1 - sc0
 * 		- dac_stb high
 * 		- Set dac value on pins a4 - a0
 * 		- dac_stb low
 * 		- Reset sel_ext_addr low
 *
// *********************************************
*/
void  configure_psd_0_dac(u8 data, u8 addr) {
	DEBUG_LCD_PRINT_LOCATION("In PSD DAC 0")
	u8 subchannel;

	subchannel = addr & 0x3;
	addr = addr >> 2;

	write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_0, HIGH) ;

	psd_strobe(LOW, 0);


	write_gpio_port(PSD_ADDR_PORT, 5, PSD0_CHAN_ADDR_OUT_0, addr);
	write_gpio_port(PSD_MISC_PORT, 2, PSD_SC0_0, subchannel);

	// address data valid
	psd_strobe(HIGH, 0);

	write_gpio_port(PSD_ADDR_PORT, 5, PSD0_CHAN_ADDR_OUT_0, data);

	// dac data valid
	psd_strobe(LOW, 0);

	write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_0, LOW) ;
    return ;
}

/*
// **********************************************
 * 	PSD 1 Offset DAC config
 * **********************************************
 * Identical to `configure_psd_1_dac` with changed pin names. Refer to that for documentation
 */
void  configure_psd_1_dac( u8 data, u8 addr) {
	DEBUG_LCD_PRINT_LOCATION("In PSD DAC 1")
	u8 subchannel;

	subchannel = addr & 0x3;
	addr = addr >> 2;

	write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_1, HIGH) ;

	psd_strobe(LOW, 1);


	write_gpio_port(PSD_ADDR_PORT, 5, PSD1_CHAN_ADDR_OUT_0, addr);
	write_gpio_port(PSD_MISC_PORT, 2, PSD_SC0_1, subchannel);

	// address data valid
	psd_strobe(HIGH, 1);

	write_gpio_port(PSD_ADDR_PORT, 5, PSD1_CHAN_ADDR_OUT_0, data);

	// dac data valid
	psd_strobe(LOW, 1);

	write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_1, LOW) ;
    return ;
}


/*
// **********************************************
 * 	PSD Trigger Mode Config
 * **********************************************
 *  Both chips will be set to the same trigger mode,
 *  Only two bits are valid in the data.
 *  2 bit mode data word [Bypass(LSB), Ack_All]
 */
void configure_psd_trigger_mode(u8 data){
	DEBUG_LCD_PRINT_LOCATION("In PSD trig Mode")
	write_gpio_port(PSD_MISC_PORT, 2, PSD_ACQ_ALL, data);

}

// ***************************************************
// Routine to control the PSD global_enable line
// Value should be either LOW or HIGH
// TODO: This is a bodge for PCB Rev 2 routing, fix it properly at some point.
// *****************************************************

void	psd_global_enable(u8 value) {
	write_gpio_port(PSD_ADDR_PORT, 1, PSD_GLOBAL_ENABLE, value) ;
}






/*
// **********************************************
 * 	PSD Test Mode Config
 * **********************************************
 * Configures the PSD0 chip test mode.
 * This function takes in the address [channel(5 bits) | sub channel(2 LSB)] and enable [1 bit].
 *
 * Sets the PSD0 in test mode if enable is High.
 * Leaves the External Address selection line high to allow the PSD0 to remain in test mode.
 *
 * Note: A subsequent disable call or any dac config will set the ext addr sel line low.
 *
 *
 *
 * TODO: enforce that only PSD 0 or PSD 1 can have test mode active at once.
 *
 */
void configure_psd_0_test_mode(u8 addr, u8 enable){
	DEBUG_LCD_PRINT_LOCATION("In PSD 0 TEST Mode")

	u8 subchannel;

	if (enable == 1){

		subchannel = addr & 0x3;
		addr = addr >> 2;
		DEBUG_LCD_PRINT_NUMBER("sub-ch: ", subchannel)
		write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_0, HIGH) ;
		write_gpio_port(PSD_ADDR_PORT, 5, PSD0_CHAN_ADDR_OUT_0, addr);
		write_gpio_port(PSD_MISC_PORT, 2, PSD_SC0_0, subchannel);
	}


	write_gpio_port(PSD_MISC_PORT, 1, PSD_TEST_MODE_INT_0, enable);
	//write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_0, enable) ;

}



/*
// **********************************************
 * 	PSD Test Mode Config
 * **********************************************
 * Configures the PSD1 chip test mode.
 * This function takes in the address [channel(5 bits) | sub channel(2 LSB)] and enable [1 bit].
 *
 * Sets the PSD1 in test mode if enable is High.
 * Leaves the External Address selection line high to allow the PSD1 to remain in test mode.
 *
 * Note: A subsequent disable call or any dac config will set the ext addr sel line low.
 *
 *
 *
 * TODO: enforce that only PSD 0 or PSD 1 can have test mode active at once.
 *
 */
void configure_psd_1_test_mode(u8 addr, u8 enable){
	DEBUG_LCD_PRINT_LOCATION("In PSD 1 TEST Mode")

	u8 subchannel;

	if (enable == 1){

		subchannel = addr & 0x3;
		addr = addr >> 2;
		DEBUG_LCD_PRINT_NUMBER("address: ", addr)
		write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_1, HIGH) ;
		write_gpio_port(PSD_ADDR_PORT, 5, PSD1_CHAN_ADDR_OUT_0, addr);
		write_gpio_port(PSD_MISC_PORT, 2, PSD_SC0_1, subchannel);
	}


	write_gpio_port(PSD_MISC_PORT, 1, PSD_TEST_MODE_INT_1, enable);
	write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_1, enable) ;

}




// *****************************************************************S
// Configure the delay chips
// chip_num :  delay chip (0 - 5)
// delay_data : 0 a b v w x y z (see datasheet)
// *****************************************************************

void configure_delay_chips(u8 chip_num, u8 delay_data) {
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
   value = (ena_val << 2) ; 	// enable with clock and data low so now we have 8 bits
   write_gpio_port(DELAY_CHIP_PORT, 8, DELAY_DATA, value) ;

// Put data out on rising edge of clock

    for (j = 7; j >= 0 ; j--) {
    	data_val = delay_data & (1 << j) ;
    	data_val = (data_val >> j) ;

    	clk_val = HIGH ;
    	value = data_val | (clk_val << 1) ;
    	write_gpio_port(DELAY_CHIP_PORT, 2, DELAY_DATA, value) ;

    	clk_val = LOW ;
    	value = clk_val ;
    	write_gpio_port(DELAY_CHIP_PORT, 1, DELAY_CLK, value) ;
    }
        
// Bring serial enable high (i.e. NOT active)

    ena_val = 0x003f ;
    clk_val = 0 ;
    data_val = 0 ;
	value = data_val | (clk_val << 1) | (ena_val << 2) ;
	write_gpio_port(DELAY_CHIP_PORT, 8, DELAY_DATA, value) ;

    return ;
}



/*
// **********************************************
 * 	MUX Configuration low level implementation
 * **********************************************
 *
 * 	This function takes in the bitmask to set the mux configuration
 *
 * 	The ADG1206 MUX takes in a 5 bit control signal.
 * 	The 4 most significant bits are the channel # in binary, and the LSB is the Enable line.
 * 	if EN is 0 the rest of the control signals are ignored, MUX is disabled.
 *
 * 	For example, data=0011 1 -> turn on channel 4
 * 				 data=0000 1 -> turn on channel 1
 * 				 data=XXXX 0 -> disable mux
 *
 * CAUTION!!!: This function does no data validation and directly writes the data to the mux lines.
// *********************************************
*/
void	write_mux(u8 data) {


	write_gpio_port(MUX_PORT, 5, MUX_EN, data) ;


	return ;
}


/*
// **********************************************
 * 	DAC Configuration low level implementation
 * **********************************************
 * 	This function takes in the 2 byte config data and shifts it into the DAC register.
 *
 * 	The LTC1660 DAC requires 4 address bits[a3-a0] followed by 10 data bits[d9-d0] representing voltage setting for the DAC channel.
 * 	+ 2 don't care bits to align the word to its 16 bit shit register.
 *
 * 	MSB is shifted first for both address and data. Data is  latched by LTC1660 on the rising edge and sifted out on falling edge
 * 	of the SCK.
 *
 * 	Data Word: [a3 a2 a1 a0| d9 d8 d7 d6| d5 d4 d3 d2| d1 d0 x1 x0]
 *
 * 	Control Sequence:
 * 	Initial state: SCK - High, DAC_LD - High
 * 	-> SCK - pulled low, a3 shifted out
 * 	-> DAC_LD - pulled low now Load Mode
 * 	-> SCK - pulled high, a3 latched
 * 	-> SCK - pulled low,  a2 shifted out
 * 	 				--
 * 	 				--
 * 	-> SCK - pulled high, x1 latched
 * 	-> SCK - pulled low,  x0 shifted out
 * 	-> SCK - pulled high, x0 latched
 * 	-> DAC_LD - pulled high, DAC is now updated
 *
 * CAUTION!!!: This function does no data validation and directly writes the data to the DAC lines.
// *********************************************
*/
void	write_dac(u16 data) {


//write_gpio_port(MUX_PORT, 5, MUX_EN, data) ;

	int i;
	u8 value;
	u8 dac_din;
	u8 dac_sclk;
	u8 dac_ld;

	// 3 bit GPIO value mask [dac_din, dac_sclk, dac_ld]

	//start state
	dac_sclk = LOW;
	dac_ld = HIGH;

	value = (dac_sclk << 1) | (dac_ld) ;

	write_gpio_port(DAC_OUT_PORT, 2, DAC_LD, value) ;

//	// Push out MSB data a3 and pull sclk low.
//
//	dac_din = ( data & (1 << 15) ) >> 15; // select the 16th bit
//	dac_sclk = LOW;
//
//	value = (dac_din << 1) | (dac_sclk) ;
//	write_gpio_port(DAC_OUT_PORT, 2, DAC_SCLK, value) ;

	//DAC_LD - pulled low
	dac_ld = LOW;
	write_gpio_port(DAC_OUT_PORT, 1, DAC_LD, dac_ld) ;


	for (i = 15; i >= 0; i--){


		dac_din = ( data & (1 << i) ) >> i;
		dac_sclk = LOW;

		//CLK is set low, data pushed out
		value = (dac_din << 1) | (dac_sclk) ;
		write_gpio_port(DAC_OUT_PORT, 2, DAC_SCLK, value) ;

		//CLK is set high, data latched by DAC
		dac_sclk = HIGH;
		write_gpio_port(DAC_OUT_PORT, 1, DAC_SCLK, dac_sclk) ;

	}
	//DAC_LD - pulled high
	dac_ld = HIGH;
	write_gpio_port(DAC_OUT_PORT, 1, DAC_LD, dac_ld) ;

	DEBUG_LCD_PRINT_LOCATION("In write_dac")

	return ;
}

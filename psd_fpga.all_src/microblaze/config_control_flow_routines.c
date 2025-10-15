#include "main.h"


/* *******************************************************************
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
	{"CFD:", CONFIG_CFD},
	{"MUX:", CONFIG_MUX},
	{"DAC:", CONFIG_DAC},
	{"TDC:", CONFIG_TDC},
	{"RST:", RESET},
	{"ACQ:", ACQ_MODE},
	{"VER:", GET_BOARD_VERSION},
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


/* **************************
 * MUX Sub command  table
 * **************************
 */
static const MUXCommand mux_command_table[] = {
    {"ORO:", OR_MUX},
    {"AMP:", AMP_MUX},
    {"CFD:", CFD_MUX},
    {"INT:", INTX_MUX},
	{"TEV:", TAKE_EVENT_MUX},
	{"TSP:", TIMESTAMP_MUX}
};

const int num_cmd_commands = sizeof(cmd_command_table) / sizeof(Command);
const int num_cfd_commands = sizeof(cfd_command_table) / sizeof(CFDCommand);
const int num_psd_commands = sizeof(psd_command_table) / sizeof(PSDCommand);
const int num_mux_commands = sizeof(mux_command_table) / sizeof(MUXCommand);
const int command_length = 4; // Commands are 4 characters long


// Token representing which command was received

enum	cmd_tokens token ;

enum	cfd_tokens cfd_token ;
// Number of bytes returned from str_to_bytes()

int		numBytes ;



/* ****************************************************
// top_control_flow()
 *
 * Entry point for the configuration command parsing loop.
 *
 * **************************************************** */
void	top_control_flow() {

	u8		*buff ;		// Pointer to u8 data

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

    		case CONFIG_DELAY :	buff = &uartStr[4] ;			// string past the :
    			    			numBytes = str_to_bytes(buff) ;		// number of hex bytes
    			    			DEBUG_LCD_PRINT_CONFIG("Config Delay command:", numBytes);
    			    			if (numBytes == 18) {				// Need 18 bytes to configure delay ICs
    	   							configure_delay_chips(buff);
    	    						uart_send_byte(ACK) ;
    			    			} else {
    			    				uart_send_byte(NAK) ;
    			    			}
    							break ;

    		case CONFIG_PSD :	buff = &uartStr[8] ;  		  //data field (if any) starts at uartStr[8] past PSD:_ _ _:data field
    							psd_control_flow(buff);
    							break ;

       		case GET_BOARD_ID :	if (useLCD) {
       	    						lcd_set_cursor(0,0) ;
       	    						lite_sprintf(LCDstr, "Board ID: %d", get_board_id() ) ;
       	    						lcd_print_str(LCDstr) ;
       	    					}
       							uart_send_byte(ACK) ;
       							xil_printf("Getting board id %d \r\n", get_board_id()) ;
       							uart_send_byte(get_board_id());

    							break ;


       		case CONFIG_CFD :	buff = &uartStr[8] ;  		//data field (if any) starts at uartStr[8] past CFD:_ _ _:data field
       							cfd_control_flow(buff);
								break ;


       		case CONFIG_MUX : 	buff = &uartStr[8] ; 	//data field (if any) starts at uartStr[8] past MUX:_ _ _:data field
       							mux_control_flow(buff);
       							break ;

       		case CONFIG_DAC : buff = &uartStr[4] ;

       						  numBytes = str_to_bytes(buff) ;		// number of hex bytes
       						  u16 data = buff[0]<<8 | buff[1];

							  DEBUG_LCD_PRINT_CONFIG("Config DAC command:", numBytes);

							  if (numBytes == 2) {					// 2 byte config word
									write_dac(data);
									uart_send_byte(ACK) ;
							  } else {
									  uart_send_byte(NAK) ;
							  } // end if-then-else
							  break ;

       		case ACQ_MODE :  buff = &uartStr[4] ;
							 numBytes = str_to_bytes(buff) ;

							 if (numBytes == 1) {					// 1 byte really 1 bit config data
									set_mode(buff[0]);
									uart_send_byte(ACK) ;
							 } else {
								  uart_send_byte(NAK) ;
							 }
							 break ;

       		case GET_BOARD_VERSION :	if (useLCD) {
       		       	    						lcd_set_cursor(0,0) ;
       		       	    						lite_sprintf(LCDstr, "Firmware Version: %s", PROJECT_VERSION ) ;
       		       	    						lcd_print_str(LCDstr) ;
       		       	    					}
       		       							uart_send_byte(ACK) ;
       		       							xil_printf("Firmware Version: %s \r\n", PROJECT_VERSION) ;
       		       							uart_send_str(PROJECT_VERSION, 6);

       		    							break ;

       		default :	uart_send_byte(NAK) ;
						break ;

    	} // end switch
    	usleep(200) ;
    } while (true) ; // end do-while loop

// Not really an infinite loop, we exit when ETX comes in

	return ;
}


/* *****************************************************************
 * cfd_control_flow(u8 *buff)
 *
 * Handles the control flow for any CFD commands
 * *****************************************************************
 */
void cfd_control_flow(u8 *buff){

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
							if (numBytes == 0) {
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

}

/* *****************************************************************
 * psd_control_flow(u8 *buff)
 *
 * Handles the control flow for any PSD commands
 * *****************************************************************
 */
void psd_control_flow(u8 *buff){

	 enum	psd_tokens psd_token = get_psd_token();

	DEBUG_LCD_PRINT_STR("In PSD ctrl", buff)

	switch  (psd_token){

		case SERIAL_REG :	numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
							if (numBytes == 12) {				// Takes 12 bytes to configure both PSD chips
								configure_psd_chips(buff) ;
								uart_send_byte(ACK) ;
							} else {
								uart_send_byte(NAK) ;
							}
							break;

		case OFFSET_DAC_0 : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
							if (numBytes == 2) {				// Takes 2 bytes to configure offset DAC
								configure_psd_0_dac(buff[0], buff[1]) ;
								uart_send_byte(ACK) ;
							} else {
								uart_send_byte(NAK) ;
							}
							break;

		case OFFSET_DAC_1 : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
							if (numBytes == 2) {				// Takes 2 bytes to configure offset DAC
								configure_psd_1_dac(buff[0], buff[1]) ;
								uart_send_byte(ACK) ;
							} else {
								uart_send_byte(NAK) ;
							}break;

		case TEST_MODE_0 : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
		DEBUG_LCD_PRINT_LOCATION("In Test Mode PSD 0");
							if (numBytes == 2) {				// Takes 2 byte to configure test mode
								configure_psd_0_test_mode(buff[0], buff[1]);
								uart_send_byte(ACK) ;
							} else {
								uart_send_byte(NAK) ;
							}
							break;

		case TEST_MODE_1 : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
		DEBUG_LCD_PRINT_LOCATION("In Test Mode PSD 1");
							if (numBytes == 2) {				// Takes 2 byte to configure test mode
								configure_psd_1_test_mode(buff[0], buff[1]);
								uart_send_byte(ACK) ;
							} else {
								uart_send_byte(NAK) ;
							}
							break;

		case TRIGGER_MODE : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return

							if (numBytes == 1) {				// Takes 1 byte to configure trigger mode
								configure_psd_trigger_mode(buff[0]);
								uart_send_byte(ACK) ;
							} else {
								uart_send_byte(NAK) ;
							}
							break;


		case PSD_GLOBAL_ENABLE_TKN : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
							DEBUG_LCD_PRINT_LOCATION("PSD GLOBAL ENABLE");
							if (numBytes == 1) {				// 1 bit in 1 byte high or low
								psd_global_enable(buff[0]);
								uart_send_byte(ACK) ;
							} else {
								uart_send_byte(NAK) ;
							}
							break;

		case RESET_PSD : numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
						DEBUG_LCD_PRINT_LOCATION("PSD RST");
						if (numBytes == 0) {	// RESET ALL
							psd_reset_all();
							xil_printf("PSD chips Reset ALL \r\n") ;
							uart_send_byte(ACK) ;
						} else if (numBytes == 1) {		// 1bit(LSB) in 1 byte, high- pulse FORCE RESET, low- pulse PSD_RESET(digital)
							psd_reset(buff[0]);
							uart_send_byte(ACK) ;
						} else {
							uart_send_byte(NAK) ;
						}
						break;

		default:	uart_send_byte(NAK) ;
					break ;
	}
}




/* *****************************************************************
 * mux_control_flow(u8 *buff)
 *
 * Handles the control flow for any MUX commands
 * *****************************************************************
 */
void mux_control_flow(u8 *buff){

	enum mux_tokens mux_token = get_mux_token();

	switch  (mux_token){

		case AMP_MUX :  	numBytes = str_to_bytes(buff) ;			// number of hex bytes it should return

						if (numBytes == 1) {					// 1 byte really 5 bit config data
							write_mux(buff[0]);
							xil_printf("Preamp MUX configured \r\n");
							uart_send_byte(ACK) ;
						} else {
							xil_printf("Command ERROR: MUX:AMP: - Incorrect Data length  \r\n");
							uart_send_byte(NAK) ;
					  }
					  break ;

		case OR_MUX :  	numBytes = str_to_bytes(buff) ;			// number of hex bytes it should return

								if (numBytes == 1) {					// 1 byte really 2 bit config data
									write_or_mux(buff[0]);
									xil_printf("OR MUX configured %d \r\n", buff[0]);
									uart_send_byte(ACK) ;
								} else {
									xil_printf("Command ERROR: MUX:AMP: - Incorrect Data length  \r\n");
									uart_send_byte(NAK) ;
							  }
							  break ;

		case CFD_MUX :  	numBytes = str_to_bytes(buff) ;			// number of hex bytes it should return

							if (numBytes == 1) {					// 1 byte really 1 bit config data
								write_cfd_mux(buff[0]);
								xil_printf("CFD out MUX configured \r\n");
								uart_send_byte(ACK) ;
							} else {
								xil_printf("Command ERROR: MUX:CFD: - Incorrect Data length  \r\n");
								uart_send_byte(NAK) ;
						  }
						  break ;

		case INTX_MUX :  	numBytes = str_to_bytes(buff) ;			// number of hex bytes it should return

							if (numBytes == 1) {					// 1 byte really 1 bit config data
								write_intx_mux(buff[0]);
								xil_printf("INTX out MUX configured \r\n");
								uart_send_byte(ACK) ;
							} else {
								xil_printf("Command ERROR: MUX:INT: - Incorrect Data length  \r\n");
								uart_send_byte(NAK) ;
						  }
						  break ;

		case TAKE_EVENT_MUX :  	numBytes = str_to_bytes(buff) ;			// number of hex bytes it should return

							if (numBytes == 1) {					// 1 byte really 1 bit config data
								write_take_event_mux(buff[0]);
								xil_printf("INTX out MUX configured \r\n");
								uart_send_byte(ACK) ;
							} else {
								xil_printf("Command ERROR: MUX:INT: - Incorrect Data length  \r\n");
								uart_send_byte(NAK) ;
						  }
						  break ;
		case TIMESTAMP_MUX :  	numBytes = str_to_bytes(buff) ;			// number of hex bytes it should return

							if (numBytes == 1) {					// 1 byte really 1 bit config data
								write_timestamp_mux(buff[0]);
								xil_printf("INTX out MUX configured \r\n");
								uart_send_byte(ACK) ;
							} else {
								xil_printf("Command ERROR: MUX:INT: - Incorrect Data length  \r\n");
								uart_send_byte(NAK) ;
						  }
						  break ;



		default:	uart_send_byte(NAK) ;
					xil_printf("Command ERROR: Unrecognized MUX command.   \r\n");
					break ;
	}

}



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

/*
 * Processes the next three characters to return the CFD config sub type
 */
enum mux_tokens get_mux_token() {

	int		i ;

	for (i = 0; i < num_mux_commands; i++) {
		// Compare the command string with the corresponding section of uartStr
		if (compare_strings((const char *)&uartStr[4], mux_command_table[i].command, command_length)) {
			return mux_command_table[i].token;
		}
	}
	return ERROR_MUX;

}



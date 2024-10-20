#include	"main.h"
// Changes begin now.
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Configuration routines
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// #define DEBUG
bool	isConfigMode() {
	if (!uart_byte_ready()) return false ;
//
// Might be special command
// If it is, STX then send ACK
// If ETX then NAK
//
	if (uart_get_str() == 2 ) {
		if (uartStr[0] == STX) {
			uart_send_byte(ACK) ;
			return true ;
		}
		if (uartStr[0] == ETX) {
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
    						return ;
    			default :	uart_send_byte(NAK) ;  // ???? so send NAK
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

    		case CONFIG_PSD :	buff = &uartStr[4] ;  			// 3 ascii character command plus the :
								numBytes = str_to_bytes(buff) ;		// number of hex bytes it should return
								if (numBytes == 12) {				// Takes 12 bytes to configure both PSD chips
									configure_psd_chips(buff) ;
									uart_send_byte(ACK) ;
									break;
								} else {
									uart_send_byte(NAK) ;
									break ;
								}

// Get board ID

       		case GET_BOARD_ID :	if (useLCD) {

       	    						lcd_set_cursor(1,0) ;
       	    						lite_sprintf(LCDstr, "Board ID: %d", get_board_id() ) ;
       	    						lcd_print_str(LCDstr) ;
       	    						sleep(2) ;
       	    					}
    							uart_send_byte(ACK) ;
    							break ;

// Write to CFD register

       		case WRITE_TO_CFD :	buff = &uartStr[4] ;  					// 3 ascii character command plus the :
								numBytes = str_to_bytes(buff) ;			// number of hex bytes it should return
    			    			if (numBytes == 2) {					// 2 bytes {addr/mode, data}
           							write_cfd_reg(buff[0], buff[1]) ;
    	    						uart_send_byte(ACK) ;
    			    			} else {
    			    				uart_send_byte(NAK) ;
    			    			} // end if-then-else
    							break ;


// Configure AMUX Channel

       		case CONFIG_MUX : buff = &uartStr[4] ;			// string past the :
       						  numBytes = str_to_bytes(buff) ;		// number of hex bytes

#ifdef DEBUG
       							  if (useLCD) {
       								  lcd_clear();
       								  lite_sprintf(LCDstr, "Config MUX command:") ;
       								  lcd_print_str(LCDstr) ;
       								  lcd_set_cursor(1,0) ;
       								  lite_sprintf(LCDstr, "# command bytes: %d", numBytes) ;
       								  lcd_print_str(LCDstr) ;
       								  lcd_set_cursor(2,0) ;

       								  sleep(2) ;
       							  	  }
#endif
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


#ifdef DEBUG
       							  if (useLCD) {
       								  lcd_clear();
       								  lite_sprintf(LCDstr, "Config DAC command:") ;
       								  lcd_print_str(LCDstr) ;
       								  lcd_set_cursor(1,0) ;
       								  lite_sprintf(LCDstr, "# command bytes: %d", numBytes) ;
       								  lcd_print_str(LCDstr) ;
       								  lcd_set_cursor(2,0) ;

       								  sleep(2) ;
       							  	  }
#endif
							  if (numBytes == 2) {					// 2 byte config word

									write_dac(data);
									uart_send_byte(ACK) ;

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

// Flag for each command

	bool 	isDEL = true ;
	bool	isPSD = true ;
	bool	isBID = true ;
	bool	isCFD = true ;
	bool	isRST = true ;
	bool	isDEB = true ;
	bool	isMUX = true ;
	bool	isDAC = true ;


// Our commands

	u8	del[4]  = {'D', 'L', 'Y', ':'} ;
	u8	psd[4]  = {'P', 'S', 'D', ':'} ;
	u8	bid[4]  = {'B', 'I', 'D', ':'} ;
	u8	cfd[4]  = {'C', 'F', 'D', ':'} ;
	u8	mux[4]  = {'M', 'U', 'X', ':'} ;
	u8	dac[4]  = {'D', 'A', 'C', ':'} ;
	u8	rst[4]  = {'R', 'S', 'T', ':'} ;

// See if we recognize a command

	for (i = 0; i < 4; i++) {
		if (uartStr[i] != del[i]) isDEL = false ;
		if (uartStr[i] != psd[i]) isPSD = false ;
		if (uartStr[i] != bid[i]) isBID = false ;
		if (uartStr[i] != cfd[i]) isCFD = false ;
		if (uartStr[i] != mux[i]) isMUX = false ;
		if (uartStr[i] != dac[i]) isDAC = false ;
		if (uartStr[i] != rst[i]) isRST = false ;
	}

	if (isDEL == true) return CONFIG_DELAY ;
	if (isPSD == true) return CONFIG_PSD ;
	if (isBID == true) return GET_BOARD_ID ;
	if (isCFD == true) return WRITE_TO_CFD ;
	if (isMUX == true) return CONFIG_MUX ;
	if (isDAC == true) return CONFIG_DAC;

	return ERROR ;
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

// It would be nice if returned an array of sdo data rather than void!!!

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

#ifdef DEBUG
       							  if (useLCD) {
       								  lcd_clear();
       								  lcd_set_cursor(0,0) ;
       								  lite_sprintf(LCDstr, "->Inside write_mux:") ;
       								  lcd_print_str(LCDstr) ;
       								  lcd_set_cursor(1,0) ;
       								  lite_sprintf(LCDstr, "Data: %x", data) ;
       								  lcd_print_str(LCDstr) ;
       								  sleep(2) ;
       							  	  }
#endif

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
 * 	MSB is shifted first for both address and data. Data is latched by LTC1660 on the rising edge and sifted out on falling edge
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

#ifdef DEBUG
       							  if (useLCD) {
       								  lcd_clear();
       								  lcd_set_cursor(0,0) ;
       								  lite_sprintf(LCDstr, "->Inside write_dac:") ;
       								  lcd_print_str(LCDstr) ;
       								  lcd_set_cursor(1,0) ;
       								  lite_sprintf(LCDstr, "Data: %x", data) ;
       								  lcd_print_str(LCDstr) ;
       								  sleep(2) ;
       							  	  }
#endif

	return ;
}

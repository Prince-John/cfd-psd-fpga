#include	"main.h"

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Configuration routines
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^



// ****************************************************
// isConfigMode()
// Check if STX as a string has come in from host
// uartStr is a global
// ***************************************************
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


	top_control_flow();

	return ;
}


// ******************************************************************************
// Routine to get the board ID (6 bits) and save to global variable board_id
// ******************************************************************************

u8	get_board_id() {
	board_id = (u8) read_gpio_port(BOARD_ID_PORT, 6, BOARD_ID_0) ;
	return board_id ;
}



/*
// **********************************************
 * 	Chipboard Acquisition Mode Configuration
 * **********************************************
 * This routine updates the global board state flag and writes to the
 * GPIO line to set FPGA hardware into acquisition mode.
 *
 * Input u8 mode: only the LSB is valid, 1 - acquisition mode
 */
void 	set_mode(u8 mode){

	if (mode == 1){
		xil_printf("Chipboard in Acquisition Mode! \r\n") ;
		acquisition_mode = true;
		write_gpio_port(TAKE_EVENT_PORT, 1, ACQUISITION_MODE, HIGH) ;
	}
	else{
		xil_printf("Chipboard out of Acquisition Mode! \r\n") ;
		acquisition_mode = false;
		write_gpio_port(TAKE_EVENT_PORT, 1, ACQUISITION_MODE, LOW) ;
	}
	return;
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
// CFD_reset is low active reset
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
// As of v0.3.1 MSB is shifted in first. ** This maintains compatibility with all previous versions of the configuration software ** -change July 9 '25 - Prince
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

        for (j = 7 ; j >= 0 ; j--) {
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
 * 		- *Reset sel_ext_addr to previous state
 * 		- *Reset subchannel, channel lines to previous state
 *
 *	*Modifications - Jul 27 - Prince - Maintains the state of the output lines.
// *********************************************
*/
void  configure_psd_0_dac(u8 data, u8 addr) {
	DEBUG_LCD_PRINT_LOCATION("In PSD DAC 0")
	u8 subchannel;

	subchannel = addr & 0x3;
	addr = addr >> 2;

	u8 psd_sel_ext_address_state = read_gpio_output_state(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_0);
	u8 psd_chan_addr_out_state = read_gpio_output_state(PSD_ADDR_PORT, 5, PSD0_CHAN_ADDR_OUT_0);
	u8 psd_sub_chan_state = read_gpio_output_state(PSD_MISC_PORT, 2, PSD_SC0_0);

	write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_0, HIGH) ;

	psd_strobe(LOW, 0);


	write_gpio_port(PSD_ADDR_PORT, 5, PSD0_CHAN_ADDR_OUT_0, addr);
	write_gpio_port(PSD_MISC_PORT, 2, PSD_SC0_0, subchannel);

	// address data valid
	psd_strobe(HIGH, 0);

	write_gpio_port(PSD_ADDR_PORT, 5, PSD0_CHAN_ADDR_OUT_0, data);

	// dac data valid
	psd_strobe(LOW, 0);

	write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_0, psd_sel_ext_address_state) ;
	write_gpio_port(PSD_ADDR_PORT, 5, PSD0_CHAN_ADDR_OUT_0, psd_chan_addr_out_state);
	write_gpio_port(PSD_MISC_PORT, 2, PSD_SC0_0, psd_sub_chan_state);


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


	u8 psd_sel_ext_address_state = read_gpio_output_state(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_1);
	u8 psd_chan_addr_out_state = read_gpio_output_state(PSD_ADDR_PORT, 5, PSD1_CHAN_ADDR_OUT_0);
	u8 psd_sub_chan_state = read_gpio_output_state(PSD_MISC_PORT, 2, PSD_SC0_1);


	write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_1, HIGH) ;

	psd_strobe(LOW, 1);


	write_gpio_port(PSD_ADDR_PORT, 5, PSD1_CHAN_ADDR_OUT_0, addr);
	write_gpio_port(PSD_MISC_PORT, 2, PSD_SC0_1, subchannel);

	// address data valid
	psd_strobe(HIGH, 1);

	write_gpio_port(PSD_ADDR_PORT, 5, PSD1_CHAN_ADDR_OUT_0, data);

	// dac data valid
	psd_strobe(LOW, 1);

	write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_1, psd_sel_ext_address_state) ;
	write_gpio_port(PSD_ADDR_PORT, 5, PSD1_CHAN_ADDR_OUT_0, psd_chan_addr_out_state);
	write_gpio_port(PSD_MISC_PORT, 2, PSD_SC0_1, psd_sub_chan_state);
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
//	PSD global_enable
// ***************************************************
// Routine to control the PSD global_enable line
// Value should be either LOW or HIGH
// TODO: This is a bodge for PCB Rev 2 routing, fix it properly at some point.
// *****************************************************

void	psd_global_enable(u8 value) {
	write_gpio_port(PSD_ADDR_PORT, 1, PSD_GLOBAL_ENABLE, value) ;
}


// ***************************************************
//	PSD Digital Reset
// ***************************************************
// Routine to reset PSD digital circuits.
// PSD_RESET is high? active reset
// *****************************************************
void 	psd_digital_reset(){
	write_gpio_port(PSD_ADDR_PORT, 1, PSD_RESET, LOW) ;
	usleep(1) ;
	write_gpio_port(PSD_ADDR_PORT, 1, PSD_RESET, HIGH) ;
	usleep(100) ;
	write_gpio_port(PSD_ADDR_PORT, 1, PSD_RESET, LOW) ;
	return;
}


// ***************************************************
// PSD Force Reset
// ***************************************************
// Routine to reset PSD hit registers circuits.
// PSD_RESET is high? active reset
// *****************************************************
void 	psd_force_reset(){
	write_gpio_port(PSD_ADDR_PORT, 1, PSD_FORCE_RST, LOW) ;
	usleep(1) ;
	write_gpio_port(PSD_ADDR_PORT, 1, PSD_FORCE_RST, HIGH) ;
	usleep(100) ;
	write_gpio_port(PSD_ADDR_PORT, 1, PSD_FORCE_RST, LOW) ;
	return;
}


// ***************************************************
// PSD RESET
// ***************************************************
// Routine to reset PSD chips both force and digital
// *****************************************************
void 	psd_reset_all(){

	psd_digital_reset();
	usleep(1) ;
	psd_force_reset();

	return;
}



// ***************************************************
// PSD RESET
// ***************************************************
// Routine to selectively reset PSD chips (Force / Digital)
// if input is 1 - Force Reset only
// if input is 0 - Digital Reset only
// other reset both.
// *****************************************************
void 	psd_reset(u8 value){

	if (value == 1){
		xil_printf("PSD Force Reset \r\n") ;
		psd_force_reset();
	}
	else if (value == 0){
		xil_printf("PSD Digital Reset \r\n") ;
		psd_digital_reset();
	}
	else{
		psd_reset_all();
		xil_printf("Could not Parse PSD reset option, RESET both! \r\n") ;
	}
	return;
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
	write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_0, enable) ;

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
	xil_printf("Control Flow Debug: PSD 1 TEST MODE with address: %d", addr);
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
	//write_gpio_port(PSD_MISC_PORT, 1, PSD_SEL_EXT_ADDR_1, enable) ;

}




/* *****************************************************************
// Delay Configuration
// *****************************************************************
 *
 * Configures all the delay chips on the chipboard, segments the
 * incoming data and calls write_delay_chip() to implement the per
 * chip configuration.
 *
 * Expects 18 bytes of configuration data.
 *
   ***************************************************************** */
void configure_delay_chips(u8 *buff){

		u8 		dlyVal ;
		int chip_num;

		for (chip_num = 0; chip_num < 6; chip_num++) {
				dlyVal = buff[(3 * chip_num)] | (1 << 5 );			// Red channel i.e. channel 1
				write_delay_chip(chip_num, dlyVal) ;
				dlyVal = buff[(3 * chip_num) + 1] | (2 << 5) ;    	// Green channel i.e. channel 2
				write_delay_chip(chip_num, dlyVal) ;
				dlyVal = buff[(3 * chip_num) + 2] | (3 << 5 );    	// Blue channel i.e. channel 3
				write_delay_chip(chip_num, dlyVal) ;
		} // end for-loop

}






/* *****************************************************************
// Delay IC Configuration low level implementation
// *****************************************************************
 *
 * Implements the configuration of a single delay chip on the
 * chipboard.
 *
 * chip_num :  delay chip (0 - 5)
// delay_data : 0 a b v w x y z (see datasheet)
 *
   ***************************************************************** */

void write_delay_chip(u8 chip_num, u8 delay_data) {
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
 * 	OR Selection MUX Configuration low level implementation
 * **********************************************
 *
 * 	This function takes in the bitmask to set the OR mux configuration
 *
 *	This multiplexer is present on the FPGA itself.
 *
 *   00 is PSD0 OR
 *   01 is PSD1 OR
 *   11 for both PSD Ors
 *   10 is the CFD chip OR
// *********************************************
*/
void	write_or_mux(u8 data) {
	write_gpio_port(BOARD_ID_PORT, 2, OR_SEL_0, data) ;
	return ;
}

/*
// **********************************************
 * 	CFD Selection MUX Configuration low level implementation
 * **********************************************
 *
 * 	This function takes in the bitmask to select the CFD MUX that routes cfd generated by psd chips.
 *
 * 	This multiplexer is present in the FPGA itself.
 *
 *   Select cfd generated output from either 0- PSD0 or 1– PSD1
// *********************************************
*/
void	write_cfd_mux(u8 data) {
	write_gpio_port(BOARD_ID_PORT, 1, CFD_OUT_SEL, data) ;
	return ;
}

/*
// **********************************************
 * 	INTx Selection MUX Configuration low level implementation
 * **********************************************
 *
 * 	This function takes in the bitmask to select the INTx MUX that routes INTx output generated by psd chips.
 *
 * 	This multiplexer is present in the FPGA itself.
 *
 *  Route out intx from either PSD 0 or PSD1 to host
// *********************************************
*/
void	write_intx_mux(u8 data) {
	write_gpio_port(BOARD_ID_PORT, 1, PSD_INTX_OUT_SEL, data) ;
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

	return ;
}









/*
// **********************************************
 * 	TDC7200 uBlaze Debug implementation
 * **********************************************


void write_tdc(u16 data){

	u8 tdc_sclk;
	u8 tdc_csb;
	u8 tdc_en;
	u8 tdc_sdin;
	u8 value;

	//start state
	tdc_sclk = LOW;
	tdc_sdin = LOW;
	tdc_en = HIGH;
	tdc_csb = HIGH;


	//init state mask
	value = (tdc_csb << 3) | (tdc_en << 2) | (tdc_sdin << 1) | (tdc_sclk)

	write_gpio_port(TDC_PORT, 4, TDC_SCLK_FROM_MICRO, value) ;

	// Pull CSB low
	write_gpio_port(TDC_PORT, 1, TDC_CSB_FROM_MICRO, LOW) ;

	for (i = 15; i >= 0; i--){


			tdc_sdin = ( data & (1 << i) ) >> i;
			tdc_sclk = LOW;

			//CLK is set low, data pushed out
			value = (tdc_sdin << 1) | (tdc_sclk) ;
			write_gpio_port(TDC_PORT, 2, TDC_SCLK_FROM_MICRO, value) ;

			//CLK is set high, data latched by TDC
			tdc_sclk = HIGH;
			write_gpio_port(TDC_PORT, 1, TDC_SCLK_FROM_MICRO, tdc_sclk) ;

		}

	//PULL chip select High
	write_gpio_port(TDC_PORT, 1, TDC_CSB_FROM_MICRO, HIGH) ;

}


u32 read_tdc(u8 addr, int num_bytes){

	u8 tdc_sclk;
	u8 tdc_csb;
	u8 tdc_en;
	u8 tdc_sdin;
	u8 tdc_sdout;
	u8 value;
	u32 data = 0;
	//start state
	tdc_sclk = LOW;
	tdc_sdin = LOW;
	tdc_en = HIGH;
	tdc_csb = HIGH;
	tdc_sdout = LOW;

	int read_cycles = num_bytes*8 - 1;


	// Pull CSB low
	write_gpio_port(TDC_PORT, 1, TDC_CSB_FROM_MICRO, LOW) ;
	for (i = 7; i >= 0; i--){


				tdc_sdin = ( addr & (1 << i) ) >> i;
				tdc_sclk = LOW;

				//CLK is set low, data pushed out
				value = (tdc_sdin << 1) | (tdc_sclk) ;
				write_gpio_port(TDC_PORT, 2, TDC_SCLK_FROM_MICRO, value) ;

				//CLK is set high, data latched by TDC
				tdc_sclk = HIGH;
				write_gpio_port(TDC_PORT, 1, TDC_SCLK_FROM_MICRO, tdc_sclk) ;

			}


	for (i = read_cycles; i >= 0; i--){

				tdc_sclk = LOW;
				//CLK is set low, data pushed out
				write_gpio_port(TDC_PORT, 1, TDC_SCLK_FROM_MICRO, tdc_sclk) ;
				//CLK is set high, data latched by uBlaze
				tdc_sclk = HIGH;
				write_gpio_port(TDC_PORT, 1, TDC_SCLK_FROM_MICRO, tdc_sclk) ;

				value = (u8) read_gpio_port(TDC_PORT, 1, TDC_DOUT_FROM_MICRO);
				data = ((value & 1) << i) | data  ;

			}

	//PULL chip select High
	write_gpio_port(TDC_PORT, 1, TDC_CSB_FROM_MICRO, HIGH) ;

	return data;
}
*/

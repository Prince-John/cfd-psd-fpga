// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// PSD FPGA main program
// 26-SEP-2024
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#include 	"main.h"

// ********************************
// Declare Global variables
// ********************************

// GPIO registers
// Remember last thing we wrote or read from GPIO modules
// THe index into the arrays is the port number!!!!

u32		gpio_in[4] ;
u32		gpio_out[4] ;

// Is the LCD module connected????

bool	useLCD = true ;

// Choose if we want to run self tests
// FifoTest should NOT be made true
// FifoTest CURRENTLY UNDER CONSTRUCTION
// doSelfTests trumps other settings!!!!

bool	doSelfTests = false ;

bool	doUartTest = false ;
bool	doMathTest = false ;
bool	doConfigTests = false ;
bool	doFifoTest = false ;

// String buffer used for writing to LCD

char    LCDstr[80] ;

// Global string variable

u8		uartStr[256] ;

//
// The following global buffers are used to send and receive data
// with the UART. TEST_BUFFER_SIZE should match the size of the
// hardware FIFO.
//

// Currently not using these

u8 SendBuffer[TEST_BUFFER_SIZE]; /* Buffer for Transmitting Data */
u8 RecvBuffer[TEST_BUFFER_SIZE]; /* Buffer for Receiving Data */

// *******************************************************************
// Picoblaze will send data back to ublaze via streaming FIFO
// FIFO related stuff is UNDER CONSTRUCTION!!!!
// *******************************************************************

XLlFifo_Config 	*Config ;
XLlFifo 		FifoInstance ;
// u32 			DestinationBuffer[MAX_DATA_BUFFER_SIZE * WORD_SIZE];
u32 			DestinationBuffer[MAX_DATA_BUFFER_SIZE];

// **************************************************
// Main program
// **************************************************

int main() {

// Init 16550 uart
// Send something to make sure UART functional

    init_uart() ;
	xil_printf("PSD_FPGA Version 0.1\r\n") ;

// Init timer/counter

	init_timer() ;

// Initialize our GPIOs.
// We have 4 32-bit input registers and 4 32-bit output registers

	init_gpio() ;

// Possibly perform some self tests

    if (doSelfTests) self_tests() ;

// Never really any need to read from CFD chip!
// Set CFD_write high and leave it HIGH!
// Writing of the data doesn't occur until strobed.

    cfd_strobe(LOW) ;
    usleep(1) ;
    cfd_write(HIGH) ;

	if (useLCD) {
	    //lcd_clear();
	    lcd_print_str("PSD_FPGA Version 0.1") ;
	    lcd_set_cursor(1,0) ;
	    lcd_print_str("--> Main loop!") ;
	}

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//		****** MAIN LOOP *********
// Just constantly polling for either host wanting to configure
// OR a nuclear physics event has occurred!!!!!!!!!!!!
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

    while (true) {
    	if ( isConfigMode() ) configHandler() ;
    	if ( isEventMode() ) eventHandler() ;
    	usleep(1) ;
    }

} // end main

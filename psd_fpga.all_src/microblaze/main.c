// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// PSD FPGA main program
// 7-Nov-2024
//
// This version allows us to get ADC data packets from the FPGA.
// Using the ADC evaluation board plugged into the PMOD connector
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

// *******************************************************************
// Picoblaze will send data back to ublaze via streaming FIFO
// *******************************************************************

XLlFifo_Config 	*Config ;
XLlFifo 		FifoInstance ;
u32 			DestinationBuffer[MAX_DATA_BUFFER_SIZE] ;

// **************************************************
// Main program
// **************************************************

int main() {

// Init 16550 uart

    init_uart() ;
//   xil_printf("PSD_FPGA %s \r\n", PROJECT_VERSION) ;

// Init timer/counter

	init_timer() ;

// Initialize our GPIOs.
// We have 4 32-bit input registers and 4 32-bit output registers

	init_gpio() ;

// Possibly perform some self tests

    if (doSelfTests) self_tests() ;

// Initialize the FIFO

    init_fifo() ;

// Never really any need to read from CFD chip!
// Set CFD_write high and leave it HIGH!
// Writing of the data doesn't occur until strobed.

    cfd_strobe(LOW) ;
    usleep(1) ;
    cfd_write(HIGH) ;

// Print version information

	if (useLCD) {
	    lcd_clear();
	    lcd_print_str("PSD_FPGA: ") ;
	    lcd_print_str(PROJECT_VERSION) ;
	    lcd_set_cursor(1,0) ;
	    lcd_print_str("--> Main loop!") ;
	}

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//						****** MAIN LOOP *********
// Just constantly polling for either host wanting to configure
// OR a nuclear physics event has occurred!!!!!!!!!!!!
// Stay in event handler until take_event goes low
// Later we will change this be busy signal probably.
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

	int event_cntr = 1 ;
    while (true) {
    	if ( isConfigMode() ) configHandler() ;
    	if ( isEventMode() ) {
    		if (useLCD) {
    		    lcd_clear();
    		    lite_sprintf(LCDstr, "Event # -> %d", event_cntr) ;
    		    lcd_print_str(LCDstr) ;
    		}
    		eventHandler() ;
    		event_cntr++ ;
    	}
    	usleep(10000) ; // wait 10 ms ... used to debounce take_event switch during testing
    }

} // end main
// 
// Perform a self test
//

// Xilinx data types

#include    <xil_types.h>

// UART support

#include    <xil_printf.h>

// I2C support

#include    "i2c.h"
#include    "str_utils.h"

// GPIO unit support

#include 	"gpio.h"

// UART support

#include 	"uart.h"

// Config routines

#include	"config_routines.h"

// Self test specific things

#include    "self_test.h"

// ************************************
// Routine to test some math operations
// Print to LCD screen
// ************************************

void math_test(void) {
    int32_t a, b, c, d, e ;

    a = 10 ;
    b = 3 ;
    c = a * b ;
    d = a / b ;
    e = a << 2 ;

    if (useLCD) {    
        lcd_clear() ;
        lcd_print_str("Doing math_test") ;;

        lcd_set_cursor(1, 0) ;   
        lite_sprintf(LCDstr, "a is %d", a) ;
        lcd_print_str(LCDstr) ;

        lcd_set_cursor(2, 0) ;
        lite_sprintf(LCDstr, "b is %d", b) ;
        lcd_print_str(LCDstr) ;

        sleep(2) ;

        lcd_clear() ;
        lite_sprintf(LCDstr, "a * b is %d", c) ;
        lcd_print_str(LCDstr) ;

        lcd_set_cursor(1, 0) ;
        lite_sprintf(LCDstr, "a / b is %d", d) ;
        lcd_print_str(LCDstr) ;

        lcd_set_cursor(2, 0) ;
        lite_sprintf(LCDstr, "a << 2 is %d", e) ;
        lcd_print_str(LCDstr) ;

        sleep(4) ;
    }
    
    return ; 
}

void config_tests() {

// Configure both PSD chips
// Make up some data

    u8     config_data[12] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B} ;

    if (doConfigTests) {

// Configure the PSDs

        if (useLCD) {
            lcd_clear() ;
            lcd_print_str("Config PSD chips");
        } // end if

        configure_psd_chips(config_data) ;
        sleep(1) ;
        if (useLCD) {
            lcd_clear() ;
            lcd_print_str("Config delay chips");
        } // end if

 // Configure the delay ICs

        int chip_num ;
        u8  delay_data = 0x4f ;
        for (chip_num = 0; chip_num < 6; chip_num++) {
            write_delay_chip(chip_num, delay_data) ;
        } // end for
        sleep(1) ;
    } // end if

}

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Test some functions out
// Uses LCD module
// Make sure it is connected.
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

void self_tests(void) {
    if (useLCD) {
        lcd_clear();
        lcd_print_str("Self tests.") ;
        sleep(3) ;
    }

// Test some stuff math operations

    if (doMathTest) math_test() ;

    // Test sending binary data using 16550 UART!

    if (doUartTest) {
    	u32     delta ;
    	xil_printf("*** Using 3 Mbaud ***\r\n") ;
        if (useLCD) {
        	lcd_clear();
        	lcd_print_str("Doing UART test NEW") ;
        	delta = uart_test() ;
        	delta /= 100 ;
        	lite_sprintf(LCDstr, "Elapsed time: %d us", delta) ;
        	lcd_set_cursor(1, 0) ;
            lcd_print_str(LCDstr) ;
        } // end if
    }

    if (doConfigTests) config_tests() ;

    return ;
}


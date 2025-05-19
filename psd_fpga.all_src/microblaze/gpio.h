//
// GPIO related stuff

#ifndef SRC_GPIO_H_
#define SRC_GPIO_H_

#include    <stdint.h>
#include    <stdio.h>
#include    <stdbool.h>
#include    <xil_types.h>

// Delay support

#include    <sleep.h>

// Microblaze parameters

#include    <xparameters.h>

// GPIO low-level support

#include    <xgpio_l.h>

// Load gpio bit assignments

#include	"gpio_defines.h"

// ^^^^^^^^^^^^^^^^^^
// Defines
// ^^^^^^^^^^^^^^^^^^

// Useful when dealing with LEDs or other such devices

#define     OFF         false
#define     ON          true

#define		DELAY_CHIP_PORT					2
#define		PSD_SERIAL_CONFIG_IN_PORT		2
#define		PSD_SERIAL_CONFIG_OUT_PORT		2
#define		BOARD_ID_PORT					0
#define		CFD_PORT						3
#define		MUX_PORT						2
#define		DAC_OUT_PORT					2
#define 	PSD_ADDR_PORT					1
#define		PSD_MISC_PORT					2
#define		TAKE_EVENT_PORT					0
#define		TDC_PORT						3

// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
// Global variables defined in main
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

extern		u32         gpio_in[4] ;
extern		u32         gpio_out[4] ;

// &&&&&&&&&&&&&&&&&&&&&&&&&&
// Function definitions
// &&&&&&&&&&&&&&&&&&&&&&&&&&

void 	write_gpio_port(int gpio_number, u32 field_width, int bit0, u32 value) ;
u32 	read_gpio_port(int gpio_number, u32 field_width, int bit0) ;
void    init_gpio(void) ;

#endif /* SRC_GPIO_H_ */



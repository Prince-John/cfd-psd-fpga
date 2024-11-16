#include    "i2c.h"
#include    "str_utils.h"
#include    <xil_types.h>
#include	"gpio.h"

// **************************************************************
// In general the gpio regs should be written
// in a "special" way. This routine takes care
// of that for the user.
//
// gpio_number --> port number so 0, 1, 2, 3
// width_field --> how many bits you want to write
// bit0 --> which bit in gpio reg corresponds to bit 0 of value
// value --> value to be written
//
// Upon caller to make sure value fits in field
//
// *******************************************************************

void write_gpio_port(int gpio_number, u32 field_width, int bit0, u32 value) {
	u32	gpio_value ;
	u32 base_addr ;
	int	mask ;
	int j ;

	switch (gpio_number) {
		case 0 : 	base_addr = XPAR_GPIO_0_BASEADDR ;
			 		break ;
		case 1 : 	base_addr = XPAR_GPIO_1_BASEADDR ;
			 		break ;
		case 2 : 	base_addr = XPAR_GPIO_2_BASEADDR ;
			 		break ;
		case 3 : 	base_addr = XPAR_GPIO_3_BASEADDR ;
			 		break ;
		default :	break ;
	}

// Get the current state of the gpio register

	gpio_value = gpio_out[gpio_number] ;

// If writing enter 32 bits then we don't need to create a bit mask

	if (field_width == 32) {
		XGpio_WriteReg(base_addr, XGPIO_DATA2_OFFSET, value) ;
		gpio_out[gpio_number] = value ;
		return ;
	}

// 	Else we need a bit mask
//  Build the appropriate mask

	mask = 0 ;
	for (j = bit0 ; j < (bit0 + field_width) ; j++) mask |= (1 << j) ;

// Clear the field

	gpio_value &= ~mask ;

// Write the field

	gpio_value |=  (value << bit0) ;

// Channel 2 is output register so XGPIO_DATA2_OFFSET ... no 2 for a input register

    XGpio_WriteReg(base_addr, XGPIO_DATA2_OFFSET, gpio_value) ;

// Don't forget to update the state variable

    gpio_out[gpio_number] = gpio_value ;

    return ;
}

// ****************************************************************
// In general the gpio regs should be read
// in a "special" way. This routine takes care
// of that for the user.
//
// gpio_number --> port number so 0, 1, 2, 3
// width_field --> how many bits you want to read
// bit0 -->  bit in gpio reg corresponding to bit 0 of the value
//
// returns the value read as a u32
//
// ****************************************************************

u32 read_gpio_port(int gpio_number, u32 field_width, int bit0) {
	u32	gpio_value ;
	u32 base_addr ;
	int	mask ;
	int j ;

	switch (gpio_number) {
		case 0 : 	base_addr = XPAR_GPIO_0_BASEADDR ;
			 	break ;
		case 1 : 	base_addr = XPAR_GPIO_1_BASEADDR ;
			 	break ;
		case 2 : 	base_addr = XPAR_GPIO_2_BASEADDR ;
			 	break ;
		case 3 : 	base_addr = XPAR_GPIO_3_BASEADDR ;
			 	break ;
		default :	break ;
	}

// Perform the gpio register read

    gpio_value = XGpio_ReadReg(base_addr, XGPIO_DATA_OFFSET) ;

// Don't forget to update the state variable

    gpio_in[gpio_number] = gpio_value ;

// If the field width is 32 bits, then return entire register

    if ( field_width == 32 ) {
    	return gpio_value ;
    }

// Else build the mask

    mask = 0 ;
    for (j = bit0 ; j < (bit0 + field_width) ; j++) mask |= (1 << j) ;
    gpio_value &= mask ;

// Shift it down so right centered in the u32

    gpio_value = (gpio_value >> bit0) ;

    return gpio_value ;
}

// ************************************
// Routine to initialize gpio
// Clear the global GPIO variables
// ************************************

void    init_gpio(void) {
	u32	gpio_value ;
	int gpio_num ;

// Read the 4 input registers
// The read_gpio_reg WILL SAVE the state to gpio_in[] array

	for (gpio_num = 0; gpio_num < 4; gpio_num++) {
		gpio_value = read_gpio_port(gpio_num, 32, 0) ;
	}

// Clear the output registers

	gpio_value = 0 ;
	for (gpio_num = 0; gpio_num < 4; gpio_num++) {
		write_gpio_port(gpio_num, 32, 0, gpio_value) ;
	}

    return ;
}



#ifndef SRC_STR_UTILS_H_
#define SRC_STR_UTILS_H_

// 
// Standard libs
//

#include <stdio.h> 
#include <stdarg.h>
#include <string.h> 
#include <stdint.h>

// 
// Xilinx related 
//

#include <sleep.h>
#include <xil_types.h>
#include <xil_printf.h>

// Converts an ascii character (0-9, A-F) into decimal equivalent

u8  asc2nybble(u8 ascChar) ;

// Convert 2 ascii nybbles to a bytes

u8  buff2byte(u8 *buff) ;

// Converts a string of ascii encoded nybbles into u8 array

int str2bytes(u8 *buff) ;

// A light weight version of the sprintf() function

void lite_sprintf(char *buf, char  *fmt, ...) ;

#endif /* SRC_STR_UTILS_H_ */



#ifndef SRC_STR_UTILS_H_
#define SRC_STR_UTILS_H_

// 
// Standard libs
//

#include <stdio.h> 
#include <stdarg.h>
#include <string.h> 
#include <stdint.h>
#include <stdbool.h>

// 
// Xilinx related 
//

#include <sleep.h>
#include <xil_types.h>
#include <xil_printf.h>



// Lightweight string comparison for command parsing

bool compare_strings(const char *a, const char *b, int length);

// Gets length of str array (include \0)

int	get_str_len(u8 *str) ;

// Converts an ascii character (0-9, A-F) into decimal equivalent

u8  asc_to_nybble(u8 ascChar) ;

// Convert 2 ascii nybbles to a bytes

u8  buff_to_byte(u8 *buff) ;

// Converts a string of ascii encoded nybbles into u8 array

int str_to_bytes(u8 *buff) ;

// A light weight version of the sprintf() and scanf function()

void lite_sprintf(char *buf, char  *fmt, ...) ;
int lite_sscanf(const char* str, const char* format, ...) ;

#endif /* SRC_STR_UTILS_H_ */


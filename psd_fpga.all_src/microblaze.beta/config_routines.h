#ifndef SRC_CONFIG_ROUTINES_H_
#define SRC_CONFIG_ROUTINES_H_

// Xilinx data types

#include    <xil_types.h>

#include 	"gpio.h"
#include    "i2c.h"
#define DEBUG
// DEBUG LCD MACRO
#ifdef DEBUG
	#define DEBUG_LCD_PRINT_CONFIG(message, numBytes) \
		if (useLCD) { \
			lcd_clear(); \
			lite_sprintf(LCDstr, "%s", message); \
			lcd_print_str(LCDstr); \
			lcd_set_cursor(1, 0); \
			lite_sprintf(LCDstr, "# command bytes: %d", numBytes); \
			lcd_print_str(LCDstr); \
			lcd_set_cursor(2, 0); \
			sleep(2); \
		}
	#define DEBUG_LCD_PRINT_LOCATION(message) \
		if (useLCD) { \
			lcd_set_cursor(1, 0); \
			lite_sprintf(LCDstr, "-->%s ", message); \
			lcd_print_str(LCDstr); \
			lcd_set_cursor(2, 0); \
			sleep(1); \
		}
	#define DEBUG_LCD_PRINT_STR(message, data) \
		if (useLCD) { \
			lcd_set_cursor(1, 0); \
			lite_sprintf(LCDstr, "-->%s ", message); \
			lcd_print_str(LCDstr); \
			lcd_set_cursor(2, 0); \
			lite_sprintf(LCDstr, "%s ", data); \
			lcd_print_str(LCDstr); \
			sleep(1); \
		}
#else
#define DEBUG_LCD_PRINT_CONFIG(message, numBytes)  // Empty when DEBUG is not defined
#define DEBUG_LCD_PRINT_LOCATION(message)
#define DEBUG_LCD_PRINT_STR(message, data)
#endif







// Global

extern	u8 	uartStr[256] ;

// Some general defines

#define	LOW		0
#define	HIGH	1

// Define enum for tokens

enum cmd_tokens {CONFIG_DELAY, CONFIG_PSD, GET_BOARD_ID, WRITE_TO_CFD, ERROR, CONFIG_MUX, CONFIG_DAC} ;

// Define enum for PSD specific tokens
enum psd_tokens {RESET, OFFSET_DAC_0, OFFSET_DAC_1, TRIGGER_MODE, SERIAL_REG};

// Functions

void	cfd_write(u8 value) ;
void	cfd_strobe(u8 value) ;
void	write_cfd_reg(u8 addr_mode, u8 data) ;

u8		get_board_id() ;

enum 	cmd_tokens get_token() ;
enum 	psd_tokens get_psd_token() ;
bool	isConfigMode() ;
void	configHandler() ;

void	configure_psd_chips(u8 *psd_config_data) ;
void  	configure_psd_0_dac(u8 data, u8 addr);
void  	configure_psd_1_dac(u8 data, u8 addr);
void 	configure_trigger_mode(u8 data);

void	configure_delay_chips(u8 chip_num, u8 delay_data) ;

void	write_mux(u8 data) ;
void	write_dac(u16 data) ;

#endif /* SRC_CONFIG_ROUTINES_H */

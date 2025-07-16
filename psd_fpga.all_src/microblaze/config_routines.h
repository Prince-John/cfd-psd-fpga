#ifndef SRC_CONFIG_ROUTINES_H_
#define SRC_CONFIG_ROUTINES_H_

// Xilinx data types

#include    <xil_types.h>

#include 	"gpio.h"
#include    "i2c.h"

// GLE: 31-Oct-2024
// Changed to LCD_DEBUG from DEBUG
// to avoid warning

#define 	LCD_DEBUG

// LCD_DEBUG LCD MACRO

#ifdef LCD_DEBUG
	#define DEBUG_LCD_PRINT_CONFIG(message, numBytes) \
		if (useLCD) { \
			lcd_clear(); \
			lite_sprintf(LCDstr, "%s", message); \
			lcd_print_str(LCDstr); \
			lcd_set_cursor(1, 0); \
			lite_sprintf(LCDstr, "# command bytes: %d", numBytes); \
			lcd_print_str(LCDstr); \
			lcd_set_cursor(2, 0); \
		}
	#define DEBUG_LCD_PRINT_LOCATION(message) \
		if (useLCD) { \
			lcd_set_cursor(0, 0); \
			lcd_print_str("                    "); \
			lite_sprintf(LCDstr, "%s", message); \
			lcd_print_str(LCDstr); \
			lcd_set_cursor(1, 0); \
		}
	#define DEBUG_LCD_PRINT_STR(message, data) \
		if (useLCD) { \
			lcd_clear(); \
			lcd_set_cursor(1, 0); \
			lite_sprintf(LCDstr, "-->%s ", message); \
			lcd_print_str(LCDstr); \
			lcd_set_cursor(2, 0); \
			lite_sprintf(LCDstr, "%s ", data); \
			lcd_print_str(LCDstr); \
		}
	#define DEBUG_LCD_PRINT_NUMBER(message, data0) \
		if (useLCD) { \
			lcd_set_cursor(2, 0); \
			lite_sprintf(LCDstr, "%s ", message); \
			lcd_print_str(LCDstr); \
			lcd_set_cursor(3, 0); \
			lite_sprintf(LCDstr, "%d", data0); \
			lcd_print_str(LCDstr); \
		}
#else
#define DEBUG_LCD_PRINT_CONFIG(message, numBytes)  // Empty when FPGA_DEBUG is not defined
#define DEBUG_LCD_PRINT_LOCATION(message)
#define DEBUG_LCD_PRINT_STR(message, data)
#define DEBUG_LCD_PRINT_NUMBER(message, data)
#endif

// Global

extern	u8 	uartStr[256] ;
extern  bool acquisition_mode;
extern 	int board_id;

// Some general defines

#define	LOW		0
#define	HIGH	1


// Functions

void	cfd_write(u8 value) ;
void	cfd_reset() ;
void	cfd_strobe(u8 value) ;
void	cfd_global_enable(u8 value) ;
void	write_cfd_reg(u8 addr_mode, u8 data) ;

u8		get_board_id() ;

/*
enum 	cmd_tokens get_token() ;
enum 	psd_tokens get_psd_token() ;
enum 	cfd_tokens get_cfd_token() ;
*/


bool	isConfigMode() ;
void	configHandler() ;

void 	set_mode(u8 mode);

void	configure_psd_chips(u8 *psd_config_data) ;
void  	configure_psd_0_dac(u8 data, u8 addr);
void  	configure_psd_1_dac(u8 data, u8 addr);


// GLE: 31-Oct-2024
// Changed to configure_psd_trigger_mode from configure_trigger_mode
// to avoid warning

void 	configure_psd_trigger_mode(u8 data);
void 	configure_psd_0_test_mode(u8 addr, u8 enable);
void 	configure_psd_1_test_mode(u8 addr, u8 enable);
void	psd_global_enable(u8 value);
void	psd_reset_all(void);
void	psd_reset(u8 value);


void 	configure_delay_chips(u8 *buff);
void	write_delay_chip(u8 chip_num, u8 delay_data) ;

void	write_mux(u8 data) ;
void	write_intx_mux(u8 data);
void	write_or_mux(u8 data);
void	write_cfd_mux(u8 data);
void	write_dac(u16 data) ;

void	write_tdc(u16 data) ;
void	read_tdc(u8 addr, int num_bytes) ;
#endif /* SRC_CONFIG_ROUTINES_H */

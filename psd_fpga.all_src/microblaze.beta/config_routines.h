#ifndef SRC_CONFIG_ROUTINES_H_
#define SRC_CONFIG_ROUTINES_H_

// Xilinx data types

#include    <xil_types.h>

#include 	"gpio.h"
#include    "i2c.h"

// Global

extern	u8 	uartStr[256] ;

// Some general defines

#define	LOW		0
#define	HIGH	1

// Define enum for tokens

enum cmd_tokens {CONFIG_DELAY, CONFIG_PSD, GET_BOARD_ID, WRITE_TO_CFD, ERROR, CONFIG_MUX} ;

// Functions

void	cfd_write(u8 value) ;
void	cfd_strobe(u8 value) ;
void	write_cfd_reg(u8 addr_mode, u8 data) ;

u8		get_board_id() ;

enum 	cmd_tokens get_token() ;
bool	isConfigMode() ;
void	configHandler() ;

void	configure_psd_chips(u8 *psd_config_data) ;
void	configure_delay_chips(u8 chip_num, u8 delay_data) ;

void	write_mux(u8 data) ;

#endif /* SRC_CONFIG_ROUTINES_H */

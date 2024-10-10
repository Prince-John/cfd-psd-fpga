#ifndef SRC_CONFIG_ROUTINES_H_
#define SRC_CONFIG_ROUTINES_H_

// Xilinx data types

#include    <xil_types.h>

#include 	"gpio.h"
#include    "i2c.h"

// Some defines

#define		LOW		0
#define		HIGH	1

// Functions

void	cfd_write(u8 value) ;
void	cfd_strobe(u8 value) ;
void	write_cfd_reg(u8 addr_mode, u8 data) ;

u8		get_board_id() ;

bool	isConfigMode() ;
void	configHandler() ;

void	configure_psd_chips(u8 *psd_config_data) ;
void	configure_delay_chips(int chip_num, u8 delay_data) ;

#endif /* SRC_CONFIG_ROUTINES_H */

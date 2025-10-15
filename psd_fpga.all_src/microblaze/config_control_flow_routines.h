#ifndef SRC_CONFIG_CONTROL_FLOW_ROUTINES_H_
#define SRC_CONFIG_CONTROL_FLOW_ROUTINES_H_


#include    <xil_types.h>
#include 	"config_routines.h"
// Global

extern	u8 	uartStr[256] ;

// Some general defines

#define	LOW		0
#define	HIGH	1

// Define enum for tokens

enum cmd_tokens {CONFIG_DELAY, CONFIG_PSD, GET_BOARD_ID, CONFIG_CFD, ERROR, CONFIG_MUX, CONFIG_DAC, CONFIG_TDC, RESET, ACQ_MODE, GET_BOARD_VERSION} ;

// Define enum for PSD specific tokens

enum psd_tokens {RESET_PSD, OFFSET_DAC_0, OFFSET_DAC_1, TRIGGER_MODE, SERIAL_REG, TEST_MODE_0,  TEST_MODE_1, CHANNEL_SELECT, ERROR_PSD, PSD_GLOBAL_ENABLE_TKN};

enum psd_subtokens  {PSD0, PSD1, ERROR_SUB_PSD};

// Define enum for CFD specific tokens

enum cfd_tokens {RESET_CFD, WRITE_REG, CFD_GLOBAL_ENABLE, ERROR_CFD};


enum mux_tokens {OR_MUX, AMP_MUX, CFD_MUX, INTX_MUX, TAKE_EVENT_MUX, TIMESTAMP_MUX, ERROR_MUX};


// PSD sub command table structure
typedef struct {
    const char *command;
    enum cmd_tokens token;
} Command;


// PSD sub command table structure
typedef struct {
    const char *command;
    enum psd_tokens token;
} PSDCommand;

// CFD sub command table structure
typedef struct {
    const char *command;
    enum cfd_tokens token;
} CFDCommand;


// MUX sub command table structure
typedef struct {
    const char *command;
    enum mux_tokens token;
} MUXCommand;




enum 	cmd_tokens get_token() ;
enum 	psd_tokens get_psd_token() ;
enum 	cfd_tokens get_cfd_token() ;
enum 	mux_tokens get_mux_token() ;

void	top_control_flow();

void cfd_control_flow(u8 *buff);
void psd_control_flow(u8 *buff);
void mux_control_flow(u8 *buff);





#endif /* SRC_CONFIG_CONTROL_FLOW_ROUTINES_H */

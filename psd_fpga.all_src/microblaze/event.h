/*
 * event.h
 *
 *  Created on: Aug 20, 2024
 *      Author: gle
 */

#ifndef SRC_EVENT_H_
#define SRC_EVENT_H_

#include 	<stddef.h>
#include 	<stdint.h>
#include	<stdbool.h>

// Xilinx xparameters

#include 	"xparameters.h"

// Xilinx data types

#include    <xil_types.h>

#include 	"xllfifo.h"

// Error status flags

#include 	"xstatus.h"

// UART

#include	"uart.h"

// LCD

#include	"str_utils.h"
#include	"i2c.h"

// GPIO

#include	"gpio.h"
#include	"gpio_defines.h"

// Delays

#include 	<sleep.h>

// Define the byte locations in data packet array where data must be

#define		BOARD_ID	0

// Next six locations contain the timestamp counter (Little Endian)

#define		TSTAMP_LOW	1
#define		TSTAMP_HIGH	4

// Start of ADC data

#define		ADC_OS		7

// *****************************************
// Some defines we need for the FIFO
// ****************************************

#define 	FIFO_DEV_ID	   	XPAR_AXI_FIFO_0_DEVICE_ID

// Size of words in bytes

#define 	FIFO_WORD_SIZE 	4

// Max packet length

#define 	MAX_PACKET_LEN 			60
#define 	NO_OF_PACKETS 			1
#define 	MAX_DATA_BUFFER_SIZE 	(NO_OF_PACKETS * MAX_PACKET_LEN)
#define		MAX_PACKET_BYTE_SIZE	MAX_DATA_BUFFER_SIZE * FIFO_WORD_SIZE

// ***********************************************
// Variables defined elsewhere
// ********************************************

extern	XLlFifo 		FifoInstance;
extern	u32 			DestinationBuffer[MAX_DATA_BUFFER_SIZE];
extern	XLlFifo_Config 	*Config ;

// ^^^^^^^^^^^^^^^^^^^
// Functions
// ^^^^^^^^^^^^^^^^^^^

// Polls the take_event line

bool	isEventMode() ;

// Handles the nuclear physics event

void 	eventHandler() ;

// COBS encoder function

size_t cobsEncode(u8 *data, size_t length, u8 *buffer) ;

// COBS decoder function

size_t cobsDecode(u8 *buffer, size_t length, u8 *data) ;

// Routine to initialize the streaming FIFO

int	init_fifo() ;

// Routine to get data from the FIFO

int get_packet (XLlFifo *InstancePtr, u32* DestinationAddr)  ;

#endif /* SRC_EVENT_H_ */

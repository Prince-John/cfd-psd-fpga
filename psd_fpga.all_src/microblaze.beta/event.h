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

// UART stuff

#include	"uart.h"

// ************************
// Useful structures
// ************************

struct	channel_t {
	u8		addr ;
	u16		a ;
	u16		b ;
	u16		c ;
	u16		t ;
} ;

struct	event_t {
	u8		board_id ;
	u8		tstamp_low ;
	u8		tstamp_mid ;
	u16		tstamp_high ;
	struct 	channel_t	chan_data[16] ;
} ;


// *****************************************
// Some defines we need for the FIFO
// ****************************************

#define 	FIFO_DEV_ID	   	XPAR_AXI_FIFO_0_DEVICE_ID

// Size of words in bytes

#define 	WORD_SIZE 	4

// Max packet length

#define 	MAX_PACKET_LEN 			200
#define 	NO_OF_PACKETS 			1
#define 	MAX_DATA_BUFFER_SIZE 	(NO_OF_PACKETS * MAX_PACKET_LEN)

// ***********************************************
// Externs
// ********************************************

extern	XLlFifo 		FifoInstance;
// extern	u32 			DestinationBuffer[MAX_DATA_BUFFER_SIZE * WORD_SIZE];
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

int rx_packet (XLlFifo *InstancePtr, u32* DestinationAddr)  ;

// A routine to test FIFO and transmission of binary data
// back to the host

// void fifo_test(void) ;

#endif /* SRC_EVENT_H_ */

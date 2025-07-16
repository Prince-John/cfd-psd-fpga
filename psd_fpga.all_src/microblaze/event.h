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

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// If time1 < TIME1_THRESHOLD then use TIME2
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#define		TIME1_THRESHOLD		400

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// INTB goes low a fixed number of clock cycles after common stop
// We would like to adjust timestamp to account for this
// I am just guessing at this point.  We will need to measure this.
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#define		TIME1_OS		1
#define		TIME2_OS		TIME1_OS + 1

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Define the byte locations in ordinary data packet array
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#define		BOARD_ID		0

// Next 4 locations contain the 32-bit event number (Little Endian)

#define		EVENT_NUMBER 	1

// Start of ADC data

#define		ADC_OS			5

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Define the byte locations in special data packet array
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

// Board id is 1 byte
// Event number is 4 bytes
// 7 bytes for timestamp counter (56 bits)
// Upper 44 bits is the integer part
// lower 12 bits is the fractional part

#define		TSTAMP			5

// Length of tstamp special packet

#define		TSTAMP_PACKET_LEN	12

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
#define		MAX_PACKET_BYTE_SIZE	200

// ***********************************************
// Variables defined elsewhere
// ********************************************

extern	XLlFifo 		FifoInstance;
extern	u32 			DestinationBuffer[MAX_DATA_BUFFER_SIZE];
extern	XLlFifo_Config 	*Config ;

// Global variable to keep track of the board's number

extern	int				board_id ;

// Global variable to keep track of event number

extern	u32				event_number ;

// ^^^^^^^^^^^^^^^^^^^
// Functions
// ^^^^^^^^^^^^^^^^^^^

// Polls the take_event line

bool	isEventMode() ;

// Routine to take TDC7200 data and compute TOF values

unsigned long long 	calculate_timestamp(unsigned long long timestamp, u32 time1, u32 time2, u32 cal1, u32 cal2) ;

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

// Routine to send packet back to host

void send_packet(int packet_len, u8 *data_packet) ;

#endif /* SRC_EVENT_H_ */

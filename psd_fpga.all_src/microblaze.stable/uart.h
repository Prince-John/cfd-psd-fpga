/*
 * uart.h
 *
 *  Created on: Aug 17, 2024
 *      Author: gle
 */

#ifndef SRC_UART_H_
#define SRC_UART_H_

// Data types

#include 	<xil_types.h>

// 16650 UART

#include	<xuartns550.h>
#include	<xuartns550_l.h>

// ******************************************************
// Some common single byte ASCII control bytes
// ******************************************************

// Start of text (^B i.e. control-b)

#define		STX		0x02

// End of text (^c)

#define		ETX		0x03

// End of transmission (^D)

#define		EOT		0x04

// Acknowledge (^F)

#define		ACK		0x06

// Alarm Bell (^G)

#define		BEL		0x07

// Negative acknowledge (^U)

#define		NAK		0x15

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */

#define STDOUT_IS_16550
#define STDOUT_BASEADDR XPAR_AXI_UART16550_0_BASEADDR

#ifndef SDT
#define UART_BASEADDR		XPAR_UARTNS550_0_BASEADDR
#define UART_CLOCK_HZ		XPAR_UARTNS550_0_CLOCK_FREQ_HZ
#else
#define UART_BASEADDR		XPAR_XUARTNS550_0_BASEADDR
#define UART_CLOCK_HZ		XPAR_XUARTNS550_0_CLOCK_FREQ
#endif

/*
 * The following constant controls the length of the buffers to be sent
 * and received with the UART, this constant must be 16 bytes or less so the
 * entire buffer will fit into the transmit and receive FIFOs of the UART
 */

#define 	UART_BAUDRATE		3000000   /* Baud Rate */
#define 	TEST_BUFFER_SIZE 16
extern		u8 SendBuffer[TEST_BUFFER_SIZE]; /* Buffer for Transmitting Data */
extern		u8 RecvBuffer[TEST_BUFFER_SIZE]; /* Buffer for Receiving Data */

// ************************************
// Functions
// ***********************************

bool 	uart_byte_ready() ;
u8 		uart_get_byte() ;
void 	uart_send_byte(u8 byte) ;

void 	init_uart(void) ;
u32 	uart_test(void) ;

#endif /* SRC_UART_H_ */

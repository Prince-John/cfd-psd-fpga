/*
 * uart.c
 *
 *  Created on: Aug 17, 2024
 *      Author: gle
 */

#include "main.h"

#define		MAX_PACKET_SIZE		200

// *****************************
// Initializes 16550 UART
// *****************************

void init_uart(void) {

// Set baudrate

    XUartNs550_SetBaud(STDOUT_BASEADDR, XPAR_XUARTNS550_CLOCK_HZ, UART_BAUDRATE);

// Other tty parms

    XUartNs550_SetLineControlReg(STDOUT_BASEADDR, XUN_LCR_8_DATA_BITS);

// Enable the FIFOs for 16550 mode since the defaults is NO FIFOs

	XUartNs550_WriteReg(UART_BASEADDR, XUN_FCR_OFFSET, XUN_FIFO_ENABLE);

    return ;
}

// ********************************************************
// Send a str
// ********************************************************

void uart_send_str(char* text, int size) {

	u8 byte = 0x00;

	for (int i = 0; i < size; i++){
		byte = text[i];
		XUartNs550_SendByte(UART_BASEADDR, byte);
	}
	XUartNs550_SendByte(UART_BASEADDR, 0x00);

	return ;
}


// ********************************************************
// Send a byte
// ********************************************************

void uart_send_byte(u8 byte) {
	XUartNs550_SendByte(UART_BASEADDR, byte);
	return ;
}

// ****************************************
// Checks to see if byte ready
// ******************************************

bool uart_byte_ready() {
	if (XUartNs550_IsReceiveData(UART_BASEADDR)) {
		return true ;
	} else {
		return false ;
	}
}

// ********************************************************
// Get the byte
// Make sure byte is available before calling this routine
// ********************************************************

u8 uart_get_byte() {
	u8	byte ;
	byte = (u8) XUartNs550_ReadReg(UART_BASEADDR, XUN_RBR_OFFSET) ;
	return byte ;
}

// ***************************************************************
// Get a string (i.e. return when \0 (NULL) is received
// Returns number of ascii characters received (including the null}
// uartStr is global variable
// ***************************************************************

int uart_get_str() {
	int		i = 0 ;
	u8		byte ;

	do {
		do {} while (!uart_byte_ready());
		byte = uart_get_byte() ;
		uartStr[i] = byte ;
		i++ ;
	} while (byte != 0x00) ;
	return i ;
}

// *******************
// Test UART
// *******************

u32 uart_test(void) {
    u8   	recv ;
    u8		packet[MAX_PACKET_SIZE] ;
    u8		cobs_packet[MAX_PACKET_SIZE + 2] ;
    u32		ts, tf, delta  ;
    int		i ;
    int		packet_len ;
    int		cobs_packet_len ;

// Send an 'X' let python script
// know it should break out and look
// for S which will start binary data test
// Need \r\n else xil_printf didn't appear to flush

    xil_printf("X\r\n") ;

 // Create the block of data
 // Use the COBS encode routine to create a \0 terminated packet
 // cobsEncode doesn't return with the \0 so we should add it

    packet_len = 100 ;
    for (i = 0 ; i  < packet_len ; i++) {
    	packet[i] = (u8) (i) ;
    }
    cobs_packet_len = cobsEncode(packet, packet_len, cobs_packet) ;
    cobs_packet[cobs_packet_len] = 0x00 ;

// Wait for start command, 'S'
// Waiting for single character to come in

    do {
    	recv = (u8) XUartNs550_RecvByte(UART_BASEADDR);
    } while (recv != 'S') ;

// Get timestamp from timer 0

    ts = XTmrCtr_GetTimerCounterReg(TMRCTR_BASEADDR, TIMER_COUNTER_0) ;

// Send the packet

    for (i = 0 ; i  <= cobs_packet_len ; i++) {
    	XUartNs550_SendByte(UART_BASEADDR, cobs_packet[i]);
    }

// Get timestamp from timer 0

	tf = XTmrCtr_GetTimerCounterReg(TMRCTR_BASEADDR, TIMER_COUNTER_0) ;

// Compute elapsed time

	delta = tf - ts ;

// Send a similar packet but this time let's change slightly
// so it contains a few more zeros

	packet[10] = 0x00 ;
	packet[15] = 0x00 ;
	packet[25] = 0x00 ;
    cobs_packet_len = cobsEncode(packet, packet_len, cobs_packet) ;
    cobs_packet[cobs_packet_len] = 0x00 ;
    for (i = 0 ; i  <= cobs_packet_len ; i++) {
    	XUartNs550_SendByte(UART_BASEADDR, cobs_packet[i]);;
    }

// 	Send a packet which is just 2 bytes long (cobs packet will be 4 bytes long)
//	That says we are done .. last packet that we are sending

    packet_len = 2 ;
    cobs_packet_len = cobsEncode(packet, packet_len, cobs_packet) ;
    cobs_packet[cobs_packet_len] = 0x00 ;
    for (i = 0 ; i  <= cobs_packet_len ; i++) {
    	XUartNs550_SendByte(UART_BASEADDR, cobs_packet[i]);;
    }

// Return the elapsed time from the first packet transmission

    return delta ;
}


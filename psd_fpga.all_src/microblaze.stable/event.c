/*
 * event.c
 *
 *  Created on: Aug 20, 2024
 *      Author: gle
 */

//
// Contains structures and routines that allow us to handle
// event data which we will transmit back to host over a
// 3 MBaud USB link
//

#include  "event.h"

// *************************************************
// Check the take event input to see if take_event is high
// *************************************************

bool	isEventMode() {
	return false ;
}

// *************************************************
// Check the take event input to see if take_event is high
// *************************************************

void 	eventHandler() {
	return ;
}


/** COBS encode data to buffer
	@param data Pointer to input data to encode
	@param length Number of bytes to encode
	@param buffer Pointer to encoded output buffer
	@return Encoded buffer length in bytes
	@note Does not output delimiter byte
*/

size_t cobsEncode(u8 *data, size_t length, u8 *buffer) {

	u8 		*encode = buffer; // Encoded byte pointer
	u8		*codep = encode++; // Output code pointer
	u8		code = 1; // Code value

	for (u8 *byte = (u8 *)data; length--; ++byte) {
		if (*byte) *encode++ = *byte, ++code;
		if (!*byte || code == 0xff) {
			*codep = code, code = 1, codep = encode;
			if (!*byte || length)
				++encode;
		} // end if
	} // end for
	*codep = code; // Write final code value

	return (size_t)(encode - buffer);
}


/** COBS decode data from buffer
	@param buffer Pointer to encoded input bytes
	@param length Number of bytes to decode
	@param data Pointer to decoded output data
	@return Number of bytes successfully decoded
	@note Stops decoding if delimiter byte is found
*/

size_t cobsDecode(u8 *buffer, size_t length, u8 *data) {

	u8  *byte = buffer; // Encoded input byte pointer
	u8  *decode = (u8 *)data; // Decoded output byte pointer

	for (u8 code = 0xff, block = 0; byte < buffer + length; --block) {
		if (block) // Decode block byte
			*decode++ = *byte++;
		else {
			block = *byte++;
			if (block && (code != 0xff)) *decode++ = 0;
			code = block;
			if (!code) break;
		} // end if-then-else
	} // end for

	return (size_t)(decode - (uint8_t *)data);
}

// *****************************************
// Initialize the streaming FIFO
// *****************************************

int		init_fifo() {

	int 	Status = XST_SUCCESS ;

/* Initialize the Device Configuration Interface driver */

#ifndef SDT
	Config = XLlFfio_LookupConfig(XPAR_AXI_FIFO_0_DEVICE_ID);
#else
	Config = XLlFfio_LookupConfig(XPAR_AXI_FIFO_0_BASEADDR);
#endif
	if (!Config) {
#ifndef SDT
		xil_printf("No config found for %d\r\n", XPAR_AXI_FIFO_0_DEVICE_ID);
#endif
		return XST_FAILURE;
	}

// Fifo instance structure now knows base address

	Status = XLlFifo_CfgInitialize(&FifoInstance, Config, Config->BaseAddress);

	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed: %d\n\r", Status) ;
		return Status ;
	} else {
		xil_printf("Initialization succeeded\n\r");
	}

//	Check for the Reset value

	Status = XLlFifo_Status(&FifoInstance);

	XLlFifo_IntClear(&FifoInstance,0xffffffff);

	Status = XLlFifo_Status(&FifoInstance);

	if(Status != 0x0) {
		xil_printf("\n ERROR : Reset value of ISR0 : 0x%x\t Expected : 0x0\n\r", XLlFifo_Status(&FifoInstance));
		return XST_FAILURE;
	}
	return XST_SUCCESS ;
}

// **********************************************************
//
// rx_packet routine.
// It will receive the data packet from the FIFO.
// Returns number of words in the packet.
//
// **********************************************************

int rx_packet (XLlFifo *InstancePtr, u32* DestinationAddr) {
	int 	i;
	u32 	RxWord ;
	u32		ReceiveLength ;

	ReceiveLength = 0 ;
	if (XLlFifo_iRxOccupancy(InstancePtr)) {
		ReceiveLength = (XLlFifo_iRxGetLen(InstancePtr)) / WORD_SIZE;
		for (i=0; i < ReceiveLength; i++) {
			RxWord = XLlFifo_RxGetWord(InstancePtr);
			*(DestinationBuffer+i) = RxWord;
		} // end for
	} // end if

	return ((int) ReceiveLength) ;
}

// **********************************************
// FIFO test (UNDER CONSTRUCTION)
// **********************************************

/*
void fifo_test(void) {
	u8		data_packet{MAX_PACKET_BYTE_SIZE] ;
    u8		cobs_packet[MAX_PACKET_BYTE_SIZE + 2] ;
    int		i ;
    int		packet_word_len ;
    int		packet_len ;
    int		cobs_packet_len ;

// Get a packet from the custom logic block
// DestinationBuffer contains 32-bit words (4-bytes per word)

	packet_word_len = rx_packet(&FifoInstance, DestinationBuffer) ;
	packet_len = 4 * packet_word_len ;
	cobs_packet_len = cobsEncode(packet, packet_len, cobs_packet) ;
	cobs_packet[cobs_packet_len] = 0x00 ;

// Send the COBS encoded packet

	for (i = 0 ; i  <= cobs_packet_len ; i++) {
	    	XUartNs550_SendByte(UART_BASEADDR, cobs_packet[i]);
	} // end for

} // end fifo_test()
*/

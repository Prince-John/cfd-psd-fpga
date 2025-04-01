// ***************************************
// event.c
//
//  Created on: Aug 20, 2024
//  Author: gle
//
// Contains structures and routines that allow us to handle
// event data which we will transmit back to host over a
// 3 MBaud USB link
//
// ***************************************

#include  "event.h"
#include "timer.h"

u32 occupancy = 0;

// ********************************************************
// Check the take event input to see if take_event is high.
// For time being, just assume take event is always high
// *******************************************************

bool	isEventMode() {
	
	if (read_gpio_port(TAKE_EVENT_PORT, 1, TAKE_EVENT)) {
		return true ;
	} else {
		return false ;
	}
	
	
}

// ********************************************************
/** COBS encode data to buffer
	@param data Pointer to input data to encode
	@param length Number of bytes to encode
	@param buffer Pointer to encoded output buffer
	@return Encoded buffer length in bytes
	@note Does not output delimiter byte
*/
// ********************************************************

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

// ********************************************************
/** COBS decode data from buffer
	@param buffer Pointer to encoded input bytes
	@param length Number of bytes to decode
	@param data Pointer to decoded output data
	@return Number of bytes successfully decoded
	@note Stops decoding if delimiter byte is found
*/
// ********************************************************

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

// Look up config

	Config = XLlFfio_LookupConfig(FIFO_DEV_ID);

// We are NOT using a device tree

	if (!Config) {
//		xil_printf("No config found for %d\r\n", FIFO_DEV_ID);
		return XST_FAILURE;
	}

// FIFO instance structure now knows base address

	Status = XLlFifo_CfgInitialize(&FifoInstance, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return Status ;
	}

//	Check for the Reset value

	Status = XLlFifo_Status(&FifoInstance);
	XLlFifo_IntClear(&FifoInstance,0xffffffff);
	Status = XLlFifo_Status(&FifoInstance);

	if(Status != 0x0) {
//		xil_printf("\n ERROR : Reset value of ISR0 : 0x%x\t Expected : 0x0\n\r", XLlFifo_Status(&FifoInstance));
		return XST_FAILURE;
	}
	return XST_SUCCESS ;
}

// **********************************************************
//
// get_packet routine.
// It will receive the data packet from the FIFO
// Returns number of words in the packet.
// Won't return until tlast asserted.
//
// **********************************************************

int get_packet (XLlFifo *InstancePtr, u32* buffer) {
	int 	i;
	u32 	RxWord ;
	u32		ReceiveLength ;

	ReceiveLength = 0 ;
	while (XLlFifo_iRxOccupancy(InstancePtr)) {
		ReceiveLength = (XLlFifo_iRxGetLen(InstancePtr)) / FIFO_WORD_SIZE ;
		for (i=0; i < ReceiveLength; i++) {
			RxWord = XLlFifo_RxGetWord(InstancePtr);
			*(buffer+i) = RxWord;
		} // end for
	} // end if
	return ((int) ReceiveLength) ;
}


// **********************************************
// New event handler
// *************************************************

void eventHandler(void) {

// Array to hold event data

	u8		data_packet[MAX_PACKET_BYTE_SIZE] ;
	int		packet_len ;

// Data packet after being COBS encoded

	u8		cobs_packet[MAX_PACKET_BYTE_SIZE + 2] ;
	int		cobs_packet_len ;

// Get a packet from the custom logic block
// DestinationBuffer contains 32-bit words (4-bytes per word)

	int		packet_word_len ;

	packet_word_len = get_packet(&FifoInstance, DestinationBuffer) ;
	
	
	

// Go through the Destination Buffer to build event
// Data tag will tell us what kind of data we have

	u32		word ;
	u8		data_tag ;
	u8		data_type ;
	u8		data_subtype ;
	int		adc_lower ;

// Keep track of channel count

	int		chan_cnt = 0 ;

// Go through FIFO data one word at a time
// Board 0 is NOT currently supported

	for (int i = 0; i < packet_word_len; i++) {
		word = DestinationBuffer[i] ;
		data_tag = (word >> 24) & 0xff ;
		data_type = (data_tag >> 6) & 0x03 ;
		data_subtype = (data_tag >> 4) & 0x03 ;
		switch (data_type) {
			case 0 :	data_packet[BOARD_ID] = (word >> 16) & 0xff ;
						data_packet[ADC_OS + 9 * chan_cnt]=  data_tag & 0x0f  ;
						adc_lower = ADC_OS + (9 * chan_cnt) + (2 * data_subtype) + 1 ;
						data_packet[adc_lower] = word & 0xff ;
						data_packet[adc_lower + 1] = (word >> 8) & 0xff ;
						if (data_subtype == 3) chan_cnt++ ; 	// increment channel count
						break ;  // adc data

			case 1 :	if (data_subtype == 0) {
							data_packet[TSTAMP_LOW] = word & 0xff ;
							data_packet[TSTAMP_LOW + 1] = (word >> 8) & 0xff ;
							data_packet[TSTAMP_LOW + 2] = (word >> 16) & 0xff ;
						} else {
							data_packet[TSTAMP_HIGH] = word & 0xff ;
							data_packet[TSTAMP_HIGH + 1] = (word >> 8) & 0xff ;
							data_packet[TSTAMP_HIGH + 2] = (word >> 16) & 0xff ;
						}
						break ;	// timestamp data

			case 2 :	break ;	// TIME1 or TIME2 data

			case 3 :	break ;	// CAL1 or CAL2 data
		} // end switch
	} // end for

// We'll COBS encode the data_packet and then send the COBS encoded packet data out UART
	
	packet_len = 7 + 9 * chan_cnt ;
	
	if (packet_word_len != 0) {
		cobs_packet_len = cobsEncode(data_packet, packet_len, cobs_packet) ;
		cobs_packet[cobs_packet_len] = 0x00 ;
		int		i ;
		for (i = 0 ; i  <= cobs_packet_len ; i++) {
	    	XUartNs550_SendByte(UART_BASEADDR, cobs_packet[i]);
		} // end for
	} // end if

// Clear the FIFO before we continue

	XLlFifo_IntClear(&FifoInstance,0xffffffff);

// Don't leave this eventHandler until take_event goes low
	while (isEventMode()){
		//eventHandler();
		usleep(100) ;
	}

} // end eventHandlerNew




// **********************************************
// Event handler (Old)
// *************************************************

/*
 
	void eventHandlerOld(void) {
	
	// Data packet
	
		u8		data_packet[MAX_PACKET_BYTE_SIZE] ;
	
	// Data packet after being COBS encoded
	
		u8		cobs_packet[MAX_PACKET_BYTE_SIZE + 2] ;
	
	// Length of packet in words
	
		int		packet_word_len ;
	
	// Length of packet in bytes
	
		int		packet_len ;
	
	// Length of packet after being COBS encoded
	
		int		cobs_packet_len ;
	
	// Get a packet from the custom logic block
	// DestinationBuffer contains 32-bit words (4-bytes per word)
	
		packet_word_len = get_packet(&FifoInstance, DestinationBuffer) ;
	
		for (int i = 0; i < packet_word_len; i++) {
			data_packet[4 * i] = (DestinationBuffer[i] >> 24) & 0xFF;
			data_packet[4 * i + 1] = (DestinationBuffer[i] >> 16) & 0xFF;
			data_packet[4 * i + 2] = (DestinationBuffer[i] >> 8) & 0xFF;
			data_packet[4 * i + 3] = DestinationBuffer[i] & 0xFF;
		}
		packet_len = 4 * packet_word_len ;
		if (packet_len != 0) {
			cobs_packet_len = cobsEncode(data_packet, packet_len, cobs_packet) ;
			cobs_packet[cobs_packet_len] = 0x00 ;
			int		i ;
			for (i = 0 ; i  <= cobs_packet_len ; i++) {
				XUartNs550_SendByte(UART_BASEADDR, cobs_packet[i]);
			} // end for
		} // end if
	
	// Don't leave this eventHandler until take_event goes low
	
		while (isEventMode()){
			//eventHandler();
			usleep(100) ;
		} ;
		

} // end eventHandler
*/

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

// ********************************************************
// Check the take event input to see if take_event is high.
// For time being, just assume take event is always high
// *******************************************************
extern int fifo_occupancy_flag;

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
	u32		occupancy ;

	ReceiveLength = 0 ;
	occupancy = XLlFifo_iRxOccupancy(InstancePtr) ;
	if (occupancy) {
		ReceiveLength = (XLlFifo_iRxGetLen(InstancePtr)) / FIFO_WORD_SIZE ;
		for (i=0; i < ReceiveLength; i++) {
			RxWord = XLlFifo_RxGetWord(InstancePtr);
			*(buffer+i) = RxWord;
		} // end for
	} // end if

//	if ((occupancy != 0) && (occupancy != 6)) {
//		while (1) { } ;
//	}

	return ((int) ReceiveLength) ;
}

// **********************************************
// Routine to transmit data packet back to host
// *************************************************

void send_packet(int packet_len, u8 *data_packet) {
	u8		cobs_packet[MAX_PACKET_BYTE_SIZE + 2] ;
	int		cobs_packet_len ;
	int		i ;

	cobs_packet_len = cobsEncode(data_packet, packet_len, cobs_packet) ;
	cobs_packet[cobs_packet_len] = 0x00 ;
	for (i = 0 ; i  <= cobs_packet_len ; i++) {
	    	XUartNs550_SendByte(UART_BASEADDR, cobs_packet[i]);
	} // end for

} // sendPacket()

// **********************************************
// Compute the complete timestamp
// Integer part is 44 bits from timestamp counter
// Fractional part is 12 bits that we will compute
// Implied binary point is 12 places in from right
// To compute time in python code
// Divide the timestamp by 2 ** 12 (4096) and then
// multiply by period of 10 MHz clock i.e. 100 ns
// *************************************************

unsigned long long create_timestamp(unsigned long long timestamp, u32 time1, u32 time2, u32 cal1, u32 cal2) {
	unsigned long long		calCount ;
	unsigned long long		tof, frac_part ;

// Compute difference between the two calibration values

	calCount = cal2 - cal1 ;

// Need to decide whether to use TIME1 or TIME2
// If time1 < 350 (TIME1_THRESHOLD) we are too close to next rising edge so use time2
// Rounding when I do divide .... should probably round
// Will worry about this later!

	if (time1 < TIME1_THRESHOLD) {
		tof = (time2 << 12) / calCount ;
		frac_part = calCount - tof ;
		timestamp = timestamp - TIME2_OS ;
	} else {
		tof = (time1 << 12) / calCount ;
		frac_part = calCount - tof ;
		timestamp = timestamp - TIME1_OS ;
	} // end if-then-else

	timestamp = (timestamp << 12) | (frac_part & 0x00000fff) ;

	return timestamp ;
}

// **********************************************
// Event handler
// board_id and event_number are global variables
// *************************************************

void eventHandler(void) {

// Array to hold event data

	u8		data_packet[MAX_PACKET_BYTE_SIZE] ;
	int		packet_len ;

// Array to hold special packet for full timestamp
// For time being sending TIME1, TIME2, CALIB1, CALIB2
// Later will use these to compute 12-bit fractional part
// and send that!

	u8		tstamp_data_packet[TSTAMP_PACKET_LEN] ;
	int		tstamp_packet_len = TSTAMP_PACKET_LEN ;

// Get a packet from the custom logic block
// DestinationBuffer contains 32-bit words (4-bytes per word)

	int		packet_word_len ;
	packet_word_len = get_packet(&FifoInstance, DestinationBuffer) ;

// If nothing in the FIFO then just return
// Increment the global variable event_number each time
// the event handler is called

	if (packet_word_len == 0) {
		return ;
	} else {
		event_number++ ;
	} // end if-else

// Go through the Destination Buffer to build event
// Data tag will tell us what kind of data we have

	u32					word ;
	u8					data_tag, data_type, data_subtype ;
	u8					*byte_ptr ;

	u32					tstamp_low, tstamp_high ;
	u32					time1, time2, cal1, cal2 ;
	unsigned long long	tstamp ;

// Keep track of channel count

	int		chan_cnt = 0 ;
	int		adc_lower ;

	tstamp_low = 0 ;
	tstamp_high = 0 ;
	time1 = 0 ;
	time2 = 0 ;
	cal1 = 0 ;
	cal2 = 0 ;

// Go through FIFO data one word at a time
// board_id is global variable set in the main.c
// Microblaze by default uses LITTLE ENDIAN
// Use this fact to access bytes correctly
// along with pointer arithmetic!

	for (int i = 0; i < packet_word_len; i++) {

// Go through and process each 32-bit word in the FIFO buffer

		word = DestinationBuffer[i] ;
		byte_ptr = (u8 *) &word ;
		data_tag = (word >> 24)  ;
		data_type = (data_tag >> 6) & 0x03 ;
		data_subtype = (data_tag >> 4) & 0x03 ;

// We have 4 different types of data (adc, time counter, tdc time data, tdc cal data)

		switch (data_type) {
			case 0 :	data_packet[ADC_OS + 9 * chan_cnt]=  data_tag & 0x0f  ;

						adc_lower = ADC_OS + (9 * chan_cnt) + (2 * data_subtype) + 1 ;
						data_packet[adc_lower] = *(byte_ptr) ;
						data_packet[adc_lower + 1] = *(byte_ptr + 1);
						if (data_subtype == 3) chan_cnt++ ; 	// increment channel count
						break ;  // adc data

			case 1 :	if (board_id == 0) {
							if (data_subtype == 0) {
								tstamp_low = word ;
							} else {
								tstamp_high = word ;
							} // end if-the-else
						} // end if
						break ;	// timestamp counter data

			case 2 :	if (board_id == 0) {
							if (data_subtype == 1) {
								time1 = word & 0x007fffff ;
							} else {
								time2 = word  & 0x007fffff ;
							} // end if-then-else
						}  // end if
						break ;	// TIME1 or TIME2 data

			case 3 :	if (board_id == 0) {
							if (data_subtype == 1) {
								cal1 = word & 0x007fffff ;
							} else {
								cal2 = word & 0x007fffff ;
							} // end if-then-else
						} // end if
						break ;	// CALIB1 or CALIB2 data
		} // end switch
	} // end for

// ORDINARY packet

	if (chan_cnt != 0) {
		//xil_printf("Channel Multiplicity -> %d, packet word length = %d \r\n", chan_cnt, packet_word_len);
		data_packet[BOARD_ID] = board_id ;
		byte_ptr = (u8 *) &event_number;
		data_packet[EVENT_NUMBER] = *(byte_ptr) ;
		data_packet[EVENT_NUMBER + 1] = *(byte_ptr + 1) ;
		data_packet[EVENT_NUMBER + 2] = *(byte_ptr + 2) ;
		data_packet[EVENT_NUMBER + 3] = *(byte_ptr + 3) ;

// Send the packet back to the host

		packet_len = ADC_OS + 9 * chan_cnt  ;
		send_packet(packet_len, data_packet) ;

	} // end if

// Check to see if this is board 255
// "SPECIAL" time packet

	if (board_id == 255) {

// Insert the board id

		tstamp_data_packet[BOARD_ID] = 0xff ;

// Insert the event number (4 bytes)

		byte_ptr = (u8 *) &event_number ;
		tstamp_data_packet[EVENT_NUMBER] = *(byte_ptr) ;
		tstamp_data_packet[EVENT_NUMBER + 1] = *(byte_ptr + 1) ;
		tstamp_data_packet[EVENT_NUMBER + 2] = *(byte_ptr + 2) ;
		tstamp_data_packet[EVENT_NUMBER + 3] = *(byte_ptr + 3) ;

// Create the integer part of the timestamp

		tstamp = ((tstamp_high & 0x00ffffff) << 24) | (tstamp_low & 0x00ffffff) ;

// Calculate the complete timestamp (integer part + fractional part)
// Integer part comes from the timestamp counter while fractional part
// is computed using TDC7200 data

		tstamp = create_timestamp(tstamp, time1, time2, cal1, cal2) ;

// Insert the complete timestamp (7 bytes long) into the packet

		byte_ptr = (u8 *) &tstamp  ;
		tstamp_data_packet[TSTAMP] =  *(byte_ptr);
		tstamp_data_packet[TSTAMP + 1] =  *(byte_ptr + 1) ;
		tstamp_data_packet[TSTAMP + 2] =  *(byte_ptr + 2) ;
		tstamp_data_packet[TSTAMP + 3] =  *(byte_ptr + 3) ;
		tstamp_data_packet[TSTAMP + 4] =  *(byte_ptr + 4) ;
		tstamp_data_packet[TSTAMP + 5] =  *(byte_ptr + 5) ;
		tstamp_data_packet[TSTAMP + 6] =  *(byte_ptr + 6) ;

// Send the packet back to host

		send_packet(tstamp_packet_len, tstamp_data_packet) ;

	} // end if

// Don't leave this eventHandler until take_event goes low
	fifo_occupancy_flag = XLlFifo_iRxOccupancy(&FifoInstance);
	while (isEventMode()){ } ;

} // end eventHandler



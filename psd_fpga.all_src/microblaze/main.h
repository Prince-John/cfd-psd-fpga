/*
 * main.h
 *
 *  Created on: Aug 16, 2024
 *      Author: gle
 */

#ifndef SRC_MAIN_H_
#define SRC_MAIN_H_

//Automated version tagging
#include "version.h"

// Boolean support

#include    <stdbool.h>

// Xilinx data types

#include    <xil_types.h>

// Xilinx light weight printf()

#include    <xil_printf.h>

// Some useful utilities

#include	"str_utils.h"

// GPIO related stuff

#include    "i2c.h"

// Tests for basic functionality
// Self tests uses LCD module

#include    "self_test.h"

// Timer support

#include 	"timer.h"

// 16650 UART stuff

#include	"uart.h"

// Configurations routines

#include    "config_routines.h"

// GPIO routines

#include 	"gpio.h"

// Event related stuff
// COBS and FIFO support

#include	"event.h"


#endif /* SRC_MAIN_H_ */

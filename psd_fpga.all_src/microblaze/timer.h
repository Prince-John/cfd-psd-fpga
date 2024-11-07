#ifndef SRC_TIMER_H_
#define SRC_TIMER_H_

// Standard stuff

#include 	<stdint.h>
#include 	<stdio.h>

// Delays

#include 	<sleep.h>

// Microblaze parameters

#include 	<xparameters.h>

// Data types

#include 	<xil_types.h>

// Light weight printf

#include 	<xil_printf.h>

// Counter/Timer support

#include 	<xtmrctr_l.h>

#ifndef SDT
#define TMRCTR_BASEADDR		XPAR_TMRCTR_0_BASEADDR
#else
#define TMRCTR_BASEADDR		XPAR_XTMRCTR_0_BASEADDR
#endif

#define TIMER_COUNTER_0	 0

// ***********************
// Function definitions
// ***********************

void    	init_timer(void) ;

#endif /* SRC_TIMER_H_ */


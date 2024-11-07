// Application specific defines

#include "timer.h"

// *******************************************
// Routine to initialize timer/counter
// Using low level routines
// *******************************************

void init_timer(void) {

//
// Clear the Control Status Register
//

	XTmrCtr_SetControlStatusReg(TMRCTR_BASEADDR, TIMER_COUNTER_0, 0x0) ;

//
// Enable the timer
//

	XTmrCtr_Enable(TMRCTR_BASEADDR, TIMER_COUNTER_0) ;

	return ;
}



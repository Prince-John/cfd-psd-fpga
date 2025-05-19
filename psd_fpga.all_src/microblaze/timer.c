// Application specific defines

#include "timer.h"

// *******************************************
// Routine to initialize timer/counter
// Using low level routines
// *******************************************
int time_1;
int time_2;
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

u32 get_timer_value(void) {

   
    u32 call_value = XTmrCtr_GetTimerCounterReg(TMRCTR_BASEADDR, TIMER_COUNTER_0);
    //XTmrCtr_Disable(TMRCTR_BASEADDR, TIMER_COUNTER_0);
    //u32 call_value_ms = (u32) call_value * 0.01;
    
    return call_value;
}

//

#ifndef SRC_SELF_TESTS_H_
#define SRC_SELF_TESTS_H_

#include "stdbool.h"

// Microblaze parameters

#include <xparameters.h>

// Counter/Timer support

#include	"timer.h"

// Variable to tell use to use LCD module for debug

extern  bool    	useLCD ;
extern	bool		doMathTest ;
extern	bool        doUartTest ;
extern	bool        doConfigTests ;

// String buffer used for writing to LCD

extern  char    LCDstr[80] ; 

// Public functions

void    self_tests(void) ;
void 	math_test(void) ;
void 	config_tests(void) ;

#endif /* SRC_SELF_TESTS_H_ */

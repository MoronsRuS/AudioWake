#include "sprs.h"

void external_exception();

void Start() {
	volatile unsigned int* leds = (unsigned int*)(0xF0000000);
	while(1) {
		*leds = 0xEEBBAA99;
//		*leds = 0x99AABBEE;
	}
}

void external_exception()
{
   unsigned long inter;
   inter = spr_int_getflags();
   spr_int_clearflags( inter );
}

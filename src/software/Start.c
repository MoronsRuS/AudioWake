#include "sprs.h"

void external_exception();

volatile unsigned int* leds = (unsigned int*)(0x80000000);

void Start() {
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

#include "sprs.h"

void external_exception();

void Start() {
	volatile unsigned int* leds = (unsigned int*)(0xF0000000);
	volatile unsigned char* i2c0_PRERlo = (unsigned char*)(0xF4000000);
	volatile unsigned char* i2c0_PRERhi = (unsigned char*)(0xF4000001);
	volatile unsigned char* i2c0_CTR = (unsigned char*)(0xF4000002);
	volatile unsigned char* i2c0_DAT = (unsigned char*)(0xF4000003);
	volatile unsigned char* i2c0_CSR = (unsigned char*)(0xF4000004);
	*i2c0_CTR =	0x00;//Disable
	*i2c0_PRERhi =	0x00;//Set prescale
	*i2c0_PRERlo =	0x63;//Set prescale
	*i2c0_CTR =	0x80;//Enable
	*i2c0_CSR =	0x68;//stop, read, nack
	while ( (*i2c0_CSR) & 0x02);
	while(1) {
		*i2c0_DAT =	0xD0;//Device address,write
		*i2c0_CSR =	0x90;//start,write
		while ( (*i2c0_CSR) & 0x02) {
			*leds = 0x00000001;
		}
		if ( ( (*i2c0_CSR) & 0x80)) {
			while (1) *leds = 0x00000002;
		}
		*i2c0_DAT =	0x00;//Register address
		*i2c0_CSR =	0x10;//write
		while ( (*i2c0_CSR) & 0x02) {
			*leds = 0x00000003;
		}
		if ( ( (*i2c0_CSR) & 0x80)) {
			while (1) *leds = 0x00000004;
		}
		*i2c0_DAT =	0xD1;//Device address,read
		*i2c0_CSR =	0x90;//start,write
		while ( (*i2c0_CSR) & 0x02) {
			*leds = 0x00000004;
		}
		if ( ( (*i2c0_CSR) & 0x80)) {
			while (1) *leds = 0x00000005;
		}
		*i2c0_CSR =	0x20;//read
		while ( (*i2c0_CSR) & 0x02) {
			*leds = 0x00000006;
		}
		*leds = *i2c0_DAT;
		while(1);
//		while (1) *leds = 0x99AABBEE;
	}
}

void external_exception()
{
	volatile unsigned int* leds = (unsigned int*)(0xF0000000);
	while(1) *leds = 0x12345678;
	unsigned long inter;
	inter = spr_int_getflags();
	spr_int_clearflags( inter );
}

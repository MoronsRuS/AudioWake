#include "sprs.h"

void external_exception();
void rtcInit();
void rtcRead(char address, char* data,unsigned int num);
void rtcWrite(char address, char* data,unsigned int num);

#define LEDS (*(volatile unsigned int*)(0xF0000000))
#define SEG7 ((volatile unsigned char*)(0xF0000010))

#define DEBUG_WORD(word) {\
	SEG7[0] = ((((unsigned int)(void*)word)>>0)&0xF); \
	SEG7[1] = ((((unsigned int)(void*)word)>>4)&0xF); \
	SEG7[2] = ((((unsigned int)(void*)word)>>8)&0xF); \
	SEG7[3] = ((((unsigned int)(void*)word)>>12)&0xF);} \
	LEDS = ((((unsigned int)(void*)word)>>24) & 0xFF); \

void Start() {
	volatile unsigned int* leds = (unsigned int*)(0xF0000000);
	volatile unsigned char* seg7 = (unsigned char*)(0xF0000010);
	volatile unsigned int* switches = (unsigned int*)(0xF0000020);
	volatile unsigned int* buttons = (unsigned int*)(0xF0000024);
	char data[3];
//	volatile unsigned int test = 0x0128;
//	while (1) LEDS = test;
//		LEDS = 0x00000150;
//	while(1) {
//		DEBUG_WORD(0xF00D0256);
//	}
	rtcInit();
//		while (1) LEDS = 0x0000016F;
	while(1) {
		if ((*buttons) & 0x04) {
			char address = (*switches)>>8;
			data[0] = (*switches);
			rtcWrite((*switches)>>8,data,1);
		} else {
			rtcRead(0x00,data,3);
			if (data[0] & 0x80) {
				data[0] = 0x00;
				rtcWrite(0x00,data,1);
				seg7[3] = 0x0B;
				seg7[2] = 0x0A;
				seg7[1] = 0x0D;
				seg7[0] = 0x0D;
			} else {
				*leds = data[0];
				seg7[0] = data[1] & 0x0F;
				seg7[1] = data[1] >> 4;
				seg7[2] = data[2] & 0x0F;
				seg7[3] =	((data[2]>>4)&0x01)|
						((data[2]<<2)&0x80);
			}
		}
	}
}
void rtcInit() {
	volatile unsigned char* i2c0_PRERlo = (unsigned char*)(0xF4000000);
	volatile unsigned char* i2c0_PRERhi = (unsigned char*)(0xF4000001);
	volatile unsigned char* i2c0_CTR = (unsigned char*)(0xF4000002);
	volatile unsigned char* i2c0_DAT = (unsigned char*)(0xF4000003);
	volatile unsigned char* i2c0_CSR = (unsigned char*)(0xF4000004);
	LEDS = 0x00000151;
//	while (1) {
//		DEBUG_WORD(&i2c0_CTR);
//	}
	*i2c0_CTR =	0x00;//Disable
	*i2c0_PRERhi =	0x00;//Set prescale
	*i2c0_PRERlo =	0x63;//Set prescale
	*i2c0_CTR =	0x80;//Enable
	*i2c0_CSR =	0x68;//stop, read, nack
	while ( (*i2c0_CSR) & 0x02);
	LEDS = 0x00000152;
}

void rtcRead(char address, char* data,unsigned int num) {
	volatile unsigned int* leds = (unsigned int*)(0xF0000000);
	volatile unsigned char* i2c0_DAT = (unsigned char*)(0xF4000003);
	volatile unsigned char* i2c0_CSR = (unsigned char*)(0xF4000004);
	unsigned int i,end;
	*i2c0_DAT =	0xD0;//Device address,write
	*i2c0_CSR =	0x90;//start,write
	while ( (*i2c0_CSR) & 0x02);
	if ( ( (*i2c0_CSR) & 0x80)) {
		while (1) *leds = 0x00000001;
	}
	*i2c0_DAT =	address;//Register address
	*i2c0_CSR =	0x10;//write
	while ( (*i2c0_CSR) & 0x02);
	if ( ( (*i2c0_CSR) & 0x80)) {
		while (1) *leds = 0x00000002;
	}
	*i2c0_DAT =	0xD1;//Device address,read
	*i2c0_CSR =	0x90;//start,write
	while ( (*i2c0_CSR) & 0x02);
	if (num) {
		end = num-1;
		for (i=0; i<end; ++i) {
			if ( ( (*i2c0_CSR) & 0x80)) {
				while (1) *leds = 0x00000005;
			}
			*i2c0_CSR =	0x20;//read
			while ( (*i2c0_CSR) & 0x02);
			data[i] = *i2c0_DAT;
		}
		if ( ( (*i2c0_CSR) & 0x80)) {
			while (1) *leds = 0x00000004;
		}
		*i2c0_CSR =	0x68;//stop, read, nack
		while ( (*i2c0_CSR) & 0x02);
		data[end] = *i2c0_DAT;
	}
}

void rtcWrite(char address, char* data,unsigned int num) {
	volatile unsigned int* buttons = (unsigned int*)(0xF0000024);
	volatile unsigned int* leds = (unsigned int*)(0xF0000000);
	volatile unsigned int* switches = (unsigned int*)(0xF0000020);
	volatile unsigned char* i2c0_DAT = (unsigned char*)(0xF4000003);
	volatile unsigned char* i2c0_CSR = (unsigned char*)(0xF4000004);
	unsigned int i,end;
	*leds = data[0];
//	while(! (*buttons & 0x2));
	*i2c0_DAT =	0xD0;//Device address,write
	*i2c0_CSR =	0x90;//start,write
	while ( (*i2c0_CSR) & 0x02);
	if ( ( (*i2c0_CSR) & 0x80)) {
		while (1) *leds = 0x00000005;
	}
	*i2c0_DAT =	address;//Register address
	*i2c0_CSR =	0x10;//write
	while ( (*i2c0_CSR) & 0x02);
	if (num) {
		end = num-1;
		for (i=0; i<end; ++i) {
			if ( ( (*i2c0_CSR) & 0x80)) {
				while (1) *leds = 0x00000006;
			}
			*i2c0_DAT =	data[i];//Data
			*i2c0_CSR =	0x10;//write
			while ( (*i2c0_CSR) & 0x02);
		}
		if ( ( (*i2c0_CSR) & 0x80)) {
			while (1) *leds = 0x00000007;
		}
		*i2c0_DAT =	data[end];//Data
		*i2c0_CSR =	0x58;//stop, write, nack
		while ( (*i2c0_CSR) & 0x02);
	}
}



void exception_bus_error() {
	while (1) {
		SEG7[0] = 0x0D;
		SEG7[1] = 0x0D;
		SEG7[2] = 0x0A;
		SEG7[3] = 0x0B;
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

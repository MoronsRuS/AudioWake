#include "sprs.h"

void external_exception();
void rtcInit();
void rtcRead(char address, char* data,unsigned int num);
void rtcWrite(char address, char* data,unsigned int num);

void Start() {
	volatile unsigned int* leds = (unsigned int*)(0xF0000000);
	volatile unsigned char* seg7 = (unsigned char*)(0xF0000010);
	char data[3];
	rtcInit();
	while(1) {
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
			seg7[3] = ((data[2]>>4)&0x01)|((data[2]<<2)&0x80);
		}
	}
}
void rtcInit() {
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
		data[i] = *i2c0_DAT;
	}
}

void rtcWrite(char address, char* data,unsigned int num) {
	volatile unsigned int* leds = (unsigned int*)(0xF0000000);
	volatile unsigned char* i2c0_DAT = (unsigned char*)(0xF4000003);
	volatile unsigned char* i2c0_CSR = (unsigned char*)(0xF4000004);
	unsigned int i,end;
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
			data[i] = *i2c0_DAT;
		}
		if ( ( (*i2c0_CSR) & 0x80)) {
			while (1) *leds = 0x00000007;
		}
		*i2c0_DAT =	data[i];//Data
		*i2c0_CSR =	0x58;//stop, write, nack
		while ( (*i2c0_CSR) & 0x02);
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

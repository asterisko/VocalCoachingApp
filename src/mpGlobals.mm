//
//  ssGlobals.cpp
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 4/30/13.
//
//

#include "mpGlobals.h"
#include "mpApp.h"

extern mpApp * myApp;   // Global Pointer to mainApp

//////////////////////////////////////////////////////////////////////////////////
// Convertion Defined functions
//////////////////////////////////////////////////////////////////////////////////
int convSamp2Fram(int Nsamples){
    return((float) (Nsamples/myApp->bufferSize));
}

int convFram2Samp(int Nframes){
    return((float) (Nframes*myApp->bufferSize));
}

float convSamp2Sec(int Nsamples){
    return((float) Nsamples/myApp->sampleRate);
}

int convSec2Samp(float Nseconds){
    return((float) Nseconds*myApp->sampleRate);
}

float convFram2Sec(int Nframes){
    return((float) (Nframes*myApp->bufferSize)/(myApp->sampleRate));
}

int convSec2Fram(float Nseconds) {
    return((float)(Nseconds*myApp->sampleRate)/myApp->bufferSize);
}

//////////////////////////////////////////////////////////////////////////////////
// Math functions
//////////////////////////////////////////////////////////////////////////////////
double roundSIL(double d, int pp) // pow() doesn't work with unsigned, so made this switch.
    {
	return int(d * pow(10.0f, pp) + .5f) /  pow(10.0f, pp);
    }

// Perform Hanning Window to array
void hamming(float* v, int size) {
	for (int n = 0;n < size;n++)
        v[n] = (0.5f - 0.5f*cos(2*PI*((float)n/size)))*v[n];
}

// convert vector to dB
void dB(float * v, int size) {
    for (int i=0;i<size;i++) v[i] = 20.0f *log10(v[i]);
}


//////////////////////////////////////////////////////////////////////////////////
// Elementary Array Operations
//////////////////////////////////////////////////////////////////////////////////
void set2zero(float* v, int size){
	memset(v, 0, size * sizeof(float));
}

float sum(float* d, int size){
    
    double acc=0.0;
    for (int i=0; i<size; i++)
        acc+=d[i];
    
    return (float) acc;
}

float power(float* d, int size){
    
    float acc = 0.0;
    for (int i=0;i<size;i++)
        acc += d[i]*d[i];
    
    return 20*log10(acc/size);;
}

void scalarProd(float* v, int size, float scalar){
    for(int i = 0; i < size; i++)
        v[i] = v[i] * scalar;
}

void copy(float* a, float *b, int size){ // copy a to b product
    for(int i = 0; i < size; i++)
        b[i] = a[i];
    
}

// return index of maximum d
int maxi(float* d, int size)
{
	float max=d[0]; int i,idx=0, rm = size - ((size>>2)<<2);
	for (i=1; i<rm; i++) {if (d[i]>max) {max=d[i]; idx=i;}}
	for (i=rm; i<size; i+=4) {
		if ((d[i] > max) || (d[i+1] > max) || (d[i+2] > max) || (d[i+3] > max)) {
			if (d[i] > max) {max=d[i]; idx=i;}
			if (d[i+1] > max) {max=d[i+1]; idx=i+1;}
			if (d[i+2] > max) {max=d[i+2]; idx=i+2;}
			if (d[i+3] > max) {max=d[i+3]; idx=i+3;}
		}
	}
	return idx;
}

// return index of minimum d
int mini(float* d, int size)
{
	float min=d[0]; int i,idx=0, rm = size - ((size>>2)<<2);
	for (i=1; i<rm; i++) {if (d[i]<min) {min=d[i]; idx=i;}}
	for (i=rm; i<size; i+=4) {
		if ((d[i] < min) || (d[i+1] < min) || (d[i+2] < min) || (d[i+3] < min)) {
			if (d[i] < min) {min=d[i]; idx=i;}
			if (d[i+1] < min) {min=d[i+1]; idx=i+1;}
			if (d[i+2] < min) {min=d[i+2]; idx=i+2;}
			if (d[i+3] < min) {min=d[i+3]; idx=i+3;}
		}
	}
	return idx;
}

//////////////////////////////////////////////////////////////////////////////////
// Stats functions
//////////////////////////////////////////////////////////////////////////////////
float mean(float* d, int size) {
	return sum(d,size)/(float)(size);
}

//////////////////////////////////////////////////////////////////////////////////
// Audio functions



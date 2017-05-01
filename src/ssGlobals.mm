//
//  ssGlobals.cpp
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 4/30/13.
//
//

#include "ssGlobals.h"
#include "ssApp.h"

extern ssApp * myApp;   // Global Pointer to mainApp

//////////////////////////////////////////////////////////////////////////////////
// Convertion Midi <-> Note
//////////////////////////////////////////////////////////////////////////////////
float midi2freq(int _midi){
    float aux = pow(2.0,1.0/12);
    return((float) A4 * pow(aux,(_midi - 69)));
}

unsigned int freq2midi(float _freq){
    return( (unsigned int) roundSIL(69 + 12*log2f(_freq/A4),0));
}

float freq2midiExact(float _freq){
    return( 69 + 12*log2f(_freq/A4));
}
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
void hanning(float* v, int size) {
	for (int n = 0;n < size;n++)
        v[n] = (0.5f - 0.5f*cos(2*PI*((float)n/size)))*v[n];
}

void hamming(float* v, int size) {
    float alfa = 0.54f;
    float beta = 1.0f - alfa;
    
	for (int n = 0;n < size;n++)
        v[n] = (alfa - beta*cos(2*PI*((float)n/size)))*v[n];
}
// convert vector to dB
void dB(float * v, int size) {
    for (int i=0;i<size;i++) v[i] = 20.0f *log10(v[i]);
}

//////////////////////////////////////////////////////////////////////////////////
// Elementary Array Operations
//////////////////////////////////////////////////////////////////////////////////
void set2zero(float* v, int size){
    for(int i = 0; i < size; i++)
        v[i] = 0.0;
}

float sum(float* d, int size){
    
    double acc=0.0;
    for (int i=0; i<size; i++)
        acc+=d[i];
    
    return (float) acc;
}

void scalarProd(float* v, int size, float scalar){
    for(int i = 0; i < size; i++)
        v[i] = v[i] * scalar;
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

float maxx(float* d, int size) {
    float _max= d[0];
    
    for (int i=0;i<size;i++)
        if (d[i] > _max) _max = d[i];
    
	return _max;
}

float minn(float* d, int size) {
    float _min= d[0];

    for (int i=0;i<size;i++)
        if (d[i] < _min) _min = d[i];
    
	return _min;
}
//////////////////////////////////////////////////////////////////////////////////
// Stats functions
//////////////////////////////////////////////////////////////////////////////////
float mean(float* d, int size) {
	return sum(d,size)/(float)(size);
}

float stdev(float* v, int size) {
    
    float ave = mean(v,size);
    
    double E=0;
    
    for(int i=0 ; i<size ; i++)
        E +=(v[i] - ave)*(v[i] - ave);

    return sqrt(1/size*E);
}

void drawRectangle(int x, int y, int w, int h) {

    vector<ofPoint> rectPoints;
    rectPoints.resize(4);

    rectPoints[0].set(x   , y  , 0.0);
    rectPoints[1].set(x+w , y  , 0.0);
    rectPoints[2].set(x+w , y+h, 0.0);
    rectPoints[3].set(x   , y+h, 0.0);

    ofEnableSmoothing();
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, sizeof(ofVec3f), &rectPoints[0].x);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    ofDisableSmoothing();
}

void drawTest(void) {

// x, y, red, green, blue
GLfloat vertices[12][2] = {
    // red
    {100.0, 100.0},         // 0
    {200.0, 100.0},         // 2
    {200.0, 200.0},         // 3
    {100.0, 200.0},         // 1
    
    // green
    {100.0, 200.0},         // 4
    {200.0, 200.0},         // 6
    {200.0, 300.0},         // 7
    {100.0, 300.0},         // 5
    
    // blue
    {100.0, 300.0},         // 8
    {200.0, 300.0},         // 10
    {200.0, 400.0},         // 11
    {100.0, 400.0}          // 9
    };
   
GLushort indices[] = {  0, 1, 2, 3,
                        4, 5, 6, 7,
                        8, 9,10,11};

    ofSetColor(100, 100, 100);
glVertexPointer(2, GL_FLOAT, sizeof(GLfloat)*2, &vertices[0][0]);
    
// GL_TRIANGLE_STRIP— Use this primitive to draw a sequence of triangles that share edges.
// OpenGL renders a triangle using the first, second, and third vertices, and then another
// using the second, third, and fourth vertices, and so on. If the application specifies n vertices,
// OpenGL renders n–2 connected triangles. If n is less than 3, OpenGL renders nothing.
glDrawElements(GL_LINE_LOOP, 12, GL_UNSIGNED_SHORT, indices);
    
    
}



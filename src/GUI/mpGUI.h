#ifndef MPGUI
#define MPGUI

#include "ofMain.h"
#include "ofxUI.h"

///////////////////////////////////////////////////////////
// mpGUI CLASS
///////////////////////////////////////////////////////////
class mpGUI{
public:

    int     sampleRate;
    int     plotBuffer_size;
    int     input_buffer_size;
    int     volume;
    int     type;
    float * plotBuffer;
    
    // Canvas Object
    ofxUICanvas * mainCanvas;
    
    // Pointers to Objects accessed from other classes
	ofxUIWaveform           * tplot;
    ofxUIImageSlider        * slider_volume;
    ofxUIImageSlider        * slider_delay;
    ofxUIImageSlider        * slider_pitch;
    ofxUILabel              * label_volume;
    ofxUILabel              * label_delay;
    ofxUILabel              * label_pitch;
    ofxUILabel              * label_power;
    ofxUIMultiImageToggle   * btn_play;
    ofxUIMultiImageToggle   * btn_T;
    ofxUIMultiImageToggle   * btn_F;
    ofxUIMultiImageToggle   * btn_F2;
    ofxUIMultiImageToggle   * btn_N;
    ofxUIMultiImageToggle   * btn_G;
    
    ///////////////////////////////////////////////////////////
    // class Constructor
    ///////////////////////////////////////////////////////////
    mpGUI(int _sampleRate, int _plotBuffer_size,int _input_buffer_size);
    
    ///////////////////////////////////////////////////////////
    // class Destructor
    ///////////////////////////////////////////////////////////
    ~mpGUI();
    
    ///////////////////////////////////////////////////////////
    // GUI Event CallBack
    ///////////////////////////////////////////////////////////
    void guiEvent(ofxUIEventArgs &e);
    
    ///////////////////////////////////////////////////////////
    // ADD Time Plot GUI
    ///////////////////////////////////////////////////////////
    void addAppGUI();
        
    double roundSIL(double d, int pp);

};

#endif


#ifndef SSGUI
#define SSGUI

#include "ofMain.h"
#include "ofxUI.h"

#include "ssGlobals.h"
#include "ssWavIO.h"

#include "tmpFile.h"

#include "ofxMSAInteractiveObject.h"


#include "ssPianoKeyboard.h"
#include "ssDragGestureRecognizer.h"



///////////////////////////////////////////////////////////
// ssGUI CLASS
///////////////////////////////////////////////////////////
class ssGUI : public ofxMSAInteractiveObject{
public:
    
    float                     volume    = 1.0;       // Audio Out Volume
    float                     mixFactor = 0.0;
    float                     tplotGain = 1.0;       //

    float                     cueBar_pos = 0.0;
    float                     dist_x_old = 0.0;
    float                     zoomStep   = 1.0;
    float                     minValue,maxValue;

    float                     piano_xi;
    float                     piano_yi;
    float                     piano_kwidth;
    float                     piano_kheight;
    
    int                       input_buffer_size;
    int                       TplotBuffer_size;
    float                   * TplotBuffer;
    ssPianoKeyboard         * piano;
    //ssDragGestureRecognizer * touchDragObj;

    ///////////////////////////////////////////////////////////
    // Objects
    ///////////////////////////////////////////////////////////
    ofDirectory * dir;

    // Canvas Objects
    ofxUICanvas             * tplotGUI;
//    ofxUICanvas             * cpanelGUICanvas;
//    ofxUICanvas             * cpanelGUICanvas2;
//    ofxUICanvas             * cpanelGUICanvas3;
    ofxUICanvas             * cpanelGUICanvas4;
    ofxUICanvas             * cpanelGUICanvas4b;
    ofxUICanvas             * cpanelGUICanvas5;

    // Pointers to Objects accessed from other classes
    ofxUIRangeSlider        * zoom_sliderH;
    //ofxUISlider             * zoom_sliderV;
    ofxUIWaveform           * tplot;
//	ofxUIWaveform           * fplot;
//    ofxUIMultiImageToggle   * btn_play;
//    ofxUIMultiImageToggle   * btn_record;
//    ofxUIImageSlider        * slider_volume;
//    ofxUIImageSlider        * slider_mixer;
//    ofxUIDropDownList       * ddl;
    ofxUILabel              * instName;
    ofxUILabel              * timeStr;
    
    ///////////////////////////////////////////////////////////
    // class Constructor
    ///////////////////////////////////////////////////////////
    ssGUI(int _plotBuffer_size);
    ///////////////////////////////////////////////////////////
    // class Destructor
    ///////////////////////////////////////////////////////////
    ~ssGUI();
    ///////////////////////////////////////////////////////////
    // Update CueBar
    ///////////////////////////////////////////////////////////
    void updateCueBarPosition(float screenPercent);
    ///////////////////////////////////////////////////////////
    // update All plots data
    ///////////////////////////////////////////////////////////
    void updatePlotsData(float valueLow,float valueHigh);
    ///////////////////////////////////////////////////////////
    // Update Tplot Buffer
    ///////////////////////////////////////////////////////////
    void updateTplotBuffer(TmpFile *tmpFile,int posicao, int tamanho);
    ///////////////////////////////////////////////////////////
    // Rephresh GL Data
    ///////////////////////////////////////////////////////////
//    void rephreshGLData(void);
    ///////////////////////////////////////////////////////////
    // Move Tplot in x axis
    ///////////////////////////////////////////////////////////
    void moveX_tplot (float diff_x);
    ///////////////////////////////////////////////////////////
    // zoom Tplot in x axis
    ///////////////////////////////////////////////////////////
    void zoomX_tplot_old (float dist_x);
    void zoomX_tplot (void);
    ///////////////////////////////////////////////////////////
    // GUI Event CallBack
    ///////////////////////////////////////////////////////////
    void guiEvent(ofxUIEventArgs &e);
    ///////////////////////////////////////////////////////////
    // ADD Time Plot GUI
    ///////////////////////////////////////////////////////////
    void addTplotGUI();
    ///////////////////////////////////////////////////////////
    // ADD Pitch Plot GUI
    ///////////////////////////////////////////////////////////
    void addPplotGUI();
    ///////////////////////////////////////////////////////////
    // ADD Control Panel
    ///////////////////////////////////////////////////////////
    void addCpanelGUI();
    ///////////////////////////////////////////////////////////
    // Draw Routine
    ///////////////////////////////////////////////////////////
    void draw();	// called every frame to draw object
    
    ///////////////////////////////////////////////////////////
    // Other Methods
    ///////////////////////////////////////////////////////////
    void listDocumentsDirectory(void);
    

};

#endif


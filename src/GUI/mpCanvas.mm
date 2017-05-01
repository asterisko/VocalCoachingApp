//
//  mpCanvas.cpp
//  MasterPitch_iOS
//
//  Created by Voice Studies on 8/30/13.
//
//

#include "mpCanvas.h"
#include "mpApp.h"

extern mpApp * myApp;

///////////////////////////////////////////////////////////
// class Constructor
///////////////////////////////////////////////////////////
mpCanvas::mpCanvas(){
    
}

///////////////////////////////////////////////////////////
// class Destructor
///////////////////////////////////////////////////////////
mpCanvas::~mpCanvas() {
    
}

void mpCanvas::init(float _x,float _y, float _W, float _H) {
    
    xi = _x*ofGetWidth();
    yi = _y*ofGetHeight();
    W = _W*ofGetWidth();
    H = _H*ofGetHeight();
    
    backgroundImage = new ofImage();
    
    backgroundImage->loadImage("GUI/UI_view1.png");

    float scale = (float) W/backgroundImage->width;
    
    if (ofGetWidth()==320)
        backgroundImage->resize(backgroundImage->width*scale,backgroundImage->height*scale);
    else // Retina Display iphone 4 and 4s
    {
        // Do nothing
    }
    
    float wi = backgroundImage->getWidth();
    float hi = backgroundImage->getHeight();
    
    set(xi,yi,wi,hi);

    // Add Buttons and Sliders
    // In percentage
    float divWidth = 0.02;                  // in percent
    float faderWidth = (1.00 - 0.02*4)/3;   // 4 barras cinza e 3 faders
    
    slider_volume.init("Volume","GUI/slider_volume/sliderhandle.png", divWidth , 0.23 , faderWidth, 0.50);
    slider_volume.setMinMaxValues(0.0, 100.0);
    slider_volume.setInitialValue(50.0);
    slider_volume.setLabelDataResolution(0);
    
    slider_delay.init ("Delay" ,"GUI/slider_delay/sliderhandle.png", 2*divWidth + faderWidth , 0.23 , faderWidth, 0.50);
    slider_delay.setMinMaxValues(23.0, 500.0);
    slider_delay.setInitialValue(23.0);
    slider_delay.setLabelDataResolution(0);
    
    slider_pitch.init ("Pitch" ,"GUI/slider_pitch/sliderhandle.png", 3*divWidth + 2*faderWidth, 0.23 , faderWidth, 0.50);
    slider_pitch.setMinMaxValues(-12.0, 12.0);
    slider_pitch.setInitialValue(0.0);
    slider_pitch.setLabelDataResolution(1);
    
    btnPlayStop.init("Play", "Stop", "GUI/btn_PlayStop/btnImageState0.png", 0.0, 0.73, 1.0, 0.27);
    btnMenu.init("Menu Closed", "Menu Open", "GUI/btn_Menu/btnImageState0.png", 0.88, 0.05, 0.08, 0.08);
}

void mpCanvas::setup() {
    printf("mpCanvas::setup() - hello!\n");
    enableMouseEvents();
    enableKeyEvents();
}

void mpCanvas::exit() {
    printf("mpCanvas::exit() - goodbye!\n");
}


void mpCanvas::update() {

    // Check if state Changed
    if (btnPlayStop.stateChanged()) {
        if (btnPlayStop.state)
            myApp->startAudioIO();
        else
            myApp->stopAudioIO();
    }
    
    // Animation Code
    if (btnMenu.stateChanged()) {
        if (btnMenu.state)
            moveFlag=2;
        else
            moveFlag=1;
    }
    
    if (moveFlag==1){
        x_pos = x_pos+22;
        if (x_pos>=0) moveFlag=0;
    }
    else if (moveFlag==2) {
        x_pos= x_pos-22;
        if (x_pos<=-ofGetWidth()*0.61) moveFlag=0;
    }
}

void mpCanvas::draw() {
    backgroundImage->draw(x_pos, y_pos, width, height);
    drawGraphic(x_pos,y_pos);

}

//--------------------------------------------------------------
void mpCanvas::drawGraphic(float _xi, float _yi){
    
    float scl = ofMap(myApp->audioInputPower,-120,0,0,50);
    
    float fact = 0; // pixels
    
    float low  =roundSIL(myApp->winSize*0.43,0);
    float high =roundSIL(myApp->winSize*0.57,0);
    
    float plot_xi = _xi + 75, plot_yi =_yi + 60;
    
    for (int i=0; i<low;i++)
    {
        ofSetColor(127+64,127+64, 127+64, 255*i/low);
        ofLine(plot_xi+i, plot_yi, plot_xi+i, plot_yi - ofMap(myApp->inputBuffer[i],-120,0,0,50) + ofRandom(-fact,fact)*0.4);
        ofLine(plot_xi+i, plot_yi, plot_xi+i, plot_yi + ofMap(myApp->inputBuffer[i],-120,0,0,50) + ofRandom(-fact,fact)*0.4);
    }
    
    for (int i=low; i<myApp->winSize;i++)
    {
        ofSetColor(127+64,127+64, 127+64, 255);
        ofLine(plot_xi+i, plot_yi, plot_xi+i, plot_yi - ofMap(myApp->inputBuffer[i],-120,0,0,50) + ofRandom(-fact,fact)*0.4);
        ofLine(plot_xi+i, plot_yi, plot_xi+i, plot_yi + ofMap(myApp->inputBuffer[i],-120,0,0,50) + ofRandom(-fact,fact)*0.4);
    }
    
    ofSetColor(127+64,127+64, 127+64, 255);
    ofEllipse(plot_xi+myApp->winSize+4, plot_yi, 8,  2*ofMap(myApp->inputBuffer[myApp->winSize-1],-120,0,0,50));
    ofRect(plot_xi+myApp->winSize-1, plot_yi - ofMap(myApp->inputBuffer[myApp->winSize-1],-120,0,0,50), 4, 2*ofMap(myApp->inputBuffer[myApp->winSize-1],-120,0,0,50) );
    ofNoFill();
    ofEllipse(plot_xi+myApp->winSize+4, plot_yi, 8,  2*ofMap(myApp->inputBuffer[myApp->winSize-1],-120,0,0,50));
    ofRect(plot_xi+myApp->winSize-1, plot_yi - ofMap(myApp->inputBuffer[myApp->winSize-1],-120,0,0,50), 4, 2*ofMap(myApp->inputBuffer[myApp->winSize-1],-120,0,0,50) );
    
    ofSetColor(127-64-32,127-64-32, 127-64-32,60);
    ofLine(plot_xi-10, plot_yi, plot_xi+myApp->winSize+18, plot_yi);
    
}

//
//  mpCanvas.h
//  MasterPitch_iOS
//
//  Created by Voice Studies on 8/30/13.
//
//

#ifndef __MasterPitch_iOS__mpCanvas__
#define __MasterPitch_iOS__mpCanvas__

#pragma once

#include "ofxMSAInteractiveObject.h"
#include "mpGlobals.h"
#include "mpSlider.h"
#include "mpButton.h"

class mpCanvas : public ofxMSAInteractiveObject {
public:
    
    float xi,yi;                // x,y position
    float W,H;                  // W,H lengths
    
    float x_pos=0.0, y_pos=0.0;
    int moveFlag =0;
    
    ofImage  * backgroundImage;
    
    mpSlider slider_volume;
    mpSlider slider_pitch;
    mpSlider slider_delay;
    
    mpButton btnPlayStop;
    mpButton btnMenu;

    mpCanvas();
    ~mpCanvas();
    void init(float _x,float _y, float _W, float _H);
    void setup();
	void exit();
	void update();
	void draw();
    void drawGraphic(float _xi, float _yi);

};

#endif /* defined(__MasterPitch_iOS__mpCanvas__) */

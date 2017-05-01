//
//  ssDragTouch.h
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/3/13.
//
//
#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ssGlobals.h"

class ssDragGestureRecognizer {

public:
    
    
    ofTouchEventArgs touch1;
    ofTouchEventArgs touch2;
        
    float distX,distY;
    
    ssDragGestureRecognizer();
    ~ssDragGestureRecognizer();
    void    onTouchDown (ofTouchEventArgs & touch);
    void    update (ofTouchEventArgs & touch);
};
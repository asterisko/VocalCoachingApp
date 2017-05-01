//
//  ssMidiThread.h
//  iOSingingStudio
//
//  Created by Voice Studies on 7/17/13.
//
//
#ifndef __iOSingingStudio__ssMidiThread__
#define __iOSingingStudio__ssMidiThread__

#include "ofThread.h"
#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

class ssMidiThread : public ofThread {
    
    bool    noteON = false;
    int     actualNoteON;
    int     actualNote;
    int     noteCnt;
    double  noteStart;
    double  noteEnd;
    
    // the thread function
    void threadedFunction();
};

#endif /* defined(__iOSingingStudio__ssMidiThread__) */

//
//  ssLoadFileThread.h
//  iOSingingStudio
//
//  Created by Voice Studies on 10/3/13.
//
//

#ifndef __iOSingingStudio__ssLoadFileThread__
#define __iOSingingStudio__ssLoadFileThread__

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ssGlobals.h"

class ssLoadFileThread : public ofThread {
    
    
    // the thread function
    void threadedFunction();

};


#endif /* defined(__iOSingingStudio__ssLoadFileThread__) */

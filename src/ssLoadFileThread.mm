#include "ssLoadFileThread.h"
#include "ssApp.h"
#include "ssGlobals.h"

extern ssApp * myApp;

// the thread function
void ssLoadFileThread::threadedFunction() {
    
        myApp->loadWAVfile(myApp->loadFileName);
    
        myApp->ssGui->rephreshGLData();
    
        myApp->fileIsLoaded=true;

    }
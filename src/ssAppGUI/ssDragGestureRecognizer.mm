//
//  ssDragTouch.cpp
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/3/13.
//
//

#include "ssDragGestureRecognizer.h"
#include "ssApp.h"

extern ssApp * myApp;

///////////////////////////////////////////////////////////
// ssDragGestureRecognizer Constructor
///////////////////////////////////////////////////////////
ssDragGestureRecognizer :: ssDragGestureRecognizer () {
    if (myApp->dbgMode) cout << "creating ssDragGestureRecognizer" << endl;
    
}

///////////////////////////////////////////////////////////
// ssDragGestureRecognizer Destructor
///////////////////////////////////////////////////////////
ssDragGestureRecognizer :: ~ssDragGestureRecognizer () {
    if (myApp->dbgMode) cout << "destroying ssDragGestureRecognizer" << endl;
}

///////////////////////////////////////////////////////////
// ssDragGesture::onFirstTouchDown
///////////////////////////////////////////////////////////
void ssDragGestureRecognizer :: onTouchDown (ofTouchEventArgs & touch) {
    if (myApp->dbgMode) cout << "in ssDragGestureRecognizer::onTouchDown" << endl;
    
    // Saves First Touch Position when Moving the Piano Roll
    
    if (touch.numTouches==1) {           // 1st Touch Detection
        touch1 = touch;
        if (myApp->dbgMode) cout << "state = DRAG | touch.x = " << touch.x <<" | touch.y = " << touch.y << endl;
        }
    else if (touch.numTouches==2) {          // Zoom the piano and pitch plot
        
        if (touch.id==0)                     // Grab the first finger
            touch1 = touch;
        
        if (touch.id==1)                     // Grab the second finger
            touch2 = touch;
        
        }
}

///////////////////////////////////////////////////////////
// ssDragGestureRecognizer::onDrag
///////////////////////////////////////////////////////////
void ssDragGestureRecognizer :: update (ofTouchEventArgs & touch) {
    
    if (touch.x>PLOTS_X && touch.x<PLOTS_X+PLOTS_W && touch.y>PLOTS_H && touch.y<CPANEL_Y) {
        
        if (touch.numTouches==1) {
            if (!myApp->recogPintch->pinching)  {
                float diff_x    = touch.x - touch1.x;        // Computes differential change in x
                myApp->ssGui->moveX_tplot(diff_x);

                float diff_y    = touch.y - touch1.y;        // Computes differential change in y
//                myApp->ssGui->piano->moveY_pplot(diff_y);
                }
            touch1 = touch;
            }
    
        if (touch.numTouches==2) {
            if (touch.id==0)
                touch1 = touch;
            if (touch.id==1) {
                touch2 = touch;
                distX = abs(touch2.x-touch1.x);
                distY = abs(touch2.x-touch1.x);
                }
        }
    }
}

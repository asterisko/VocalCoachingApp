#include "ssPianoKey.h"
#include "ssPianoKeyboard.h"

#include "ssApp.h"

extern ssApp * myApp;

//--------------------------------------------------------------
void ssPianoKey::setup() {
    
    if (myApp->dbgMode) cout << "ssPianoKey::setup() - Creating: " << midiInfo.label << " | midicode = " << midiInfo.code << endl;
    
    // in setup:
    myfont.loadFont("fonts/C&C Red Alert [INET].ttf", 9);
    
    disableAppEvents();
    enableMouseEvents();
    enableKeyEvents();
	}

//--------------------------------------------------------------
void ssPianoKey::exit() {
		printf("ssPianoKey::exit() - goodbye!\n");
	}

//--------------------------------------------------------------
void ssPianoKey::update() {
		//		x = ofGetWidth()/2 + cos(ofGetElapsedTimef() * 0.2) * ofGetWidth()/4;
		//		y = ofGetHeight()/2 + sin(ofGetElapsedTimef() * 0.2) * ofGetHeight()/4;
	}

//--------------------------------------------------------------
void ssPianoKey::draw() {
    
    //cout << " in ssPianoKey::draw()" << endl;

    ofPushStyle();
    //////////////////////////////////////////////////
    // Draw Key
    //////////////////////////////////////////////////
    ofNoFill();
    setKeyBlackColor();
    ofSetLineWidth(2.0);
    ofRect(x, y, width, height);                        // Draw Key Frame in Black
    ofSetLineWidth(1.0);
    ofFill();
    
    if(isMousePressed()) {
        
//        if (midiInfo.keyColor==WHITE_COLOR && actualX>PLOTS_X*0.6) {
//            ofSetHexColor(DOWN_COLOR);
//            ofRect(x, y, width, height);
//            }
//        else if (midiInfo.keyColor==WHITE_COLOR && actualX<PLOTS_X*0.6) {
//            ofSetHexColor(WHITE_COLOR);
//            ofRect(x, y, width, height);
//            }
//        else if (midiInfo.keyColor==BLACK_COLOR && actualX<PLOTS_X*0.6) {
//            ofSetHexColor(DOWN_COLOR);
//            ofRect(x, y, width, height);                        // Draw Key in Red
//            }
        
        if (midiInfo.keyColor==WHITE_COLOR && actualY > PLOTS_H + KEY_LENGTH*0.6) {
//            cout << "[1] White clicked and > key length x 0.6" << endl;
                ofSetHexColor(DOWN_COLOR);
                ofRect(x, y, width, height);
                }
        else if (midiInfo.keyColor==WHITE_COLOR && actualY < PLOTS_H + KEY_LENGTH*0.6) {
//            cout << "[2] White clicked and < key length x 0.6" << endl;
                ofSetHexColor(WHITE_COLOR);
                ofRect(x, y, width, height);
                }
        else if (midiInfo.keyColor==BLACK_COLOR && actualY < PLOTS_H + KEY_LENGTH*0.6) {
//            cout << "[3] Black clicked and < key length x 0.6" << endl;
                ofSetHexColor(DOWN_COLOR);
                ofRect(x, y, width, height);                        // Draw Key in Red
                }


        }
    else {
        ofSetHexColor(midiInfo.keyColor);                   // Set Key Color
        ofRect(x, y, width, height);                        // Draw Key            float x = keyboard[i].x;
        }
    
    //////////////////////////////////////////////////
    // Draw Label
    //////////////////////////////////////////////////
 //   if (midiInfo.label=="C1" ||midiInfo.label=="C2"||midiInfo.label=="C3"||midiInfo.label=="C4"||midiInfo.label=="C5"||midiInfo.label=="C6"||midiInfo.label=="C7") {
        if (midiInfo.keyColor==BLACK_COLOR) {
            setKeyWhiteColor();
            myfont.drawString(midiInfo.label , x + width/2 - 10 , roundSIL(y + height/2 + 3,0));
            }
        else {
            setKeyBlackColor();
//            myfont.drawString(midiInfo.label , x + 2*width/3 + 10, roundSIL(y + height/2 + 4,0));
            myfont.drawString(midiInfo.label , x + width/2 - 5, roundSIL(y + 4*height/5,0));
            }
 //   }
	ofPopStyle();
    }



//--------------------------------------------------------------
void ssPianoKey::onRollOver(int x, int y) {
		if (myApp->dbgMode) cout << "ssPianoKey::onRollOver | x=" << x << " y=" << y << " | Key = " << midiInfo.label << endl;
    }
	
//--------------------------------------------------------------
void ssPianoKey::onRollOut() {
		if (myApp->dbgMode) cout << "ssPianoKey::onRollOut | x=" << x << " y=" << y << " | Key = " << midiInfo.label << endl;
	}
	
//--------------------------------------------------------------
void ssPianoKey::onMouseMove(int x, int y){
		if (myApp->dbgMode) cout << "ssPianoKey::onMouseMove | x=" << x << " y=" << y << " | Key = " << midiInfo.label << endl;
	}
	
//--------------------------------------------------------------
void ssPianoKey::onDragOver(int x, int y, int button) {
		if (myApp->dbgMode) cout << "ssPianoKey::onDragOver | x=" << x << " y=" << y << " | Key = " << midiInfo.label << endl;

    }
	
//--------------------------------------------------------------
void ssPianoKey::onDragOutside(int x, int y, int button) {
		if (myApp->dbgMode) cout << "ssPianoKey::onDragOutside | x=" << x << " y=" << y << " | Key = " << midiInfo.label << endl;
	}
	
//--------------------------------------------------------------
void ssPianoKey::onPress(int x, int y, int button) {
    
    if (myApp->dbgMode) cout << "ssPianoKey::onPress | x=" << x << " y=" << y << " | Key = " << midiInfo.label << endl;
    
    actualX = x;
    actualY = y;
    
//    if (y>PLOTS_H && y<CPANEL_Y) {
//        if(myApp->midiWrapper!=nil) {
//            
//            if (midiInfo.keyColor==WHITE_COLOR && actualX>PLOTS_X*0.6)
//                myApp->midiWrapper->noteON(midiInfo.code);
//            else if (midiInfo.keyColor==BLACK_COLOR && actualX<PLOTS_X*0.6) 
//                myApp->midiWrapper->noteON(midiInfo.code);
//
//            }
//
//        }
    
    //if (y>PLOTS_H && y<PLOTS_H+KEY_LENGTH) {
        if(myApp->midiWrapper!=nil) {
            
            if (midiInfo.keyColor==WHITE_COLOR && actualY > PLOTS_H + KEY_LENGTH*0.6)
                myApp->midiWrapper->noteON(midiInfo.code);
            else if (midiInfo.keyColor==BLACK_COLOR && actualY < PLOTS_H + KEY_LENGTH*0.6)
                myApp->midiWrapper->noteON(midiInfo.code);
            
        }
        
    //}

}

//--------------------------------------------------------------
void ssPianoKey::onRelease(int x, int y, int button) {
    
    if (myApp->dbgMode) cout << "ssPianoKey::onRelease | x=" << x << " y=" << y << " | Key = " << midiInfo.label << endl;
    
    actualX = x;
    actualY = y;

//    if (y>PLOTS_H && y<CPANEL_Y) {
//        if(myApp->midiWrapper!=nil) {
//            
//            if (midiInfo.keyColor==WHITE_COLOR && actualX>PLOTS_X*0.6)
//                myApp->midiWrapper->noteOFF(midiInfo.code);
//            else if (midiInfo.keyColor==BLACK_COLOR && actualX<PLOTS_X*0.6)
//                myApp->midiWrapper->noteOFF(midiInfo.code);
//            }
//    }
    
    //if (y>PLOTS_H && y<PLOTS_H+KEY_LENGTH) {
        if(myApp->midiWrapper!=nil) {
            
            if (midiInfo.keyColor==WHITE_COLOR && actualY > PLOTS_H + KEY_LENGTH*0.6)
                myApp->midiWrapper->noteOFF(midiInfo.code);
            else if (midiInfo.keyColor==BLACK_COLOR && actualY < PLOTS_H + KEY_LENGTH*0.6)
                myApp->midiWrapper->noteOFF(midiInfo.code);
        }
    //}

}


//--------------------------------------------------------------
void ssPianoKey::onReleaseOutside(int x, int y, int button) {
    
    if (myApp->dbgMode) cout << "ssPianoKey::onReleaseOutside | x=" << x << " y=" << y << " | Key = " << midiInfo.label << endl;
    
    actualX = x;
    actualY = y;

    //if (y>PLOTS_H && y<CPANEL_Y) {
    //if (y>PLOTS_H && y<PLOTS_H+KEY_LENGTH) {
        if(myApp->midiWrapper!=nil)
            myApp->midiWrapper->noteOFF(midiInfo.code);
    //}
}

//--------------------------------------------------------------
void ssPianoKey::keyPressed(int key) {
		printf("ssPianoKey::keyPressed(key: %i)\n", key);
	}
	
//--------------------------------------------------------------
void ssPianoKey::keyReleased(int key) {
		printf("ssPianoKey::keyReleased(key: %i)\n", key);
	}

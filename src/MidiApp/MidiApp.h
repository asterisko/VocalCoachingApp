#pragma once

#include <AudioToolbox/AudioToolbox.h> // ANDRE

#include <AVFoundation/AVAudioSession.h>
#include <Foundation/Foundation.h>

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ssGlobals.h"

#include "ssPianoKeyboard.h"

class MidiApp : public ofxiPhoneApp {
	
public:
    
    Float64   graphSampleRate;
    AUGraph   processingGraph;
    AudioUnit samplerUnit;
    AudioUnit ioUnit;
    
     MidiApp ();
    ~MidiApp ();
    
	void setup();
	void update();
	void draw();
	void exit();
	
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
	void touchCancelled(ofTouchEventArgs &touch);

	void lostFocus();
	void gotFocus();
	void gotMemoryWarning();
	void deviceOrientationChanged(int newOrientation);
    
    ofTrueTypeFont font;
    
    ofImage bkg;

    UInt32 notePressed;
    
    BOOL createAUGraph (void);
    BOOL configureAndStartAudioProcessingGraph(AUGraph graph);
    OSStatus loadSynthFromPresetURL( NSURL * presetURL);
    BOOL setupAudioSession(void);
};



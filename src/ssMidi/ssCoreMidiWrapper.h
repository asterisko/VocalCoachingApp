#pragma once

#import <AudioToolbox/AudioToolbox.h> // ANDRE

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ssGlobals.h"

#define kLowNote  48
#define kHighNote 72
#define kMidNote  60
#define kMIDIMessage_NoteOn         0x9
#define kMIDIMessage_NoteOff        0x8
#define kMIDIMessage_AllNotesOff    0xB

class ssCoreMidiWrapper {
	
public:
    
    Float64     graphSampleRate;
    AUGraph     processingGraph;
    AudioUnit   samplerUnit;
    AudioUnit   ioUnit;
    string      instrumentName;
    UInt32      notePressed;

     ssCoreMidiWrapper ();
    ~ssCoreMidiWrapper ();
	void init(string _instrumentName);
	BOOL createAUGraph (void);
    BOOL configureAndStartAudioProcessingGraph(AUGraph graph);
    BOOL setupAudioSession(void);
    OSStatus loadSynthFromPresetURL( NSURL * presetURL);
    void loadInstrument(string instrumentName);
    BOOL noteON(UInt32 notePressed);
    BOOL noteOFF(UInt32 notePressed);
    BOOL allNotesOFF(void);
    };



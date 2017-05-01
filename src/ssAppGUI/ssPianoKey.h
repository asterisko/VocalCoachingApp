/********  Test sample for ofxInteractiveObject									********/
/********  Make sure you open your console to see all the events being output	********/
#pragma once


#include "ofMain.h"
#include "ssGlobals.h"

#define		BLACK_COLOR		0x000000
#define		WHITE_COLOR		0xFFFFFF
#define		OVER_COLOR		0x00FF00
#define		DOWN_COLOR		0xFF0000

///////////////////////////////////////////////////////////
// MidiNote CLASS
///////////////////////////////////////////////////////////
// http://www.cs.au.dk/~dsound/DigitalAudio.dir/MidiAndFrequencies/MidiAndNoteFrequencies.html
// http://markprigoff.com/media/MIDI_Keyboard.pdf
// http://subsynth.sourceforge.net/midinote2freq.html

class MidiKeyInfo {
public:
    // Public vars
    int     code;
    float   freq;
    int     octave;
    string  label;
    float   keyPosPercent;
    float   keyPosBackgroundPercent;
    float   keyWidthPercent;
    float   keyHeightPercent;
    int     keyColor;
    
    // Default Constructor
    MidiKeyInfo(){
    }
    
    // Default Destructor
    ~MidiKeyInfo(){
        
    }
    
    // Public Methods
    float midi2freq(int _midi){
        float aux = pow(2.0,1.0/12);
        return((float) A4 * pow(aux,(_midi - 69)));
    }
    
    int freq2midi(float _freq){
        return( (int) 69 + 12*log2f(_freq/A4));
    }
        
};


///////////////////////////////////////////////////////////
// PianoKey CLASS
///////////////////////////////////////////////////////////
#include "ofxMSAInteractiveObject.h"

class ssPianoKey : public ofxMSAInteractiveObject {

public:
    
    MidiKeyInfo midiInfo;
    
    // in the h file:
    ofTrueTypeFont myfont;

    int actualX, actualY;
    
    void setup();
	void exit();
	void update();
	void draw();
	
	virtual void onRollOver(int x, int y);
	virtual void onRollOut();
	virtual void onMouseMove(int x, int y);
	virtual void onDragOver(int x, int y, int button);
	virtual void onDragOutside(int x, int y, int button);
	virtual void onPress(int x, int y, int button);
	virtual void onRelease(int x, int y, int button);
    virtual void onReleaseOutside(int x, int y, int button);
    virtual void keyPressed(int key);
    virtual void keyReleased(int key);
};
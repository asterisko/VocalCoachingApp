//
//  ssComputeMidiNotes.h
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/11/13.
//
//

#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ssMidiFileIO.h"

#include "PitchMeter.h"

using namespace std;

struct NoteLimits {
	int inicio;
	int fim;
	int nota;
    int duration;
};

class ssComputeMidiNotes {
    
public:

    PitchMeter      * pitchMeter;
    ssMidiFileIO    * midiFile;

    int num_bins;

    vector<NoteLimits> noteData;
    vector<float>      freqNoteData;
    vector<float>      midiExactNoteData;
    vector<float>      midiNoteData;
    vector<float>      diff_midiNoteData;     // Get 1st Diff vector
    
    vector<double>     notePower; // ANDRE
    
    ssComputeMidiNotes(PitchMeter * _pitchMeter);
    ~ssComputeMidiNotes();
    void    processNotes();
    void    clear();
    int     getNumOfFrames(void);
    void    pushNewPitchValue(float _pitchValue);
    void    pushNewPitchAndPowerValue(float _pitchValue, double _powerValue); // ANDRE
};

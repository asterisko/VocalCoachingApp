//
//  ssComputeMidiNotes.cpp
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/11/13.
//
//

#include "ssComputeMidiNotes.h"
#include "ssApp.h"

extern ssApp * myApp;

///////////////////////////////////////////////////////////
// ssComputeMidiNotes Constructor
///////////////////////////////////////////////////////////
ssComputeMidiNotes :: ssComputeMidiNotes(PitchMeter * _pitchMeter ) {

    if (myApp->dbgMode) cout << "creating ssComputeMidiNotes" << endl;
    
    pitchMeter = _pitchMeter;
    midiFile = new ssMidiFileIO();
    
    // Generate a Midi file for each existent Wav File
//    midiFile->createMidiFileForExistentWavFiles();
}

///////////////////////////////////////////////////////////
// ssComputeMidiNotes Destructor
///////////////////////////////////////////////////////////
ssComputeMidiNotes :: ~ssComputeMidiNotes () {
    if (myApp->dbgMode) cout << "destroying ssComputeMidiNotes" << endl;
    
    noteData.clear();
    freqNoteData.clear();
    midiExactNoteData.clear();
    midiNoteData.clear();
    
    pitchMeter = NULL;
    delete midiFile;
}


///////////////////////////////////////////////////////////
// ssComputeMidiNotes::resetNoteTest
///////////////////////////////////////////////////////////
void ssComputeMidiNotes::clear() {
    if (myApp->dbgMode) cout << "in ssComputeMidiNotes::clear()" << endl;
    freqNoteData.clear();
    midiExactNoteData.clear();
    midiNoteData.clear();
}

void ssComputeMidiNotes::processNotes(void) {

    if (myApp->dbgMode) cout << "in ssComputeMidiNotes::processNotes" << endl;
    
    // Compute 1st Derivative from the Quantized sequence
    for (int i=1;i<midiNoteData.size();i++)
        {
        diff_midiNoteData.push_back(midiNoteData[i]-midiNoteData[i-1]);
        }
    
    int noteON=false;

    NoteLimits note;
    
    // Process note data
    for (int i=0;i<diff_midiNoteData.size()-1;i++){
        
        if (diff_midiNoteData[i]!=0 && noteON==false) // Note Begin
            {
            noteON = true;
            note.inicio = i+1;
            note.nota   = midiNoteData[i+1];
            }
        
        if (diff_midiNoteData[i+1]!=0 && noteON==true) // Note End
            {
            noteON = false;
            note.fim = i+2;
            note.duration = note.fim - note.inicio;
            noteData.push_back(note);
            }
    }
    
    midiFile->saveMidiFile(myApp->recFileName);
}

///////////////////////////////////////////////////////////
// ssComputeMidiNotes::pushNewPitchValue
// Computes Frequency and Midi info from pitch detection values
// freqNoteData - vector of frequency values (float)
// midiExactNoteData - vector of midi exact values (float)
// midiNoteData - vector of midi integer values (int)
///////////////////////////////////////////////////////////
void   ssComputeMidiNotes::pushNewPitchValue(float _pitchValue){
    
    if (_pitchValue != 0.0f) {
        
        float freq = _pitchValue/(float) myApp->num_bins * myApp->sampleRate;
        freqNoteData.push_back(freq);
        
        float midiExact = freq2midiExact(freq);
        midiExactNoteData.push_back(midiExact);
        
//        cout << "midi exact note: " << midiExact << endl;
        
        float midi = freq2midi(freq);
        midiNoteData.push_back(midi);
    }
    else {
        freqNoteData.push_back(0.0f);
        midiExactNoteData.push_back(-1);
        midiNoteData.push_back(-1);
    }
    
}

///////////////////////////////////////////////////////////
// ssComputeMidiNotes::pushNewPitchAndPowerValue
// Computes Frequency and Midi info from pitch detection values
// freqNoteData - vector of frequency values (float)
// midiExactNoteData - vector of midi exact values (float)
// midiNoteData - vector of midi integer values (int)
// notePower - vector that stores the power of each frame note (double)
///////////////////////////////////////////////////////////
void   ssComputeMidiNotes::pushNewPitchAndPowerValue(float _pitchValue, double _powerValue){
    
    if (_pitchValue != 0.0f) {
        
        float freq = _pitchValue/(float) myApp->num_bins * myApp->sampleRate;
        freqNoteData.push_back(freq);
        
        float midiExact = freq2midiExact(freq);
        midiExactNoteData.push_back(midiExact);
        
        //        cout << "midi exact note: " << midiExact << endl;
        
        float midi = freq2midi(freq);
        midiNoteData.push_back(midi);
        
        notePower.push_back(_powerValue);
        
//        cout << "Pitch frequency: " << freq << "    | Frame Power: " << _powerValue << "    | MIDI exact: " << midiExact << "   | MIDI: " << midi << endl;
//        cout << _powerValue << endl; // power values ready to be inserted in a spreadsheet
    }
    else {
        freqNoteData.push_back(0.0f);
        midiExactNoteData.push_back(-1);
        midiNoteData.push_back(-1);
        notePower.push_back(0.0);
    }
    
}


///////////////////////////////////////////////////////////
// getNumOfFrames
///////////////////////////////////////////////////////////
int   ssComputeMidiNotes::getNumOfFrames(void){
    return freqNoteData.size();
}






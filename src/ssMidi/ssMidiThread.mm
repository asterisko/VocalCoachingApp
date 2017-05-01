//
//  ssMidiThread.cpp
//  iOSingingStudio
//
//  Created by Voice Studies on 7/17/13.
//
//
#include "ssMidiThread.h"
#include "ssApp.h"
#include "ssGlobals.h"

extern ssApp * myApp;

// the thread function
void ssMidiThread::threadedFunction() {
    
        noteCnt = 0;
        noteON = false;
        actualNoteON = 0;
        noteStart = 0.0;
        noteEnd = 0.0;
    
        while(isThreadRunning()) {

        if (myApp->appWorkingMode==PLAY_MODE && myApp->pitchMeterWrapper->midiNotes->getNumOfFrames()>0)
            {
            // Gest actual note
            actualNote  = myApp->pitchMeterWrapper->midiNotes->noteData[noteCnt].nota;
            
            // Discard notes == -1
            while (actualNote == -1) {  // Toca apenas notas !=-1
                noteCnt++;
                actualNote = myApp->pitchMeterWrapper->midiNotes->noteData[noteCnt].nota;
                }

            noteStart   = convFram2Sec(myApp->pitchMeterWrapper->midiNotes->noteData[noteCnt].inicio);
            noteEnd     = convFram2Sec(myApp->pitchMeterWrapper->midiNotes->noteData[noteCnt].fim);
            
       //     if (myApp->wavMidi_mode==PLAY_MIDI || myApp->wavMidi_mode==PLAY_BOTH){
                
                if (convFram2Sec(myApp->appStateMachine->FRAME.Playing) >= noteStart && noteON == false){
                    if (myApp->dbgMode) cout << convFram2Sec(myApp->appStateMachine->FRAME.Playing) << " | nota = " << actualNote << " - Note ON" << " | Begin = " << noteStart << " | End = " << noteEnd << endl;
                    myApp->midiWrapper->noteON(actualNote);
                    noteON = true;
                    }

                if (convFram2Sec(myApp->appStateMachine->FRAME.Playing) >= noteEnd && noteON == true){
                    if (myApp->dbgMode) cout << convFram2Sec(myApp->appStateMachine->FRAME.Playing) << " | nota = " << actualNote << " - Note OFF" << " | Begin = " << noteStart << " | End = " << noteEnd << endl;
                    myApp->midiWrapper->noteOFF(actualNote);
                    // Force All notes Off to prevent disasters
                    myApp->midiWrapper->allNotesOFF();
                    noteON = false;
                    noteCnt++;
                    }
       //     }
            }
        }
}


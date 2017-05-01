//
//  ssAppStateMachine.h
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/26/13.
//
//
#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ssGlobals.h"


class ssAppStateMachine {
    
public:
    
    //////////////////////////////////////////////////////////////////////////////////
    // Frame Position Play/Record Structure
    //////////////////////////////////////////////////////////////////////////////////
    struct  {
        long Recording = 0;
        long Playing   = 0;
        long Start     = 0;
        long Stop      = 0;
        long EoF       = 0;
        long Begin     = 0; // Start Position when playback starts
        long End       = 0; // Stop  Position when playback starts
    }FRAME;

    
    EXEC_STATE          execState = STATE_IDLE;
    GRAPHIC_PLAY_MODE   graphicPlayMode = BLOCK_MODE;

    float               timeBefore;
    float               percent = 0.0;        // Cue Bar position in %
    
    ssAppStateMachine();
    ~ssAppStateMachine();
    
    void setNewExecState(EXEC_STATE _state);
    void update(void);
    void savePlayingContext(void);
    void restorePlayingContext(void);
    void showAlertAndRecordFile(void);

};

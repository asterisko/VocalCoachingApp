//
//  ssAudioIOWrapper.h
//  iOSingingStudio
//
//  Created by Voice Studies on 7/26/13.
//
//

#pragma once

#include <AudioToolbox/AudioToolbox.h> // ANDRE

#include "ofMain.h"
#include "ssGlobals.h"

extern AudioUnit *aUnit;
extern float     *convertedSampleBuffer;

class ssAudioIOWrapper {
	
public:
    
    //////////////////////////////////////////////////////////////////////////////////
    // Frame Position Play/Record Structure
    //////////////////////////////////////////////////////////////////////////////////
    ssAudioIOWrapper();
    ~ssAudioIOWrapper();
    
    int initAudioSession();
    int initAudioStreams(AudioUnit *aUnit);
    int startAudioUnit(AudioUnit *aUnit);
    int stopProcessingAudio(AudioUnit *aUnit);
    
};

//
//  ssMidiFile.h
//  iOSingingStudio
//
//  Created by Voice Studies on 9/26/13.
//
//

#ifndef __iOSingingStudio__ssMidiFile__
#define __iOSingingStudio__ssMidiFile__

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

class ssMidiFileIO {
    
public:
    
    int ticksPerBeat;
    int bpm;

    ssMidiFileIO();
    ~ssMidiFileIO();
    void setBPM(int _bpm);
    void setTicksPerBeat(int _ticksPerBeat);
    void saveMidiFile(string filename);
    vector<char> computeMidiDeltaTime(long Nticks, long ticksPerBeat);
//    void createMidiFileForExistentWavFiles(void);
};


#endif /* defined(__iOSingingStudio__ssMidiFile__) */

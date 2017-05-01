//
//  mpNoiseGate.h
//  MasterPitch_iOS
//
//  Created by Sérgio Ivan Lopes on 5/9/13.
//
//
#include "ofMain.h"

class mpNoiseGate{
    
public:
    
    float   audioInputPower=-100;
    
    float   input=0.0;
    float   ratio=0.0;
    float   currentRatio=0.0;
    float   threshold=0.0;
    float   output=0.0;
    float   attack=0.0;
    float   release=0.0;
    float   amplitude=0.0;
    long    holdtime=0.0;
    long    holdcount=0.0;
    int     attackphase=0,holdphase=0,releasephase=0;
    
    mpNoiseGate(long _holdtime, float _attack, float _release);
    ~mpNoiseGate();
    float   processSample(float input, float threshold, long holdtime, float attack, float release);
    void    processBuffer(float *buffer, int bufferSize, float thresDB,float _audioInputPower);
};



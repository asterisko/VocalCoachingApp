//
//  mpNoiseGate.cpp
//  MasterPitch_iOS
//
//  Created by Sérgio Ivan Lopes on 5/9/13.
//
//
#include "mpNoiseGate.h"
#include "mpGlobals.h"

/* OK this compressor and gate are now ready to use. The envelopes, like all the envelopes in this recent update, use stupid algorithms for
 incrementing - consequently a long attack is something like 0.0001 and a long release is like 0.9999.
 Annoyingly, a short attack is 0.1, and a short release is 0.99. I'll sort this out laters */

mpNoiseGate::mpNoiseGate(long _holdtime, float _attack, float _release){

    holdtime =  _holdtime;
    attack   =  _attack;
    release  =  _release;
}

mpNoiseGate::~mpNoiseGate(){
}

float mpNoiseGate::processSample(float input, float threshold_dB, long holdtime, float attack, float release) {
        if (audioInputPower>threshold_dB && attackphase!=1) {
            holdcount=0;
            releasephase=0;
            attackphase=1;
            if(amplitude==0) amplitude=0.01;
        }
        
        if (attackphase==1 && amplitude<1) {
            amplitude*=(1+attack);
            output=input*amplitude;
        }
        
        if (amplitude>=1) {
            attackphase=0;
            holdphase=1;
        }
        
        if (holdcount<holdtime && holdphase==1) {
            output=input;
            holdcount++;
        }
        
        if (holdcount==holdtime) {
            holdphase=0;
            releasephase=1;
        }
        
        if (releasephase==1 && amplitude>0.) {
            output=input*(amplitude*=release);
        }
        
        return output;
    }

void mpNoiseGate::processBuffer(float *_buffer, int _bufferSize, float _thresDB, float _audioInputPower){

    audioInputPower = _audioInputPower;
    float aux;
    for(int i = 0; i < _bufferSize; i++)
        {
        aux = _buffer[i];
        _buffer[i] = processSample(aux, _thresDB, holdtime, attack, release);
        }

};
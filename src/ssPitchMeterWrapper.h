//
//  ssPitchMeterWrapper.h
//  iOSingingStudio
//
//  Created by Voice Studies on 10/7/13.
//
//

#ifndef __iOSingingStudio__ssPitchMeterWrapper__
#define __iOSingingStudio__ssPitchMeterWrapper__

#include "ofMain.h"
#include "PitchMeter.h"
#include "ssComputeMidiNotes.h"

class ssPitchMeterWrapper {

public:
    
    int                 num_2bins;
    int                 num_bins;
    int                 bufferSize;
    int                 sampleRate;
    
    double              * bufferAux;
    PitchMeter          * pitchMeter;
    ssComputeMidiNotes  * midiNotes;
    
    vector<float>       statsPitchBuffer;
    vector<float>       energyEstimator;

    ssPitchMeterWrapper(int _num_2bins, int _num_bins, int _sampleRate, int _bufferSize);
    ~ssPitchMeterWrapper();
    
    double getPowerFromFrame(float *input, int _bufferSize); // ANDRE (ver se é necessário)
    float getPitchFromFrame(float *input, int _bufferSize);
    
    ///////////////////////////////////////
    // Frame Energy in Time
    ///////////////////////////////////////
    float getFrameEnergy(float *buffer, int _bufferSize);
    
    ///////////////////////////////////////
    // Pitch Stats
    ///////////////////////////////////////
    float getPitchMean(void);       // Mean
    float getPitchStd(void);        // Std
    float getPitchMedian(void);     // Median

    
    void computePitchONLine(float * bufferIN, int _bufferSize);
    void computePitchOFFLine(void);

};


#endif /* defined(__iOSingingStudio__ssPitchMeterWrapper__) */

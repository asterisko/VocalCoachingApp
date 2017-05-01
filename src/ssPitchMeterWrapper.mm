//
//  ssPitchMeterWrapper.cpp
//  iOSingingStudio
//
//  Created by Voice Studies on 10/7/13.
//
//

#include "ssPitchMeterWrapper.h"
#include "ssApp.h"

extern ssApp * myApp;

///////////////////////////////////////////////////////////
// class Constructor
///////////////////////////////////////////////////////////
ssPitchMeterWrapper::ssPitchMeterWrapper(int _num_2bins, int _num_bins, int _sampleRate, int _bufferSize) {
    
    if (myApp->dbgMode) cout << "creating ssPitchMeterWrapper" << endl;
    
    num_2bins  = _num_2bins;
    num_bins   = _num_bins;
    sampleRate = _sampleRate;
    bufferSize = _bufferSize;

    bufferAux  = new double[num_2bins];
    
    pitchMeter = new PitchMeter(num_2bins, num_bins);
    midiNotes  = new ssComputeMidiNotes(pitchMeter);

    // Init Stats Buffers
    statsPitchBuffer.assign(10,0.0);
    energyEstimator.assign(10,0.0);
    
    }

///////////////////////////////////////////////////////////
// class Destructor
///////////////////////////////////////////////////////////
ssPitchMeterWrapper::~ssPitchMeterWrapper() {
    if (myApp->dbgMode) cout << "destroying ssPitchMeterWrapper" << endl;
    
    delete [] bufferAux;
    delete pitchMeter;
    delete midiNotes;
}

///////////////////////////////////////////////////////////
// getPowerFromFrame
///////////////////////////////////////////////////////////
double ssPitchMeterWrapper::getPowerFromFrame(float *input, int _bufferSize){
    
    // Clacula pitch com volume a 10%
    int last = num_2bins - num_bins;
    
    // Window Overlap and convertion to long
    for (int j=0; j < last; j++)        bufferAux[j] = bufferAux[j + num_bins];
    for (int j=0; j < num_bins; j++)	bufferAux[j+last] = (double) input[j]*32767.0f;
    
    // Pitch Calculus
    pitchMeter->getValue(bufferAux, sampleRate);
    
    // Return Power Value
    return pitchMeter->getFramePower_dB();
}

///////////////////////////////////////////////////////////
// getPitchFromFrame
///////////////////////////////////////////////////////////
float ssPitchMeterWrapper::getPitchFromFrame(float *input, int _bufferSize){
        
    // Clacula pitch com volume a 10%
    int last = num_2bins - num_bins;
    
    // Window Overlap and convertion to long
    for (int j=0; j < last; j++)        bufferAux[j] = bufferAux[j + num_bins];
    for (int j=0; j < num_bins; j++)	bufferAux[j+last] = (double) input[j]*32767.0f;
    
    // Pitch Calculus
    pitchMeter->getValue(bufferAux, sampleRate);
    
    //return pitchMeter->getFramePower_dB();
    
    // Return Pitch Value
    return pitchMeter->getF0harm();
}

///////////////////////////////////////////////////////////
// computePitchOnLine
///////////////////////////////////////////////////////////
void ssPitchMeterWrapper::computePitchONLine(float * bufferIN, int _bufferSize) {
        
    float pitch = getPitchFromFrame(bufferIN,_bufferSize);
    
    double framePower = getPowerFromFrame(bufferIN, _bufferSize);
    
    //float freqValue = pitch/(float) num_bins * sampleRate;
    
    // Update Stats Delay Line
    statsPitchBuffer.push_back(pitch);
    statsPitchBuffer.erase(statsPitchBuffer.begin());
        
    float newPitch;
    if (getFrameEnergy(bufferIN,bufferSize) > 0.3) {
        newPitch = pitch;
//        newPitch = getPitchMean();
//        newPitch = getPitchMedian();
        }
    else
        newPitch = 0.0;
    
    midiNotes->pushNewPitchAndPowerValue(newPitch, framePower);
    
//    if (myApp->dbgMode) cout<< "in calculaPitchONLine | Pitch = "<< roundSIL(pitch,1) << "\t| Mean = " << roundSIL(getPitchMean(),1) << "\t| std = " << roundSIL(getPitchStd(),1) << "\t\t| Median = " << roundSIL(getPitchMedian(),1) << "\t| EnergyEstimator = " << roundSIL(getFrameEnergy(bufferIN,bufferSize),1) <<endl;
}

///////////////////////////////////////////////////////////
// computePitchOffLine
///////////////////////////////////////////////////////////
void ssPitchMeterWrapper::computePitchOFFLine(void) {
    
    long    st = ofGetElapsedTimeMillis();
    float   bufferIN[bufferSize];
    int     Nsamples = myApp->tmpFile->getSize();
    
    delete pitchMeter;
    pitchMeter = new PitchMeter(num_2bins, num_bins);
    delete midiNotes;
    midiNotes  = new ssComputeMidiNotes(pitchMeter);

    for (int i=0 ; i < Nsamples ; i = i + bufferSize) {
        
        myApp->tmpFile->readBlock(bufferIN, i, bufferSize);
        
        ////////////////////////////////////////
        // Real-Time Pitch Computation
        ////////////////////////////////////////
        float pitch = getPitchFromFrame(bufferIN,bufferSize);
       // float freqValue = pitch/(float) num_bins * sampleRate;
        
        // Update Stats Delay Line
        statsPitchBuffer.push_back(pitch);
        statsPitchBuffer.erase(statsPitchBuffer.begin());
        
        float newPitch;
        if (getFrameEnergy(bufferIN,bufferSize) > 0.3) {
            newPitch = pitch;
//            newPitch = getPitchMean();
//            newPitch = getPitchMedian();
            }
        else
            newPitch = 0.0;
    
        midiNotes->pushNewPitchValue(newPitch);

        if (myApp->dbgMode) cout<< "Pitch = "<< roundSIL(pitch,1) << "\t| Mean = " << roundSIL(getPitchMean(),1) << "\t| std = " << roundSIL(getPitchStd(),1) << "\t\t| Median = " << roundSIL(getPitchMedian(),1) << "\t| EnergyEstimator = " << roundSIL(getFrameEnergy(bufferIN,bufferSize),1) <<endl;
    }
    
    midiNotes->processNotes();

    long et = ofGetElapsedTimeMillis();
    if (myApp->dbgMode) cout<< "in calculaPitchOFFLine " << " | st = " << st << " | et = " << et <<  " | diff = " << et-st << endl;
}

////////////////////////////////////////
// Get Frame Energy in Time Domain
////////////////////////////////////////
float ssPitchMeterWrapper::getFrameEnergy(float *buffer, int _bufferSize) {
    
    float EE=0.0;
    
    for (int i=0;i<_bufferSize;i++)
        EE += buffer[i]*buffer[i];
    
    EE = sqrt(EE);
    
    return EE;
}

///////////////////////////////////////
// Pitch Stats
///////////////////////////////////////
// Mean
///////////////////////////////////////
float ssPitchMeterWrapper::getPitchMean(void) {
    int sum=0;
    for(int i=0 ; i < statsPitchBuffer.size() ; i++)
        sum+=statsPitchBuffer[i];
    
    return ((float) sum/statsPitchBuffer.size());
}
///////////////////////////////////////
// STD
///////////////////////////////////////
float ssPitchMeterWrapper::getPitchStd(void) {

    float E=0;
    float ave = getPitchMean();
    for (int i = 0 ; i < statsPitchBuffer.size() ; i++)
        E += (float)(statsPitchBuffer[i] - ave)*(statsPitchBuffer[i] - ave);
    
    return ((float) sqrt((float) 1/statsPitchBuffer.size()*E));
}

///////////////////////////////////////
// Median
///////////////////////////////////////
float ssPitchMeterWrapper::getPitchMedian(void) {
    vector<float> aux = statsPitchBuffer;
    sort (aux.begin(), aux.end());
    return(aux[aux.size()/2-1]);
}

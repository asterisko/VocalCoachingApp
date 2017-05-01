//
//  ssStatsFilter.cpp
//  iOSingingStudio
//
//  Created by Voice Studies on 8/20/13.
//
//

#include "ssStatsFilter.h"
#include "ssApp.h"

extern ssApp * myApp;

///////////////////////////////////////////////////////////
// class Constructor
///////////////////////////////////////////////////////////
ssStatsFilter::ssStatsFilter(int ord) {
    
    if (myApp->dbgMode) cout << "creating ssStatsFilter" << endl;
    delayLine.assign(ord, 0.0);
    
}

///////////////////////////////////////////////////////////
// class Destructor
///////////////////////////////////////////////////////////
ssStatsFilter::~ssStatsFilter() {
    if (myApp->dbgMode) cout << "destroying ssStatsFilter" << endl;

}

void ssStatsFilter::update(float input) {
    if (myApp->dbgMode) cout << "ssStatsFilter::processing" << endl;
    
    delayLine.push_back(input);
    delayLine.erase(delayLine.begin());
    
    ///////////////////////////////////////
    // Pitch Stats
    ///////////////////////////////////////
    ///////////////////////////////////////
    // Mean
    ///////////////////////////////////////
    int sum=0;
    for(int i=0 ; i < delayLine.size() ; i++)
        sum+=delayLine[i];
    _average = (float) sum/delayLine.size();
    
    ///////////////////////////////////////
    // Median
    ///////////////////////////////////////
    vector<float> aux = delayLine;
    sort (delayLine.begin(), delayLine.end());
    _median = aux[aux.size()/2-1];
    
    ///////////////////////////////////////
    // std
    ///////////////////////////////////////
    float E=0;
    for(int i = 0 ; i < delayLine.size() ; i++)
        E += (float)(delayLine[i] - _average)*(delayLine[i] - _average);
    _std = (float) sqrt((float) 1/delayLine.size()*E);
}

float ssStatsFilter::getAverage(void){
    return(_average);
}

float ssStatsFilter::getMedian(void){
    return(_median);

}

float ssStatsFilter::getStd(void){
    return(_std);

}

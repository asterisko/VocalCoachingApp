//
//  ssStatsFilter.h
//  iOSingingStudio
//
//  Created by Voice Studies on 8/20/13.
//
//

#ifndef __iOSingingStudio__ssStatsFilter__
#define __iOSingingStudio__ssStatsFilter__

#include "ofMain.h"

class ssStatsFilter {
public:
    vector<float> delayLine;
    
    float L2norm;
    float _median;
    float _average;
    float _std;
    
    ssStatsFilter(int ord);
    ~ssStatsFilter();
    void update(float input);
    float getAverage(void);
    float getMedian(void);
    float getStd(void);
    
};

#endif /* defined(__iOSingingStudio__ssStatsFilter__) */

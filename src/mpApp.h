#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "tpitchshiftorig.h"
#include "fpitchshift.h"

#include "mpGlobals.h"

#include "mpNoiseGate.h"

//#include "mpCanvas.h"

#include "mpSlider.h"

#include "mpButton.h"


#define VOLUME_MIN    0.0  // in %
#define VOLUME_MAX  100.0  // in %

#define DELAY_MAX   0.500  // in s

#define PITCH_MIN   -12.0  // in semitones (Half Octave Below)
#define PITCH_MAX    12.0  // in semitones (Half Octave Above)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

enum DEVICETYPE{
        i320x480,   // iPhone (3G)
        i640x960,   // iPhone Retina (4/4S)
        i640x1136,  // iPhone Retina 4" (5/5S)
        i768x1024,  // iPad/iPad2
        i1536x2048, // iPad Retina
    };

enum BUILDTYPE{
    DEBUG,
    RELEASE,
};

class mpApp : public ofxiPhoneApp{
	   
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);

        void audioIn(float * input, int bufferSize, int nChannels);
        void audioOut(float * output, int bufferSize, int nChannels);
    
        void startAudioIO();
        void stopAudioIO();
        void initTplot(float xi,float yi, float _W, float _H);
        void drawTplot();

        bool areHeadphonesPlugedIn( void );
    
        void createPresetFile(string filename, int _type, float _volume, float _delay, float _pitch);
        void saveCustomPreset(string filename);
        void loadCustomPreset(string filename);
    
    
        BUILDTYPE debugType = RELEASE;
    
    
        int bufferSize;
        int	sampleRate;
        int bufferINCounter=0;
        int bufferOUTCounter=0;
    
        float volume = 50.0;
        float delay = 12.0;
        float pitch = 0.0;
    
    bool editingMode=false;
    
        float * auxBufferIN;
    
        UIAlertView *alert;
    
        DEVICETYPE device=i320x480;
    
        int pbsize =2000;
    
    
        float audioInputPower=0.0;
    
        vector<float> delayBuffer;

        ofImage UI_BKG;
    
    UIWebView *infoView;
    
        mpSlider slider_volume;
        mpSlider slider_pitch;
        mpSlider slider_delay;
    
        mpButton btnNoiseGate;
        mpButton btnTimeFrequency;
        mpButton btnPlayStop;
        mpButton btnMenu;
        mpButton btnLogo;

        mpButton btnMild;
        mpButton btnMedium;
        mpButton btnStrong;
        mpButton btnCustom1;
        mpButton btnCustom2;

        tpitchshiftorig *tp;
        fpitchshift     *fp;
        mpNoiseGate     *ng;
    
        float   lateralmenuPercent;
    
        vector<float> inputBuffer;
        
    int btnCustomPresetPressed=0;
    
    float x_pos=0.0, y_pos=0.0;
    int moveFlag =0;
    
    
    float plotXi;
    float plotYi;

    float plotWidth;
    float plotHeigth;
    
    float plotLow;
    float plotHigh;
    
    float buttonTimeDown;
};



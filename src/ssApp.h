#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ssGlobals.h"

#include "ssGUI.h"

//#include "ssPianoKeyboard.h"

#include "ssWavIO.h"

#include "ssAppStateMachine.h"

#include "PitchMeter.h"

#include "FFTAccelerate.h"

//#include "ssComputeMidiNotes.h"

#include "ofPinchGestureRecognizer.h"

#include "ssCoreMidiWrapper.h"

#include "ssMidiThread.h"

#include "ssAudioIOWrapper.h"

//#include "ssLoadFileThread.h"

#include "ssPitchMeterWrapper.h"

class ssApp : public ofxiPhoneApp{
	
    public:
    
        DEBUG_MODE dbgMode = RELEASE;

        ssApp();
        ~ssApp();
        //////////////////////////////////////////////////////////////////////////////////
        // APP methods
        //////////////////////////////////////////////////////////////////////////////////
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
    

        //////////////////////////////////////////////////////////////////////////////////
        // Audio I/O methods
        //////////////////////////////////////////////////////////////////////////////////
        //double getPowerFromFrame(PitchMeter * pm, float *input, int _bufferSize); // ANDRE (ver se é necessário)
        float getPitchFromFrame(PitchMeter * pm, float *input, int _bufferSize);
        void audioInCallBack(float *input, int _bufferSize, int nChannels);
    
        void startPlayback();
        void startRecording();
        void stopAudioIO();

        
//        void loadWAVfile(string filename);
//        void recordWAVfile(string filename);

        //////////////////////////////////////////////////////////////////////////////////
        // App Working Mode
        //////////////////////////////////////////////////////////////////////////////////
        APP_WORKING_MODE appWorkingMode;
    
        ofImage bkg;
    
        //////////////////////////////////////////////////////////////////////////////////
        // Audio I/O Stuff
        //////////////////////////////////////////////////////////////////////////////////
        int                 sampleRate;         // Audio I/O samplerate
        int                 bufferSize;         // Audio I/O buffersize

//        string              loadFileName;
//        string              recFileName;
//        ssWavIO           * wavFile;
//        ssWavIO           * recFile;
        TmpFile           * tmpFile;
        ofSoundStream       IOSoundStream;
        ssAudioIOWrapper    AudioIO;
    
        //////////////////////////////////////////////////////////////////////////////////
        // GUI Stuff
        //////////////////////////////////////////////////////////////////////////////////
        int                 first_key;
        int                 last_key;
        float               piano_xi;
        float               piano_yi;
        float               piano_kwidth;
        float               piano_kheight;
        int                 plotBuffer_size;    // Tplot Buffer size
        ssGUI             * ssGui;
        ssAppStateMachine * appStateMachine;
    
        bool                doubleTouchLock = false;
        //////////////////////////////////////////////////////////////////////////////////
        // PitchMeter Stuff
        //////////////////////////////////////////////////////////////////////////////////
        int                 num_bins;
        int                 num_2bins;
    
        //////////////////////////////////////////////////////////////////////////////////
        // FFT Stuff
        //////////////////////////////////////////////////////////////////////////////////
//        int                 Nfft = 2048;
//        float             * fftBufferOUT;
//        float             * fftBufferIN;
//        FFTAccelerate     * myFFT;
    
        //////////////////////////////////////////////////////////////////////////////////
        // MIDI Stuff
        //////////////////////////////////////////////////////////////////////////////////
        APP_PLAY_MODE       wavMidi_mode = PLAY_WAV;
    
        ssCoreMidiWrapper   * midiWrapper;
        ssMidiThread        * midiThread;
    
        //////////////////////////////////////////////////////////////////////////////////
        // OTHER Stuff
        //////////////////////////////////////////////////////////////////////////////////
        ofstream file2;
    
        ofPinchGestureRecognizer * recogPintch;
        
   //     void calculaPitchSIL(TmpFile* tmpfile, int _bufferSize, int _sampleRate);

        int PlayFrameStamp;
    
        int heightNavController;
    
//        ssLoadFileThread loadFileThread;
//        bool fileIsLoaded=false;
    
        ssPitchMeterWrapper * pitchMeterWrapper;
    
        // Midi Functions
     //   void saveMidiFile(string filename);
     //   vector<char> computeMidiDeltaTime(long tick, long);
    
     //   void createMidiFileForExistentWavFiles(void);

};

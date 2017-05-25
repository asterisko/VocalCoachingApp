//
//  ssAppStateMachine.cpp
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 6/26/13.
//
//

#include "ssAppStateMachine.h"
#include "ssPianoKeyboard.h"
#include "ofxiPhoneAlertView.h"
#include "ssApp.h"
extern ssApp * myApp;

//#include "ssAppViewController.h"
//extern ssAppViewController * mySsAppViewController;
#include "vcAppViewController.h"
extern vcAppViewController * myVcAppViewController;

ofxiPhoneAlertView *alert;

///////////////////////////////////////////////////////////
// ssAppStateMachine Constructor
///////////////////////////////////////////////////////////
ssAppStateMachine :: ssAppStateMachine() {
    if (myApp->dbgMode) cout << "creating ssAppStateMachine" << endl;
    execState=STATE_IDLE;
}
///////////////////////////////////////////////////////////
// ssAppStateMachine Destructor
///////////////////////////////////////////////////////////
ssAppStateMachine :: ~ssAppStateMachine() {
    if (myApp->dbgMode) cout << "destroying ssAppStateMachine" << endl;
}


///////////////////////////////////////////////////////////
// setNewExecState
///////////////////////////////////////////////////////////
void ssAppStateMachine::setNewExecState(EXEC_STATE newState){
    
    if (myApp->dbgMode) cout << "in ssAppStateMachine::setNewExecState" << endl;
    ///////////////////////////////////////////////////////////
    // EXECUTION STATE
    ///////////////////////////////////////////////////////////
    switch (execState){
        case STATE_RECORDING        :   if (myApp->dbgMode) cout << "Actual State -> STATE_RECORDING" << endl;          break;
        case STATE_RECORDING_PAUSE  :   if (myApp->dbgMode) cout << "Actual State -> STATE_RECORDING_PAUSE" << endl;    break;
        case STATE_IDLE             :   if (myApp->dbgMode) cout << "Actual State -> STATE_IDLE" << endl;               break;
        }
    ///////////////////////////////////////////////////////////
    // NEW STATE
    ///////////////////////////////////////////////////////////    
    switch (newState){
        case STATE_IDLE             :   {
                                        if (myApp->dbgMode) cout << "New State -> STATE_IDLE" << endl;
                                        //myApp->ssGui->btn_play->setValue(false);    // Força btn_play para o Pause State
                                        //myApp->ssGui->btn_record->setValue(false);  // Força btn_record para Record_Pause State
            
                                        switch (execState){
                                            case STATE_RECORDING        :   
                                            case STATE_RECORDING_PAUSE  :   myApp->appWorkingMode = PLAY_MODE;
                                            case STATE_IDLE             :   break;
                                            }
                                        break;
                                        }
            

        case STATE_RECORDING        :   {
                                        if (myApp->dbgMode) cout << "New State -> STATE_RECORDING" << endl;
            
                                        switch (execState){
                                            case STATE_RECORDING        :   break;
                                            case STATE_RECORDING_PAUSE  :   myApp->startRecording();
                                                                            break;
                                            case STATE_IDLE             :
//                                                                            float sliderMin = myApp->ssGui->zoom_sliderH->getScaledValueLow();
//                                                                            myApp->ssGui->updatePlotsData(sliderMin , sliderMin + PLOT_BUFFER_DURATION);
                                                
                                                                        //  myApp->pitchMeterWrapper->midiNotes->~ssComputeMidiNotes();
                                                                        //  myApp->pitchMeter->~PitchMeter();
                                
                                                                        //  myApp->pitchMeter = new PitchMeter(myApp->num_2bins, myApp->num_bins);
                                                                        //  myApp->pitchMeterWrapper->midiNotes = new ssComputeMidiNotes(myApp->pitchMeterWrapper->pitchMeter);
                                                
                                                                            delete myApp->tmpFile;//myApp->tmpFile->~TmpFile();       // Remove Old TmpFile Object
                                                                            myApp->tmpFile = new TmpFile("SingingStudioTime");   // Create New TmpFile Object

                                                                            delete myApp->pitchMeterWrapper;
                                                                            myApp->pitchMeterWrapper = new ssPitchMeterWrapper(myApp->num_2bins,myApp->num_bins,myApp->sampleRate,myApp->bufferSize);

                                                
                                                                            FRAME.Start      = 0;
                                                                            FRAME.Stop       = 0;
                                                                            FRAME.Recording  = 0;      // Reset Rec Position
                                                                            FRAME.EoF        = 0;
                                                                            FRAME.Playing    = 0;
                                                
                                                                            myApp->startRecording();
                                                                            break;
                                            }
                                        break;
                                        }
        case STATE_RECORDING_PAUSE  :   if (myApp->dbgMode) cout << "New State -> STATE_RECORDING_PAUSE" << endl;
                                        switch (execState){
                                            case STATE_RECORDING        :   myApp->stopAudioIO();
                                                                            break;
                                            case STATE_RECORDING_PAUSE  :   break;
                                            case STATE_IDLE             :   break;
                                            }
                                        break;
        }
    
    execState = newState;   // Actualiza a maquina de estados

}


///////////////////////////////////////////////////////////
// update
///////////////////////////////////////////////////////////
void ssAppStateMachine :: update(void) {
//    if (myApp->dbgMode) cout << "in ssAppStateMachine::update" << endl;
    
//    float timeActual    = ofGetElapsedTimef();
//    float timeDiff      = timeActual - timeBefore;
//    float sliderMin     = myApp->ssGui->zoom_sliderH->getScaledValueLow();
//    float sliderMax     = myApp->ssGui->zoom_sliderH->getScaledValueHigh();
//    float sliderLengthHalf = (sliderMax - sliderMin)/2;
//    float sliderCenter  = sliderMin + sliderLengthHalf;

    //////////////////////////////////////////////////////////////////////////////////
    // 1) Update STATE in RunTime
    //////////////////////////////////////////////////////////////////////////////////
//    if (FRAME.Playing > FRAME.End)// || myApp->FRAME.Playing > myApp->FRAME.Stop)
//        {
//        setNewExecState(STATE_IDLE);
////        [mySsAppViewController.buttonPlay setSelected:NO];
//        [myVcAppViewController.buttonPlay setSelected:NO];
//        }
    
    //////////////////////////////////////////////////////////////////////////////////
    // 2) Execute APP STATE MACHINE
    //////////////////////////////////////////////////////////////////////////////////
    switch(execState) {
        case STATE_IDLE             :   percent = 0.0;
                                        FRAME.Playing = FRAME.Start;
                                        break;
            
        case STATE_RECORDING        :   if (FRAME.Recording < convSec2Fram(PLOT_BUFFER_DURATION)) {
                                            percent = (float) FRAME.Recording/convSec2Fram(PLOT_BUFFER_DURATION);
                                            FRAME.Start  = FRAME.Recording;
                                            FRAME.Begin  = 0.0;
                                            FRAME.Stop   = 0.0;
                                            FRAME.End    = 0.0;
                                            FRAME.EoF    = 0.0;
                                            }
                                        else{
                                            percent = (float) ((float)FRAME.Recording - (float)FRAME.Start)/((float)FRAME.Stop - (float)FRAME.Start);
                                            }
            
                                        ////////////////////////////////////////
                                        // Update Real Time do TPlot e Pplot
                                        ////////////////////////////////////////
                                        if (convFram2Sec(FRAME.Recording) < PLOT_BUFFER_DURATION)
                                            myApp->ssGui->updatePlotsData(0.0, PLOT_BUFFER_DURATION);
                                        else
                                            myApp->ssGui->updatePlotsData(convSamp2Sec(myApp->tmpFile->getSize()) - PLOT_BUFFER_DURATION, convSamp2Sec(myApp->tmpFile->getSize()));

            
//FFT                                        myApp->tmpFile->readBlock( myApp->fftBufferIN , myApp->tmpFile->getSize() - myApp->Nfft, myApp->Nfft );
                                        break;
            
        case STATE_RECORDING_PAUSE  :   break;
        }
    
    myApp->ssGui->updateCueBarPosition(percent);
}


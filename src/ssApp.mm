#include "ssApp.h"
//#include "ssAppNativeGUIView.h"
#include "ssAudioIOWrapper.h"
//#include "mainAppViewController.h"
#include "vcAppViewController.h"

//#import "mainAppDelegate.h"
#import "vcAppDelegate.h"

extern vcAppDelegate * vcAppDelegatePNT;

//ssAppNativeGUIView *myGuiViewController;

ofMutex mutex;

//--------------------------------------------------------------
ssApp :: ssApp () {
    if (dbgMode) cout << "in creating ssApp" << endl;
    appWorkingMode = RECORD_MODE;
    
}

//--------------------------------------------------------------
ssApp :: ~ssApp () {
    if (dbgMode) cout << "in destroying ssApp" << endl;

    if (midiWrapper!= NULL) {
        midiWrapper->allNotesOFF();
        stopAudioIO();
    }

    if (midiThread != NULL) {
        midiThread->stopThread();
        delete midiThread;
        }
    
    file2.close();
        
//    delete [] fftBufferOUT;
//    delete [] fftBufferIN;
//    delete myFFT;
    
    delete ssGui;
    delete tmpFile;
//    delete wavFile;
//    delete recFile;
    delete midiWrapper;
    delete pitchMeterWrapper;
    delete appStateMachine;
}

//--------------------------------------------------------------
void ssApp::setup(){

    if (dbgMode) cout << "in ssApp setup" << endl;

    ofEvents().disable();

    EAGLView *view = ofxiPhoneGetGLView();
    recogPintch = [[ofPinchGestureRecognizer alloc] initWithView:view];

    //////////////////////////////////////////////////////////////////////////////////
    // OFX Settings
    //////////////////////////////////////////////////////////////////////////////////
    ofxAccelerometer.setup();                                       // initialize the accelerometer
    
    ofSetFrameRate(30);

//    ofxiPhoneAlerts.addListener(this);      //allows elerts to appear while app is running
    
	//iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_LEFT); 	//If you want a landscape oreintation
    //ofSetOrientation(OF_ORIENTATION_90_LEFT); // ANDRE orientation
    
    setAppBackgroundColor();

//    ofSetVerticalSync(true);
    
    //////////////////////////////////////////////////////////////////////////////////
    // ADD AUDIO INPUT/OUTPUT
    //////////////////////////////////////////////////////////////////////////////////
    // IMPORTANT!!! if your sound doesn't work in the simulator - read this post - which requires you set the input stream to 24bit!!
	//	http://www.cocos2d-iphone.org/forum/topic/4159
	// for some reason on the iphone simulator 256 doesn't work - it comes in as 512!
	// so we do 512 - otherwise we crash
    // 0 output channels,
	// 1 input channels
	// 44100 samples per second
	// 512 samples per buffer
	// 4 num buffers (latency)
    
    
    cout << "ofGetHeight: " << ofGetHeight() << "; ofGetWidth: " << ofGetWidth() << " ; ofGetOrientation: " << ofGetOrientation() << endl;
    cout << "APP_HEIGHT: " << APP_HEIGHT << endl << "APP_WIDTH: " << APP_WIDTH << endl << "PLOTS_DIM: " << PLOTS_DIM << endl << "PLOTS_X: " << PLOTS_X << endl << "PLOTS_Y: " << PLOTS_Y << endl << "PLOTS_W: " << PLOTS_W << endl << "PLOTS_H: " << PLOTS_H << endl << "PLOT_T_H: " << PLOT_T_H << endl << "PLOT_F_H: " << PLOT_F_H << endl << "OFFSET_X: " << OFFSET_X << endl << "CPANEL_DIM: " << CPANEL_DIM << endl << "CPANEL_X: " << CPANEL_X << endl << "CPANEL_Y: " << CPANEL_Y << endl << "CPANEL_W: " << CPANEL_W << endl << "CPANEL_H: " << CPANEL_H << endl;
    
    cout << endl << endl << "MAINPLOT_X: " << MAINPLOT_X << "; MAINPLOT_H: " << MAINPLOT_H << endl;
    
    
    //////////////////////////////////////////////////////////////////////////////////
    // Create File Objects
    //////////////////////////////////////////////////////////////////////////////////
    tmpFile = new TmpFile("SingingStudio");   // Create New TmpFile Object

    //////////////////////////////////////////////////////////////////////////////////
    // Default Sample Rate and Buffersize
    //////////////////////////////////////////////////////////////////////////////////
    //sampleRate = 22050;
    sampleRate = 44100; // ANDRE
    bufferSize = 512;
    
    //////////////////////////////////////////////////////////////////////////////////
    // PITCH METER OBJ
    //////////////////////////////////////////////////////////////////////////////////
    num_bins  = bufferSize;     // 
    num_2bins = num_bins << 1;  //512

    pitchMeterWrapper = new ssPitchMeterWrapper(num_2bins,num_bins,sampleRate,bufferSize);

    
    ///////////////////////////////////////////////////////////
    // Create Gui Object
    ///////////////////////////////////////////////////////////
    
    plotBuffer_size = PLOTS_W; // In samples (note that inside ssGUI it shows 2*plotBuffer_size based in the min/max metric per buffer
    ssGui = new ssGUI(plotBuffer_size);
    
    ///////////////////////////////////////////////////////////
    // Create New App State Machine Object
    ///////////////////////////////////////////////////////////
    appStateMachine = new ssAppStateMachine();

    ssGui->piano->initGLPianoRollData();

    // Midi Objects
    midiWrapper = new ssCoreMidiWrapper();
    midiWrapper->init("Piano");

    midiThread = new ssMidiThread();
    
    //////////////////////////////////////////////////////////////////////////////////
    // OTHER I/O
    //////////////////////////////////////////////////////////////////////////////////
    file2.open(ofToString(ofxiPhoneGetDocumentsDirectory() + "debugAudioIO.txt").c_str());
    
//    bkg.loadImage("DSGNbkg.png");
    
    bkg.loadImage("/Users/vocalcoach/Documents/OpenFrameworks/of_v0.9.8_ios_release_WORKING VERSION_modificada/apps/myApps/SingingStudio_16_05/Resources/bin/data/DSGNbkg.png"); // PROBLEMA
    
//    cout << appWorkingMode << endl;

    ofEnableSmoothing();
    ofEnableAlphaBlending();
    ofEvents().enable();
}

//--------------------------------------------------------------
void ssApp::update(){

    appStateMachine->update();
    
}

//--------------------------------------------------------------
void ssApp::draw(){
//    
//    ofSetColor(255, 0, 0);
//    ofCircle(pos.x, pos.y, 20);
//
    setPlotsColorBack();
    bkg.draw(0,0);
    
}

//--------------------------------------------------------------
void ssApp::audioInCallBack(float *input, int _bufferSize, int nChannels){
        
    ////////////////////////////////////////
    // Write Input Data to Temp File
    ////////////////////////////////////////
    tmpFile->writeBlockAtEnd( input, _bufferSize);
    
    pitchMeterWrapper->computePitchONLine(input, _bufferSize);
    
    appStateMachine->FRAME.Recording++;
}

//--------------------------------------------------------------
void ssApp::touchDown(ofTouchEventArgs & touch){
    //ssGui->touchDragObj->onTouchDown(touch);
}

//--------------------------------------------------------------
void ssApp::touchMoved(ofTouchEventArgs & touch){
    
    if (dbgMode) cout << "in ssApp::touchMoved | piano->yi = " << ssGui->piano->yi << " | piano->Wkeyboard = " << ssGui->piano->Wkeyboard << endl;
    
    //ssGui->touchDragObj->update(touch);
}

//--------------------------------------------------------------
void ssApp::touchUp(ofTouchEventArgs & touch){
    doubleTouchLock = false;
}

//--------------------------------------------------------------
void ssApp::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ssApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ssApp::lostFocus(){

}

//--------------------------------------------------------------
void ssApp::gotFocus(){

}

//--------------------------------------------------------------
void ssApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ssApp::deviceOrientationChanged(int newOrientation){

}


//--------------------------------------------------------------
void ssApp::startPlayback(){
    if (dbgMode) cout<<"in ssApp::startPlayback()"<<endl;
//    IOSoundStream.setup(this,1,0,sampleRate,bufferSize,4);
    AudioIO.initAudioSession();
    AudioIO.initAudioStreams(aUnit);
    AudioIO.startAudioUnit(aUnit);
}

//--------------------------------------------------------------
void ssApp::startRecording(){
    if (dbgMode) cout<<"in ssApp::startRecording()"<<endl;
//    IOSoundStream.setup(this,0,1,sampleRate,bufferSize,1);
    AudioIO.initAudioSession();
    AudioIO.initAudioStreams(aUnit);
    AudioIO.startAudioUnit(aUnit);
}

//--------------------------------------------------------------
void ssApp::stopAudioIO(){
    if (dbgMode) cout<<"in ssApp::stopAudioIO()"<<endl;
//    IOSoundStream.stop();
    AudioIO.stopProcessingAudio(aUnit);
}

//--------------------------------------------------------------
void ssApp::exit(){
    
    if (dbgMode) cout<<"in exit() method"<<endl;

    midiWrapper->allNotesOFF();
    stopAudioIO();
    
}

#include "ssApp.h"
#include "ssAppNativeGUIView.h"
#include "ssAudioIOWrapper.h"
//#include "mainAppViewController.h"
#include "vcAppViewController.h"

//#import "mainAppDelegate.h"
#import "vcAppDelegate.h"

extern vcAppDelegate * vcAppDelegatePNT;

ssAppNativeGUIView *myGuiViewController;

ofMutex mutex;

//--------------------------------------------------------------
ssApp :: ssApp () {
    if (dbgMode) cout << "in creating ssApp" << endl;
    appWorkingMode = RECORD_MODE;
    
}

//--------------------------------------------------------------
ssApp :: ssApp (string _filename) {
    if (dbgMode) cout << "in creating ssApp" << endl;

    loadFileName = ofSplitString(_filename,".wav")[0];
    appWorkingMode = PLAY_MODE;
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
    delete wavFile;
    delete recFile;
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

    wavFile = new ssWavIO();
    recFile = new ssWavIO();
    
    ///////////////////////////////////////////////////////////
    // FFT Stuff
    ///////////////////////////////////////////////////////////
//    fftBufferIN  = new float[Nfft];
//    fftBufferOUT = new float[Nfft];
//    set2zero(fftBufferIN,Nfft);
//    set2zero(fftBufferOUT,Nfft);
//    myFFT = new FFTAccelerate(4096);
    
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
    
    // ssAppNativeGui example
//    myGuiViewController	= [[ssAppNativeGUIView alloc] init];
//	[ofxiPhoneGetGLParentView() addSubview:myGuiViewController.view];
    
    //////////////////////////////////////////////////////////////////////////////////
    // OTHER I/O
    //////////////////////////////////////////////////////////////////////////////////
    file2.open(ofToString(ofxiPhoneGetDocumentsDirectory() + "debugAudioIO.txt").c_str());
    
//    bkg.loadImage("DSGNbkg.png");
    
    bkg.loadImage("/Users/vocalcoach/Documents/OpenFrameworks/of_v0.9.8_ios_release_WORKING VERSION_modificada/apps/myApps/SingingStudio_16_05/Resources/bin/data/DSGNbkg.png"); // PROBLEMA
    
    cout << appWorkingMode << endl;
    
    
    // Start App with File loaded
//    if (appWorkingMode==PLAY_MODE)
//        {
//        //ssGui->btn_record->setVisible(false);
//        if (dbgMode) cout << "Opening Filename: " << loadFileName + ".wav"<< endl;
//        
//        // start the thread
//        //loadFileThread.startThread(false, false);    // blocking, non verbose
//        loadWAVfile(loadFileName);
//        fileIsLoaded=true;
//        }

    ofEnableSmoothing();
    ofEnableAlphaBlending();
    ofEvents().enable();
}

//--------------------------------------------------------------
void ssApp::update(){
    
    //////////////////////////////////////////////////////////////////////////////////
    // 1) Update the Actual State
    //////////////////////////////////////////////////////////////////////////////////
    appStateMachine->update();

    //////////////////////////////////////////////////////////////////////////////////
    // 2) PROCESS ONLY WHEN APP IS NOT IN IDLE STATE
    //////////////////////////////////////////////////////////////////////////////////
    if (appStateMachine->execState != STATE_IDLE) {
        //////////////////////////////////////////////////////////////////////////////////
        // REAL TIME FFT COMPUTATION
        //////////////////////////////////////////////////////////////////////////////////
        // Perform Hanning Window
//        hamming(fftBufferIN,Nfft);
        // FFT computation
//        myFFT->doFFTReal(fftBufferIN, fftBufferOUT, Nfft);
        // convert to DB Scale
//        dB(fftBufferOUT,Nfft/2);
        }
 //   if (dbgMode) cout << "Framerate = " << ofGetFrameRate()<< endl;
    
//    if(ssGui->touchDragObj->touch1.y>PLOTS_H)
//    if (recogPintch->pinching) { // Pinching
//        if (recogPintch->direction==PinchAxisVertical) {
//            if (dbgMode) cout << "PINCHING | scale =" << recogPintch->scale << " | Direction = " << recogPintch->direction  << endl;
//            //////////////////////////////////////////////////////////////////////////
//            // Y-ZOOM
//            //////////////////////////////////////////////////////////////////////////
//            ssGui->piano->zoomY_pplot();
//        }
//        else if (recogPintch->direction == PinchAxisHorizontal) {
//            if (dbgMode) cout << "PINCHING | scale =" << recogPintch->scale << " | Direction = " << recogPintch->direction  << endl;
//            //////////////////////////////////////////////////////////////////////////
//            // X-ZOOM
//            //////////////////////////////////////////////////////////////////////////
//            ssGui->zoomX_tplot();
//        }
//    }
    
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

void ssApp::audioOutCallBack(float *output, int _bufferSize, int _nChannels){

    // if (dbgMode) cout<< "in audioOut"<< endl;
    
    if(bufferSize != _bufferSize){
        ofLog(OF_LOG_ERROR, "your buffer size was set to %i - but the stream needs a buffer size of %i", bufferSize, _bufferSize);
        return;
        }
        
    ////////////////////////////////////////
    // Read Data from Temp File
    ////////////////////////////////////////
    tmpFile->readBlock( output , convFram2Samp(appStateMachine->FRAME.Playing) , _bufferSize);
        
    ////////////////////////////////////////
    // Volume Update
    ////////////////////////////////////////
    //if (wavMidi_mode==PLAY_WAV || wavMidi_mode==PLAY_BOTH)
    //    scalarProd(output,_bufferSize,ssGui->volume);
    //else
    //    scalarProd(output,_bufferSize,0.0);
        
    scalarProd(output,_bufferSize,ssGui->volume * (1.0 - (1.0 + ssGui->mixFactor)/2));
    
    //if (dbgMode) cout<<"Play Buffer Conter: "<< FRAME.PlayFrame_cnt <<endl;

    if(!doubleTouchLock)
        appStateMachine->FRAME.Playing++;
    else
        hamming(output, _bufferSize);
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
 
    /*
    if (touch.x>PLOTS_X && touch.x<PLOTS_X+PLOTS_W && touch.y>PLOTS_H && touch.y<CPANEL_Y) {
        doubleTouchLock = true;
        FRAME.Playing = ofMap(touch.x, PLOTS_X, PLOTS_X + PLOTS_W, FRAME.Start, FRAME.Stop);
    
        if (midiWrapper!=NULL) {
            midiWrapper->allNotesOFF();
            }
                
        if (appStateMachine->execState==STATE_IDLE) {
            FRAME.Start = FRAME.Playing;
            appStateMachine->setNewExecState(STATE_PLAYING);
            }
    }
    */
    
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

////--------------------------------------------------------------
//void ssApp::loadWAVfile(string filename){
//    
//    if (dbgMode) cout<<"in loadWAVfile method"<<endl;
//    
//  //  ofEvents().disable();
//    
//        delete wavFile;
//        wavFile = new ssWavIO();
//        wavFile->setPath(ofxiPhoneGetDocumentsDirectory()+filename + ".wav");
//        wavFile->read();
//    
//        sampleRate = wavFile->getSampleRate();
//    
//        // Write Wav Data in TempFile
//        //tmpFile->~TmpFile();       // Remove Old TmpFile Object
//        delete tmpFile;
//        tmpFile = new TmpFile("SingingStudioTime");   // Create New TmpFile Object
//        tmpFile->writeBlock(wavFile->myFloatData, 0, wavFile->getLengthInSamples());
//
//        delete pitchMeterWrapper;
//        pitchMeterWrapper = new ssPitchMeterWrapper(num_2bins,num_bins,sampleRate,bufferSize);
//
//        // Points to the begining of the Loaded file
//        appStateMachine->FRAME.Playing = 0;     // in Frames -> Frame 0 points to the beggining of the file
//        appStateMachine->FRAME.Start   = 0;       // in Frames -> Frame 0 points to the beggining of the file
//        appStateMachine->FRAME.Stop    = convSamp2Fram(tmpFile->getSize());                               // Updates StopFrame to End of tmpFile
//        appStateMachine->FRAME.EoF     = convSamp2Fram(tmpFile->getSize());
//    
//        pitchMeterWrapper->computePitchOFFLine();
//        //recalculaPitchOffLine();
//
//        // Update GUI Dependancies, i.e. Tplot buffer and zoom_slider range
//        ssGui->piano->copyData2FileBuffer();
//
//        if (convSamp2Sec(tmpFile->getSize())<=ZOOM_MAX_TIME)
//            ssGui->updatePlotsData(0.0, convSamp2Sec(tmpFile->getSize()));
//        else
//            ssGui->updatePlotsData(0.0, ZOOM_MAX_TIME);
//    
//    //ofEvents().enable();
//
//}
//
//void ssApp::recordWAVfile(string filename){
//    
//    if (dbgMode) cout<<"in ssApp::recordWAVfile method"<<endl;
//    
//    
//    recFileName = filename;
//    recFile->setChannels(1);
//    recFile->setSampleRate(sampleRate);
//    recFile->setResolution(16);
//    recFile->setLength(tmpFile->getSize());
//    recFile->setPath(ofxiPhoneGetDocumentsDirectory() + recFileName + ".wav");
//    recFile->updateFloatDataBuffer(tmpFile, 0, tmpFile->getSize());             // in samples || update Tplot buffer
//    recFile->save();
//
//    // Points to the begining of previous Recorded file
//    appStateMachine->FRAME.Playing = 0;                                       // Reset Play Position
//    appStateMachine->FRAME.Start   = 0;                                         // Resets to the start Frame
//    appStateMachine->FRAME.Stop    = convSamp2Fram(tmpFile->getSize());         // Updates StopFrame to End of tmpFile
//    appStateMachine->FRAME.EoF     = convSamp2Fram(tmpFile->getSize());
//    
//    //recalculaPitchOffLine();
//    pitchMeterWrapper->computePitchOFFLine();
//    
//    ssGui->piano->copyData2FileBuffer();
//    
//    // Update GUI Dependancies, i.e. Tplot buffer and zoom_slider range
//    if (convSamp2Sec(tmpFile->getSize())<=ZOOM_MAX_TIME)
//        ssGui->updatePlotsData(0.0, convSamp2Sec(tmpFile->getSize()));
//    else
//        ssGui->updatePlotsData(0.0, ZOOM_MAX_TIME);
//    
//    appWorkingMode = PLAY_MODE;
//    
//    ssGui->rephreshGLData();
//    
//    // Midi Objects
//    midiWrapper = new ssCoreMidiWrapper();
//    midiWrapper->init("Piano");
//    
//    appWorkingMode = PLAY_MODE;
//
////    ssGui->btn_record->setVisible(false);
//
//    fileIsLoaded = true;
//
//    vcAppDelegatePNT.navigationController.navigationBar.topItem.title = ofxStringToNSString(recFileName+".wav");
//}


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

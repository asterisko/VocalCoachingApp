#include "mpApp.h"
#import <AVFoundation/AVAudioSession.h> //ADDED BY MJ


//void smbPitchShift(float pitchShift, long numSampsToProcess, long fftFrameSize, long osamp, float sampleRate, float *indata, float *outdata);

extern mpApp * myApp;

//--------------------------------------------------------------
void mpApp::setup(){	

    if(debugType==DEBUG) cout << "in mpApp::setup: " << ofGetElapsedTimef() << endl;
    
 //   ofEvents().disable();
    
    bufferSize = 512;
	sampleRate = 22050;

    ofBackground(0);
    ofSetFrameRate(30);
    // initialize the accelerometer
	ofxAccelerometer.setup();

    if(debugType==DEBUG) cout << "time1: " << ofGetElapsedTimef() << endl;

    //If you want a landscape oreintation
	//iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
    //////////////////////////////////////////////////////////////////////////////////
    // Add Sliders and Buttons for different devices
    //////////////////////////////////////////////////////////////////////////////////
    
    float sliderWidth   = 0.30;   // 4 barras cinza e 3 faders
    float sliderMargin  = (0.333333-sliderWidth)/2;
    float sliderHeigth;
    float sliderYi;
    
    float btnControlYi;
    float btnControlWidth  = 0.25;      // 4 barras cinza e 3 faders
    float btnControlMargin = (0.333333-btnControlWidth)/2 + 0.005;

    float btnPresetsXi;
    float btnPresetsWidth;	
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    // Remove Status bar for ios 7.0 and higher
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
//        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if (ofGetWidth()==320 && ofGetHeight()==480){
        
        std::cout << "1" << std::endl;
        
        device = i320x480;
        UI_BKG.loadImage("GUI/background/BKG_320x480.png");
        infoView = [[UIWebView alloc] initWithFrame:CGRectMake(ofGetWidth()/4-ofGetWidth()/8, ofGetHeight()/4-ofGetHeight()/8, ofGetWidth()*3/4, ofGetHeight()*3/4)];
        sliderYi  = 0.19;
        sliderHeigth = 0.61;
        btnControlYi = 0.83;
        btnPresetsXi = 1.045;
        btnPresetsWidth = 0.183;
        lateralmenuPercent = 0.25;
        }
    else if (ofGetWidth()==640 && ofGetHeight()==960){
        
        std::cout << "2" << std::endl;
        
        device = i640x960;
        UI_BKG.loadImage("GUI/background/BKG_640x960.png");
        infoView = [[UIWebView alloc] initWithFrame:CGRectMake(ofGetWidth()/8-ofGetWidth()/16, ofGetHeight()/8-ofGetHeight()/16, ofGetWidth()*3/8, ofGetHeight()*3/8)];
        sliderYi  = 0.19;
        sliderHeigth = 0.61;
        btnControlYi = 0.83;
        btnPresetsXi = 1.045;
        btnPresetsWidth = 0.183;
        lateralmenuPercent = 0.25;
        }
    else if (ofGetWidth()==640 && ofGetHeight()==1136){
        
        std::cout << "3" << std::endl;
        
        device = i640x1136;
        UI_BKG.loadImage("GUI/background/BKG_640x1136.png");
        infoView = [[UIWebView alloc] initWithFrame:CGRectMake(ofGetWidth()/8-ofGetWidth()/16, ofGetHeight()/8-ofGetHeight()/16, ofGetWidth()*3/8, ofGetHeight()*3/8)];
        sliderYi  = 0.17;
        sliderHeigth = 0.66;
        btnControlYi = 0.86;
        btnPresetsXi = 1.045;
        btnPresetsWidth = 0.183;
        lateralmenuPercent = 0.25;
        }
    else if (ofGetWidth()==768 && ofGetHeight()==1024){
        
        std::cout << "4" << std::endl;
        
        device = i768x1024;
        UI_BKG.loadImage("GUI/background/BKG_768x1024.png");
        infoView = [[UIWebView alloc] initWithFrame:CGRectMake(ofGetWidth()/4-ofGetWidth()/8, ofGetHeight()/4-ofGetHeight()/8, ofGetWidth()*3/4, ofGetHeight()*3/4)];
        sliderYi  = 0.21;
        sliderHeigth = 0.57;
        btnControlYi = 0.80;
        btnPresetsXi = 1.012;
        btnPresetsWidth = 0.183;
        lateralmenuPercent = 0.19;
        }
    else if (ofGetWidth()==1536 && ofGetHeight()==2048){
        
        std::cout << "5" << std::endl;
        
        device = i1536x2048;
        UI_BKG.loadImage("GUI/background/BKG_1536x2048.png");
        infoView = [[UIWebView alloc] initWithFrame:CGRectMake(ofGetWidth()/8-ofGetWidth()/16, ofGetHeight()/8-ofGetHeight()/16, ofGetWidth()*3/8, ofGetHeight()*3/8)];
        sliderYi  = 0.21;
        sliderHeigth = 0.57;
        btnControlYi = 0.80;
        btnPresetsXi = 1.012;
        btnPresetsWidth = 0.183;
        lateralmenuPercent = 0.19;
        }
    else if (ofGetWidth()==960 && ofGetHeight()==1704){
        
        std::cout << "6" << std::endl;
        
        device = i640x1136;
        UI_BKG.loadImage("GUI/background/BKG_960x1704.png");
        infoView = [[UIWebView alloc] initWithFrame:CGRectMake(ofGetWidth()/8-ofGetWidth()/16, ofGetHeight()/8-ofGetHeight()/16, ofGetWidth()*3/8, ofGetHeight()*3/8)];
        sliderYi  = 0.17;
        sliderHeigth = 0.66;
        btnControlYi = 0.86;
        btnPresetsXi = 1.045;
        btnPresetsWidth = 0.183;
        lateralmenuPercent = 0.25;
    }
    else if (ofGetWidth()==1080 && ofGetHeight()==1920){
        
        std::cout << "7" << std::endl;
        
        device = i640x1136;
        UI_BKG.loadImage("GUI/background/BKG_1080x1920.png");
        infoView = [[UIWebView alloc] initWithFrame:CGRectMake(ofGetWidth()/8-ofGetWidth()/16, ofGetHeight()/8-ofGetHeight()/16, ofGetWidth()*3/8, ofGetHeight()*3/8)];
        sliderYi  = 0.17;
        sliderHeigth = 0.66;
        btnControlYi = 0.86;
        btnPresetsXi = 1.045;
        btnPresetsWidth = 0.183;
        lateralmenuPercent = 0.25;
    }
    
    std::cout << ofGetHeight() <<" x "<< ofGetWidth() << std::endl;
    
    //////////////////////////////////////////////////////////////////////////////////
    // ADD SLIDERS
    //////////////////////////////////////////////////////////////////////////////////
    if(debugType==DEBUG) cout << "time3: " << ofGetElapsedTimef() << endl;
    slider_volume.init("Volume","GUI/sliders/volume/sliderhandle.png", 0.00   + sliderMargin , sliderYi , sliderWidth, sliderHeigth);
    slider_volume.setMinMaxValues(0.0, 100.0);
    slider_volume.setValue(50.0);
    slider_volume.setLabelDataResolution(0);

    float minDelayMS = (float)((float)1/sampleRate)*bufferSize*1000;
    slider_delay.init ("Delay" ,"GUI/sliders/delay/sliderhandle.png", 0.333333 + sliderMargin, sliderYi , sliderWidth, sliderHeigth);
    slider_delay.setMinMaxValues(40.0, 500.0);
    slider_delay.setValue(40.0);
    slider_delay.setLabelDataResolution(0);
    
    slider_pitch.init ("Pitch" ,"GUI/sliders/pitch/sliderhandle.png", 0.666666 + sliderMargin, sliderYi , sliderWidth, sliderHeigth);
    slider_pitch.setMinMaxValues(-12.1, 12.0);
    slider_pitch.setValue(0.0);
    slider_pitch.setLabelDataResolution(1);
    
    if(debugType==DEBUG) cout << "time4: " << ofGetElapsedTimef() << endl;
    //////////////////////////////////////////////////////////////////////////////////
    // ADD Buttons
    //////////////////////////////////////////////////////////////////////////////////
    btnNoiseGate.init    (PUSH_BUTTON, "Off", "ON",         "GUI/btns/NoiseGate/btnImageState0.png"        , 0.00    + btnControlMargin   , btnControlYi +0.03, btnControlWidth, 0.50);
    if(debugType==DEBUG) cout << "time41: " << ofGetElapsedTimef() << endl;
    btnPlayStop.init     (PUSH_BUTTON, "Play", "Stop",      "GUI/btns/PlayStop/btnImageState0.png"         , 0.333333 + btnControlMargin  , btnControlYi + 0.01, btnControlWidth, 0.50);
    if(debugType==DEBUG) cout << "time42: " << ofGetElapsedTimef() << endl;
    btnTimeFrequency.init(SLIDER_BUTTON, "Time", "Frequency", "GUI/btns/TimeFrequency/btnImageState0.png"  , 0.666666 + btnControlMargin  , btnControlYi, btnControlWidth, 0.50);
    if(debugType==DEBUG) cout << "time43: " << ofGetElapsedTimef() << endl;
    btnMenu.init         (PUSH_BUTTON, "Menu", "Menu Open", "GUI/btns/Menu/btnImageState0.png"      , 0.825 , 0.05  , 0.14  , 0.16);
    if(debugType==DEBUG) cout << "time44: " << ofGetElapsedTimef() << endl;
    btnLogo.init         (PUSH_BUTTON,"Logo", "Logo Open", "GUI/btns/Logo/btnImageState0.png"       , 0.015 , 0.000 , 0.23  , 0.08);
    if(debugType==DEBUG) cout << "time45: " << ofGetElapsedTimef() << endl;
    
    btnMild.init         (TOGGLE_BUTTON,"Mild", "Mild Selected",     "GUI/btns/Presets/Mild/btnImageState0.png"       , btnPresetsXi  , 0.18   , btnPresetsWidth  , btnPresetsWidth);
    if(debugType==DEBUG) cout << "time46: " << ofGetElapsedTimef() << endl;
    btnMedium.init       (TOGGLE_BUTTON,"Medium", "Medium Selected", "GUI/btns/Presets/Medium/btnImageState0.png"     , btnPresetsXi  , 0.32   , btnPresetsWidth  , btnPresetsWidth);
    if(debugType==DEBUG) cout << "time47: " << ofGetElapsedTimef() << endl;
    btnStrong.init       (TOGGLE_BUTTON,"Strong", "Strong Selected", "GUI/btns/Presets/Strong/btnImageState0.png"     , btnPresetsXi  , 0.46   , btnPresetsWidth  , btnPresetsWidth);
    if(debugType==DEBUG) cout << "time48: " << ofGetElapsedTimef() << endl;
    btnCustom1.init      (TOGGLE_BUTTON,"Custom1", "Custom1 Selected", "GUI/btns/Presets/Custom1/btnImageState0.png"  , btnPresetsXi  , 0.71, btnPresetsWidth  , btnPresetsWidth);
    if(debugType==DEBUG) cout << "time49: " << ofGetElapsedTimef() << endl;
    btnCustom2.init      (TOGGLE_BUTTON,"Custom2", "Custom2 Selected", "GUI/btns/Presets/Custom2/btnImageState0.png"  , btnPresetsXi  , 0.85   , btnPresetsWidth  , btnPresetsWidth);

    //////////////////////////////////////////////////////////////////////////////////
    // CREATE THE INFO VIEW
    //////////////////////////////////////////////////////////////////////////////////
    [infoView setDelegate:nil];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"info" withExtension:@"html"];
    [infoView loadRequest:[NSURLRequest requestWithURL:url]];
    [infoView setOpaque:YES];
    [[infoView layer] setCornerRadius:10];
    [infoView setClipsToBounds:YES];
    [[infoView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[infoView layer] setBorderWidth:4.75];
    [[infoView layer] setBackgroundColor: [[UIColor blackColor] CGColor]];
    infoView.alpha=1.0f;
    infoView.hidden=YES;
    [ofxiPhoneGetGLView() addSubview:infoView];
    
    if(debugType==DEBUG) cout << "time3: " << ofGetElapsedTimef() << endl;

    if(debugType==DEBUG) cout << "time5: " << ofGetElapsedTimef() << endl;
    //////////////////////////////////////////////////////////////////////////////////
    // ADD Time Plot
    //////////////////////////////////////////////////////////////////////////////////
    initTplot(0.25,0.10,0.55,0.08);

    if(debugType==DEBUG) cout << "time6: " << ofGetElapsedTimef() << endl;
    //////////////////////////////////////////////////////////////////////////////////
    // Processing Objects
    //////////////////////////////////////////////////////////////////////////////////
	fp = new fpitchshift(bufferSize, sampleRate);
	tp = new tpitchshiftorig(bufferSize, sampleRate);
    ng = new mpNoiseGate(5.0, 0.1, 0.9999);
    
    // Buffer de DELAY_MAX
    int Nsamples = (int) roundSIL(float(DELAY_MAX)*float(sampleRate) + float(bufferSize),0);
    delayBuffer.assign(Nsamples, 0.0);
    
    auxBufferIN = new float[bufferSize];
    set2zero(auxBufferIN,bufferSize);

    if(debugType==DEBUG) cout << "time7: " << ofGetElapsedTimef() << endl;
    //////////////////////////////////////////////////////////////////////////////////
    // ADD AUDIO INPUT/OUTPUT
    //////////////////////////////////////////////////////////////////////////////////
    ofSoundStreamSetup(1, 1, this, sampleRate, bufferSize, 1);
    ofSoundStreamStop();
    
    if(debugType==DEBUG) cout << "time8: " << ofGetElapsedTimef() << endl;

    //////////////////////////////////////////////////////////////////////////////////
    // ADD Alert View
    //////////////////////////////////////////////////////////////////////////////////
    alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Connect your Headphone/Headset to use this app!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

    if(debugType==DEBUG) cout << "time9: " << ofGetElapsedTimef() << endl;

    //////////////////////////////////////////////////////////////////////////////////
    // CREATE PRESET FILES
    //////////////////////////////////////////////////////////////////////////////////
    //                                T/F  ,  Volume[0-100] ,  Delay[23-500] , Pitch[-12,12]
    createPresetFile("mild.pre"     , 0    ,  40.0          ,  40.0          , -3.1);
    createPresetFile("medium.pre"   , 0    ,  40.0          ,  100.0         , -6.1);
    createPresetFile("strong.pre"   , 0    ,  40.0          ,  250.0         , +6.0);
    createPresetFile("custom1.pre"   , 0   ,  100.0         ,  40.0         , 0.0);
    createPresetFile("custom2.pre"   , 1   ,  100.0         ,  40.0         , 0.0);
    
    // Create last.pre if it doesnt exist!!!
    ofFile aux;
    if (!aux.doesFileExist(ofxiPhoneGetDocumentsDirectory() + "last.pre"))
        createPresetFile("last.pre"   , 1   ,  100.0         ,  40.0         , 0.0);

    // Load last slider positions
    loadCustomPreset("last.pre");

    if(debugType==DEBUG) cout << "time10: " << ofGetElapsedTimef() << endl;

    ofSetLogLevel(OF_LOG_ERROR);
    ofLogToConsole();
    ofEnableAlphaBlending();
    ofEnableSmoothing();

   // ofEvents().enable();
    
    if(debugType==DEBUG) cout << "in mpApp::setup END: " << ofGetElapsedTimef() << endl;
}

//--------------------------------------------------------------
void mpApp::update(){

    //////////////////////////////////////////////////////////////////////////////////
    // Check if headphones are plugged in
    //////////////////////////////////////////////////////////////////////////////////
    if (btnPlayStop.getState())
    if (!areHeadphonesPlugedIn()) {
        [alert show];
        stopAudioIO();
        btnPlayStop.setState(0);
        }

    //////////////////////////////////////////////////////////////////////////////////
    // Check if state Changed
    //////////////////////////////////////////////////////////////////////////////////
    if (btnPlayStop.stateChanged()) {
        if (btnPlayStop.state)
            myApp->startAudioIO();
        else
            myApp->stopAudioIO();
    }
    
    //////////////////////////////////////////////////////////////////////////////////
    // Animation Code
    //////////////////////////////////////////////////////////////////////////////////
    if (btnMenu.stateChanged()) {
        if (btnMenu.state) {
            moveFlag=2;
            }
        else
            moveFlag=1;
        }
    
    if (moveFlag==1){ //Close
        x_pos = x_pos + roundSIL(0.05*ofGetWidth(),0);
        if (x_pos>=0) moveFlag=0;
        }
    else if (moveFlag==2) { //Open
        x_pos= x_pos - roundSIL(0.05*ofGetWidth(),0);
        if (x_pos<=-roundSIL(ofGetWidth()*lateralmenuPercent,0)) moveFlag=0;   // 0.2 is the length in % of lateral panel
        }
    
    //////////////////////////////////////////////////////////////////////////////////
    // Handle with Custom Preset Saving
    //////////////////////////////////////////////////////////////////////////////////   
    if (btnCustom1.isPressing) {
            if (ofGetElapsedTimef() - buttonTimeDown > 2.0) {// Pressionou o botão por mais de 2 segundos
                saveCustomPreset("custom1.pre");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved Custom Preset #1" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                }
            }
    
    if (btnCustom2.isPressing) {
            if (ofGetElapsedTimef() - buttonTimeDown > 2.0) {// Pressionou o botão por mais de 2 segundos
                saveCustomPreset("custom2.pre");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved Custom Preset #2" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                }
            }
    // Update status of button pressed
    if (btnMild.isPressing){
       // btnMild.state = 1;
        btnMedium.state = 0;
        btnStrong.state = 0;
        btnCustom1.state = 0;
        btnCustom2.state = 0;
    }
    else if (btnMedium.isPressing) {
        btnMild.state = 0;
       // btnMedium.state = 1;
        btnStrong.state = 0;
        btnCustom1.state = 0;
        btnCustom2.state = 0;
    }
    else if (btnStrong.isPressing) {
        btnMild.state = 0;
        btnMedium.state = 0;
      //  btnStrong.state = 1;
        btnCustom1.state = 0;
        btnCustom2.state = 0;
    }
    else if (btnCustom1.isPressing) {
        btnMild.state = 0;
        btnMedium.state = 0;
        btnStrong.state = 0;
     //   btnCustom1.state = 1;
        btnCustom2.state = 0;
    }
    else if (btnCustom2.isPressing) {
        btnMild.state = 0;
        btnMedium.state = 0;
        btnStrong.state = 0;
        btnCustom1.state = 0;
   //     btnCustom2.state = 1;
    }

}

//--------------------------------------------------------------
void mpApp::draw(){
	
    ofPushStyle();
    
    ////////////////////////////////////////
    // Draw Main View
    ///////////////////////////////////////
    UI_BKG.draw(x_pos,y_pos);
    
    drawTplot();
    
    ofPopStyle();
}

//--------------------------------------------------------------
void mpApp::audioIn(float *input, int _bufferSize, int nChannels){
    
    if(bufferSize != _bufferSize){
        ofLog(OF_LOG_ERROR, "your buffer size was set to %i - but the stream needs a buffer size of %i", bufferSize, _bufferSize);
        return;
        }
    
    if (btnPlayStop.getState()) // OLD
        {
        ////////////////////////////////////////
        // Continuous update of the Delay Buffer
        ///////////////////////////////////////
        delayBuffer.insert( delayBuffer.end()  , input,     input    + _bufferSize);
        delayBuffer.erase ( delayBuffer.begin(), delayBuffer.begin() + _bufferSize);
//        if(debugType==DEBUG) cout<< "Buffer IN : " <<     bufferINCounter << endl;
        bufferINCounter++;
        }
}

//--------------------------------------------------------------
void mpApp::audioOut(float *output, int _bufferSize, int _nChannels){
    
    if(bufferSize != _bufferSize){
        ofLog(OF_LOG_ERROR, "your buffer size was set to %i - but the stream needs a buffer size of %i", bufferSize, _bufferSize);
        return;
        }

    ////////////////////////////////////////
    // Select the Delayed Buffer to Process
    ///////////////////////////////////////    
    int delayInSamples = (int)((float)(DELAY_MAX*slider_delay.value)*sampleRate);
 //   if(debugType==DEBUG) cout << "Delay in Samples:" << delayInSamples << endl;
    int init = delayBuffer.size() - delayInSamples - _bufferSize;
    int end  = delayBuffer.size() - delayInSamples;

    for(int i = init; i < end; i++)
        {
        auxBufferIN[i-init] = delayBuffer[i];
        }

    ////////////////////////////////////////
    // Pitch Shifting Processing
    ///////////////////////////////////////
//    float ti = ofGetElapsedTimef();
    float actPitchVal;
    switch (btnTimeFrequency.getState()) {
        case 0:     ////////////////////////////////////////
                    // Seegnal Method T
                    ///////////////////////////////////////
                    actPitchVal = ofMap(slider_pitch.scaledValue, PITCH_MIN, PITCH_MAX, -0.5, 0.5);
                    tp->process(auxBufferIN, output, actPitchVal);
                    break;
        case 1:     ////////////////////////////////////////
                    // Seegnal Method F
                    ///////////////////////////////////////
                    actPitchVal = pow(2., slider_pitch.scaledValue/12.);
                    fp->process(auxBufferIN, output, actPitchVal);
                    break;
        }
    
    //if(debugType==DEBUG) cout << "Duration : " << ofGetElapsedTimef()-ti << endl;
    
    ///////////////////////////////////////
    // Noise Gate Processing
    ///////////////////////////////////////
    audioInputPower = power(output, bufferSize);
    
    if (btnNoiseGate.getState()){
        float thresHold_dB = -70;
        ng->processBuffer(output, bufferSize, thresHold_dB, audioInputPower);
        }
    
    inputBuffer.push_back(audioInputPower);
    inputBuffer.erase(inputBuffer.begin());
    
    ///////////////////////////////////////
    // Volume control
    ///////////////////////////////////////
    scalarProd(output,bufferSize,slider_volume.value);
    
    bufferOUTCounter++;
    
//    if(debugType==DEBUG) cout<< "Input Power in dB: " << audioInputPower << endl;
//    if(debugType==DEBUG) cout<< "Actual Pitch : " << actPitchVal << endl;
//    if(debugType==DEBUG) cout<< "Actual Delay : " << slider_delay.value << endl;
//    if(debugType==DEBUG) cout<< "Actual Volume : " << slider_volume.scaledValue << endl;
//    if(debugType==DEBUG) cout<< "Buffer OUT : " <<     bufferOUTCounter << endl;

}

//--------------------------------------------------------------
void mpApp::exit(){
    
}

//--------------------------------------------------------------
void mpApp::touchDown(ofTouchEventArgs & touch){

    buttonTimeDown = ofGetElapsedTimef();

    // Close and Open the infoView when touching the logoBtn
    if (btnLogo.isPressing && infoView.hidden==YES)
        infoView.hidden=NO;
    else
        infoView.hidden=YES;
    
    // Close infoView if touch is outside of the infoView
    if (!btnLogo.isPressing)
        infoView.hidden=YES;
    
    if (btnMild.isPressing){
        loadCustomPreset("mild.pre");
        }
    else if (btnMedium.isPressing) {
        loadCustomPreset("medium.pre");
        }
    else if (btnStrong.isPressing) {
        loadCustomPreset("strong.pre");
        }
    else if (btnCustom1.isPressing) {
        btnCustomPresetPressed=1;
        }
    else if (btnCustom2.isPressing) {
        btnCustomPresetPressed=2;
        }
}

//--------------------------------------------------------------
void mpApp::touchMoved(ofTouchEventArgs & touch){

    if (slider_delay.isDragging || slider_pitch.isDragging || slider_volume.isDragging) {
        saveCustomPreset("last.pre");
        // Unselect Preset
        btnMild.state = 0;
        btnMedium.state = 0;
        btnStrong.state = 0;
        btnCustom1.state = 0;
        btnCustom2.state = 0;
        }

}

//--------------------------------------------------------------
void mpApp::touchUp(ofTouchEventArgs & touch){
        
    if (btnCustomPresetPressed==1) {
        loadCustomPreset("custom1.pre");
        }
    else if (btnCustomPresetPressed==2) {
        loadCustomPreset("custom2.pre");
        }

    btnCustomPresetPressed=0;
}

//--------------------------------------------------------------
void mpApp::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void mpApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void mpApp::lostFocus(){

}

//--------------------------------------------------------------
void mpApp::gotFocus(){

}

//--------------------------------------------------------------
void mpApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void mpApp::deviceOrientationChanged(int newOrientation){

}

//--------------------------------------------------------------
void mpApp::startAudioIO(){
    ofSoundStreamStart();
}

//--------------------------------------------------------------
void mpApp::stopAudioIO(){
    ofSoundStreamStop();
}


//--------------------------------------------------------------
void mpApp::initTplot(float _xi, float _yi, float _W, float _H){
    
    x_pos = 0.0;
    plotXi      = _xi*ofGetWidth();
    plotYi      = _yi*ofGetHeight();
    plotWidth   = _W*ofGetWidth();
    plotHeigth  = _H*ofGetHeight();
    
    inputBuffer.assign(plotWidth, -120.0);

    plotLow     = roundSIL(plotWidth*0.43,0);
    plotHigh    = roundSIL(plotWidth*0.57,0);


}

//--------------------------------------------------------------
void mpApp::drawTplot(){
                
    for (int i=0; i<plotLow;i++)
        {
        ofSetColor(255,255, 255, 255*i/plotLow);
        ofLine(x_pos+plotXi+i, plotYi, x_pos+plotXi+i, plotYi - ofMap(inputBuffer[i],-120,0,0,plotHeigth));
        ofLine(x_pos+plotXi+i, plotYi, x_pos+plotXi+i, plotYi + ofMap(inputBuffer[i],-120,0,0,plotHeigth));
        }
    
    for (int i=plotLow; i<inputBuffer.size();i++)
        {
        ofSetColor(255,255,255, 255);
        ofLine(x_pos+plotXi+i, plotYi, x_pos+plotXi+i, plotYi - ofMap(inputBuffer[i],-120,0,0,plotHeigth));
        ofLine(x_pos+plotXi+i, plotYi, x_pos+plotXi+i, plotYi + ofMap(inputBuffer[i],-120,0,0,plotHeigth));
        }
    
    ofSetColor(255,255,255, 255);
    ofEllipse(x_pos+plotXi+inputBuffer.size()+4, plotYi, 8,  2*ofMap(inputBuffer[inputBuffer.size()-1],-120,0,0,plotHeigth));
    ofRect(x_pos+plotXi+inputBuffer.size()-1, plotYi - ofMap(inputBuffer[inputBuffer.size()-1],-120,0,0,plotHeigth), 4, 2*ofMap(inputBuffer[inputBuffer.size()-1],-120,0,0,plotHeigth) );
    ofNoFill();
    ofEllipse(x_pos+plotXi+inputBuffer.size()+4, plotYi, 8,  2*ofMap(inputBuffer[inputBuffer.size()-1],-120,0,0,plotHeigth));
    ofRect(x_pos+plotXi+inputBuffer.size()-1, plotYi - ofMap(inputBuffer[inputBuffer.size()-1],-120,0,0,plotHeigth), 4, 2*ofMap(inputBuffer[inputBuffer.size()-1],-120,0,0,plotHeigth) );
    
    
    //myfont.drawString( selectedLabel ,  x_pos + 0.85*ofGetWidth(), plotYi +  0.07*ofGetHeight());
    
    
    ofSetColor(31,31, 31,60);
    ofLine(x_pos+plotXi-10, plotYi, x_pos+plotXi + ofGetHeight()*0.5 - 10, plotYi);


}

bool mpApp::areHeadphonesPlugedIn(void) {

    UInt32 routeSize = sizeof (CFStringRef);
    
    // CFStringRef route; COMMENTED BY MJ
    
    // TODO OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute,&routeSize,&route);
    OSStatus error = false;
    
    /* Known values of route:
     * "Headset"
     * "Headphone"
     * "Speaker"
     * "SpeakerAndMicrophone"
     * "HeadphonesAndMicrophone"
     * "HeadsetInOut"
     * "ReceiverAndMicrophone"
     * "Lineout"
     */
    
    /* PREVIOUS FUNCTION (COMMENTED BY MJ)

    if (!error && (route != NULL)) {
        NSString * routeStr = (NSString*)route;
        NSRange headphoneRange = [routeStr rangeOfString : @"Head"];
        if (headphoneRange.location != NSNotFound)
            return YES;
        }
     */
    
    // ADDED BY MJ FUNCTION
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    
    return NO;
}

void mpApp::createPresetFile(string filename, int _type, float _volume, float _delay, float _pitch) {
    if(debugType==DEBUG) cout << " in mpApp::createPresetFile" <<endl;
    
    ofstream file;
    string fullpath = ofxiPhoneGetDocumentsDirectory() + filename;
    file.open(fullpath.c_str());
    file << "TimeFrequencyType=" << _type << endl;
    file << "SliderVolume="<< _volume << endl;
    file << "SliderDelay="<< _delay << endl;
    file << "SliderPitch="<< _pitch << endl;
    file.close();
}

void mpApp::saveCustomPreset(string filename) {
    if(debugType==DEBUG) cout << " in mpApp::saveCustomPreset" <<endl;

    ofstream file;
    string fullpath = ofxiPhoneGetDocumentsDirectory() + filename;
    file.open(fullpath.c_str());
    file << "TimeFrequencyType=" << btnTimeFrequency.getState() << endl;
    file << "SliderVolume="<< slider_volume.scaledValue << endl;
    file << "SliderDelay="<< slider_delay.scaledValue << endl;
    file << "SliderPitch="<< slider_pitch.scaledValue - (slider_pitch.scaledValue>0.0?0.0:0.1)<< endl;
    file.close();
}

void mpApp::loadCustomPreset(string filename) {
    if(debugType==DEBUG) cout << " in mpApp::loadCustomPreset" <<endl;

    ofFile file;
    string fullpath = ofxiPhoneGetDocumentsDirectory() + filename;
    
    file.open(fullpath);
    
    string line;
    
    file>>line;
    if(debugType==DEBUG) cout << line<<endl;
    btnTimeFrequency.setState(ofToBool(ofSplitString(line,"=")[1]));
    file>>line;
    if(debugType==DEBUG) cout << line<<endl;
    slider_volume.setValue(ofToFloat(ofSplitString(line,"=")[1]));
    file>>line;
    if(debugType==DEBUG) cout << line<<endl;
    slider_delay.setValue(ofToFloat(ofSplitString(line,"=")[1]));
    file>>line;
    if(debugType==DEBUG) cout << line<<endl;
    slider_pitch.setValue(ofToFloat(ofSplitString(line,"=")[1]));
    
    file.close();
}

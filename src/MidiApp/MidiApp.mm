#include "MidiApp.h"
#include "ssApp.h"

#define kLowNote  48
#define kHighNote 72
#define kMidNote  60

extern ssApp * myApp;

//--------------------------------------------------------------
MidiApp :: MidiApp () {
    if (myApp->dbgMode) cout << "creating MidiApp" << endl;
}

//--------------------------------------------------------------
MidiApp :: ~MidiApp () {
    if (myApp->dbgMode) cout << "destroying MidiApp" << endl;
}

//--------------------------------------------------------------
void MidiApp::setup() {
    
    bkg.loadImage("DSGNintro.png");
    
    int fontSize = 16;
    
// ANDRE (comentei)
//    if (ofxiPhoneGetOFWindow()->isRetinaSupported())
//        fontSize *= 2;
    
    font.loadFont("fonts/C&C Red Alert [INET].ttf", fontSize);

    // Set up the audio session for this app, in the process obtaining the
    // hardware sample rate for use in the audio processing graph.
    BOOL audioSessionActivated = setupAudioSession();
    
    // Create the audio processing graph; place references to the graph and to the Sampler unit
    // into the processingGraph and samplerUnit instance variables.
    
    if (audioSessionActivated)
        {
        // 1 - Create AUgraph
        createAUGraph();
        // 2 - Configure and Start Audio Processing Graph
        configureAndStartAudioProcessingGraph(processingGraph);
            
        // 3 - Load instrument
        NSString *instrument = @"Piano";
            
        
        NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:instrument ofType:@"aupreset"]];
        if (presetURL) {
                NSLog(@"Attempting to load preset '%@'\n", [presetURL description]);
            }
        else {
                NSLog(@"COULD NOT GET PRESET PATH!");
            }
            
        loadSynthFromPresetURL(presetURL);
        }
}

//--------------------------------------------------------------
void MidiApp::update(){

}

//--------------------------------------------------------------
void MidiApp::draw() {

        
    
    bkg.draw(0,0);

    int x = 100;
    int y = 100;
    int p = 20;
    
//    ofSetColor(ofColor::white);
//    font.drawString("frame num      = " + ofToString(ofGetFrameNum() ),    x, y+=p);
//    font.drawString("frame rate     = " + ofToString(ofGetFrameRate() ),   x, y+=p);
//    font.drawString("screen width   = " + ofToString(ofGetWidth() ),       x, y+=p);
//    font.drawString("screen height  = " + ofToString(ofGetHeight() ),      x, y+=p);
}

//--------------------------------------------------------------
void MidiApp::exit() {
    //
    
    UInt32 noteCommand = 	kMIDIMessage_AllNotesOff << 4 | 0;
	
    OSStatus result = noErr;
    result = MusicDeviceMIDIEvent(samplerUnit, noteCommand, 120, 0, 0);

}

//--------------------------------------------------------------
void MidiApp::touchDown(ofTouchEventArgs &touch){

    float posy = touch.x;
    float posx = touch.y;
    
    notePressed = ofMap(posy,0,ofGetWidth(),FIRST_KEY,LAST_KEY);
    
	UInt32 onVelocity = ofMap(posx, 0, ofGetHeight(), 127,64);
    
	UInt32 noteCommand = 	kMIDIMessage_NoteOn << 4 | 0;
	
    OSStatus result = noErr;
    result = MusicDeviceMIDIEvent(samplerUnit, noteCommand, notePressed, onVelocity, 0);

    
}

//--------------------------------------------------------------
void MidiApp::touchMoved(ofTouchEventArgs &touch){

}

//--------------------------------------------------------------
void MidiApp::touchUp(ofTouchEventArgs &touch){

    
	UInt32 noteCommand = 	kMIDIMessage_NoteOff << 4 | 0;
	
    OSStatus result = noErr;
    result = MusicDeviceMIDIEvent(samplerUnit, noteCommand, notePressed, 0, 0);

    
}

//--------------------------------------------------------------
void MidiApp::touchDoubleTap(ofTouchEventArgs &touch){

}

//--------------------------------------------------------------
void MidiApp::lostFocus(){

}

//--------------------------------------------------------------
void MidiApp::gotFocus(){

}

//--------------------------------------------------------------
void MidiApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void MidiApp::deviceOrientationChanged(int newOrientation){

}


//--------------------------------------------------------------
void MidiApp::touchCancelled(ofTouchEventArgs& args){

}



// Create an audio processing graph.
BOOL MidiApp::createAUGraph (void) {
    
    if (myApp->dbgMode) cout << "in MidiApp::createAUGraph" << endl;
    
	OSStatus result = noErr;
	AUNode samplerNode, ioNode;
    
    // Specify the common portion of an audio unit's identify, used for both audio units
    // in the graph.
	AudioComponentDescription cd = {};
	cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
	cd.componentFlags            = 0;
	cd.componentFlagsMask        = 0;
    
    // Instantiate an audio processing graph
	result = NewAUGraph (&processingGraph);
    if (result != noErr){
        if (myApp->dbgMode) cout << "Unable to create an AUGraph object. Error code: " << result << endl;
        return NO;
        }
    
	//Specify the Sampler unit, to be used as the first node of the graph
	cd.componentType = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_Sampler;
	
    // Add the Sampler unit node to the graph
	result = AUGraphAddNode (processingGraph, &cd, &samplerNode);
    if (result != noErr){
        if (myApp->dbgMode) cout << "Unable to add the Sampler unit to the audio processing graph. Error code: " << result << endl;
        return NO;
    }
    
	// Specify the Output unit, to be used as the second and final node of the graph
	cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_RemoteIO;
    
    // Add the Output unit node to the graph
	result = AUGraphAddNode (processingGraph, &cd, &ioNode);
    if (result != noErr){
        if (myApp->dbgMode) cout << "Unable to add the Output unit to the audio processing graph. Error code: " << result << endl;
        return NO;
    }
    
    // Open the graph
	result = AUGraphOpen (processingGraph);
    if (result != noErr){
        if (myApp->dbgMode) cout << "Unable to open the audio processing graph. Error code: " << result << endl;
        return NO;
    }

    // Connect the Sampler unit to the output unit
	result = AUGraphConnectNodeInput (processingGraph, samplerNode, 0, ioNode, 0);
    if (result != noErr){
        if (myApp->dbgMode) cout << "Unable to interconnect the nodes in the audio processing graph. Error code: " << result << endl;
        return NO;
    }

	// Obtain a reference to the Sampler unit from its node
	result = AUGraphNodeInfo (processingGraph, samplerNode, 0, &samplerUnit);
    if (result != noErr){
        if (myApp->dbgMode) cout << "Unable to obtain a reference to the Sampler unit. Error code: " << result << endl;
        return NO;
    }
    
	// Obtain a reference to the I/O unit from its node
	result = AUGraphNodeInfo (processingGraph, ioNode, 0, &ioUnit);
    if (result != noErr){
        if (myApp->dbgMode) cout << "Unable to obtain a reference to the I/O unit. Error code: " << result << endl;
        return NO;
    }
    
    return YES;
}

// Starting with instantiated audio processing graph, configure its
// audio units, initialize it, and start it.
BOOL MidiApp::configureAndStartAudioProcessingGraph(AUGraph graph) {


    OSStatus result = noErr;
    UInt32 framesPerSlice = 0;
    UInt32 framesPerSlicePropertySize = sizeof (framesPerSlice);
    UInt32 sampleRatePropertySize = sizeof (graphSampleRate);
    
    result = AudioUnitInitialize (ioUnit);
    if (result != noErr){
        if (myApp->dbgMode) cout << "Unable to initialize the I/O unit. Error code: " << result << endl;
        return NO;
    }
    
    // Set the I/O unit's output sample rate.
    result =    AudioUnitSetProperty (
                                      ioUnit,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    if (result != noErr){
        if (myApp->dbgMode) cout << "AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: " << result << endl;
        return NO;
    }
    
    // Obtain the value of the maximum-frames-per-slice from the I/O unit.
    result =    AudioUnitGetProperty (
                                      ioUnit,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      &framesPerSlicePropertySize
                                      );
    
    if (result != noErr){
        if (myApp->dbgMode) cout << "Unable to retrieve the maximum frames per slice property from the I/O unit. Error code: " << result << endl;
        return NO;
    }

    // Set the Sampler unit's output sample rate.
    result =    AudioUnitSetProperty (
                                      samplerUnit,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    if (result != noErr){
        if (myApp->dbgMode) cout << "AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: " << result << endl;
        return NO;
    }
    
    // Set the Sampler unit's maximum frames-per-slice.
    result =    AudioUnitSetProperty (
                                      samplerUnit,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      framesPerSlicePropertySize
                                      );
    
    if (result != noErr){
        if (myApp->dbgMode) cout << "AudioUnitSetProperty (set Sampler unit maximum frames per slice). Error code: " << result << endl;
        return NO;
    }
        
    
    if (graph) {
        
        // Initialize the audio processing graph.
        result = AUGraphInitialize (graph);
        if (result != noErr){
            if (myApp->dbgMode) cout << "Unable to initialze AUGraph object. Error code: " << result << endl;
            return NO;
        }
        
        // Start the graph
        result = AUGraphStart (graph);
        if (result != noErr){
            if (myApp->dbgMode) cout << "Unable to start audio processing graph. Error code: " << result << endl;
            return NO;
        }
        
        // Print out the graph to the console
        CAShow (graph); 
    }
    return YES;
}


// Load a synthesizer preset file and apply it to the Sampler unit
OSStatus MidiApp::loadSynthFromPresetURL( NSURL * presetURL) {

	CFDataRef propertyResourceData = 0;
	Boolean status;
	SInt32 errorCode = 0;
	OSStatus result = noErr;
	
	// Read from the URL and convert into a CFData chunk
	status = CFURLCreateDataAndPropertiesFromResource (
                                                       kCFAllocatorDefault,
                                                       (CFURLRef) presetURL,
                                                       &propertyResourceData,
                                                       NULL,
                                                       NULL,
                                                       &errorCode
                                                       );
    
    if (status != YES && propertyResourceData == 0){
        if (myApp->dbgMode) cout << "Unable to create data and properties from a preset. Error code: " << errorCode << endl;
        return NO;
    }
       	
	// Convert the data object into a property list
	CFPropertyListRef presetPropertyList = 0;
	//CFPropertyListFormat dataFormat = 0;
    CFPropertyListFormat dataFormat; // ANDRE
	CFErrorRef errorRef = 0;
	presetPropertyList = CFPropertyListCreateWithData (
                                                       kCFAllocatorDefault,
                                                       propertyResourceData,
                                                       kCFPropertyListImmutable,
                                                       &dataFormat,
                                                       &errorRef
                                                       );
    
    // Set the class info property for the Sampler unit using the property list as the value.
	if (presetPropertyList != 0) {
		
		result = AudioUnitSetProperty(
                                      samplerUnit,
                                      kAudioUnitProperty_ClassInfo,
                                      kAudioUnitScope_Global,
                                      0,
                                      &presetPropertyList,
                                      sizeof(CFPropertyListRef)
                                      );
        
		CFRelease(presetPropertyList);
	}
    
    if (errorRef) CFRelease(errorRef);
    
    CFRelease (propertyResourceData);
    
    return result;
}


// Set up the audio session for this app.
BOOL MidiApp::setupAudioSession(void) {
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    // Assign the Playback category to the audio session. This category supports
    //    audio output with the Ring/Silent switch in the Silent position.
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayback error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error setting audio session category."); return NO;}
    
    // Request a desired hardware sample rate.
    graphSampleRate = 44100.0;    // Hertz
    
    [mySession setPreferredHardwareSampleRate: graphSampleRate error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error setting preferred hardware sample rate."); return NO;}
    
    // Activate the audio session
    [mySession setActive: YES error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error activating the audio session."); return NO;}
    
    // Obtain the actual hardware sample rate and store it for later use in the audio processing graph.
    graphSampleRate = [mySession currentHardwareSampleRate];
    
    return YES;
}





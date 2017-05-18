//
//  ssAudioIOWrapper.cpp
//  iOSingingStudio
//
//  Created by Voice Studies on 7/26/13.
//
//
#include "ssAudioIOWrapper.h"
#include "ssApp.h"

extern ssApp * myApp;

// Yeah, global variables suck, but it's kind of a necessary evil here
AudioUnit *aUnit = NULL;
float     *convertedSampleBuffer = NULL;

OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags, const AudioTimeStamp *audioTimeStamp,
                        UInt32 busNumber, UInt32 numFrames, AudioBufferList *buffers) {
    
    OSStatus status = AudioUnitRender(*aUnit, actionFlags, audioTimeStamp,1, numFrames, buffers);
    if(status != noErr) {
        return status;
    }
    
    if(convertedSampleBuffer == NULL) {
        // Lazy initialization of this buffer is necessary because we don't
        // know the frame count until the first callback
        convertedSampleBuffer = (float*)malloc(sizeof(float) * numFrames);
    }
    
    SInt16 *inputFrames = (SInt16*)(buffers->mBuffers->mData);
    
    /////////////////////////////////////////////////////////
    // AUDIO INPUT CALLBACK
    /////////////////////////////////////////////////////////
    if (myApp->appStateMachine->execState == STATE_RECORDING)
        {
        // If your DSP code can use integers, then don't bother converting to
        // floats here, as it just wastes CPU. However, most DSP algorithms rely
        // on floating point, and this is especially true if you are porting a
        // VST/AU to iOS.
        for(int i = 0; i < numFrames; i++) {
            convertedSampleBuffer[i] = (float)inputFrames[i] / 32768.0f;
            inputFrames[i] = 0.0; // Silent Output
            }
            
        myApp->audioInCallBack(convertedSampleBuffer, numFrames, 1);
        }
}

ssAudioIOWrapper::ssAudioIOWrapper() {

}

ssAudioIOWrapper::~ssAudioIOWrapper() {
  //  delete [] convertedSampleBuffer;
}


int ssAudioIOWrapper::initAudioSession() {
    
    aUnit = (AudioUnit*)malloc(sizeof(AudioUnit));
    
    if(AudioSessionInitialize(NULL, NULL, NULL, NULL) != noErr) {
        return 1;
        }
    
    if(AudioSessionSetActive(true) != noErr) {
        return 1;
        }
    
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                               sizeof(UInt32), &sessionCategory) != noErr) {
        return 1;
        }
    
    Float32 bufferSizeInSec = (float) myApp->bufferSize/myApp->sampleRate;
    if(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
                               sizeof(Float32), &bufferSizeInSec) != noErr) {
        return 1;
        }
    
    UInt32 overrideCategory = 1;
    if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                               sizeof(UInt32), &overrideCategory) != noErr) {
        return 1;
        }
    
    // There are many properties you might want to provide callback functions for:
    // kAudioSessionProperty_AudioRouteChange
    // kAudioSessionProperty_OverrideCategoryEnableBluetoothInput
    // etc.
      
    return 0;
}

int ssAudioIOWrapper::initAudioStreams(AudioUnit *audioUnit) {
    
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                               sizeof(UInt32), &audioCategory) != noErr) {
        return 1;
        }
    
    UInt32 overrideCategory = 1;
    if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                               sizeof(UInt32), &overrideCategory) != noErr) {
        // Less serious error, but you may want to handle it and bail here
        }
    
    AudioComponentDescription componentDescription;
    componentDescription.componentType = kAudioUnitType_Output;
    componentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    componentDescription.componentFlags = 0;
    componentDescription.componentFlagsMask = 0;
    AudioComponent component = AudioComponentFindNext(NULL, &componentDescription);
    if(AudioComponentInstanceNew(component, audioUnit) != noErr) {
        return 1;
        }
    
    UInt32 enable = 1;
    if(AudioUnitSetProperty(*audioUnit, kAudioOutputUnitProperty_EnableIO,
                            kAudioUnitScope_Input, 1, &enable, sizeof(UInt32)) != noErr) {
        return 1;
        }
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback; // Render function
    callbackStruct.inputProcRefCon = NULL;
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_SetRenderCallback,
                            kAudioUnitScope_Input, 0, &callbackStruct,
                            sizeof(AURenderCallbackStruct)) != noErr) {
        return 1;
        }
    
    AudioStreamBasicDescription streamDescription;
    // You might want to replace this with a different value, but keep in mind that the
    // iPhone does not support all sample rates. 8kHz, 22kHz, and 44.1kHz should all work.
    streamDescription.mSampleRate = myApp->sampleRate;
    // Yes, I know you probably want floating point samples, but the iPhone isn't going
    // to give you floating point data. You'll need to make the conversion by hand from
    // linear PCM <-> float.
    streamDescription.mFormatID = kAudioFormatLinearPCM;
    // This part is important!
    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger |
    kAudioFormatFlagsNativeEndian |
    kAudioFormatFlagIsPacked;
    // Not sure if the iPhone supports recording >16-bit audio, but I doubt it.
    streamDescription.mBitsPerChannel = 16;
    // 1 sample per frame, will always be 2 as long as 16-bit samples are being used
    streamDescription.mBytesPerFrame = 2;
    // Record in mono. Use 2 for stereo, though I don't think the iPhone does true stereo recording
    streamDescription.mChannelsPerFrame = 1;
    streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame * streamDescription.mChannelsPerFrame;
    // Always should be set to 1
    streamDescription.mFramesPerPacket = 1;
    // Always set to 0, just to be sure
    streamDescription.mReserved = 0;
    
    // Set up input stream with above properties
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Input, 0, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
        }
    
    // Ditto for the output stream, which we will be sending the processed audio to
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Output, 1, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
        }
    
    return 0;
}


int ssAudioIOWrapper::startAudioUnit(AudioUnit *audioUnit) {
    
    if(AudioUnitInitialize(*audioUnit) != noErr) {
        return 1;
        }
    
    if(AudioOutputUnitStart(*audioUnit) != noErr) {
        return 1;
        }
    
    return 0;
}


int ssAudioIOWrapper::stopProcessingAudio(AudioUnit *audioUnit) {
    
    if (audioUnit!=NULL) {
   
        if(AudioOutputUnitStop(*audioUnit) != noErr) {
            return 1;
            }
        
        if(AudioUnitUninitialize(*audioUnit) != noErr) {
            return 1;
            }
        
        *audioUnit = NULL;
    
    }
    
    return 0;
}

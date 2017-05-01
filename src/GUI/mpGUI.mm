#include "mpGUI.h"
#include "mpApp.h"

extern mpApp * myApp;

///////////////////////////////////////////////////////////
// class Constructor
///////////////////////////////////////////////////////////
mpGUI::mpGUI(int _sampleRate, int _plotBuffer_size , int _input_buffer_size) {
    
    // Get Main APP pointer
    
    // Init Plot Buffers
    sampleRate = _sampleRate;
    
    plotBuffer_size = _plotBuffer_size;
    
    input_buffer_size = _input_buffer_size;
    
    plotBuffer = new float[plotBuffer_size];
    
    for(int i = 0; i < plotBuffer_size; i++)
        plotBuffer[i] = 0;
    
    type = 0;
    
}

///////////////////////////////////////////////////////////
// class Destructor
///////////////////////////////////////////////////////////
mpGUI::~mpGUI() {
    delete mainCanvas;
}

///////////////////////////////////////////////////////////
// GUI Event CallBack and APP STATE UPDATE
///////////////////////////////////////////////////////////
void mpGUI::guiEvent(ofxUIEventArgs &e) {
    
    string name = e.widget->getName();
    int kind = e.widget->getKind();
    int state = e.widget->getID();
    
    cout << "got event from: " << name << endl;

    ///////////////////////////////////////////////////////////
    // Buttons
    ///////////////////////////////////////////////////////////
    if(name=="btn_play")
        {
        cout << "Btn Value: " << btn_play->getValue() << endl;
        if (btn_play->getValue())
            myApp->startAudioIO();
        else
            myApp->stopAudioIO();
        }

    
    if(name=="btn_T")
        {
        btn_T->setValue(false);
        btn_F->setValue(true);
        btn_F2->setValue(true);
        btn_N->setValue(true);
        type = 0;
        
        cout << "Changed to TSeeg method" << endl;
        }

    if(name=="btn_F")
        {
        btn_T->setValue(true);
        btn_F->setValue(false);
        btn_F2->setValue(true);
        btn_N->setValue(true);
        type = 1;

        cout << "Changed to FSeeg method" << endl;
        }
    
    if(name=="btn_F2")
        {
        btn_T->setValue(true);
        btn_F->setValue(true);
        btn_F2->setValue(false);
        btn_N->setValue(true);
        type = 2;
        
        cout << "Changed to DspDim method" << endl;
        }

    if(name=="btn_N")
    {
        btn_T->setValue(true);
        btn_F->setValue(true);
        btn_F2->setValue(true);
        btn_N->setValue(false);
        type = 3;
        cout << "Changed to None method" << endl;
    }
    ///////////////////////////////////////////////////////////
    // Sliders
    ///////////////////////////////////////////////////////////
    if(name=="slider_volume")
        {
        myApp->volume = slider_volume->getScaledValue();
        label_volume->setLabel(ofToString(roundSIL(slider_volume->getScaledValue(),0)) + " %");
        cout<<"Volume: " << myApp->volume << endl;
        }

    if(name=="slider_delay")
        {
        myApp->delay = slider_delay->getValue();
        label_delay->setLabel(ofToString(roundSIL(slider_delay->getScaledValue(),0)) + " ms");
        cout<<"Delay: " << myApp->delay << endl;
        }

    if(name=="slider_pitch")
        {
        myApp->pitch = slider_pitch->getScaledValue();
        label_pitch->setLabel(ofToString(roundSIL(slider_pitch->getScaledValue(),1)) + " semitones");
        cout<<"Pitch: " << myApp->pitch << endl;
        }
}

///////////////////////////////////////////////////////////
// ADD App GUI
///////////////////////////////////////////////////////////
void mpGUI::addAppGUI()
{
    float dim = 16;
    
    ///////////////////////////////////////////////////////////
    // ADD Time Domain Plot Canvas
    ///////////////////////////////////////////////////////////
    mainCanvas = new ofxUICanvas(20, 20, ofGetWidth() - 40, ofGetHeight() - 60);

    ///////////////////////////////////////////////////////////
    // ADD WAVFORM PLOT
    ///////////////////////////////////////////////////////////
    mainCanvas->addWidgetDown(new ofxUILabel("Audio Input Monitor : ", OFX_UI_FONT_MEDIUM));

    label_power = new ofxUILabel( ofToString(roundSIL(myApp->audioInputPower,0)), OFX_UI_FONT_MEDIUM);
    mainCanvas->addWidgetRight(label_power);

    tplot = new ofxUIWaveform( ofGetWidth() - 48, 70, plotBuffer, plotBuffer_size, -1.0, 1.0, "plot_time");
    mainCanvas->addWidgetDown(tplot);

    ///////////////////////////////////////////////////////////
    // ADD Volume SLIDER
    ///////////////////////////////////////////////////////////
    mainCanvas->addWidgetDown(new ofxUILabel("Volume : ", OFX_UI_FONT_MEDIUM));
    label_volume = new ofxUILabel( ofToString(roundSIL(myApp->volume,0)) + " %", OFX_UI_FONT_MEDIUM);
    mainCanvas->addWidgetRight(label_volume);

    slider_volume = new ofxUIImageSlider(ofGetWidth() - 48,dim*1.2, VOLUME_MIN, VOLUME_MAX, myApp->volume, "GUI/slider_volume/slider.png", "slider_volume");
    slider_volume->setLabelVisible(false);
    mainCanvas->addWidgetDown(slider_volume);

    ///////////////////////////////////////////////////////////
    // ADD Delay SLIDER
    ///////////////////////////////////////////////////////////
    mainCanvas->addWidgetDown(new ofxUILabel("Delay : ", OFX_UI_FONT_MEDIUM));
    label_delay= new ofxUILabel( ofToString(roundSIL(myApp->delay,0)) + " ms", OFX_UI_FONT_MEDIUM);
    mainCanvas->addWidgetRight(label_delay);
    
    float Delay_Min = (float) myApp->bufferSize/myApp->sampleRate;
    slider_delay = new ofxUIImageSlider(ofGetWidth() - 48, dim*1.2, Delay_Min*1000, DELAY_MAX*1000, myApp->delay, "GUI/slider_delay/slider.png", "slider_delay");
    slider_delay->setLabelVisible(false);
    mainCanvas->addWidgetDown(slider_delay);
    
    ///////////////////////////////////////////////////////////
    // ADD Pitch SLIDER
    ///////////////////////////////////////////////////////////
    mainCanvas->addWidgetDown(new ofxUILabel("Pitch : ", OFX_UI_FONT_MEDIUM));
    label_pitch = new ofxUILabel(ofToString(roundSIL(myApp->pitch,1)) + " semitones", OFX_UI_FONT_MEDIUM);
    mainCanvas->addWidgetRight(label_pitch);

    slider_pitch = new ofxUIImageSlider(ofGetWidth() - 48, dim*1.2, PITCH_MIN, PITCH_MAX, myApp->pitch, "GUI/slider_pitch/slider.png", "slider_pitch");
    slider_pitch->setLabelVisible(false);
    mainCanvas->addWidgetDown(slider_pitch);
    
    ///////////////////////////////////////////////////////////
    // ADD Type Button
    ///////////////////////////////////////////////////////////
    mainCanvas->addWidgetDown(new ofxUILabel("Method Used", OFX_UI_FONT_MEDIUM));
    mainCanvas->addWidgetDown(new ofxUILabel(" T:", OFX_UI_FONT_SMALL));
    
    btn_T = new ofxUIMultiImageToggle(2*dim, 2*dim, true, "GUI/btn_T_.png", "btn_T");
    btn_T->setLabelVisible(false);
    btn_T->setValue(true);
    mainCanvas->addWidgetRight(btn_T);

    mainCanvas->addWidgetRight(new ofxUILabel("F1:", OFX_UI_FONT_SMALL));

    btn_F = new ofxUIMultiImageToggle(2*dim, 2*dim, false, "GUI/btn_F_.png", "btn_F");
    btn_F->setLabelVisible(false);
    btn_F->setValue(false);
    mainCanvas->addWidgetRight(btn_F);

    mainCanvas->addWidgetRight(new ofxUILabel("F2:", OFX_UI_FONT_SMALL));
    
    btn_F2 = new ofxUIMultiImageToggle(2*dim, 2*dim, false, "GUI/btn_F_.png", "btn_F2");
    btn_F2->setLabelVisible(false);
    btn_F2->setValue(false);
    mainCanvas->addWidgetRight(btn_F2);

    mainCanvas->addWidgetRight(new ofxUILabel("N:", OFX_UI_FONT_SMALL));
    
    btn_N = new ofxUIMultiImageToggle(2*dim, 2*dim, false, "GUI/btn_F_.png", "btn_N");
    btn_N->setLabelVisible(false);
    btn_N->setValue(false);
    mainCanvas->addWidgetRight(btn_N);

    mainCanvas->addWidgetRight(new ofxUILabel("G:", OFX_UI_FONT_SMALL));

    btn_G = new ofxUIMultiImageToggle(2*dim, 2*dim, false, "GUI/btn_F_.png", "btn_G");
    btn_G->setLabelVisible(false);
    btn_G->setValue(false);
    mainCanvas->addWidgetRight(btn_G);
    
    ///////////////////////////////////////////////////////////
    // ADD PLAY/STOP Button
    ///////////////////////////////////////////////////////////
    
    btn_play = new ofxUIMultiImageToggle(ofGetWidth() - 48, dim*5, false, "GUI/btn_play_.png", "btn_play");
    btn_play->setLabelVisible(false);
    mainCanvas->addWidgetDown(btn_play);

    ofAddListener(mainCanvas->newGUIEvent,this,&mpGUI::guiEvent);

    mainCanvas->loadSettings(ofxiPhoneGetDocumentsDirectory() + "appGUISettings.xml");
    
    // Force these buttons to the following states    
    btn_play->setValue(false);
}


///////////////////////////////////////////////////////////
// Local Round Function
///////////////////////////////////////////////////////////
double mpGUI::roundSIL(double d, int pp) // pow() doesn't work with unsigned, so made this switch.
{
	return int(d * pow(10.0, pp) + .5) /  pow(10.0, pp);
}

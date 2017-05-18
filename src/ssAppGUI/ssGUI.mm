#include "ssGUI.h"
#include "ssApp.h"

extern ssApp * myApp;   // Global Pointer to mainApp

///////////////////////////////////////////////////////////
// class Constructor
///////////////////////////////////////////////////////////
ssGUI::ssGUI(int _plotBuffer_size) {
    
    if (myApp->dbgMode) cout << "creating ssGUI" << endl;
    
    TplotBuffer_size = 2*_plotBuffer_size;

    TplotBuffer = new float[TplotBuffer_size];    
    set2zero(TplotBuffer, TplotBuffer_size);
    
    //////////////////////////////////////////////////////////////////////////////////
    // ADD PIANO KEYBOARD - 1st Layer
    //////////////////////////////////////////////////////////////////////////////////
    
    piano_xi = 0;
//    piano_yi = PLOTS_Y;
    piano_yi = PLOTS_H;
    piano_kwidth = ofGetWidth();
    piano_kheight = 0.12*APP_HEIGHT;
    //piano_kheight = PLOTS_X*1.6;
//    piano_kheight = ofGetWidth();
//    piano_kwidth = PLOTS_X;

    piano = new ssPianoKeyboard(TplotBuffer_size);
    piano->init(piano_xi, piano_yi , piano_kwidth , piano_kheight);
    
    addTplotGUI();
    addCpanelGUI();
    
    updateCueBarPosition(0.0);

    // Create Pinch Object
    //touchDragObj = new ssDragGestureRecognizer();
}

///////////////////////////////////////////////////////////
// class Destructor
///////////////////////////////////////////////////////////
ssGUI::~ssGUI() {
    if (myApp->dbgMode) cout << "destroying ssGUI" << endl;
    
    tplotGUI->saveSettings("GUI/tplotGUISettings.xml");

    delete tplotGUI;
    delete cpanelGUICanvas4;
    delete cpanelGUICanvas4b;
    delete [] TplotBuffer;
    //delete touchDragObj;
    delete piano;
}

///////////////////////////////////////////////////////////
// ADD Time Domain GUI
///////////////////////////////////////////////////////////
void ssGUI::addTplotGUI()
{
    ///////////////////////////////////////////////////////////
    // ADD Time Domain Plot Canvas
    ///////////////////////////////////////////////////////////
    tplotGUI = new ofxUICanvas(PLOTS_X,PLOTS_Y,PLOTS_W + 4*PLOTS_DIM ,PLOTS_H+4*PLOTS_DIM);

    ///////////////////////////////////////////////////////////
    // ADD WAV RANGE SLIDER
    ///////////////////////////////////////////////////////////
    zoom_sliderH= new ofxUIRangeSlider("zoom_sliderH", 0.0, 1.0, 50.0, 100.0, PLOTS_W , PLOTS_DIM);
    zoom_sliderH->setLabelVisible(false);
   // zoom_sliderH->setVisible(false);
    tplotGUI->addWidgetRight(zoom_sliderH);
    
    ///////////////////////////////////////////////////////////
    // ADD WAVFORM PLOT
    ///////////////////////////////////////////////////////////
    tplot = new ofxUIWaveform(PLOTS_W, PLOT_T_H, TplotBuffer, TplotBuffer_size, -1.0, 1.0, "plot_time");
    tplotGUI->addWidgetDown(tplot);
    
////    zoom_sliderV = new ofxUIImageSlider(PLOT_T_H,PLOTS_DIM, 1.0, 5.0, tplotGain, "GUI/slider_.png", "zoom_sliderV");
//    zoom_sliderV= new ofxUISlider("zoom_sliderV", 1.0, 5.0, tplotGain, PLOTS_DIM,PLOT_T_H);
//    zoom_sliderV->setLabelVisible(false);
//    tplotGUI->addWidgetRight(zoom_sliderV);
    
    cout << "in addTplotGUI()" << endl;
    
    ///////////////////////////////////////////////////////////
    // ADD Frequency Plot
    ///////////////////////////////////////////////////////////
//FFT    fplot = new ofxUIWaveform(PLOTS_W, PLOT_F_H, myApp->fftBufferOUT, myApp->Nfft/2, 0.0f, -100.0f, "plot_frequency");
    //   tplotGUI->addWidgetDown(fplot);
    
    tplotGUI->setDrawBack(false);
    tplotGUI->setDrawPadding(false);
    
    ofAddListener(tplotGUI->newGUIEvent,this,&ssGUI::guiEvent);
}

///////////////////////////////////////////////////////////
// ADD Control Panel
///////////////////////////////////////////////////////////
void ssGUI::addCpanelGUI()
{
    ///////////////////////////////////////////////////////////
    // BOTTOM CANVAS WITH CONTROLS
    ///////////////////////////////////////////////////////////
    cpanelGUICanvas4 = new ofxUICanvas(CPANEL_X + PLOTS_X                  , PLOTS_Y + 204 , CPANEL_DIM*9   , CPANEL_H);
    cpanelGUICanvas4b = new ofxUICanvas(CPANEL_X + PLOTS_X + CPANEL_DIM*3.3, PLOTS_Y + 204 , CPANEL_DIM*9   , CPANEL_H);
    cpanelGUICanvas5 = new ofxUICanvas(CPANEL_X + PLOTS_X + CPANEL_DIM*5  , PLOTS_Y + 204 , CPANEL_DIM*19   , CPANEL_H);

    cpanelGUICanvas4->addWidgetRight(new ofxUILabel("Midi: ", OFX_UI_FONT_LARGE));

    instName = new ofxUILabel("Piano", OFX_UI_FONT_LARGE);
    cpanelGUICanvas4->addWidgetRight(instName);
    
    timeStr = new ofxUILabel("", OFX_UI_FONT_LARGE);
    cpanelGUICanvas5->addWidgetRight(timeStr);
    cpanelGUICanvas4->setDrawBack(false);
    cpanelGUICanvas4->setDrawPadding(false);
    cpanelGUICanvas4b->setDrawBack(false);
    cpanelGUICanvas4b->setDrawPadding(false);
    cpanelGUICanvas5->setDrawBack(false);
    cpanelGUICanvas5->setDrawPadding(false);
}

///////////////////////////////////////////////////////////
// Update CueBar
///////////////////////////////////////////////////////////
void ssGUI::updateCueBarPosition(float screenPercent){
    
    int cueBarStartPixelPosition = PLOTS_X + OFX_UI_GLOBAL_WIDGET_SPACING;
    int aux = (float) cueBarStartPixelPosition + PLOTS_W*((float)screenPercent);
    cueBar_pos = aux;
}

void ssGUI::updatePlotsData(float valueLow, float valueHigh){
    
    float tdiff = abs(valueHigh - valueLow);

    // Adjust to Min and Max Zoom Values
    if (tdiff > ZOOM_MAX_TIME ) {
        tdiff = ZOOM_MAX_TIME;
        if (zoom_sliderH->hitHigh==true)
            valueLow = valueHigh - ZOOM_MAX_TIME;
        }
    
    if (tdiff < ZOOM_MIN_TIME ) {
        tdiff = ZOOM_MIN_TIME;
        if (zoom_sliderH->hitHigh==true)
            valueLow = valueHigh - ZOOM_MIN_TIME;
        }
    
    
    int sample_position = convSec2Samp(valueLow);
    int Nsamples = convSec2Samp(tdiff);
    
    // Readjust Max and min value of Slider
    zoom_sliderH->setMaxAndMin(convSamp2Sec(myApp->tmpFile->getSize()), 0.0);
    zoom_sliderH->setValueLow(convSamp2Sec(sample_position));
    zoom_sliderH->setValueHigh(convSamp2Sec(sample_position) + convSamp2Sec(Nsamples));
    
    // UPDATE TIME PLOT Data
    updateTplotBuffer(myApp->tmpFile, sample_position, Nsamples);
    
    // UPDATE PITCH PLOT Visible Data
    piano->pitchBuffer_pos  = convSamp2Fram(sample_position);
    piano->pitchBuffer_size = convSamp2Fram(Nsamples);
    
    // UPDATE PLAY POSITION
    myApp->appStateMachine->FRAME.Start = convSamp2Fram(sample_position);
    myApp->appStateMachine->FRAME.Stop  = convSamp2Fram(sample_position + Nsamples);
    
    // REPHRESH GL DATA
//    rephreshGLData();
}

////////////////////////////////////////////////////////
// Updates the Tplot Buffer using the MIN/MAX Metric
///////////////////////////////////////////////////////////
void ssGUI::updateTplotBuffer(TmpFile *tmpFile,int posicao, int tamanho)
{
    float * aux = new float[tamanho];
    
    tmpFile->readBlock(aux, posicao, tamanho);
    
    int step = tamanho/(TplotBuffer_size/2);
    int residue = tamanho%(TplotBuffer_size/2);
    
    int pos=0;
    
    for(int i=0; i<tamanho-residue; i=i+step)
    {
        float _min = 0.0;
        float _max = 0.0;
        int   min_pos = 0;
        int   max_pos = 0;
        
        for (int j=0;j<step;j++)
        {
            if (aux[i+j] < _min) { _min = aux[i+j]; min_pos = i*step + j; };
            if (aux[i+j] > _max) { _max = aux[i+j]; max_pos = i*step + j; };
        }

        // Also Update Tplot Zoom in Y axis
        TplotBuffer[pos++] = _min*tplotGain;
        TplotBuffer[pos++] = _max*tplotGain;
    }

    delete[] aux; // Free memory to prevent disastrous memory allocation
}

//void ssGUI::rephreshGLData(void){
//    
//    piano->rephreshGLPianoRollData();
//    if (myApp->appWorkingMode==PLAY_MODE) {
////        piano->rephreshGLPitchNotesData();
//        piano->rephreshGLPitchPlotData();
//        }
//}


///////////////////////////////////////////////////////////
// ssGUI::moveX_tplot
///////////////////////////////////////////////////////////
void ssGUI :: moveX_tplot (float diff_x){
    
    if (myApp->dbgMode) cout << "in moveX" << endl;
    
    float dt = zoom_sliderH->getScaledValueHigh() - zoom_sliderH->getScaledValueLow();
    
    float diff_x_sec = abs((dt * diff_x)/PLOTS_W); // Convert pixel movement to seconds
    
    if (diff_x<0)                          // Update X position
        {
        zoom_sliderH->setValueLow(zoom_sliderH->getScaledValueLow()   + diff_x_sec);
        zoom_sliderH->setValueHigh(zoom_sliderH->getScaledValueHigh() + diff_x_sec);
        }
    else
        {
        zoom_sliderH->setValueLow(zoom_sliderH->getScaledValueLow()   - diff_x_sec);
        zoom_sliderH->setValueHigh(zoom_sliderH->getScaledValueHigh() - diff_x_sec);
        }
    
    updatePlotsData(zoom_sliderH->getScaledValueLow(),zoom_sliderH->getScaledValueHigh());
}

///////////////////////////////////////////////////////////
// ssTouch::zoomX
///////////////////////////////////////////////////////////
void ssGUI :: zoomX_tplot_old (float dist_x){
    
    if (myApp->dbgMode) cout << "in zoomX" << endl;
    
    float zoomPercent = 0.035;
    // Zoom Step is a percentage of actual File Selection
    zoomStep = abs(zoom_sliderH->getScaledValueHigh() - zoom_sliderH->getScaledValueLow())*zoomPercent;
    
    if (myApp->pitchMeterWrapper->midiNotes->freqNoteData.size() != 0) { // Is there data to pinch?
        
        if (dist_x - dist_x_old > 0.0) { // Zoom IN - Time
            if (myApp->dbgMode) cout << "distX = " << dist_x << " | dist_x_old=" << dist_x_old << " | zoomStep=" << zoomStep;
            zoom_sliderH->setValueLow(zoom_sliderH->getScaledValueLow()   + zoomStep);
            zoom_sliderH->setValueHigh(zoom_sliderH->getScaledValueHigh()   - zoomStep);
            }
        else if (dist_x - dist_x_old < 0.0) { // Zoom Out - Time
            zoom_sliderH->setValueLow(zoom_sliderH->getScaledValueLow()   - zoomStep);
            zoom_sliderH->setValueHigh(zoom_sliderH->getScaledValueHigh() + zoomStep);
            }
        
        dist_x_old = dist_x;
        
        // Update DATA IN TPLOT and PPLOT
        updatePlotsData(zoom_sliderH->getScaledValueLow(),zoom_sliderH->getScaledValueHigh());
    }
}

///////////////////////////////////////////////////////////
// ssTouch::zoomX
///////////////////////////////////////////////////////////
void ssGUI :: zoomX_tplot (void){
    
    if (myApp->dbgMode) cout << "in zoomX" << endl;
    
    ofPinchGestureRecognizer * pinchObj = myApp->recogPintch;
    
    zoomStep = abs(zoom_sliderH->getScaledValueHigh() - zoom_sliderH->getScaledValueLow())*0.035;

    if (myApp->pitchMeterWrapper->midiNotes->freqNoteData.size() != 0) { // Is there data to pinch?
        
        if (pinchObj->scale > 1.0) { // Zoom IN - Time
            zoom_sliderH->setValueLow(zoom_sliderH->getScaledValueLow()   + zoomStep);
            zoom_sliderH->setValueHigh(zoom_sliderH->getScaledValueHigh()   - zoomStep);
        }
        else if (pinchObj->scale < 1.0) { // Zoom Out - Time
            zoom_sliderH->setValueLow(zoom_sliderH->getScaledValueLow()   - zoomStep);
            zoom_sliderH->setValueHigh(zoom_sliderH->getScaledValueHigh() + zoomStep);
        }

        // Update DATA IN TPLOT and PPLOT
        updatePlotsData(zoom_sliderH->getScaledValueLow(),zoom_sliderH->getScaledValueHigh());
    }
}

///////////////////////////////////////////////////////////
// GUI Event CallBack and APP STATE UPDATE
///////////////////////////////////////////////////////////
void ssGUI::guiEvent(ofxUIEventArgs &e) {
    string name = e.widget->getName();
    int kind = e.widget->getKind();
    int state = e.widget->getID();
    
    if (myApp->dbgMode) cout << "got event from: " << name << endl;
    
    ///////////////////////////////////////////////////////////
    // Change Zoom Slot
    ///////////////////////////////////////////////////////////
    if (name=="zoom_sliderH"){
        updatePlotsData(zoom_sliderH->getScaledValueLow(),zoom_sliderH->getScaledValueHigh());
        }
    
    ///////////////////////////////////////////////////////////
    // Change Zoom Slot
    ///////////////////////////////////////////////////////////
//    if (name=="zoom_sliderV"){
//        tplotGain = zoom_sliderV->getScaledValue();
//        updatePlotsData(zoom_sliderH->getScaledValueLow(), zoom_sliderH->getScaledValueHigh());
//    }

}


///////////////////////////////////////////////////////////
// ssGUI Draw Method
///////////////////////////////////////////////////////////
void ssGUI::draw(){
    //if (myApp->dbgMode) cout << "in ssGUI draw method------------------------------------------------------------" << endl;

}

void ssGUI::listDocumentsDirectory(void){
    // List Documents Directory Files
    dir = new ofDirectory(ofxiPhoneGetDocumentsDirectory());
    dir->allowExt("wav");
    dir->sort();
    dir->listDir();
    for (int i = 0; i < dir->numFiles(); i++){
        if (myApp->dbgMode) cout << "File: " << dir->getPath(i) << endl;
    }
}

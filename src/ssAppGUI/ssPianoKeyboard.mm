#include "ssPianoKeyboard.h"
#include "ssApp.h"

extern ssApp * myApp;


///////////////////////////////////////////////////////////
// ssPianoKeyboard Constructor
///////////////////////////////////////////////////////////
ssPianoKeyboard::ssPianoKeyboard(int _fileBuffer_size){
    
    
    myApp->dbgMode = DEBUG; // ANDRE comm (turn debugging on)
    
    if (myApp->dbgMode) cout << "creating ssPianoKeyboard" << endl;
    
//    myfont.loadFont("fonts/C&C Red Alert [INET].ttf", 9);
//    myfont2.loadFont("fonts/C&C Red Alert [INET].ttf", 17);
//    myfont3.loadFont("fonts/fontawesome-webfont.ttf", 9);
    
    myfont.loadFont("fonts/C&C Red Alert [INET].ttf", 9);
    myfont2.loadFont("fonts/C&C Red Alert [INET].ttf", 17);
    myfont3.loadFont("fonts/fontawesome-webfont.ttf", 9);

    
    fileBuffer_size = _fileBuffer_size;
    fileBuffer   = new float[fileBuffer_size];
    set2zero(fileBuffer, fileBuffer_size);
    
    img_note.loadImage("images/fundo2_unit_transp.png");
    img.loadImage("images/UI_view1.png");
    
    // Posicoes relativas das teclas brancas
    for (int i = 0; i < 12; ++i) {
        switch (i) {
            case 0:     xpos_percent[i] = (float) 0*1/7; break;
            case 2:     xpos_percent[i] = (float) 1*1/7; break;
            case 4:     xpos_percent[i] = (float) 2*1/7; break;
            case 5:     xpos_percent[i] = (float) 3*1/7; break;
            case 7:     xpos_percent[i] = (float) 4*1/7; break;
            case 9:     xpos_percent[i] = (float) 5*1/7; break;
            case 11:    xpos_percent[i] = (float) 6*1/7; break;
                break;
        }
    };
    
    
    // Posicoes relativas das teclas pretas
    for (int i = 0; i < 12; ++i) {
        switch (i) {
            case 1:     xpos_percent[i] = (float) 1*1/12; break;
            case 3:     xpos_percent[i] = (float) 3*1/12; break;
            case 6:     xpos_percent[i] = (float) 6*1/12; break;
            case 8:     xpos_percent[i] = (float) 8*1/12; break;
            case 10:    xpos_percent[i] = (float) 10*1/12; break;
                break;
        }
    };
    
    for (int i = 0; i < 12; ++i)
        xpos_BackgroundPercent[i] = (float)i*1/12;
};
///////////////////////////////////////////////////////////
// ssPianoKeyboard Destructor
///////////////////////////////////////////////////////////
ssPianoKeyboard::~ssPianoKeyboard(){
    if (myApp->dbgMode) cout << "destroying ssPianoKeyboard" << endl;
    
    delete [] fileBuffer;

};

///////////////////////////////////////////////////////////
// Initialization
///////////////////////////////////////////////////////////
void ssPianoKeyboard::init(float _xi, float _yi, float _w,float _h){
    
    if (myApp->dbgMode) cout << "in ssPianoKeyboard::init" << endl;
    
    xi = _xi;
    yi = _yi;
//    xi = 400;
//    yi = 800;
    Wkeyboard = _w;
    Hkeyboard = _h;
    
    cout << "Wkeyboard: " << Wkeyboard << "; Hkeyboard: " << Hkeyboard << endl;
    
    // Generate MidiScaleVector with all 128 midi notes
    int octave;
    int Noctaves = (LAST_KEY-FIRST_KEY+1)/12;
    
    for (int i = FIRST_KEY; i <=LAST_KEY; ++i)
    {
        MidiKeyInfo midiNote;
        
        octave = (i-FIRST_KEY)/12;
        
        midiNote.code = i;
        midiNote.octave = octave;
        midiNote.keyPosPercent = (float) (xpos_percent[i%12]/(float)Noctaves + (float)octave/((float)Noctaves));
        midiNote.freq = midiNote.midi2freq(i);
        midiNote.keyPosBackgroundPercent = (float) (xpos_BackgroundPercent[i%12]/(float)Noctaves + (float)octave/((float)Noctaves));
        
        switch(i%12)
        {
            case 0:  midiNote.label = "C" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/(NKeys*7/12);
                midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // C
            case 2:  midiNote.label = "D" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/(NKeys*7/12);
                midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // D
            case 4:  midiNote.label = "E" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/(NKeys*7/12);
                midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // E
            case 5:  midiNote.label = "F" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/(NKeys*7/12);
                midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // F
            case 7:  midiNote.label = "G" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/(NKeys*7/12);
                midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // G
            case 9:  midiNote.label = "A" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/(NKeys*7/12);
                midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // A
            case 11: midiNote.label = "B" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/(NKeys*7/12);
                midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // B
                
            case 1:  midiNote.label = "C#" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/NKeys;
                midiNote.keyHeightPercent = 0.6; midiNote.keyColor = BLACK_COLOR; break;    // C#
            case 3:  midiNote.label = "D#" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/NKeys;
                midiNote.keyHeightPercent = 0.6; midiNote.keyColor = BLACK_COLOR; break;    // D#
            case 6:  midiNote.label = "F#" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/NKeys;
                midiNote.keyHeightPercent = 0.6; midiNote.keyColor = BLACK_COLOR; break;    // F#
            case 8:  midiNote.label = "G#" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/NKeys;
                midiNote.keyHeightPercent = 0.6; midiNote.keyColor = BLACK_COLOR; break;    // G#
            case 10: midiNote.label = "A#" + ofToString(octave + 1 ); midiNote.keyWidthPercent = (float) 1/NKeys;
                midiNote.keyHeightPercent = 0.6; midiNote.keyColor = BLACK_COLOR; break;    // A#
        }
        
        midiScale.push_back(midiNote);
        
        if (myApp->dbgMode) cout <<"MidiScale Size = " << midiScale.size() << " | Code = " << midiNote.code << " | Note = "<< midiNote.label << " | Freq = "<< (float) midiNote.freq << " | Oct =" << octave << " | Pos = " << midiNote.keyPosPercent << endl;
    }
    
    // Add Keyboard
    addKeyboard();

}
///////////////////////////////////////////////////////////
// addPianoKeyboard
///////////////////////////////////////////////////////////
void ssPianoKeyboard::addKeyboard(void)
{
    if (myApp->dbgMode) cout << "in ssPianoKeyboard::addKeyboard" << endl;
    
    ///////////////////////////////////////////////////////////
    // Generate Keyboard Vector with all 128 midi notes
    ///////////////////////////////////////////////////////////
    float keypos,keywidth,keyheight;
    
    int   keycolor;
    
    for (int i=0;i<midiScale.size(); i++)
    {
//        keywidth = roundf(midiScale[i].keyWidthPercent*Wkeyboard);
//        keyheight = roundf(midiScale[i].keyHeightPercent*Hkeyboard);
//        keycolor = midiScale[i].keyColor;
//        keypos = roundf(Wkeyboard - midiScale[i].keyPosPercent*Wkeyboard - keywidth);
//        ssPianoKey key;
//        key.disableAppEvents();
//        // key.enableAppEvents();				// call this if object should update/draw automatically	(default)
//        key.enableMouseEvents();
//        key.set(xi , yi + keypos , keyheight , keywidth);
//        key.midiInfo = midiScale[i];
//        keyboard[i] = key;
//        keyboard[i].setup(); // ANDRE
        
        keywidth = roundf(midiScale[i].keyWidthPercent*Wkeyboard);
        keyheight = roundf(midiScale[i].keyHeightPercent*Hkeyboard);
        keycolor = midiScale[i].keyColor;
//        keypos = roundf(Wkeyboard - midiScale[i].keyPosPercent*Wkeyboard - keywidth);
        keypos = roundf(midiScale[i].keyPosPercent*Wkeyboard);  // FAZ COM QUE AS TECLAS SEJAM ORDENADAS DA MAIS GRAVE PARA A MAIS AGUDA
        ssPianoKey key;
        key.disableAppEvents();
        key.enableMouseEvents();
        key.set(xi + keypos, yi , keywidth , keyheight);
        key.midiInfo = midiScale[i];
        keyboard[i] = key;
        keyboard[i].setup(); // ANDRE

        
        
        cout << "Keywidth: " << keywidth << ";   Keyheight: " << keyheight << ";   Keypos: " << keypos << endl;
    }
}

///////////////////////////////////////////////////////////
// Set New Keyboard Position
///////////////////////////////////////////////////////////
void ssPianoKeyboard::setKeyboardPosition(float _xi,float _yi){
    
    if (myApp->dbgMode) cout << "in ssPianoKeyboard::setKeyboardPosition" << endl;
    
    xi = _xi;
    yi = _yi;
    
    float keypos,keywidth,keyheight,keyBackPos;
    
    for (int i=0;i<midiScale.size();i++) {
        keywidth = roundf(midiScale[i].keyWidthPercent*Wkeyboard);
        keyheight = roundf(midiScale[i].keyHeightPercent*Hkeyboard);
        keyBackPos = roundf(midiScale[i].keyPosBackgroundPercent*Wkeyboard);
        keypos = roundf(Wkeyboard - midiScale[i].keyPosPercent*Wkeyboard - keywidth);
        keyboard[i].set(_xi , _yi + keypos , keyheight , keywidth);
    }
    
    myApp->ssGui->rephreshGLData();
}

///////////////////////////////////////////////////////////
// Set New Keyboard Position Y
///////////////////////////////////////////////////////////
void ssPianoKeyboard::setKeyboardPositionY(float _yi){
    
    setKeyboardPosition(xi,_yi);
}

////////////////////////////////////////////////////////
// Copy data in plotBuffer 2 fileBuffer
///////////////////////////////////////////////////////////
void ssPianoKeyboard::copyData2FileBuffer(void) {
    
    if (myApp->dbgMode) cout << "in ssPianoKeyboard::copyData2FileBuffer" << endl;
    
    // UPDATE TplotBuffer with all file data
    myApp->ssGui->updateTplotBuffer(myApp->tmpFile, 0, myApp->tmpFile->getSize());

    // Automatic scaling
    float _max = maxx(myApp->ssGui->TplotBuffer, fileBuffer_size);
    float _min = minn(myApp->ssGui->TplotBuffer, fileBuffer_size);
    
    float abs_max;
    
    if (abs(_max) > abs(_min))
        abs_max = abs(_max);
    else
        abs_max = abs(_min);
    
    float gain = (1.0 - abs_max)+1.0;
    
    for (int i=0 ; i < fileBuffer_size ; i++)
        {
        fileBuffer[i] = myApp->ssGui->TplotBuffer[i]*gain;
        }
    
    rephreshGLFileBufferData();
}

///////////////////////////////////////////////////////////
// pitch2pixel -  converts pitch to pixels
///////////////////////////////////////////////////////////
float ssPianoKeyboard::frame2pixelX(float pos, float _begin, float _end){
    
    return ofMap(pos, _begin, _end, 0, PLOTS_W);
}

float ssPianoKeyboard::midi2pixelY(float midi){
    
    return roundSIL(ofMap(midi, FIRST_KEY, LAST_KEY, Wkeyboard, 0) - Wkeyboard*1/NKeys/2,0);
}

// ANDRE
float ssPianoKeyboard::midi2pixelX(float midi){
    
//    cout << "midi: " << midi << endl << "return: " << roundSIL(ofMap(midi, FIRST_KEY, LAST_KEY, 0, Wkeyboard) - Wkeyboard*1/NKeys/2,0) << endl;
    
    midi = midi - 12*(myApp->sampleRate/22050 - 1); // dado o sample rate ter sido alterado de 22050 para 44100, o midi resultante era calculado uma oitava acima
    return roundSIL(ofMap(midi, FIRST_KEY, LAST_KEY, 0, Wkeyboard) - Wkeyboard*1/NKeys/2,0);
}

float ssPianoKeyboard::power2pixelY(float power) {
    
    return roundSIL(ofMap(power, MIN_POWER, MAX_POWER, MAINPLOT_X + MAINPLOT_H, MAINPLOT_X), 0);
}

///////////////////////////////////////////////////////////
// ssPianoKeyboard::moveY_pitchPlot
///////////////////////////////////////////////////////////
void ssPianoKeyboard :: moveY_pplot (float diff_y){
    
    if (myApp->dbgMode) cout << "in moveY" << endl;
    
    int   newPos_y = diff_y + yi;
    
    if (newPos_y < PLOTS_H && newPos_y > CPANEL_Y - Wkeyboard) {
        setKeyboardPositionY(newPos_y); // Update Y position
    }
}

///////////////////////////////////////////////////////////
// ssTouch::zoomY
///////////////////////////////////////////////////////////
//void ssPianoKeyboard :: zoomY_pplot_old (float dist_y){
//    
//    if (myApp->dbgMode) cout << "in zoomY" << endl;
//        
//    float zoomPercent = 0.10;
//    
//    float t1 = myApp->ssGui->touchDragObj->touch1.y;
//    float t2 = myApp->ssGui->touchDragObj->touch2.y;
//    
//    float touchMin = t1 < t2 ? t1 : t2;
//    
//    float keyboardGravityCenterFactor = ofMap(touchMin + dist_y/2 , yi, yi+Wkeyboard, 0.0, 1.0);
//    //////////////////////////////////////////
//    // ZOOM IN Y
//    //////////////////////////////////////////
//    if (dist_y - dist_y_old > 0.0) {        // estica
//        Wkeyboard = roundSIL((1+zoomPercent)*Wkeyboard,0);
//        if (Wkeyboard>2*ofGetWidth()){
//            Wkeyboard = 2*ofGetWidth();
//            setKeyboardPositionY(yi);
//        }
//        else
//            setKeyboardPositionY(yi - roundSIL(zoomPercent*Wkeyboard,0)*keyboardGravityCenterFactor);
//    }
//    //////////////////////////////////////////
//    // ZOOM OUT Y
//    //////////////////////////////////////////
//    else if (dist_y - dist_y_old < 0.0) {   // encolhe
//        
//        Wkeyboard = roundSIL((1-zoomPercent)*Wkeyboard,0);
//        
//        if (Wkeyboard<ofGetWidth()){
//            Wkeyboard = ofGetWidth();
//            setKeyboardPositionY(yi);
//        }
//        else
//        {
//            //TOP:      yi = 225 (zoom min)  -> yi = 225 (zoom Max)
//            if (yi>220) {
//                yi=220;
//                setKeyboardPositionY(yi+roundSIL(zoomPercent*Wkeyboard,0)*keyboardGravityCenterFactor);
//            }
//            //BOTTOM:   yi = -355 (zoom min) -> yi = -1379 (zoom Max)
//            else if (yi + Wkeyboard < CPANEL_Y) {
//                yi = CPANEL_Y - Wkeyboard;
//                setKeyboardPositionY(yi);
//            }
//            else
//                setKeyboardPositionY(yi + roundSIL(zoomPercent*Wkeyboard,0)*keyboardGravityCenterFactor);
//        }
//    }
//    dist_y_old = dist_y;
//}
//
/////////////////////////////////////////////////////////////
//// ssTouch::zoomY
/////////////////////////////////////////////////////////////
//void ssPianoKeyboard :: zoomY_pplot (void){
//    
//    if (myApp->dbgMode) cout << "in zoomY" << endl;
//    
//    ofPinchGestureRecognizer * pinchObj = myApp->recogPintch;
//    
//    Wkeyboard = roundSIL(pinchObj->scale*Wkeyboard,0);
//
//    float dy = pinchObj->touchMinY + pinchObj->distY/2;
//    
//    float keyboardGravityCenterFactor = ofMap( dy , yi , yi + Wkeyboard, 0.0, 1.0);
//    
//   // cout << "keyboardGravityCenterFactor >>>>>>>>>>>>>>>>>>>> " << keyboardGravityCenterFactor << endl;
//   // cout << "dy >>>>>>>>>>>>>>>>>>>>  " << dy << endl;
//    
//    if (Wkeyboard>2*ofGetWidth()){
//        Wkeyboard = 2*ofGetWidth();
//        setKeyboardPositionY(yi);
//    }
//    else if (Wkeyboard<ofGetWidth()){
//        Wkeyboard = ofGetWidth();
//        setKeyboardPositionY(yi);
//        }
//    else {
//        setKeyboardPositionY(yi + (1.0-pinchObj->scale)*keyboardGravityCenterFactor*Wkeyboard);
//        }
//}

///////////////////////////////////////////////////////////
// ssPianoKeyboard Update Method
///////////////////////////////////////////////////////////
void ssPianoKeyboard::update(){
    // if (myApp->dbgMode) cout<< "in Update Method of ssPianoKeyboard" << endl;
    
}

///////////////////////////////////////////////////////////
// ssPianoKeyboard Draw Method
///////////////////////////////////////////////////////////
void ssPianoKeyboard::draw(){
    //if (myApp->dbgMode) cout<< "in Draw Method of ssPianoKeyboard" << endl;
    
//    float xiPitchMagnitudePlot = OFX_UI_GLOBAL_WIDGET_SPACING;
//    float widthPitchMagnitudePlot = APP_WIDTH;
    
    float yiPitchMagnitudePlot = MAINPLOT_X;
    float lengthPitchMagnitudePlot = MAINPLOT_H;


    
    //////////////////////////////////////////
    // Draw Keyboard + PIANO ROLL
    //////////////////////////////////////////////////      Alone                   Al
    setPlotsColorBack();
    drawKeyboardAndPianoRoll_Optimized(yiPitchMagnitudePlot,lengthPitchMagnitudePlot);       // Decrease to 15fps
    
//    if (myApp->fileIsLoaded) {
//        if (myApp->appWorkingMode==PLAY_MODE) {
//            //////////////////////////////////////////////////
//            // Draw Pitch Notes in Piano Roll
//            //////////////////////////////////////////////////
//            drawPitchNotes_Optimized();
//            //OLD__drawPitchNotes();
//            //////////////////////////////////////////////////
//            // Draw Pitch Plot in Piano Roll
//            //////////////////////////////////////////////////
//            drawPitchPlot_Optimized();                 // decrease to 10fps     |   6.0  fps
//            //OLD__drawPitchPlot();
//            }
//        }
//    else if (myApp->appWorkingMode==RECORD_MODE) {
        //drawPitchPlot2();
//    }
    
    if (myApp->appWorkingMode==RECORD_MODE) {
        //ANDRE PLOT
        drawPitchPowerPlot();
    }
    else if (myApp->appWorkingMode == PLAY_MODE)
        drawFullPitchPowerPlot();

    
    //////////////////////////////////////////////////
    // Draw Top Background
    //////////////////////////////////////////////////
    setPlotsColorBack();
    ofFill();
//    img.draw(-4, 0,APP_WIDTH+4,PLOTS_H);
    ofRect(-4, 0,APP_WIDTH+4,PLOTS_H);

    //////////////////////////////////////////////////
    // Draw vertical Time Lines
    //////////////////////////////////////////////////
    drawVerticalTimeLines();                 // decrease to 15fps     |    6.0 fps
    
    
    //////////////////////////////////////////////////
    // Draw vertical Time Lines
    //////////////////////////////////////////////////
    if (myApp->fileIsLoaded)
        drawFileBuffer_Optimized();
    
    
    //////////////////////////////////////////////////
    // Draw cueBar
    //////////////////////////////////////////////////
//    if (myApp->ssGui->cueBar_pos>PLOTS_X && myApp->ssGui->cueBar_pos<PLOTS_X+PLOTS_W){
//        setBarColor();
//        ofSetLineWidth(2.0);
//        ofLine(myApp->ssGui->cueBar_pos   , APP_HEIGHT*0.14 , myApp->ssGui->cueBar_pos   , APP_HEIGHT);
//        ofSetLineWidth(1.0);
//        }
    
    //////////////////////////////////////////////////
    // Draw Bottom Background
    //////////////////////////////////////////////////
 //   setCPanelColorBack();
 //   ofFill();
 //   img.draw(-4, CPANEL_Y,APP_WIDTH+4,PLOTS_H);
    
    float durationInSec;
    
    if (myApp->appWorkingMode==PLAY_MODE)
        durationInSec = convFram2Sec(myApp->appStateMachine->FRAME.Playing);
    else
        durationInSec = convFram2Sec(myApp->appStateMachine->FRAME.Recording);

    string strTimeBar = formatTimeMMSS(durationInSec);
    
//    string strTimeDur = formatTimeMMSS(myApp->ssGui->zoom_sliderH->getScaledValueHigh()-myApp->ssGui->zoom_sliderH->getScaledValueLow());
    
//    myApp->ssGui->timeStr->setLabel("Cursor > " + strTimeBar + "   Duration > " + strTimeDur);
    
    ofPopStyle();

}

///////////////////////////////////////////////////////////
// ssPianoKeyboard Rephresh Piano Bar GL data
///////////////////////////////////////////////////////////
void ssPianoKeyboard::initGLPianoRollData(){
    // if (myApp->dbgMode) cout<< "in Update Method of ssPianoKeyboard" << endl;
    
//    float xiPitchPlot = PLOTS_X + OFX_UI_GLOBAL_WIDGET_SPACING;
//    float widthPitchPlot = PLOTS_W;
    
    float yiPitchMagnitudePlot = MAINPLOT_X;
    float lengthPitchMagnitudePlot = MAINPLOT_H;
    
    float Wkey = Wkeyboard*1/(NKeys+1);
    
    for ( int i = 0; i <= LAST_KEY - FIRST_KEY; i++) {
    
        //float xiPitchMagnitudePlot = xi + Wkeyboard - (i+1)*Wkey;
        float xiPitchMagnitudePlot = xi + (i)*Wkey;
        
        ofVec2f v;
        ofFloatColor c;
        
        // Create Color Array
        if (midiScale[i].keyColor == WHITE_COLOR){
            c.r = 0.16; c.g = 0.20; c.b = 0.23;
            cout << "white" << endl;
        }
        else{
            c.r = 0.13; c.g = 0.16; c.b = 0.18;
            cout << "black" << endl;
        }
        
        c.a = 0.65;
        
        c_pr.push_back(c);
        c_pr.push_back(c);
        c_pr.push_back(c);
        c_pr.push_back(c);
        
//        cout << midiScale[i].keyColor << endl;
        
        // Create Vertices Array
        
//        v.x = xiPitchMagnitudePlot;                   v.y = yiPitchMagnitudePlot;         // x , y
//        v_pr.push_back(v);
//        v.x = xiPitchMagnitudePlot;                   v.y = yiPitchMagnitudePlot + lengthPitchMagnitudePlot;  // x , y
//        v_pr.push_back(v);
//        v.x = xiPitchMagnitudePlot + Wkey;            v.y = yiPitchMagnitudePlot;         // x , y
//        v_pr.push_back(v);
//        v.x = xiPitchMagnitudePlot + Wkey;            v.y = yiPitchMagnitudePlot + lengthPitchMagnitudePlot;  // x , y
//        v_pr.push_back(v);

        v.x = xiPitchMagnitudePlot + Wkey;            v.y = yiPitchMagnitudePlot + lengthPitchMagnitudePlot;  // x , y
        v_pr.push_back(v);
        v.x = xiPitchMagnitudePlot + Wkey;            v.y = yiPitchMagnitudePlot;         // x , y
        v_pr.push_back(v);
        v.x = xiPitchMagnitudePlot;                   v.y = yiPitchMagnitudePlot + lengthPitchMagnitudePlot;  // x , y
        v_pr.push_back(v);
        v.x = xiPitchMagnitudePlot;                   v.y = yiPitchMagnitudePlot;         // x , y
        v_pr.push_back(v);
    }
    
    VBO_pr_size = v_pr.size();
    
    // Create Index Array
    for (int j=0;j<VBO_pr_size;j++)
        ind_pr.push_back(j);
    
    VBO_pianoRoll.setVertexData(&v_pr[0], VBO_pr_size, GL_DYNAMIC_DRAW );
    VBO_pianoRoll.setColorData (&c_pr[0], VBO_pr_size, GL_DYNAMIC_DRAW );
    VBO_pianoRoll.setIndexData (&ind_pr[0], VBO_pr_size, GL_DYNAMIC_DRAW );
    glEnable(GL_DEPTH_TEST);
    
    // Free Memory
    v_pr.clear();
    v_pr.clear();
    ind_pr.clear();

    
    ////////////////////////////////////////////
    // Prepare Piano Roll Draw
    ////////////////////////////////////////////
    // Create Vertex Array
//    for ( int i = 0; i <= LAST_KEY - FIRST_KEY; i++) {
//        
//        float yiPitchPlot = yi + Wkeyboard - (i+1)*Wkey;
//        
//        ofVec2f v;
//        ofFloatColor c;
//        
//        // Create Color Array
//        if (midiScale[i].keyColor == WHITE_COLOR){
//            c.r = 0.16; c.g = 0.20; c.b = 0.23;
//        }
//        else{
//            c.r = 0.13; c.g = 0.16; c.b = 0.18;
//        }
//        
//        c.a = 0.65;
//        
//        c_pr.push_back(c);
//        c_pr.push_back(c);
//        c_pr.push_back(c);
//        c_pr.push_back(c);
//        
//        // Create Vertices Array
//        
//        v.x = xiPitchPlot;                   v.y = yiPitchPlot;         // x , y
//        v_pr.push_back(v);
//        v.x = xiPitchPlot + widthPitchPlot;  v.y = yiPitchPlot;         // x , y
//        v_pr.push_back(v);
//        v.x = xiPitchPlot;                   v.y = yiPitchPlot + Wkey;  // x , y
//        v_pr.push_back(v);
//        v.x = xiPitchPlot + widthPitchPlot;  v.y = yiPitchPlot + Wkey;  // x , y
//        v_pr.push_back(v);
//    }
//    
//    VBO_pr_size = v_pr.size();
//    
//    // Create Index Array
//    for (int j=0;j<VBO_pr_size;j++)
//        ind_pr.push_back(j);
//    
//    VBO_pianoRoll.setVertexData(&v_pr[0], VBO_pr_size, GL_DYNAMIC_DRAW );
//    VBO_pianoRoll.setColorData (&c_pr[0], VBO_pr_size, GL_DYNAMIC_DRAW );
//    VBO_pianoRoll.setIndexData (&ind_pr[0], VBO_pr_size, GL_DYNAMIC_DRAW );
//    glEnable(GL_DEPTH_TEST);
//    
//    // Free Memory
//    v_pr.clear();
//    v_pr.clear();
//    ind_pr.clear();
}

///////////////////////////////////////////////////////////
// ssPianoKeyboard Init Piano Bar GL data
///////////////////////////////////////////////////////////
//void ssPianoKeyboard::initGLPitchPlotData(){
//    // if (myApp->dbgMode) cout<< "in ssPianoKeyboard::rephreshGLPitchNotes" << endl;
//    
//    float _begin = pitchBuffer_pos;
//    float _end   = pitchBuffer_pos + pitchBuffer_size;
//    
//    //////////////////////////////////////////////////
//    // Draw piano roll notes
//    //////////////////////////////////////////////////
//    for (int i=_begin ; i<_end ; i++) {
//        
//        float x_pos = frame2pixelX(i , _begin , _end) + PLOTS_X + OFFSET_X;
//        float y_pos = midi2pixelY(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[i]) + yi;
//        
//        
//        ofVec2f v;
//        ofFloatColor c;
//        
//        // Create Color Value
//        c.r = 1.00; c.g = 0.0; c.b = 0.0; c.a = 1.0;
//        
//        // Create Vertices Value
//        v.x = x_pos; v.y = y_pos;         // x , y
//        
//        // Add to Vertex Vectors only Valid Midi Data
//        if (myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[i]>FIRST_KEY && myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[i]<LAST_KEY)
//        {
//            c_pp.push_back(c);
//            v_pp.push_back(v);
//        }
//    }
//    
//    VBO_pp_size = v_pp.size();
//    
//    // Create Index Array
//    for (int j=0;j<VBO_pp_size;j++)
//        ind_pp.push_back(j);
//    
//    VBO_pitchPlot.setVertexData(&v_pp[0], VBO_pp_size, GL_DYNAMIC_DRAW );
//    VBO_pitchPlot.setColorData (&c_pp[0], VBO_pp_size, GL_DYNAMIC_DRAW );
//    VBO_pitchPlot.setIndexData (&ind_pp[0], VBO_pp_size, GL_DYNAMIC_DRAW );
//    glEnable(GL_DEPTH_TEST);
//    
//    // Free Memory
//    v_pp.clear();
//    c_pp.clear();
//    ind_pp.clear();
//}


///////////////////////////////////////////////////////////
// ssPianoKeyboard Rephresh Piano Bar GL data
///////////////////////////////////////////////////////////
void ssPianoKeyboard::rephreshGLPianoRollData(){
    // if (myApp->dbgMode) cout<< "in Update Method of ssPianoKeyboard" << endl;
    
//    float xiPitchPlot = PLOTS_X + OFX_UI_GLOBAL_WIDGET_SPACING;
//    float widthPitchPlot = PLOTS_W;
    
//    float Wkey = Wkeyboard*1/NKeys;
    
    float yiPitchMagnitudePlot = MAINPLOT_X;
    float lengthPitchMagnitudePlot = MAINPLOT_H;
    
    float Wkey = Wkeyboard*1/(NKeys+1);
    
    ////////////////////////////////////////////
    // Prepare Piano Roll Draw
    ////////////////////////////////////////////
    // Create Vertex Array
//    for ( int i = 0; i <= LAST_KEY - FIRST_KEY; i++) {
//        
//        float yiPitchPlot = yi + Wkeyboard - (i+1)*Wkey;
//        
//        ofVec2f v;
//        
//        // Create Vertices Array
//        v.x = xiPitchPlot;                   v.y = yiPitchPlot;         // x , y
//        v_pr.push_back(v);
//        v.x = xiPitchPlot + widthPitchPlot;  v.y = yiPitchPlot;         // x , y
//        v_pr.push_back(v);
//        v.x = xiPitchPlot;                   v.y = yiPitchPlot + Wkey;  // x , y
//        v_pr.push_back(v);
//        v.x = xiPitchPlot + widthPitchPlot;  v.y = yiPitchPlot + Wkey;  // x , y
//        v_pr.push_back(v);
//    }
    
    for ( int i = 0; i <= LAST_KEY - FIRST_KEY; i++) {
        
        //float xiPitchMagnitudePlot = xi + Wkeyboard - (i+1)*Wkey;
        float xiPitchMagnitudePlot = xi + (i)*Wkey;
        
        ofVec2f v;
        
        // Create Vertices Array
        v.x = xiPitchMagnitudePlot + Wkey;            v.y = yiPitchMagnitudePlot + lengthPitchMagnitudePlot;  // x , y
        v_pr.push_back(v);
        v.x = xiPitchMagnitudePlot + Wkey;            v.y = yiPitchMagnitudePlot;         // x , y
        v_pr.push_back(v);
        v.x = xiPitchMagnitudePlot;                   v.y = yiPitchMagnitudePlot + lengthPitchMagnitudePlot;  // x , y
        v_pr.push_back(v);
        v.x = xiPitchMagnitudePlot;                   v.y = yiPitchMagnitudePlot;         // x , y
        v_pr.push_back(v);
    }

    
    VBO_pr_size = v_pr.size();
    
    VBO_pianoRoll.setVertexData(&v_pr[0], VBO_pr_size, GL_DYNAMIC_DRAW );
    
    // Free Memory
    v_pr.clear();
    v_pr.clear();
    ind_pr.clear();
}

//void ssPianoKeyboard::c(){
//    // if (myApp->dbgMode) cout<< "in ssPianoKeyboard::rephreshGLPitchNotes" << endl;
//    
//    float _begin = pitchBuffer_pos;
//    float _end   = pitchBuffer_pos + pitchBuffer_size;
//    float Wkey = Wkeyboard*1/NKeys;
//    
//    //////////////////////////////////////////////////
//    // Draw piano roll notes
//    //////////////////////////////////////////////////
//    for (int i=0;i<myApp->pitchMeterWrapper->midiNotes->noteData.size();i++) {
//        
//        float x_pos = frame2pixelX(myApp->pitchMeterWrapper->midiNotes->noteData[i].inicio , _begin , _end) + PLOTS_X + OFFSET_X;
//        float y_pos = midi2pixelY(myApp->pitchMeterWrapper->midiNotes->noteData[i].nota) - Wkey/2 + yi;
//        float w = frame2pixelX(myApp->pitchMeterWrapper->midiNotes->noteData[i].duration , 0 , pitchBuffer_size);
//        float h = Wkey;
//        
//        // Draw only notes in visible pianoRoll
//        if (myApp->pitchMeterWrapper->midiNotes->noteData[i].fim > _begin && myApp->pitchMeterWrapper->midiNotes->noteData[i].inicio < _end) {
//            // First Note Visual Adjustment (overwrite xpos and w)
//            if (myApp->pitchMeterWrapper->midiNotes->noteData[i].inicio < _begin)
//            {
//                x_pos = frame2pixelX(_begin , _begin , _end) + PLOTS_X;
//                w = frame2pixelX(myApp->pitchMeterWrapper->midiNotes->noteData[i].fim - _begin , 0 , pitchBuffer_size);
//            }
//            // Last Note Visual Adjustment (overwrite w)
//            else if (myApp->pitchMeterWrapper->midiNotes->noteData[i].fim > _end)
//            {
//                w = frame2pixelX(_end - myApp->pitchMeterWrapper->midiNotes->noteData[i].inicio , 0 , pitchBuffer_size);
//            }
//            
//            ofVec2f v;
//            ofFloatColor c;
//            
//            // Create Color Value
//            c.r = 0.39; c.g = 0.66; c.b = 0.75; c.a = 1.0;
//            
//            // Add Color Value to the 4 vertices
//            c_pn.push_back(c);
//            c_pn.push_back(c);
//            c_pn.push_back(c);
//            c_pn.push_back(c);
//            
//            
//            // Create Vertices Points and push into Vertex Array
//            v.x = x_pos;          v.y = y_pos;         // x , y
//            v_pn.push_back(v);
//            v.x = x_pos;          v.y = y_pos + h;  // x , y
//            v_pn.push_back(v);
//            v.x = x_pos + w;      v.y = y_pos;         // x , y
//            v_pn.push_back(v);
//            v.x = x_pos + w;      v.y = y_pos + h;  // x , y
//            v_pn.push_back(v);
//        }
//    }
//    
//    VBO_pn_size = v_pn.size();
//    // Create Index Array
//    for (int j=0;j<VBO_pn_size;j++)
//        ind_pn.push_back(j);
//    
//    VBO_pitchNotes.setVertexData(&v_pn[0], VBO_pn_size, GL_DYNAMIC_DRAW );
//    VBO_pitchNotes.setColorData (&c_pn[0], VBO_pn_size, GL_DYNAMIC_DRAW );
//    VBO_pitchNotes.setIndexData (&ind_pn[0], VBO_pn_size, GL_DYNAMIC_DRAW );
//    glEnable(GL_DEPTH_TEST);
//    
//    // Free Memory
//    v_pn.clear();
//    v_pn.clear();
//    ind_pn.clear();
//}



///////////////////////////////////////////////////////////
// ssPianoKeyboard Rephresh Piano Bar GL data
///////////////////////////////////////////////////////////
void ssPianoKeyboard::rephreshGLPitchPlotData(){
    // if (myApp->dbgMode) cout<< "in ssPianoKeyboard::rephreshGLPitchNotes" << endl;
    
    int _begin = pitchBuffer_pos;
    int _end   = pitchBuffer_pos + pitchBuffer_size;
    
    //////////////////////////////////////////////////
    // Draw pitch Plot Data
    //////////////////////////////////////////////////
    bool flag = false;
    for (int i=_begin ; i<_end ; i++) {
        
        float x_pos = frame2pixelX(i , _begin , _end) + PLOTS_X + OFFSET_X;
        float y_pos = midi2pixelY(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[i]) + yi;
        
        
        ofVec2f v;
        ofFloatColor c;
        
        // Create Vertices Value
        v.x = x_pos; v.y = y_pos;         // x , y
        
        // Add to Vertex Vectors only Valid Midi Data
        //  if (myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[i]>FIRST_KEY && myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[i]<LAST_KEY)
        c.r = 1.00; c.g = 0.0; c.b = 0.0;
        
        c_pp.push_back(c);
        v_pp.push_back(v);
        
        // Set vertexs to invisible when note is invalid
        if (myApp->pitchMeterWrapper->midiNotes->midiNoteData[i]==-1)
            {
            // Set last 2 vertex to invisible
            c_pp[c_pp.size()-1].a = 0.0;      // Set vertex to invisible
            if (c_pp.size()>2)
                c_pp[c_pp.size()-2].a = 0.0;      // Set vertex to invisible
            flag = true;
            }
        else{
            if (flag == true){
                c_pp[c_pp.size()-1].a = 0.0;      // Set vertex to invisible
                flag = !flag;
                }
            else{
                c_pp[c_pp.size()-1].a = 1.0;      // Set vertex to visible
                }
            }
    }
    
    VBO_pp_size = v_pp.size();
    
    // Create Index Array
    for (int j=0;j<VBO_pp_size;j++)
        ind_pp.push_back(j);
    
    VBO_pitchPlot.setVertexData(&v_pp[0], VBO_pp_size, GL_DYNAMIC_DRAW );
    VBO_pitchPlot.setColorData (&c_pp[0], VBO_pp_size, GL_DYNAMIC_DRAW );
    VBO_pitchPlot.setIndexData (&ind_pp[0], VBO_pp_size, GL_DYNAMIC_DRAW );
    glEnable(GL_DEPTH_TEST);
    
    // Free Memory
    v_pp.clear();
    c_pp.clear();
    ind_pp.clear();
}

///////////////////////////////////////////////////////////
// ssPianoKeyboard Rephresh Piano Bar GL data
///////////////////////////////////////////////////////////
void ssPianoKeyboard::rephreshGLFileBufferData(){
    // if (myApp->dbgMode) cout<< "in Update Method of ssPianoKeyboard" << endl;
    
    int xi = PLOTS_X + OFX_UI_GLOBAL_WIDGET_SPACING;
    int yi = PLOTS_Y + PLOTS_DIM/2 + OFX_UI_GLOBAL_WIDGET_SPACING;
    
    ////////////////////////////////////////////
    // Create Vertex Array
    
    for (int i=0 ; i < fileBuffer_size ; i++) {
                
        int x_pixel_pos = ofMap(i, 0, fileBuffer_size, xi, xi + PLOTS_W);
        
        ofVec2f v;
        ofFloatColor c;
        
        // Create Color Array
        //c.r = 0.45; c.g = 0.63; c.b = 0.48; c.a = 1.0;
        c.r = 0.35; c.g = 0.78; c.b = 0.98; c.a = 1.0;
        c_fb.push_back(c);
        
        // Create Vertices Array
        v.x = x_pixel_pos;   v.y = yi + roundSIL(0.9*fileBuffer[i]*PLOTS_DIM/2,0);         // x , y
        v_fb.push_back(v);
    }
    
    VBO_fb_size = v_fb.size();
    
    // Create Index Array
    for (int j=0;j<VBO_fb_size;j++)
        ind_fb.push_back(j);
    
    VBO_fileBuffer.setVertexData(&v_fb[0]  , VBO_fb_size, GL_STATIC_DRAW );
    VBO_fileBuffer.setColorData (&c_fb[0]  , VBO_fb_size, GL_STATIC_DRAW );
    VBO_fileBuffer.setIndexData (&ind_fb[0], VBO_fb_size, GL_STATIC_DRAW );
    glEnable(GL_DEPTH_TEST);
    
    v_fb.clear();
    c_fb.clear();
    ind_fb.clear();
}


//////////////////////////////////////////////////
// Draw Pitch Graph
//////////////////////////////////////////////////
void ssPianoKeyboard::rephreshGLPitchPlot_RT(void) {
    
    if (myApp->pitchMeterWrapper->midiNotes->getNumOfFrames() != 0) {
        //////////////////////////////////////////////////
        // Draw pitch Line
        //////////////////////////////////////////////////
        
        int _begin = pitchBuffer_pos;
        int _end   = pitchBuffer_pos + pitchBuffer_size;
        
        for (int pos = _begin ; pos < myApp->pitchMeterWrapper->midiNotes->midiExactNoteData.size() ; pos++) {
            
            // Remap pitch info to Pixel Position in XY grid
            float x_pixel_pos = frame2pixelX(pos,_begin, _end) + PLOTS_X + OFFSET_X;
            float y_pixel_pos = midi2pixelY(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[pos]) + yi;
            
            ofVec2f v;
            ofFloatColor c;
            
            // Create Color Value
            c.r = 1.00; c.g = 0.0; c.b = 0.0; c.a = 1.0;
            
            // Create Vertices Value
            v.x = x_pixel_pos; v.y = y_pixel_pos;         // x , y
            
            // Add to Vertex Vectors only Valid Midi Data
            //      if (myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[pos]>FIRST_KEY && myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[pos]<LAST_KEY) {
            c_pp_rt.push_back(c);
            v_pp_rt.push_back(v);
            //          }
        }
        
    }
    
    VBO_pp_size_rt = v_pp_rt.size();
    
    // Create Index Array
    for (int j=0;j<VBO_pp_size_rt;j++)
        ind_pp_rt.push_back(j);
    
    VBO_pitchPlot_RT.setVertexData(&v_pp_rt[0], VBO_pp_size_rt, GL_DYNAMIC_DRAW );
    VBO_pitchPlot_RT.setColorData (&c_pp_rt[0], VBO_pp_size_rt, GL_DYNAMIC_DRAW );
    VBO_pitchPlot_RT.setIndexData (&ind_pp_rt[0], VBO_pp_size_rt, GL_DYNAMIC_DRAW );
    glEnable(GL_DEPTH_TEST);
    
    // Free Memory
    v_pp_rt.clear();
    c_pp_rt.clear();
    ind_pp_rt.clear();
}


///////////////////////////////////////////////////////////
// drawKeyboard
///////////////////////////////////////////////////////////
void ssPianoKeyboard::OLD__drawKeyboardAndPianoRoll(float xiPitchPlot, float widthPitchPlot) {
    
    float Wkey = Wkeyboard*1/NKeys;
    
    //////////////////////////////////////////////////
    // Draw Piano Roll
    //////////////////////////////////////////////////
    // Draw PianoRoll Background - White
    setPitchPlotWhiteColor();
    ofRect(xiPitchPlot ,yi, widthPitchPlot, Wkeyboard);
    
    for (int i=0;i<midiScale.size(); i++) {
        ////////////////////////////////////
        // Draw PianoRoll Black Bars
        ////////////////////////////////////
        ofFill();
        if (keyboard[i].midiInfo.keyColor == BLACK_COLOR)
            setPitchPlotBlackColor();
        else
            setPitchPlotWhiteColor();
        ofRect(xiPitchPlot ,yi + Wkeyboard - (i+1)*Wkey, widthPitchPlot, Wkey);
        
        ////////////////////////////////////
        // Draw PianoRoll Line Splitter
        ////////////////////////////////////
        ofSetColor(0,0,0,30);
        ofSetLineWidth(2.0);
        ofLine( xiPitchPlot ,yi + Wkeyboard - (i+1)*Wkey, xiPitchPlot + widthPitchPlot, yi + Wkeyboard - (i+1)*Wkey);
        ofSetLineWidth(1.0);
        
        // Draw Frequency String
        if (keyboard[midiScale.size()-i-1].midiInfo.keyColor == BLACK_COLOR)
            ofSetColor(255,255,255,60);
        else
            ofSetColor(255,255,255,90);
        myfont.drawString(ofToString(roundSIL(keyboard[midiScale.size()-i-1].midiInfo.freq,0)) + " Hz", xiPitchPlot + widthPitchPlot + 5, roundSIL(yi + (i)*Wkey - Wkey/2 + 3,0));
    }
    
    ////////////////////////////////////
    // Draw Keyboard - White Keys First
    ////////////////////////////////////
    for (int i=0;i<midiScale.size(); i++) {
        if (keyboard[i].midiInfo.keyColor == WHITE_COLOR){
            keyboard[i].draw();
        }
    }
    //////////////////////////////////////////////////
    // Draw Black Keys in Second (Place on top of white keys)
    //////////////////////////////////////////////////
    for (int i=0;i<midiScale.size(); i++) {
        if (keyboard[i].midiInfo.keyColor == BLACK_COLOR) {
            keyboard[i].draw();
        }
    }
}


///////////////////////////////////////////////////////////
// drawKeyboard
///////////////////////////////////////////////////////////
void ssPianoKeyboard::drawKeyboardAndPianoRoll_Optimized(float yiPitchMagnitudePlot, float lengthPitchMagnitudePlot) {
    
    float Wkey = Wkeyboard*1/(NKeys+1);
    
    //////////////////////////////////////////////////
    // Draw Piano Roll
    //////////////////////////////////////////////////
    VBO_pianoRoll.drawElements(GL_TRIANGLE_STRIP, VBO_pr_size);
    
    for (int i=0;i<midiScale.size(); i++) {
        ////////////////////////////////////
        // Draw PianoRoll Split Notes Bar
        ////////////////////////////////////
        ofSetColor(0,0,0,30);
//        ofSetColor(255,255,255,255);
        ofSetLineWidth(2.0);
//        ofLine( xiPitchMagnitudePlot ,yi + Wkeyboard - (i+1)*Wkey, xiPitchMagnitudePlot + widthPitchMagnitudePlot, yi + Wkeyboard - (i+1)*Wkey);
        ofLine( xi + Wkey*(i+1) ,yiPitchMagnitudePlot, xi + Wkey*(i+1), yiPitchMagnitudePlot + lengthPitchMagnitudePlot);
        ofSetLineWidth(1.0);
        
        // Draw Frequency String
//        if (keyboard[midiScale.size()-i-1].midiInfo.keyColor == BLACK_COLOR)
//            ofSetColor(255,255,255,60);
//        else
//            ofSetColor(255,255,255,90);
        
        ofSetColor(255, 255, 255, 120);
        
//        myfont.drawString(ofToString(roundSIL(keyboard[midiScale.size()-i-1].midiInfo.freq,0)) + " Hz", yiPitchMagnitudePlot + lengthPitchMagnitudePlot + 5, roundSIL(yi + (i)*Wkey - Wkey/2 + 3,0));
        myfont.drawString(ofToString(roundSIL(keyboard[i].midiInfo.freq,0)), roundSIL(xi + (i)*Wkey + Wkey/3,0), yiPitchMagnitudePlot + lengthPitchMagnitudePlot - 19);
        myfont.drawString("Hz", roundSIL(xi + (i)*Wkey + Wkey/3 + 2,0), yiPitchMagnitudePlot + lengthPitchMagnitudePlot - 5);
//        cout << ofToString(roundSIL(keyboard[midiScale.size()-i-1].midiInfo.freq,0)) << " Hz" << endl;
    }
    
    ////////////////////////////////////
    // Draw Keyboard - White Keys First
    ////////////////////////////////////
    for (int i=0;i<midiScale.size(); i++) {
        if (keyboard[i].midiInfo.keyColor == WHITE_COLOR){
//            keyboard[i].setup(); // ANDRE
            keyboard[i].draw();
        }
    }
    //////////////////////////////////////////////////
    // Draw Black Keys in Second (Place on top of white keys)
    //////////////////////////////////////////////////
    for (int i=0;i<midiScale.size(); i++) {
        if (keyboard[i].midiInfo.keyColor == BLACK_COLOR) {
//            keyboard[i].setup(); // ANDRE
            keyboard[i].draw();
        }
    }
}

//////////////////////////////////////////////////
// Draw Pitch Graph
//////////////////////////////////////////////////
void ssPianoKeyboard::OLD__drawPitchNotes(void) {
    
    int _begin = pitchBuffer_pos;
    int _end   = pitchBuffer_pos + pitchBuffer_size;
    float Wkey = Wkeyboard*1/NKeys;
    
    if (myApp->pitchMeterWrapper->midiNotes->getNumOfFrames() != 0) {
        //////////////////////////////////////////////////
        // Draw piano roll notes
        //////////////////////////////////////////////////
        for (int i=0;i<myApp->pitchMeterWrapper->midiNotes->noteData.size();i++) {
            float x_pos = frame2pixelX(myApp->pitchMeterWrapper->midiNotes->noteData[i].inicio , _begin , _end) + PLOTS_X;
            float y_pos = midi2pixelY(myApp->pitchMeterWrapper->midiNotes->noteData[i].nota) - Wkey/2 + yi;
            float w = frame2pixelX(myApp->pitchMeterWrapper->midiNotes->noteData[i].duration , 0 , pitchBuffer_size);
            float h = Wkey;
            // Draw only notes in visible pianoRoll
            if (myApp->pitchMeterWrapper->midiNotes->noteData[i].fim > _begin && myApp->pitchMeterWrapper->midiNotes->noteData[i].inicio < _end) {
                // First Note Visual Adjustment (overwrite xpos and w)
                if (myApp->pitchMeterWrapper->midiNotes->noteData[i].inicio < _begin)
                {
                    x_pos = frame2pixelX(_begin , _begin , _end) + PLOTS_X;
                    w = frame2pixelX(myApp->pitchMeterWrapper->midiNotes->noteData[i].fim - _begin , 0 , pitchBuffer_size);
                }
                // Last Note Visual Adjustment (overwrite w)
                else if (myApp->pitchMeterWrapper->midiNotes->noteData[i].fim > _end)
                {
                    w = frame2pixelX(_end - myApp->pitchMeterWrapper->midiNotes->noteData[i].inicio , 0 , pitchBuffer_size);
                }
                
                ofPushStyle();
                // Draw MidiNote
                setMidiNoteColor();
                ofNoFill();
                ofSetLineWidth(1.0);
                ofRectRounded(x_pos + OFFSET_X, y_pos, w, h, 3.0);
                ofFill();
                ofSetColor(101, 169, 191,100);
                ofRectRounded(x_pos + OFFSET_X, y_pos, w, h, 3.0);
                ofSetLineWidth(1.0);
                ofPopStyle();
            }
        }
    }
}

//void ssPianoKeyboard::drawPitchNotes_Optimized() {
//    
//    VBO_pitchNotes.drawElements(GL_TRIANGLE_STRIP, VBO_pn_size);
//}


//////////////////////////////////////////////////
// Draw Pitch Graph
//////////////////////////////////////////////////
void ssPianoKeyboard::OLD__drawPitchPlot(void) {
    
    
    if (myApp->pitchMeterWrapper->midiNotes->getNumOfFrames() != 0) {    
        //////////////////////////////////////////////////
        // Draw pitch Line
        //////////////////////////////////////////////////
        vector<float> xBuff;
        vector<float> yBuff;
        xBuff.assign(4, frame2pixelX(pitchBuffer_pos, pitchBuffer_pos, pitchBuffer_pos + pitchBuffer_size) + PLOTS_X);
        yBuff.assign(4, midi2pixelY(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[pitchBuffer_pos]) + yi);
    
        ofNoFill();
        setPitchColor();
        ofSetLineWidth(2.0);
    
        int _begin = pitchBuffer_pos;
        int _end   = pitchBuffer_pos + pitchBuffer_size;
        
     //   int step = (_end - _begin)/PLOTS_W;
        
        for (int pos = _begin ; pos < _end ; pos++) {
        
            // Remap pitch info to Pixel Position in XY grid
            float x_pixel_pos = frame2pixelX(pos,_begin, _end) + PLOTS_X;
            float y_pixel_pos = midi2pixelY(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[pos]) + yi;
        
            // X coordinate FIFO for the last 4 positions
            xBuff.push_back(x_pixel_pos);
            xBuff.erase(xBuff.begin(), xBuff.begin()+1);
        
            // Y coordinate FIFO for the last 4 positions
            yBuff.push_back(y_pixel_pos);
            yBuff.erase(yBuff.begin(), yBuff.begin()+1);
        
            float maxPixel = myApp->ssGui->piano->Wkeyboard + yi;
        
            // If midiNoteData is valid, i.e. >0, draw curve!!!
            if (yBuff[0]<maxPixel &&
                yBuff[1]<maxPixel &&
                yBuff[2]<maxPixel &&
                yBuff[3]<maxPixel) {
                ofCurve(xBuff[0] + OFFSET_X, yBuff[0], xBuff[1]+OFFSET_X, yBuff[1], xBuff[2]+OFFSET_X, yBuff[2], xBuff[3]+OFFSET_X, yBuff[3]);
                }
        
        }
        ofSetLineWidth(1.0);
        ofFill();
    }
}

void ssPianoKeyboard::drawPitchPlot2() {
    
    if (myApp->pitchMeterWrapper->midiNotes->getNumOfFrames() != 0) {
        //////////////////////////////////////////////////
        // Draw pitch Line
        //////////////////////////////////////////////////
        setPitchColor();
        ofSetLineWidth(2.0);
        
        int _begin = pitchBuffer_pos;
        int _end   = pitchBuffer_pos + pitchBuffer_size;
        
        for (int pos = _begin ; pos < myApp->pitchMeterWrapper->midiNotes->midiExactNoteData.size() ; pos++) {
            // Remap pitch info to Pixel Position in XY grid
            float x_pixel_pos = frame2pixelX(pos,_begin, _end) + PLOTS_X  + OFFSET_X;
            float y_pixel_pos = midi2pixelY(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[pos]) + yi;
            
            float x_pixel_pos_last = frame2pixelX(pos-1,_begin, _end) + PLOTS_X  + OFFSET_X;
            float y_pixel_pos_last = midi2pixelY(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[pos-1]) + yi;

            ofLine(x_pixel_pos_last, y_pixel_pos_last, x_pixel_pos, y_pixel_pos);
            }
        }
}


// ANDRE PLOT
void ssPianoKeyboard::drawPitchPowerPlot() {
    
//    cout << "in ssPianoKeyboard::drawPitchPowerPlot()" << endl;
//    cout << myApp->pitchMeterWrapper->midiNotes->notePower.size() << endl;
    
    cout << "previous size: " << previousSizePowerVector << "   |   current size: " << myApp->pitchMeterWrapper->midiNotes->notePower.size() << "   |   novos elementos: " << myApp->pitchMeterWrapper->midiNotes->notePower.size() - previousSizePowerVector << endl;
    
    ofFill();
    int dotRadius = DOT_RADIUS;
    
    int min_fade_time = 40;
//    int max_fade_time = 697; // final transparency: 36
//    int max_fade_time = 765; // fade to zero
    int max_fade_time = min_fade_time + 762;
    
    for (int pos = (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() ; pos > max((int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - max_fade_time, 0) ; pos--) {
        
//        cout << pos << endl;
        
        // DEFINE DOT POSITIONS
        
//        if (myApp->pitchMeterWrapper->midiNotes->notePower.size() >= max_fade_time
        float x_pixel_pos = midi2pixelX(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[pos]);   // pitch
        float y_pixel_pos = power2pixelY(myApp->pitchMeterWrapper->midiNotes->notePower[pos]);          // power
        
        // FADING
        // testei inicialmente para 400 e dava um delay de aproximadamente 5.6 segundos
        // por isso defini o tempo em que começa o fading como sendo 40 para dar os desejados 0.5 segundos
        // o tempo em que os dots assumem a transparência final é definido como sendo 10 segundos, logo aproximadamente 700
        
        if (pos >= (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - min_fade_time) { // dots drawn less than 0.5 seconds ago
            
//            cout << "in condition 1: pos = " << pos << "    |  size = " << myApp->pitchMeterWrapper->midiNotes->notePower.size() << endl;
            ofSetColor(30, 178, 47);
        }
        else if (pos < (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - min_fade_time && pos > (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - max_fade_time) { // dots drawn between 0.5 and 10 seconds ago

            // PROGRESSIVE FADING
//            int transp_factor = (((int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - pos - min_fade_time)/9 + 1)*3;
            int transp_factor = (((int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - pos - min_fade_time)/6 + 1)*2;
            
//            cout << "in condition 2: pos = " << pos << "    |  size = " << myApp->pitchMeterWrapper->midiNotes->notePower.size() << "    |   transp factor = " << transp_factor << endl;
            
            ofSetColor(30, 178, 47, 255 - transp_factor);
            
        }
//        else { // dots drawn more than 10 seconds ago
//
//            cout << "in condition 3: pos = " << pos << endl;
//
////            ofSetColor(30, 178, 47, 36);
//            
//        }
        
        ofCircle(x_pixel_pos, y_pixel_pos, dotRadius);
    }
    
    ofNoFill();
    
    drawPowerLines();
    
    previousSizePowerVector = myApp->pitchMeterWrapper->midiNotes->notePower.size();
}

void ssPianoKeyboard::drawFullPitchPowerPlot() {
    
    cout << "in drawFullPitchPowerPlot()" << endl;
//    cout << "previous size: " << previousSizePowerVector << "   |   current size: " << myApp->pitchMeterWrapper->midiNotes->notePower.size() << "   |   novos elementos: " << myApp->pitchMeterWrapper->midiNotes->notePower.size() - previousSizePowerVector << endl;
    
    ofFill();
    int dotRadius = DOT_RADIUS;
    
    for (int pos = (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() ; pos > 0 ; pos--) {
        
        // DEFINE DOT POSITIONS
        
        float x_pixel_pos = midi2pixelX(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[pos]);   // pitch
        float y_pixel_pos = power2pixelY(myApp->pitchMeterWrapper->midiNotes->notePower[pos]);          // power
        
        ofSetColor(30, 178, 47);
        ofCircle(x_pixel_pos, y_pixel_pos, dotRadius);
    }
    
    ofNoFill();
    drawPowerLines();
    
}


void ssPianoKeyboard::drawPowerLines() {
    
    ofSetLineWidth(1.0);
    
    for(int i = MIN_POWER + 5; i <= MAX_POWER - 5 ; i += 5) {
        
        float y = power2pixelY(i);
        ofSetColor(141, 145, 139, 75);
        ofLine(0, y, Wkeyboard, y);
        ofSetColor(255, 255, 255, 120);
        myfont.drawString(ofToString(i) + " dB", OFX_UI_GLOBAL_WIDGET_SPACING, y - 5);
        myfont.drawString(ofToString(i) + " dB", Wkeyboard - Wkeyboard/NKeys + 10 , y - 5);
    }
}


void ssPianoKeyboard::drawPitchPlot_Optimized(void) {
    
    ofSetLineWidth(2.0);
    VBO_pitchPlot.drawElements(GL_LINE_STRIP, VBO_pp_size);
    ofSetLineWidth(1.0);
}

void ssPianoKeyboard::drawFileBuffer_Optimized(void) {
    
    int xi = PLOTS_X + OFX_UI_GLOBAL_WIDGET_SPACING;
    int yi = PLOTS_Y + PLOTS_DIM/2 + OFX_UI_GLOBAL_WIDGET_SPACING;
    
    //ofSetColor(0.45*256, 0.63*256, 0.48*256, 1.0*256);
    ofSetColor(90,200,250); // SIL
    ofLine(xi,yi+1,xi + PLOTS_W,yi+1);
    ofSetLineWidth(2.0);
    VBO_fileBuffer.drawElements(GL_LINES, VBO_fb_size);
    ofSetLineWidth(1.0);
}

//////////////////////////////////////////////////
// draw Vertical Time Lines
/////////////////////////////////////////////////
void ssPianoKeyboard::drawVerticalTimeLines(void) {

    int _begin = pitchBuffer_pos;
    int _end   = pitchBuffer_pos + pitchBuffer_size;
    
    float _min = myApp->ssGui->zoom_sliderH->getScaledValueLow();
    float _max = myApp->ssGui->zoom_sliderH->getScaledValueHigh();
  
    int tBar = convSec2Fram((_max - _min)/NTIMEBARS);
    //////////////////////////////////////////////////
    // Draw vertical Time Lines
    //////////////////////////////////////////////////
    setTimeBarsColor();
    if (myApp->appWorkingMode==PLAY_MODE)
        if (myApp->pitchMeterWrapper->midiNotes->getNumOfFrames()>0)
            for (int i = _begin ; i< _end ; i++) {
                // Remap pitch info to Pixel Position in XY grid
                float x_pos = frame2pixelX(i,_begin,_end) + PLOTS_X;
                if (i%tBar==0)
                    {
                    ofPushStyle();
                    //ofLine(x_pos + OFFSET_X , PLOTS_Y + 45, x_pos + OFFSET_X, 1024);
                    ofLine(x_pos + OFFSET_X , PLOTS_Y + 51, x_pos + OFFSET_X, PLOTS_Y + 54);
                        
 
                    float durationInSec = convFram2Sec(i);
                    
                    string strTimeGrid = formatTimeMMSS(durationInSec);
                    
                    myfont.drawString(strTimeGrid, roundSIL(x_pos + OFFSET_X,0), roundSIL(PLOTS_Y + 50,0));
                    ofPopStyle();
                    }
            }
}


//////////////////////////////////////////////////
// Draw Pitch Graph
//////////////////////////////////////////////////
void ssPianoKeyboard::drawPitchPlot_RT(void) {
    
    //////////////////////////////////////////////////
    // Draw pitch Line
    //////////////////////////////////////////////////
    
    setPitchColor();
    ofSetLineWidth(2.0);
    VBO_pitchPlot_RT.drawElements(GL_LINE_STRIP, VBO_pp_size_rt);
    ofSetLineWidth(1.0);
    ofFill();
}

string ssPianoKeyboard::formatTimeMMSS(float durationInSec) {
    
    float seconds1,miliseconds1;
    
    miliseconds1 = (int) ((float) modf (durationInSec , &seconds1)*10);
    
    int   minutes1 = (int)seconds1/60;
    
    string minutes1_str;
    
    if (minutes1<10)
        minutes1_str = "0" + ofToString(minutes1);
    else
        minutes1_str = ofToString(minutes1);
    
    string seconds1_str;
    
    if (seconds1<10)
        seconds1_str = "0" + ofToString(seconds1-minutes1*60);
    else
        seconds1_str = ofToString(seconds1);

    return (minutes1_str + "m" + seconds1_str + "." + ofToString(miliseconds1)+"s");
}


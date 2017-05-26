#include "ssPianoKeyboard.h"
#include "ssApp.h"

extern ssApp * myApp;


///////////////////////////////////////////////////////////
// ssPianoKeyboard Constructor
///////////////////////////////////////////////////////////
ssPianoKeyboard::ssPianoKeyboard(int _fileBuffer_size){
    
    
    myApp->dbgMode = DEBUG; // RELEASE or DEBUG
    
    if (myApp->dbgMode) cout << "creating ssPianoKeyboard" << endl;
    
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

float ssPianoKeyboard::midi2pixelX(float midi){
    
//    cout << "midi: " << midi << endl << "return: " << roundSIL(ofMap(midi, FIRST_KEY, LAST_KEY, 0, Wkeyboard) - Wkeyboard*1/NKeys/2,0) << endl;
    
    midi = midi - 12*(myApp->sampleRate/22050 - 1); // dado o sample rate ter sido alterado de 22050 para 44100, o midi resultante era calculado uma oitava acima
    return roundSIL(ofMap(midi, FIRST_KEY, LAST_KEY, 0, Wkeyboard) - Wkeyboard*1/NKeys/2,0);
}

float ssPianoKeyboard::power2pixelY(float power) {
    
//    return roundSIL(ofMap(power, MIN_POWER, MAX_POWER, MAINPLOT_X + MAINPLOT_H, MAINPLOT_X), 0);
    return roundSIL(ofMap(power, MIN_POWER, MAX_POWER, APP_HEIGHT - myApp->heightNavController, MAINPLOT_X), 0);
}




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
    
    float yiPitchMagnitudePlot = MAINPLOT_X;
//    float lengthPitchMagnitudePlot = MAINPLOT_H;
    float lengthPitchMagnitudePlot = APP_HEIGHT - MAINPLOT_X - myApp->heightNavController;
//    float lengthPitchMagnitudePlot = myApp->heightNavController;
    
    //////////////////////////////////////////
    // Draw Keyboard + PIANO ROLL
    //////////////////////////////////////////////////      Alone                   Al
    setPlotsColorBack();
    drawKeyboardAndPianoRoll_Optimized(yiPitchMagnitudePlot,lengthPitchMagnitudePlot);       // Decrease to 15fps
    
    if (myApp->appWorkingMode==RECORD_MODE) {
//        if(myApp->pitchMeterWrapper->midiNotes->notePower.size() > 0) // FOR DEBUGGING
//            printMatrix();
        drawPitchPowerPlot();
    }
    else if (myApp->appWorkingMode == PLAY_MODE) {
        drawRegionsPlot();
//        drawFullPitchPowerPlot();
    }

    
    //////////////////////////////////////////////////
    // Draw Top Background
    //////////////////////////////////////////////////
    setPlotsColorBack();
    ofFill();
//    img.draw(-4, 0,APP_WIDTH+4,PLOTS_H);
    ofRect(-4, 0,APP_WIDTH+4,PLOTS_H);
    
//    float durationInSec;
//    
//    if (myApp->appWorkingMode==PLAY_MODE)
//        durationInSec = convFram2Sec(myApp->appStateMachine->FRAME.Playing);
//    else
//        durationInSec = convFram2Sec(myApp->appStateMachine->FRAME.Recording);
//
//    string strTimeBar = formatTimeMMSS(durationInSec);
    
    ofPopStyle();

}

///////////////////////////////////////////////////////////
// ssPianoKeyboard Rephresh Piano Bar GL data
///////////////////////////////////////////////////////////
void ssPianoKeyboard::initGLPianoRollData(){
    // if (myApp->dbgMode) cout<< "in Update Method of ssPianoKeyboard" << endl;
    
    float yiPitchMagnitudePlot = MAINPLOT_X;
//    float lengthPitchMagnitudePlot = MAINPLOT_H;
    float lengthPitchMagnitudePlot = APP_HEIGHT - MAINPLOT_X - myApp->heightNavController;
    
//    float Wkey = Wkeyboard*1/(NKeys+1);
    float Wkey = Wkeyboard*1/(NKeys);
    
    for ( int i = 0; i <= LAST_KEY - FIRST_KEY; i++) {
    
        //float xiPitchMagnitudePlot = xi + Wkeyboard - (i+1)*Wkey;
        float xiPitchMagnitudePlot = xi + (i)*Wkey;
        
        ofVec2f v;
        ofFloatColor c;
        
        // Create Color Array
        if (midiScale[i].keyColor == WHITE_COLOR){
//            c.r = 0.16; c.g = 0.20; c.b = 0.23;
            c.r = 0.05; c.g = 0.05; c.b = 0.05;
//            cout << "white" << endl;
        }
        else{
//            c.r = 0.13; c.g = 0.16; c.b = 0.18;
            c.r = 0.08; c.g = 0.08; c.b = 0.08;
//            cout << "black" << endl;
        }
        
        c.a = 0.65;
        
        c_pr.push_back(c);
        c_pr.push_back(c);
        c_pr.push_back(c);
        c_pr.push_back(c);
        
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


///////////////////////////////////////////////////////////
// drawKeyboard
///////////////////////////////////////////////////////////
void ssPianoKeyboard::drawKeyboardAndPianoRoll_Optimized(float yiPitchMagnitudePlot, float lengthPitchMagnitudePlot) {
    
    cout << "in drawKeyboardAndPianoRoll_Optimized = " << endl;
    
//    float Wkey = Wkeyboard*1/(NKeys+1);
    
    float Wkey = Wkeyboard/NKeys;
    
    //////////////////////////////////////////////////
    // Draw Piano Roll
    //////////////////////////////////////////////////
    VBO_pianoRoll.drawElements(GL_TRIANGLE_STRIP, VBO_pr_size);
    
    for (int i=0;i<midiScale.size(); i++) {
        ////////////////////////////////////
        // Draw PianoRoll Split Notes Bar
        ////////////////////////////////////
//        Wkey = Wkeyboard*1/(NKeys+1);
        cout << "Wkey = " << Wkey << endl;
//        ofSetColor(0,0,0,30);
        ofSetColor(30,30,30);
//        ofSetColor(141, 145, 139, 75);
//        ofSetColor(255,255,255,100);
//        ofSetLineWidth(2.0);
//        ofLine( xiPitchMagnitudePlot ,yi + Wkeyboard - (i+1)*Wkey, xiPitchMagnitudePlot + widthPitchMagnitudePlot, yi + Wkeyboard - (i+1)*Wkey);
        ofLine( roundSIL(xi + Wkey*(i+1), 0) ,yiPitchMagnitudePlot, roundSIL(xi + Wkey*(i+1), 0), yiPitchMagnitudePlot + lengthPitchMagnitudePlot);
        
        cout << "line X coordinate = " << xi + Wkey*(i+1) << endl;
        
//        ofSetColor(255,0,0,100);
//        Wkey = Wkeyboard/NKeys;
//        cout << "Wkey = " << Wkey << endl;
//        ofLine( xi + Wkey*(i+1) ,yiPitchMagnitudePlot, xi + Wkey*(i+1), yiPitchMagnitudePlot + lengthPitchMagnitudePlot);
        
        ofSetLineWidth(1.0);
        
        // Draw Frequency String
//        if (keyboard[midiScale.size()-i-1].midiInfo.keyColor == BLACK_COLOR)
//            ofSetColor(255,255,255,60);
//        else
//            ofSetColor(255,255,255,90);
        
        ofSetColor(255, 255, 255, 120);
        
//        myfont.drawString(ofToString(roundSIL(keyboard[midiScale.size()-i-1].midiInfo.freq,0)) + " Hz", yiPitchMagnitudePlot + lengthPitchMagnitudePlot + 5, roundSIL(yi + (i)*Wkey - Wkey/2 + 3,0));
        myfont.drawString(ofToString(roundSIL(keyboard[i].midiInfo.freq,0)), roundSIL(xi + (i)*Wkey + Wkey/5,0), yiPitchMagnitudePlot + lengthPitchMagnitudePlot - 10);
//        myfont.drawString("Hz", roundSIL(xi + (i)*Wkey + Wkey/3 + 2,0), yiPitchMagnitudePlot + lengthPitchMagnitudePlot - 5);
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


void ssPianoKeyboard::drawPitchPowerPlot() {
    
//    cout << "in ssPianoKeyboard::drawPitchPowerPlot()" << endl;
//    cout << myApp->pitchMeterWrapper->midiNotes->notePower.size() << endl;
    
    cout << "previous size: " << previousSizePowerVector << "   |   current size: " << myApp->pitchMeterWrapper->midiNotes->notePower.size() << "   |   novos elementos: " << myApp->pitchMeterWrapper->midiNotes->notePower.size() - previousSizePowerVector << endl;
    
    cout << "n rows: " << N_ROWS << "       n cols: " << N_COLS << endl;
    
    drawPowerLines();
    
    ofFill();
    
    int dotRadius = DOT_RADIUS;
    
    int min_fade_time = MIN_FADE_TIME;
    int max_fade_time = MAX_FADE_TIME;
    
    for (int pos = max((int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - max_fade_time + 1, 0) ; pos < (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() ; pos++) {
        
        // DEFINE DOT POSITIONS
        float x_pixel_pos = midi2pixelX(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[pos]);   // pitch
        float y_pixel_pos = power2pixelY(myApp->pitchMeterWrapper->midiNotes->notePower[pos]);          // power
        
//        cout << "x = " << x_pixel_pos << "  |   y = " << y_pixel_pos << endl;
        
        // STORING DOTS IN THE MATRIX
//        if ((pos > previousSizePowerVector) && x_pixel_pos >= 0 && x_pixel_pos <= APP_WIDTH && y_pixel_pos >= MAINPLOT_X && y_pixel_pos <= MAINPLOT_X + MAINPLOT_H) {
        if ((pos > previousSizePowerVector) && x_pixel_pos >= 0 && x_pixel_pos <= APP_WIDTH && y_pixel_pos >= MAINPLOT_X && y_pixel_pos <= APP_HEIGHT - myApp->heightNavController) {
            
//            int columnIndex = ceil(x_pixel_pos*N_COLS/APP_WIDTH);
//            int rowIndex = ceil(y_pixel_pos*((int)N_ROWS)/(MAINPLOT_X + MAINPLOT_H));

            int columnIndex = ceil(ofMap(x_pixel_pos, 0, APP_WIDTH, 0, N_COLS));
//            int rowIndex = ceil(ofMap(y_pixel_pos, MAINPLOT_X, MAINPLOT_H + MAINPLOT_X, 0, N_ROWS));
            int rowIndex = ceil(ofMap(y_pixel_pos, MAINPLOT_X, APP_HEIGHT - myApp->heightNavController, 0, N_ROWS));

            cout << "pos = " << pos << "    |   x = " << x_pixel_pos << "   |   y = " << y_pixel_pos << "   |   column index: " << columnIndex << "   |   row index: " << rowIndex << endl;
            
            dotsMatrix[(columnIndex-1) + (rowIndex-1)*N_COLS]++;
        }
        else
            cout << "pos = " << pos << endl;
        
        // FADING
        // testei inicialmente para 400 e dava um delay de aproximadamente 5.6 segundos
        // por isso defini o tempo em que começa o fading como sendo 40 para dar os desejados 0.5 segundos
        // o tempo em que os dots assumem a transparência final é definido como sendo 10 segundos, logo aproximadamente 700
        
        if (pos > (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - 10){
            
//            cout << "in condition 0: pos = " << pos << "    |  size = " << myApp->pitchMeterWrapper->midiNotes->notePower.size() << "    |   transp factor = " << roundSIL(ofMap(pos, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size(), (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - 10, 0, 255), 0) << endl;
            
            ofSetColor(255, 255, 0, roundSIL(ofMap(pos, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size(), (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - 10, 0, 255), 0));
        }
        else if (pos >= (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - min_fade_time) { // dots drawn less than 0.5 seconds ago
            
//            cout << "in condition 1: pos = " << pos << "    |  size = " << myApp->pitchMeterWrapper->midiNotes->notePower.size() << endl;
            
            // yellow:  rgb(255, 255, 0)
            // green:   rgb( 30, 180, 50)
            ofSetColor(roundSIL(ofMap(pos, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - 10, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - min_fade_time, 255, 30), 0),roundSIL(ofMap(pos, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - 10, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - min_fade_time, 255, 180), 0), roundSIL(ofMap(pos, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - 10, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - min_fade_time, 0, 50), 0));
        }
        else if (pos < (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - min_fade_time && pos > (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - max_fade_time) { // dots drawn between 0.5 and 10 seconds ago

            // PROGRESSIVE FADING
            
//            cout << "in condition 2: pos = " << pos << "    |  size = " << myApp->pitchMeterWrapper->midiNotes->notePower.size() << "    |   transp factor = " << roundSIL(ofMap(pos, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - min_fade_time, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - max_fade_time, 255, 0), 0) << endl;
            
            ofSetColor(30, 180, 50, roundSIL(ofMap(pos, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - min_fade_time, (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() - max_fade_time, 255, 0), 0));
            
        }
        
        ofCircle(x_pixel_pos, y_pixel_pos, dotRadius);
//        ofNoFill();
//        ofSetColor(200, 200, 0);
//        ofCircle(x_pixel_pos, y_pixel_pos, dotRadius + 10);
//        ofFill();
//        ofDrawSphere(x_pixel_pos, y_pixel_pos, 10, dotRadius + 20);
    }
    
    
    // FREE MEMMORY ALLOCATED TO OUTDATED DOTS (WHOSE INFORMATION IS SAVED IN THE MATRIX)
    
    if (myApp->pitchMeterWrapper->midiNotes->notePower.size() > max_fade_time){
        myApp->pitchMeterWrapper->midiNotes->notePower.erase(myApp->pitchMeterWrapper->midiNotes->notePower.begin(), myApp->pitchMeterWrapper->midiNotes->notePower.end() - max_fade_time);
        myApp->pitchMeterWrapper->midiNotes->midiExactNoteData.erase(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData.begin(), myApp->pitchMeterWrapper->midiNotes->midiExactNoteData.end() - max_fade_time);
    }
    
    ofNoFill();
    
    previousSizePowerVector = myApp->pitchMeterWrapper->midiNotes->notePower.size();
}


void ssPianoKeyboard::printMatrix() {

//    ofNoFill();
    for(int i = 0; i < N_ROWS*N_COLS; i++) {
        
//        ofSetColor(255, 0, 0, 200);
//        ofRect((i%N_COLS)*SQUARE_GRANULARITY, MAINPLOT_X + (int)((i/N_COLS)*SQUARE_GRANULARITY), SQUARE_GRANULARITY, SQUARE_GRANULARITY);
//        myfont.drawString(ofToString(i%N_COLS) + ", " + ofToString(i/N_COLS), i%N_COLS*SQUARE_GRANULARITY + 3, MAINPLOT_X + (int)((i/N_COLS)*SQUARE_GRANULARITY) + 15);
        
        cout << dotsMatrix[i] << ' ';
        if((i+1)%N_COLS == 0) {
            cout << endl;
        }
    }
//    ofFill();
    
    cout << endl;
}


void ssPianoKeyboard::drawRegionsPlot() {
    
    cout << "in drawRegionsPlot()" << endl;
    
    cout << "SQUARE GRANULARITY = " << SQUARE_GRANULARITY << endl;
    
    
    float square_side = ((float)APP_WIDTH/(float)NKeys);
    
    cout << "SQUARE SIDE = " << square_side << endl;
    
    int maxDots = 0;
    
    for (int i = 0 ; i < N_ROWS*N_COLS ; i++) {
        
        if (dotsMatrix[i] > maxDots)
            maxDots = dotsMatrix[i];
    }
    
    ofFill();
    drawPowerLines();
    
    for (int i = 0 ; i < N_ROWS*N_COLS ; i++) {
        
//        ofNoFill();
//        ofSetColor(255, 0, 0, 200);
//        ofRect((i%N_COLS)*SQUARE_GRANULARITY, MAINPLOT_X + (int)((i/N_COLS)*SQUARE_GRANULARITY), SQUARE_GRANULARITY, SQUARE_GRANULARITY);
//        myfont.drawString(ofToString(i%N_COLS) + ", " + ofToString(i/N_COLS), i%N_COLS*SQUARE_GRANULARITY + 3, MAINPLOT_X + (int)((i/N_COLS)*SQUARE_GRANULARITY) + 15);
//        ofFill();
    
        if (!dotsMatrix[i])
            continue;
        
        else {
            
//            ofSetColor(255, 255, 255, ofMap(dotsMatrix[i], 0, myApp->pitchMeterWrapper->midiNotes->midiNoteData.size(), 0, 255));
            ofSetColor(255, 255, 255, ofMap(dotsMatrix[i], 0, maxDots, 0, 255));
//            ofSetColor(237, 0, 0, ofMap(dotsMatrix[i], 0, maxDots, 0, 255));
//            ofRect((i%N_COLS)*SQUARE_GRANULARITY, MAINPLOT_X + (int)((i/N_COLS)*SQUARE_GRANULARITY), SQUARE_GRANULARITY, SQUARE_GRANULARITY);
            ofRect((float)(i%N_COLS)*square_side, MAINPLOT_X + ((float)(i/N_COLS)*square_side), square_side, square_side);
            
            cout << "x = " << (i%N_COLS)*square_side << "     |       y = " << (MAINPLOT_X + (i/N_COLS)*square_side) << "    |   column index: " << i%N_COLS << "    |   row index: " << i/N_COLS << endl;
        }
    }
    
    ofNoFill();
    
}

void ssPianoKeyboard::drawFullPitchPowerPlot() {
    
    cout << "in drawFullPitchPowerPlot()" << endl;
    //    cout << "previous size: " << previousSizePowerVector << "   |   current size: " << myApp->pitchMeterWrapper->midiNotes->notePower.size() << "   |   novos elementos: " << myApp->pitchMeterWrapper->midiNotes->notePower.size() - previousSizePowerVector << endl;
    
    drawPowerLines();
    
    ofFill();
    int dotRadius = DOT_RADIUS;
    
    for (int pos = (int)myApp->pitchMeterWrapper->midiNotes->notePower.size() ; pos > 0 ; pos--) {
        
        // DEFINE DOT POSITIONS
        
        float x_pixel_pos = midi2pixelX(myApp->pitchMeterWrapper->midiNotes->midiExactNoteData[pos]);   // pitch
        float y_pixel_pos = power2pixelY(myApp->pitchMeterWrapper->midiNotes->notePower[pos]);          // power
        
        //        ofSetColor(20, 200, 40);
        ofSetColor(30, 180, 50);
        ofCircle(x_pixel_pos, y_pixel_pos, dotRadius);
    }
    
    ofNoFill();
    
}


void ssPianoKeyboard::drawPowerLines() {
    
    ofSetLineWidth(1.0);
    
    for(int i = MIN_POWER + 5; i <= MAX_POWER - 5 ; i += 5) {
        
        float y = power2pixelY(i);
//        ofSetColor(141, 145, 139, 75);
        ofSetColor(60, 60, 60);
        ofLine(0, y, Wkeyboard, y);
        ofSetColor(255, 255, 255, 120);
        myfont.drawString(ofToString(i) + " dB", OFX_UI_GLOBAL_WIDGET_SPACING, y - 5);
        myfont.drawString(ofToString(i) + " dB", Wkeyboard - Wkeyboard/NKeys - 10 , y - 5);
    }
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


//string ssPianoKeyboard::formatTimeMMSS(float durationInSec) {
//    
//    float seconds1,miliseconds1;
//    
//    miliseconds1 = (int) ((float) modf (durationInSec , &seconds1)*10);
//    
//    int   minutes1 = (int)seconds1/60;
//    
//    string minutes1_str;
//    
//    if (minutes1<10)
//        minutes1_str = "0" + ofToString(minutes1);
//    else
//        minutes1_str = ofToString(minutes1);
//    
//    string seconds1_str;
//    
//    if (seconds1<10)
//        seconds1_str = "0" + ofToString(seconds1-minutes1*60);
//    else
//        seconds1_str = ofToString(seconds1);
//
//    return (minutes1_str + "m" + seconds1_str + "." + ofToString(miliseconds1)+"s");
//}


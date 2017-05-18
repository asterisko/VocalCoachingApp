#pragma once

#include "ofMain.h"

#include "ssGlobals.h"

#include "tmpFile.h"

#include "PitchMeter.h"

#include "ssPianoKey.h"


///////////////////////////////////////////////////////////
// ssPianoKeyboard CLASS
///////////////////////////////////////////////////////////
class ssPianoKeyboard : public ofxMSAInteractiveObject{
public:
    
    float * fileBuffer;
    int     fileBuffer_size;
    
    int     previousSizePowerVector = 0;
    
    int *dotsMatrix = (int *) calloc(N_ROWS*N_COLS, sizeof(int));
    
    ofMutex mutex;

    float   xpos_percent[12];
    float   xpos_BackgroundPercent[12];
    vector<MidiKeyInfo> midiScale;
    ssPianoKey keyboard[73];
    
    float   xi;
    float   yi;
    float   Wkeyboard;
    float   Hkeyboard;
    ofImage img;
    ofImage img_note;

    int     pitchBuffer_pos = 0;
    int     pitchBuffer_size = 0;
    
    ofTrueTypeFont myfont;
    ofTrueTypeFont myfont2;
    ofTrueTypeFont myfont3;


    ///////////////////////////////////////////////////////////
    // ssPianoKeyboard Methods
    ///////////////////////////////////////////////////////////
    ssPianoKeyboard(int TplotBuffer_size);
    ~ssPianoKeyboard();
    
    void init(float _xi, float _yi, float _w, float _h);
    void addKeyboard(void);

    void initGLPianoRollData();
    
    void drawKeyboardAndPianoRoll_Optimized(float xiPitchPlot, float widthPitchPlot);
    
    // ANDRE PLOT
    void drawPitchPowerPlot();      // Draws dots with fading in real time, saves them to a matrix
    void drawRegionsPlot();         // Draws regions according to the occurrence of the dots (Only after clicking STOP)
    void drawFullPitchPowerPlot();  // Draws all the dots (NOT EFFICIENT IN TERMS OF MEMMORY AND CPU USAGE) (Only after clicking STOP)
    void drawPowerLines();          // Marks the lines that indicate the power in dB
    void printMatrix();

//    void drawVerticalTimeLines();
   
    void copyData2FileBuffer(void);
    void rephreshGLFileBufferData(void);
    void drawFileBuffer_Optimized(void);

    float frame2pixelX(float pos,float _begin, float _end);
    float midi2pixelY(float midi);
    float midi2pixelX(float midi); // ANDRE
    float power2pixelY(float power); // ANDRE
    
    vector<float> diffVector(vector<float> vin);
    
    void update();	// called every frame to update object
    void draw();	// called every frame to draw object
    
//    float dist_y_old=0.0;
//    void  moveY_pplot (float diff_y);
//    void  zoomY_pplot_old (float dist_y);
//    void  zoomY_pplot (void);

//    string formatTimeMMSS(float durationInSec);

        
    // GL Optimization
    ofVbo                   VBO_pianoRoll;
    vector<ofIndexType>     ind_pr;
    vector<ofVec2f>         v_pr;
    vector<ofFloatColor>    c_pr;
    int                     VBO_pr_size;
    
    ofVbo                   VBO_fileBuffer;
    vector<ofIndexType>     ind_fb;
    vector<ofVec2f>         v_fb;
    vector<ofFloatColor>    c_fb;
    int                     VBO_fb_size;
    
};

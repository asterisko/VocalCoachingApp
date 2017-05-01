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
    void setKeyboardPosition(float _xi,float _yi);
    void setKeyboardPositionY(float _yi);
    void addKeyboard(void);

    void initGLPianoRollData();
    //void initGLPitchPlotData();
    
    //void rephreshGLPitchNotesData();
    void rephreshGLPianoRollData();
    void rephreshGLPitchPlotData();
    
    void OLD__drawKeyboardAndPianoRoll(float xiPitchPlot, float widthPitchPlot);
    void drawKeyboardAndPianoRoll_Optimized(float xiPitchPlot, float widthPitchPlot);
    
    void OLD__drawPitchNotes();
    //void drawPitchNotes_Optimized();
    
    void OLD__drawPitchPlot();
    void drawPitchPlot_Optimized();
    void drawPitchPlot_RT();
    void drawPitchPlot2();
    
    // ANDRE PLOT
    void drawPitchPowerPlot();
    void drawFullPitchPowerPlot();
    void drawPowerLines();

    void rephreshGLPitchPlot_RT();

    void drawVerticalTimeLines();
   
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
    
    float dist_y_old=0.0;
    void  moveY_pplot (float diff_y);
    void  zoomY_pplot_old (float dist_y);
    void  zoomY_pplot (void);

    string formatTimeMMSS(float durationInSec);

        
    // GL Optimization
    ofVbo                   VBO_pianoRoll;
    vector<ofIndexType>     ind_pr;
    vector<ofVec2f>         v_pr;
    vector<ofFloatColor>    c_pr;
    int                     VBO_pr_size;

    ofVbo                   VBO_pitchNotes;
    vector<ofIndexType>     ind_pn;
    vector<ofVec2f>         v_pn;
    vector<ofFloatColor>    c_pn;
    int                     VBO_pn_size;

    ofVbo                   VBO_pitchPlot;
    vector<ofIndexType>     ind_pp;
    vector<ofVec2f>         v_pp;
    vector<ofFloatColor>    c_pp;
    int                     VBO_pp_size;

    ofVbo                   VBO_pitchPlot_RT;
    vector<ofIndexType>     ind_pp_rt;
    vector<ofVec2f>         v_pp_rt;
    vector<ofFloatColor>    c_pp_rt;
    int                     VBO_pp_size_rt;
    
    ofVbo                   VBO_fileBuffer;
    vector<ofIndexType>     ind_fb;
    vector<ofVec2f>         v_fb;
    vector<ofFloatColor>    c_fb;
    int                     VBO_fb_size;
    
};

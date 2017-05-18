//
//  ssGlobals.h
//  iOS_singingStudio
//
//  Created by Sérgio Ivan Lopes on 4/30/13.
//
//
#ifndef MY_GLOBAL_FUN
#define MY_GLOBAL_FUN

#include "ofMain.h"
#include <stdlib.h>
#include <math.h>

//////////////////////////////////////////////////////////////////////////////////
// APP Defines
//////////////////////////////////////////////////////////////////////////////////
#define PITCHPLOT_SIZE       1024 // Samples duration of visualization buffer in Time Domain
#define PLOT_BUFFER_DURATION 5.0  // seconds
#define ZOOM_MIN_TIME        1.0  // seconds
#define ZOOM_MAX_TIME       30.0  //
#define APP_WIDTH    ofGetWidth()
#define APP_HEIGHT   ofGetHeight()

#define NTIMEBARS   10           // Number of Time Bars in Tplot
//////////////////////////////////////////////////////////////////////////////////
// GUI Position/width/height in percentage
//////////////////////////////////////////////////////////////////////////////////
#define PLOTS_DIM   40*APP_HEIGHT/1024  // in pixels
#define PLOTS_X     (0.10*APP_WIDTH + OFX_UI_GLOBAL_WIDGET_SPACING)
#define PLOTS_Y     50 + OFX_UI_GLOBAL_WIDGET_SPACING
#define PLOTS_W     (1.00*APP_WIDTH - PLOTS_X - 0.06*APP_WIDTH)
//#define PLOTS_H     (0.3*APP_HEIGHT)
#define PLOTS_H     (0.25*APP_HEIGHT)
#define PLOT_T_H    (0.19*APP_HEIGHT)
#define PLOT_F_H    (0.10*APP_HEIGHT)
#define OFFSET_X     OFX_UI_GLOBAL_WIDGET_SPACING                // in pixels

#define CPANEL_DIM  60*APP_HEIGHT/1024  // in pixels
#define CPANEL_X    OFX_UI_GLOBAL_WIDGET_SPACING
#define CPANEL_Y    (0.94*APP_HEIGHT)
#define CPANEL_W    (APP_WIDTH - CPANEL_X)
#define CPANEL_H    (0.06*APP_HEIGHT)   // antes 0.13

// ANDRE
#define KEY_LENGTH  0.12*APP_HEIGHT
#define MAINPLOT_X  PLOTS_H + KEY_LENGTH
#define MAINPLOT_H  (APP_HEIGHT - (MAINPLOT_X) - CPANEL_H)

// THEORETICAL SOUND POWER VALUES
//#define MIN_POWER   40  // 40 dB corresponds to a quiet environment
//#define MAX_POWER   110 // 100 dB corresponds to a very loud sound (rock band)

#define MIN_POWER   75
#define MAX_POWER   115

//#define MIN_POWER   80
//#define MAX_POWER   130

#define MIN_FADE_TIME   60
#define MAX_FADE_TIME   MIN_FADE_TIME + 700


//////////////////////////////////////////////////////////////////////////////////
// GUI COLORS
//////////////////////////////////////////////////////////////////////////////////
#define setAppBackgroundColor()     ofBackground(36,42,49)
#define setPlotsColorBack()         ofSetColor(110, 110, 110)
#define setCPanelColorBack()        ofSetColor(92, 100, 107)
#define setFileBufferColor()        ofSetColor(200, 200, 200,127)
#define setWaveColor()              ofSetColor(86,115,245)
#define setTimeBarsColor()          ofSetColor(255,255,255,60);

// Pitch Plot
#define setKeyWhiteColor()          ofSetColor(195, 199, 209)
#define setKeyBlackColor()          ofSetColor(66, 66, 70)
#define setPitchPlotWhiteColor()    ofSetColor(40, 51, 60,200)
#define setPitchPlotBlackColor()    ofSetColor(32, 40, 46,200)
#define setBarColor()               ofSetColor(242,177,41)
//#define setMidiNoteColor()          ofSetColor(101, 169, 191)
#define setMidiNoteColor()          ofSetColor(255, 150, 0)
#define setPitchColor()             ofSetColor(200,0,16)


//////////////////////////////////////////////////////////////////////////////////
// Keyboard Defines
//////////////////////////////////////////////////////////////////////////////////
#define A4         440      // G is 440 hz...
#define FIRST_KEY   36  // Midi:  36 | B6 | 3951.07 Hz
#define LAST_KEY    71 // Midi: 108 | C1 | 65.41   Hz
#define NKeys       (LAST_KEY-FIRST_KEY)

// ANDRE
//#define DOT_RADIUS 3;
#define DOT_RADIUS 0.006 * APP_WIDTH;

//#define SQUARE_GRANULARITY  ((APP_WIDTH/NKeys))
#define SQUARE_GRANULARITY  ((APP_WIDTH/NKeys)/2)

#define N_ROWS      (MAINPLOT_H/SQUARE_GRANULARITY)
#define N_COLS      (APP_WIDTH/SQUARE_GRANULARITY)


enum APP_WORKING_MODE {
    PLAY_MODE,
    RECORD_MODE,
};

enum APP_PLAY_MODE {
    PLAY_WAV,
    PLAY_MIDI,
    PLAY_BOTH,
    };

enum GRAPHIC_PLAY_MODE {
    CONTINUOUS_MODE,
    BLOCK_MODE,
};

//////////////////////////////////////////////////////////////////////////////////
// EXECUTION STATES
//////////////////////////////////////////////////////////////////////////////////
enum EXEC_STATE {
    STATE_RECORDING,
    STATE_RECORDING_PAUSE,
//    STATE_PLAYING,
//    STATE_PLAYING_PAUSE,
    STATE_IDLE,
};

//////////////////////////////////////////////////////////////////////////////////
// IDLE STATES
//////////////////////////////////////////////////////////////////////////////////
enum IDLE_STATE {
	IDLE_NO_AUDIO,
	IDLE_WITH_AUDIO_ONLY,
	IDLE_WITH_MIDI_ONLY,
	IDLE_WITH_AUDIO_MIDI,
};

//////////////////////////////////////////////////////////////////////////////////
// PLAY STATES
//////////////////////////////////////////////////////////////////////////////////
enum PLAYING_STATE {
	PLAYING_AUDIO,
	PLAYING_AUDIO_SELECTION,
	PLAYING_MIDI_VOICE,
	PLAYING_MIDI_VOICE_SELECTION,
	PLAYING_MIDI_FILE,
	PLAYING_MIDI_FILE_SELECTION,
};

// DEBUG MODE
enum DEBUG_MODE {
    RELEASE,
    DEBUG,
};

//////////////////////////////////////////////////////////////////////////////////
// Convertion Midi <-> Note
//////////////////////////////////////////////////////////////////////////////////
float midi2freq(int _midi);
unsigned int freq2midi(float _freq);
float freq2midiExact(float _freq);

//////////////////////////////////////////////////////////////////////////////////
// Convertion Defined functions
//////////////////////////////////////////////////////////////////////////////////
int     convSamp2Fram(int Nsamples);
int     convFram2Samp(int Nframes);
float   convSamp2Sec(int Nsamples);
int     convSec2Samp(float Nseconds);
float   convFram2Sec(int Nframes);
int     convSec2Fram(float Nseconds);

//////////////////////////////////////////////////////////////////////////////////
// Math functions
//////////////////////////////////////////////////////////////////////////////////
double  roundSIL(double d, int pp);
void    hanning(float* v, int size);        // Perform Hanning Window to array
void    hamming(float* v, int size);        // Perform Hanning Window to array
void    dB(float * v, int size);               // convert vector to dB

//////////////////////////////////////////////////////////////////////////////////
// Elementary Array Operations
//////////////////////////////////////////////////////////////////////////////////
void    set2zero(float* v, int size);
float   sum(float* d, int size);				// return sum
void    scalarProd(float* v, int size, float scalar); // product
vector<float> diffVector(vector<float> v);

//////////////////////////////////////////////////////////////////////////////////
// Stats functions
//////////////////////////////////////////////////////////////////////////////////
float   mean(float* d, int size);				// return arithmetic mean
int     maxi(float* d, int size);               // return indice of max in array
int     mini(float* d, int size);               // return indice of min in array
float   stdev(float * v, int size);

float maxx(float* d, int size);
float minn(float* d, int size);
//////////////////////////////////////////////////////////////////////////////////
// OpenGl functions
//////////////////////////////////////////////////////////////////////////////////
void drawRectangle(int x, int y, int w, int h);
void drawTest(void);

#endif

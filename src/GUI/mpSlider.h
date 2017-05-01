/********  Test sample for ofxInteractiveObject									********/
/********  Make sure you open your console to see all the events being output	********/


#pragma once
#include "ofUtils.h"
#include "ofxMSAInteractiveObject.h"
#include "mpGlobals.h"

class mpSlider : public ofxMSAInteractiveObject {
public:
    
    // Fader data
    float xi,yi;                // x,y fader position
    float W,H;                  // W,H fader lengths
    float value;                // actual value
    float scaledValue;          // actual scaled value
    float minValue, maxValue;   // scaled value interval
    
    float offsety,offsetx;      // Touch fader offset
    
    float imageW,imageH;        // Fader PNG size
    
    int labelRes;               // Number of floating point elements

    bool isDragging=false;
    
    ofTrueTypeFont myfont;

    string urlImage;
    string urlImageDown;
    string label;
    
    ofImage sliderImage;
    ofImage sliderImageDown;

    mpSlider();
    ~mpSlider();
    void setMinMaxValues(float _min, float _max);
    void setLabelDataResolution(float _res);
    void setValue(float _value);
    void init (string _label, string _urlImage, float _xi, float _yi, float _W, float _H);
    void setup();
	void exit();
	void update();
	void draw();
	virtual void onRollOver(int x, int y);
	virtual void onRollOut();
	virtual void onMouseMove(int _x, int _y);
	virtual void onDragOver(int _x, int _y, int button);
	virtual void onDragOutside(int _x, int _y, int button);
	virtual void onPress(int _x, int _y, int button);
    virtual void onRelease(int x, int y, int button);
    virtual void onReleaseOutside(int x, int y, int button);
    virtual void keyPressed(int key);
    virtual void keyReleased(int key);
    };
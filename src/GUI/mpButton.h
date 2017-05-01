/********  Test sample for ofxInteractiveObject									********/
/********  Make sure you open your console to see all the events being output	********/


#pragma once
#include "ofxMSAInteractiveObject.h"
#include "mpGlobals.h"

enum BUTTON_TYPE{
    PUSH_BUTTON,
    SLIDER_BUTTON,
    TOGGLE_BUTTON,
};

enum DRAG_TYPE{
    DRAG_LEFT,
    DRAG_RIGHT,
    DRAG_UP,
    DRAG_DOWN,
};

class mpButton : public ofxMSAInteractiveObject {
public:
    
    // Fader data
    BUTTON_TYPE btnType;
    float xi,yi;                // x,y Button position
    float W,H;                  // W,H Button lengths
    bool state=0;                // actual state
    bool type=PUSH_BUTTON;
    float imageW,imageH;        // Button PNG size
    
    bool isPressing=false;
    bool stateToggled=false;
    bool drawLabel=false;
        
    string urlImageState0;
    string urlImageState0Down;
    string urlImageState1;
    string urlImageState1Down;
    
    ofImage btnImageState0;
    ofImage btnImageState0Down;
    ofImage btnImageState1;
    ofImage btnImageState1Down;
    
    string strBtnState0Label;
    string strBtnState1Label;
    
    float x_old;
    float y_old;
    
    mpButton();
    ~mpButton();
    
    void setState(bool _state);
    bool getState(void);
    void toggleState(void);
    bool stateChanged(void);
    void init (BUTTON_TYPE _btnType, string _btnLabelState0, string _btnLabelState1, string _urlImage, float _xi, float _yi, float _W, float _H);
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
#include "mpButton.h"
#include "mpApp.h"

extern mpApp * myApp;

///////////////////////////////////////////////////////////
// class Constructor
///////////////////////////////////////////////////////////
mpButton::mpButton(){

}

///////////////////////////////////////////////////////////
// class Destructor
///////////////////////////////////////////////////////////
mpButton::~mpButton() {
    
}

void mpButton::setState(bool _state){
    state=_state;
    stateToggled = true;
    }

bool mpButton::getState(void){
    return state;
    }

void mpButton::toggleState(void){
    state = !state;
    stateToggled = true;
    }

bool mpButton::stateChanged(void){
    if(stateToggled) {
        stateToggled=false;
        return true;
        }
    else
        return false;
    }

void mpButton::init (BUTTON_TYPE _btnType,string _btnLabelState0, string _btnLabelState1, string _urlImage, float _xi, float _yi, float _W, float _H){
    
    btnType = _btnType;
    
    xi = roundSIL(_xi*ofGetWidth(),0);
    yi = roundSIL(_yi*ofGetHeight(),0);
    W  = roundSIL(_W*ofGetWidth(),0);
    H  = roundSIL(_H*ofGetHeight(),0);
        
    strBtnState0Label = _btnLabelState0;
    strBtnState1Label = _btnLabelState1;
    string aux = ofSplitString(_urlImage,"State0.png")[0];
    urlImageState0      = _urlImage;
    urlImageState0Down  = aux + "State0down.png";
    urlImageState1      = aux + "State1.png";
    urlImageState1Down  = aux + "State1down.png";
    
    btnImageState0.loadImage(urlImageState0);
    btnImageState0Down.loadImage(urlImageState0Down);
    btnImageState1.loadImage(urlImageState1);
    btnImageState1Down.loadImage(urlImageState1Down);

    float scale = (float) W/btnImageState0.getWidth();

    imageW = btnImageState0.getWidth()*scale;
    imageH = btnImageState0.getHeight()*scale;
        
    btnImageState0.resize(imageW,imageH);
    btnImageState0Down.resize(imageW,imageH);
    btnImageState1.resize(imageW,imageH);
    btnImageState1Down.resize(imageW,imageH);
        
    float wi = btnImageState0.getWidth();
    float hi = btnImageState0.getHeight();
        
    set(xi,yi,wi,hi);
    
    }



void mpButton::setup() {
    if(myApp->debugType==DEBUG) printf("mpButton::setup() - hello!\n");
    enableMouseEvents();
    enableKeyEvents();
    }

void mpButton::exit() {
    if(myApp->debugType==DEBUG) printf("mpButton::exit() - goodbye!\n");
    }
	
	
void mpButton::update() {
        x =  myApp->x_pos + xi;
    }

void mpButton::draw() {
        
    if      (state ==0 && !isMousePressed()) {
        btnImageState0.draw(x, y, width, height);
        if (drawLabel) ofDrawBitmapString(strBtnState0Label, x+5,y+15);
        }
    else if (state ==0 && isMousePressed()) {
        btnImageState0Down.draw(x, y, width, height);
        }
    else if (state ==1 && !isMousePressed()){
        btnImageState1.draw(x, y, width, height);
        if (drawLabel) ofDrawBitmapString(strBtnState1Label, x+5,y+15);
        }
    else if (state ==1 && isMousePressed()){
        btnImageState1Down.draw(x, y, width, height);
        }
    }
	
void mpButton::onRollOver(int x, int y) {
    if(myApp->debugType==DEBUG) printf("mpButton::onRollOver(x: %i, y: %i)\n", x, y);
    }
	
void mpButton::onRollOut() {
    if(myApp->debugType==DEBUG) printf("mpButton::onRollOut()\n");
    }
	
void mpButton::onMouseMove(int _x, int _y){
    if(myApp->debugType==DEBUG) printf("mpButton::onMouseMove(x: %i, y: %i)\n", _x, _y);
    }
	
void mpButton::onDragOver(int _x, int _y, int button) {
    if(myApp->debugType==DEBUG) printf("mpButton::onDragOver(x: %i, y: %i, button: %i)\n", _x, _y, button);
    // Basic Gesture Classification
    float diff_x = _x - x_old;
    float diff_y = _y - y_old;
    
    if (btnType == SLIDER_BUTTON && isPressing) {
    if (abs(diff_y) > abs(diff_x)) {
        if(myApp->debugType==DEBUG) cout << "DRAGGING Y -> ";
        if (abs(diff_y)>imageH/4) { // Filtra cliques de tomarem accao
            if (diff_y>0) {
                if(myApp->debugType==DEBUG) cout<< "DOWN"<< endl;
                setState(1);
                }
            else {
                if(myApp->debugType==DEBUG) cout<< "UP"<< endl;
                setState(0);
                }
            }
            }
        else {
            if(myApp->debugType==DEBUG) cout << "DRAGGING X" << endl;
            }
        }
    }

void mpButton::onDragOutside(int _x, int _y, int button) {
    if(myApp->debugType==DEBUG) printf("mpButton::onDragOutside(x: %i, y: %i, button: %i)\n", _x, _y, button);
    // Basic Gesture Classification
    float diff_x = _x - x_old;
    float diff_y = _y - y_old;
    
    if (btnType == SLIDER_BUTTON) {
        if (abs(diff_y) > abs(diff_x)) {
            if(myApp->debugType==DEBUG) cout << "DRAGGING Y -> ";
            if (abs(diff_y)>imageH/4) { // Filtra cliques de tomarem accao
                if (diff_y>0) {
                    if(myApp->debugType==DEBUG) cout<< "DOWN"<< endl;
                    setState(1);
                    }
                else {
                    if(myApp->debugType==DEBUG) cout<< "UP"<< endl;
                    setState(0);
                    }
                }
            }
        else {
            if(myApp->debugType==DEBUG) cout << "DRAGGING X" << endl;
            }
        }
    }

void mpButton::onPress(int _x, int _y, int button) {
    if(myApp->debugType==DEBUG) printf("mpButton::onPress(x: %i, y: %i, button: %i)\n", _x, _y, button);
    isPressing = true;
    x_old=_x;
    y_old=_y;
    }
	
void mpButton::onRelease(int _x, int _y, int button) {
    if(myApp->debugType==DEBUG) printf("mpButton::onRelease(x: %i, y: %i, button: %i)\n", _x, _y, button);

    if (btnType==PUSH_BUTTON && isPressing)
        toggleState();
 
    if (btnType==TOGGLE_BUTTON && isPressing)
        state=true;
    
    isPressing = false;
}

void mpButton::onReleaseOutside(int _x, int _y, int button) {
    if(myApp->debugType==DEBUG) printf("mpButton::onReleaseOutside(x: %i, y: %i, button: %i)\n", _x, _y, button);
    isPressing = false;
    }

void mpButton::keyPressed(int key) {
    if(myApp->debugType==DEBUG) printf("mpButton::keyPressed(key: %i)\n", key);
    }
	
void mpButton::keyReleased(int key) {
    if(myApp->debugType==DEBUG) printf("mpButton::keyReleased(key: %i)\n", key);
    }

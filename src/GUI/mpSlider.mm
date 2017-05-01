#include "mpSlider.h"
#include "mpApp.h"

extern mpApp * myApp;

///////////////////////////////////////////////////////////
// class Constructor
///////////////////////////////////////////////////////////
mpSlider::mpSlider(){

}

///////////////////////////////////////////////////////////
// class Destructor
///////////////////////////////////////////////////////////
mpSlider::~mpSlider() {

}


void mpSlider::setMinMaxValues(float _min, float _max){
        minValue = _min;
        maxValue = _max;
        }
    
void mpSlider::setLabelDataResolution(float _res){
        labelRes = _res;
        }

void mpSlider::setValue(float _value){
        y =  roundSIL(ofMap(_value, maxValue,minValue, yi, yi + H - imageH),0);
        value = roundSIL(ofMap(y, yi, yi + H - imageH, 1.0,0.0),3);
        scaledValue = roundSIL(ofMap(y, yi, yi + H - imageH,maxValue,minValue),labelRes);
        }
        
void mpSlider::init (string _label, string _urlImage, float _xi, float _yi, float _W, float _H){
    
    if (myApp->device==i320x480)
        myfont.loadFont("GUI/fonts/roboto/Roboto-Regular.ttf", 12);
    else if (myApp->device==i640x960 || myApp->device==i640x1136)
        myfont.loadFont("GUI/fonts/roboto/Roboto-Regular.ttf", 24);
    else if (myApp->device==i768x1024)
        myfont.loadFont("GUI/fonts/roboto/Roboto-Regular.ttf", 28);
    else if (myApp->device==i1536x2048)
        myfont.loadFont("GUI/fonts/roboto/Roboto-Regular.ttf", 56);
    
    xi = roundSIL(_xi*ofGetWidth(),0);
    yi = roundSIL(_yi*ofGetHeight(),0);
    W  = roundSIL(_W*ofGetWidth(),0);
    H  = roundSIL(_H*ofGetHeight(),0);
        
    label = _label;
    urlImage = _urlImage;
    urlImageDown = ofSplitString(urlImage,".")[0] + "down.png";

    sliderImage.loadImage(urlImage);
    sliderImageDown.loadImage(urlImageDown);

    float scale = (float) W/sliderImage.getWidth();

    imageW = sliderImage.getWidth()*scale;
    imageH = sliderImage.getHeight()*scale;
        
    sliderImage.resize(imageW,imageH);

    float wi = sliderImage.getWidth();
    float hi = sliderImage.getHeight();
        
    set(xi,yi,wi,hi);
    }

void mpSlider::setup() {
    if(myApp->debugType==DEBUG) printf("mpSlider::setup() - hello!\n");
    enableMouseEvents();
    enableKeyEvents();
    }

void mpSlider::exit() {
    if(myApp->debugType==DEBUG) printf("mpSlider::exit() - goodbye!\n");
    }
	
	
void mpSlider::update() {
    value = roundSIL(ofMap(y , yi , yi + H - imageH, 1.0,0.0),3);
    scaledValue = roundSIL(ofMap(y , yi, yi + H - imageH,maxValue,minValue),labelRes);
    x = myApp->x_pos + xi;
    //x = myApp->mainCanvas->x_pos + xi;
    }
	
	
void mpSlider::draw() {
    if(isMousePressed())
        sliderImageDown.draw(x, y, width, height);
    else
        sliderImage.draw(x, y, width, height);
        
    //ofDrawBitmapString(ofToString(scaledValue), x+5,y+40);
    myfont.drawString(ofToString(scaledValue),  x + 0.12*width , y + 0.6*height);
    }
	
void mpSlider::onRollOver(int x, int y) {
    if(myApp->debugType==DEBUG) printf("mpSlider::onRollOver(x: %i, y: %i)\n", x, y);
    }
	
void mpSlider::onRollOut() {
    if(myApp->debugType==DEBUG) printf("mpSlider::onRollOut()\n");
    }
	
void mpSlider::onMouseMove(int _x, int _y){
    if(myApp->debugType==DEBUG) printf("mpSlider::onMouseMove(x: %i, y: %i)\n", _x, _y);
    }
	
void mpSlider::onDragOver(int _x, int _y, int button) {
 // if(debugType==DEBUG) printf("mpSlider::onDragOver(x: %i, y: %i, button: %i)\n", _x, _y, button);
    if (isDragging) {
        if (_y - offsety >= yi && _y - offsety <= yi + H - imageH)
            y = roundSIL(_y - offsety,0);
        else if (_y - offsety < yi)
                y = roundSIL(yi,0);
            else
                y = roundSIL(yi + H - imageH,0);
        }
    }
	
void mpSlider::onDragOutside(int _x, int _y, int button) {
	//	if(debugType==DEBUG) printf("mpSlider::onDragOutside(x: %i, y: %i, button: %i)\n", _x, _y, button);
    if (isDragging) {
        if (_y - offsety >= yi && _y - offsety <= yi + H - imageH)
            y = roundSIL(_y - offsety,0);
        else if (_y - offsety < yi)
                y = roundSIL(yi,0);
            else
                y = roundSIL(yi + H - imageH,0);
        }
    }

void mpSlider::onPress(int _x, int _y, int button) {
    if(myApp->debugType==DEBUG) printf("mpSlider::onPress(x: %i, y: %i, button: %i)\n", _x, _y, button);
    offsety = roundSIL(_y - y,0);
    if (_y - offsety >= yi && _y - offsety <= yi + H)
        isDragging = true;
    }

void mpSlider::onRelease(int x, int y, int button) {
    if(myApp->debugType==DEBUG) printf("MyTestObject::onRelease(x: %i, y: %i, button: %i)\n", x, y, button);
    isDragging = false;
    }
	
void mpSlider::onReleaseOutside(int x, int y, int button) {
    if(myApp->debugType==DEBUG) printf("MyTestObject::onReleaseOutside(x: %i, y: %i, button: %i)\n", x, y, button);
    isDragging = false;
    }

void mpSlider::keyPressed(int key) {
    if(myApp->debugType==DEBUG) printf("mpSlider::keyPressed(key: %i)\n", key);
    }

void mpSlider::keyReleased(int key) {
    if(myApp->debugType==DEBUG) printf("mpSlider::keyReleased(key: %i)\n", key);
    }

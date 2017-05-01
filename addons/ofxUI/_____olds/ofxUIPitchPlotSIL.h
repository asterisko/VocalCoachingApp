/********************************************************************************** 
 
 Copyright (C) 2012 Syed Reza Ali (www.syedrezaali.com)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 **********************************************************************************/

#ifndef OFXUI_PITCHPLOTSIL
#define OFXUI_PITCHPLOTSIL

#include "ofxUIWidget.h"
#include "ssPianoKey.h"

class ofxUIPitchPlotSIL : public ofxUIWidget
{
    
public:
    
    int cueBar_pos = 0; // in seconds
    
    int first_key = 0;
    int last_key = 120;
    
    float xi;
    float yi;
    float Wkeyboard;
    float Hkeyboard;
    
    bool bdrawPiano = true;
    
    vector<float> pitchVec;
    
    vector<MidiKeyInfo> midiScale;
    
    ssPianoKey keyboard[120];
    
    float xpos_percent[12];
    float xpos_BackgroundPercent[12];
    
    
    ///////////////////////////////////////////////////////////
    // Constructor
    ///////////////////////////////////////////////////////////
    ofxUIPitchPlotSIL(float x, float y, float w, float h, float *_buffer, int _bufferSize, float _min, float _max, string _name) : ofxUIWidget()
    {
        rect = new ofxUIRectangle(x,y,w,h); 
        init(w, h, _buffer, _bufferSize, _min, _max, _name);
    }
    
    ///////////////////////////////////////////////////////////
    // Constructor
    ///////////////////////////////////////////////////////////
    ofxUIPitchPlotSIL(float w, float h, float *_buffer, int _bufferSize, float _min, float _max, string _name) : ofxUIWidget()
    {
        rect = new ofxUIRectangle(0,0,w,h); 
        init(w, h, _buffer, _bufferSize, _min, _max, _name);
    }
    
    ///////////////////////////////////////////////////////////
    // OBJ Initialization
    ///////////////////////////////////////////////////////////
    void init(float w, float h, float *_buffer, int _bufferSize, float _min, float _max, string _name)
    {
        name = string(_name);  				
        kind = OFX_UI_WIDGET_WAVEFORM; 

        paddedRect = new ofxUIRectangle(-padding, -padding, w+padding*2.0, h+padding*2.0);
        paddedRect->setParent(rect); 
		
        draw_fill = true; 
        
        if(_buffer != NULL)
        {
            buffer = _buffer;					//the widget's value
        }
        else
        {
            buffer = NULL; 
        }
        
        bufferSize = _bufferSize; 
        max = _max; 
        min = _min; 		
        scale = rect->getHeight()*.5;
        inc = rect->getWidth()/((float)bufferSize-1.0);
        
        // Posicoes relativas das teclas brancas
        for (int i = 0; i < 12; ++i)
        {
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
        for (int i = 0; i < 12; ++i)
        {
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
            xpos_BackgroundPercent[i] = i*1/12;
        
        initPiano(OFX_UI_GLOBAL_WIDGET_SPACING, 250 + OFX_UI_GLOBAL_WIDGET_SPACING , 1600 , 100);
        addKeyboard();
    }
    
    ///////////////////////////////////////////////////////////
    // Piano Initialization
    ///////////////////////////////////////////////////////////
    void initPiano(float _xi, float _yi, float _w,float _h){
        
        xi = _xi;
        yi = _yi;
        Wkeyboard = _w;
        Hkeyboard = _h;
        
        // Generate MidiScaleVector with all 128 midi notes
        int octave;
        int Noctaves = 120/12;
        
        for (int i = 0; i < 120; ++i)
        {
            MidiKeyInfo midiNote;
            
            octave = i/12;
            
            midiNote.code = i;
            midiNote.octave = octave;
            midiNote.keyPosPercent = (float) (xpos_percent[i%12]/(float)Noctaves + (float)octave/((float)Noctaves));
            midiNote.freq = midiNote.midi2freq(i);
            midiNote.keyPosBackgroundPercent = (float) (xpos_BackgroundPercent[i%12]/(float)Noctaves + (float)octave/((float)Noctaves));
            
            switch(i%12)
            {
                case 0:  midiNote.label = "C" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/70;
                    midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // C
                case 2:  midiNote.label = "D" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/70;
                    midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // D
                case 4:  midiNote.label = "E" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/70;
                    midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // E
                case 5:  midiNote.label = "F" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/70;
                    midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // F
                case 7:  midiNote.label = "G" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/70;
                    midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // G
                case 9:  midiNote.label = "A" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/70;
                    midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // A
                case 11: midiNote.label = "B" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/70;
                    midiNote.keyHeightPercent = 1.0; midiNote.keyColor = WHITE_COLOR; break;    // B
                    
                case 1:  midiNote.label = "C#" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/120;
                    midiNote.keyHeightPercent = 0.56; midiNote.keyColor = BLACK_COLOR; break;    // C#
                case 3:  midiNote.label = "D#" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/120;
                    midiNote.keyHeightPercent = 0.56; midiNote.keyColor = BLACK_COLOR; break;    // D#
                case 6:  midiNote.label = "F#" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/120;
                    midiNote.keyHeightPercent = 0.56; midiNote.keyColor = BLACK_COLOR; break;    // F#
                case 8:  midiNote.label = "G#" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/120;
                    midiNote.keyHeightPercent = 0.56; midiNote.keyColor = BLACK_COLOR; break;    // G#
                case 10: midiNote.label = "A#" + ofToString(octave - 1 ); midiNote.keyWidthPercent = (float) 1/120;
                    midiNote.keyHeightPercent = 0.56; midiNote.keyColor = BLACK_COLOR; break;    // A#
            }
            
            midiScale.push_back(midiNote);
            cout <<" Code = " << midiNote.code << " | Note = "<< midiNote.label << " | Freq = "<< (float) midiNote.freq << " | Oct =" << octave << " | Pos = " << midiNote.keyPosPercent << endl;
        }
    }

    ///////////////////////////////////////////////////////////
    // Show Piano Method
    ///////////////////////////////////////////////////////////
    void showPiano(bool _bdrawPiano){
        bdrawPiano = _bdrawPiano;
    }
    
    ///////////////////////////////////////////////////////////
    // Set New Keyboard Position
    ///////////////////////////////////////////////////////////
    void setKeyboardPosition(float _xi,float _yi){
        
        float offset_pos = midiScale[first_key].keyPosPercent;
        float keypos,keywidth,keyheight,keyBackPos;
        
        for (int i=0;i<120;i++) {
            keypos = roundf((midiScale[i].keyPosPercent-offset_pos)*Wkeyboard);
            keywidth = roundf(midiScale[i].keyWidthPercent*Wkeyboard);
            keyheight = roundf(midiScale[i].keyHeightPercent*Hkeyboard);
            keyBackPos = roundf(midiScale[i].keyPosBackgroundPercent*Wkeyboard);
            keyboard[i].set(_xi,_yi + keypos,keyheight,keywidth);
        }
    }
    
    
    ///////////////////////////////////////////////////////////
    // Set New Keyboard Position Y
    ///////////////////////////////////////////////////////////
    void setKeyboardPositionY(float _yi){
        
        setKeyboardPosition(xi,_yi);
    }
    
    ///////////////////////////////////////////////////////////
    // addPianoKeyboard
    ///////////////////////////////////////////////////////////
    void addKeyboard(void)
    {
        ///////////////////////////////////////////////////////////
        // Generate Keyboard Vector with all 128 midi notes
        ///////////////////////////////////////////////////////////
        float keypos,keywidth,keyheight;
        
        float offset_pos = midiScale[first_key].keyPosPercent;
        int   keycolor;
        
        for (int i=0; i<120; i++)
        {
            keypos = roundf((midiScale[i].keyPosPercent-offset_pos)*Wkeyboard);
            keywidth = roundf(midiScale[i].keyWidthPercent*Wkeyboard);
            keyheight = roundf(midiScale[i].keyHeightPercent*Hkeyboard);
            keycolor = midiScale[i].keyColor;
            ssPianoKey key;
            key.disableAppEvents();
            // key.enableAppEvents();				// call this if object should update/draw automatically	(default)
            key.enableMouseEvents();
            key.set(xi,yi+keypos,keyheight,keywidth);
            key.midiInfo = midiScale[i];
            keyboard[i]=key;
        }
    }
    
    ///////////////////////////////////////////////////////////
    // ssPianoKeyboard Update Method
    ///////////////////////////////////////////////////////////
    void update(){
        // cout<< "in Update Method of ssPianoKeyboard" << endl;
    }
    
    ///////////////////////////////////////////////////////////
    // ssPianoKeyboard Draw Method
    ///////////////////////////////////////////////////////////
    virtual void draw(){
        //cout<< "in Draw Method of ssPianoKeyboard" << endl;
        //////////////////////////////////////////
        // Draw Keyboard
        //////////////////////////////////////////
        if (bdrawPiano) {
            // Draw White Keys First
            for (int i=0; i<120; i++) {
                if (keyboard[i].midiInfo.keyColor == WHITE_COLOR)
                    keyboard[i].draw();
            }
            // Draw White Keys in Second (Place on top of white keys)
            for (int i=0; i<120; i++) {
                if (keyboard[i].midiInfo.keyColor == BLACK_COLOR)
                    keyboard[i].draw();
            }
            
            // Draw Pitch Graph
            ofColor(255,0,0,127);
            for (int i=0; i<pitchVec.size(); i++) {
                //   ofLine(, <#float y1#>, <#float x2#>, <#float y2#>)
            }
            
        }
    }
    
    virtual void drawBack()
    {
        if(draw_back)
        {
            ofFill();
            ofSetColor(color_back);
            rect->draw();
            
            ofLine(rect->getX(), rect->getY()+rect->getHalfHeight(), rect->getX()+rect->getWidth(), rect->getY()+rect->getHalfHeight());
        }
    }
    
    
    virtual void drawFill()
    {
        if(draw_fill)
        {			
			ofNoFill(); 
			if(draw_fill_highlight)
                {
				ofSetColor(color_fill_highlight); 
                }
			else 
                {
				ofSetColor(color_fill); 		 	
                }
            if(buffer != NULL)
                {
                ofPushMatrix(); 
                ofTranslate(rect->getX(), rect->getY()+scale, 0);
                ofSetLineWidth(1.5); 
                ofBeginShape();		
                for (int i = 0; i < bufferSize; i++)
                    {
                    ofVertex(inc*(float)i, ofMap(buffer[i], min, max, -scale, scale, true));
                    }
                ofEndShape();
                ofSetLineWidth(1); 
                ofPopMatrix(); 
                }
            // Draw Cue Bar
            ofSetColor(255,0,0);
          //  cout<<"cueBar_Pos= " << cueBar_pos << endl;
            ofLine(cueBar_pos,rect->getY(),cueBar_pos,rect->getY()+2*scale);
        }
    }
		
	void setParent(ofxUIWidget *_parent)
	{
		parent = _parent; 
	}
    
    void setMax(float _max)
    {
        max = _max;
    }
    
    float getMax()
    {
        return max;
    }
    
    void setMin(float _min)
    {
        min = _min;
    }
    
    float getMin()
    {
        return min;
    }
    
    ofVec2f getMaxAndMind()
    {
        return ofVec2f(max, min);
    }
    
    void setMaxAndMin(float _max, float _min)
    {
        max = _max;
        min = _min;
    }
    
protected:    //inherited: ofxUIRectangle *rect; ofxUIWidget *parent; 
	float *buffer; 
	float max, min, scale, inc; 
	int bufferSize;
}; 



#endif

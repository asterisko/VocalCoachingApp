//
//  ssMidiFile.cpp
//  iOSingingStudio
//
//  Created by Voice Studies on 9/26/13.
//
//

#include "ssMidiFileIO.h"
#include "ssApp.h"

extern ssApp * myApp;

ssMidiFileIO::ssMidiFileIO() {

    ticksPerBeat = 128;
    bpm = 120;

}

ssMidiFileIO::~ssMidiFileIO() {
    
}

void ssMidiFileIO::setBPM(int _bpm){

    bpm = _bpm;
}

void ssMidiFileIO::setTicksPerBeat(int _ticksPerBeat){
    
    ticksPerBeat = _ticksPerBeat;
}

void ssMidiFileIO::saveMidiFile(string filename) {
        
    ////////////////////////////////////////////////
    // GENERATE ALL MIDI DATA
    // see: http://www.skytopia.com/project/articles/midi.html
    //      http://www.ccarh.org/courses/253/assignment/midifile/
    ////////////////////////////////////////////////
    // MIDI HEADER CHUNK
    ////////////////////////////////////////////////
    string A = "MThd";                      // A = The very first 4 bytes (hex for "MThd") show that the file is a MIDI.
    char B[4] = {0x00,0x00,0x00,0x06};      // B = The next four bytes indicate how big the rest of the MIDI Header is (C, D & E). It's always 00000006 for Standard MIDI Files (SMF).
    char C[2] = {0x00,0x00};                // C = MIDI has sub-formats. 0000 means that's it's a Type-0 MIDI file. 0001 (shown) is Type-1.
    char D[2] = {0x00,0x01};                // D = The number should reflect the number of tracks in the MIDI. Type-0 is limited to 1 track.
    // ANDRE
    char E[2] = {0x00,static_cast<char>(ticksPerBeat)};        // E = The speed of the music. The hexadecimal value 60 shown will mean 96 ticks per quarter note (crotchet). (@120BPM -> 500ms/Beat -> Ttick= 500ms/96 = 5.2ms
    
    ////////////////////////////////////////////////
    // GENERATE MIDI DATA CHUNK
    ////////////////////////////////////////////////
    string F = "MTrk";                      // F = "4D 54 72 6B" is hexadecimal for the ascii "MTrk", and marks the start of the track data.
    vector<char> H;
    
    float Tbuffer_us = roundSIL(float(float(myApp->bufferSize)/float(myApp->sampleRate))*1000*1000,0);
    float Ttick_us   = roundSIL((60.0f/float(bpm))/float(ticksPerBeat)*1000*1000, 0);
    float tickON     =0.0, tickOFF=0.0;
    float ticksPerBuffer = float(Tbuffer_us/Ttick_us);
    
    NoteLimits lastNote;
    lastNote.inicio = 0;
    lastNote.fim = 0;
    
    // Begin of Data CHUNK
    //  Delta time of the first MIDI message (0 ticks)
    H.push_back(0x00);
    // Meta Message #58 = Time Signature
    H.push_back(0xff); H.push_back(0x58); H.push_back(0x04);
    // Message contains 4 bytes: 04 02 30 08
    // 04 = four beats per measure
    // 02 = 2^2 = 4 --> quarter note is the beat
    // 30 = 48 decimal --> clock ticks par quarter note (tempo 60 beats per minute)
    // 08 = 8 32nd notes per quarter note (beat)
    H.push_back(0x04);H.push_back(0x02);H.push_back(ticksPerBeat);H.push_back(0x08);
    
    // Delta time for next message (0 = no wait)
    H.push_back(0x00);
    // Meta Message #51 = Set Tempo
    //FF 51 03 tttttt Set Tempo (in microseconds per MIDI quarter-note)
    H.push_back(0xff);H.push_back(0x51);H.push_back(0x03);
    H.push_back(0x07);H.push_back(0xA1);H.push_back(0x20);
    
    // Delta time for next message (0 = no wait)
    H.push_back(0x00);
    // Meta Message #59 = Key signature
    H.push_back(0xff);H.push_back(0x59);H.push_back(0x02);
    // Message contains 2 bytes: 00 00
    // 00 = no sharps or flats
    // 00 = major mode (01 = minor)
    H.push_back(0x00);H.push_back(0x00);
    
    long tick=0;
    
    // Rest of Midi Data
    for (int i=0;i<myApp->pitchMeterWrapper->midiNotes->noteData.size();i++) {     // H = All the music data. See further below for details.
        
        if (myApp->pitchMeterWrapper->midiNotes->noteData[i].nota!=-1) {
            
            tickON = myApp->pitchMeterWrapper->midiNotes->noteData[i].inicio - lastNote.fim ;
            tick = tickON*ticksPerBuffer;
            
            //  tick = 267;
            
            // DELTA TIME COMPUTATION before ON
            vector<char> Haux = computeMidiDeltaTime(tick,ticksPerBeat);
            H.insert(H.end(), Haux.begin(), Haux.end());
            
            H.push_back(0x90);                                  // Note ON(9)/OFF(8) | CHANNEL
            H.push_back(char(myApp->pitchMeterWrapper->midiNotes->noteData[i].nota));     // NOTE
            H.push_back(127);                                   // VOLUME
            
            tickOFF = myApp->pitchMeterWrapper->midiNotes->noteData[i].fim - myApp->pitchMeterWrapper->midiNotes->noteData[i].inicio;
            tick = tickOFF*ticksPerBuffer;
            
            // DELTA TIME COMPUTATION before OFF
            vector<char> Haux2 = computeMidiDeltaTime(tick,ticksPerBeat);
            H.insert(H.end(), Haux2.begin(), Haux2.end());
            
            // Note OFF
            H.push_back(0x80);                                  // Note ON(9)/OFF(8) | CHANNEL
            H.push_back(char(myApp->pitchMeterWrapper->midiNotes->noteData[i].nota));     // NOTE
            H.push_back(127);                                   // VOLUME
            
            lastNote = myApp->pitchMeterWrapper->midiNotes->noteData[i];
            
            if (myApp->dbgMode) cout << int(tickON*ticksPerBuffer) << endl;
            if (myApp->dbgMode) cout << int(tickOFF*ticksPerBuffer) << endl;
        }
    }
    
    // GET CHUNK DATA SIZE
    long size = H.size() + 4; // G = This should be the number of bytes present in H & I (Track data & Track Out). Shown is 0000000A, so that means 10 more bytes (10 is decimal for hex A).
    char* G = reinterpret_cast<char*>(&size);
    
    // ANDRE
    char I[4] = {0x00,static_cast<char>(0xFF),0x2F,0x00};      // I = 00 FF 2F 00 is required to show that the end of the track has been reached.
    
    ////////////////////////////////////////////////
    // COPY MIDI DATA TO FILE
    ////////////////////////////////////////////////
    ofstream midiFile;
    midiFile.open(ofToString(ofxiPhoneGetDocumentsDirectory() + ofSplitString(filename, ".wav")[0] + ".mid" ).c_str(),ios::binary);
    
    midiFile << A;
    midiFile << hex << B[0]<<B[1]<<B[2]<<B[3];
    midiFile << hex << C[0]<<C[1];
    midiFile << hex << D[0]<<D[1];
    midiFile << hex << E[0]<<E[1];
    midiFile << F;
    midiFile << hex << G[3]<<G[2]<<G[1]<<G[0];
    
    for (int i = 0; i < H.size(); i++) {              // H = All the music data. See further below for details.
        midiFile << hex << H[i];
    }
    
    midiFile << hex << I[0]<<I[1]<<I[2]<<I[3] ;
    midiFile.close();
}

vector<char> ssMidiFileIO::computeMidiDeltaTime(long Nticks, long ticksPerBeat) {
    
    // see info: http://cs.uccs.edu/~cs525/midi/midi.html
    
    vector<char> H;
    
    if (Nticks<ticksPerBeat){
        H.push_back(0b01111111 & Nticks);
    }
    else if (Nticks>=ticksPerBeat) {
        long block7bits1 = Nticks>>7  & 0x000000EF;
        long block7bits0 = Nticks     & 0x000000EF;
        Nticks = (0b10000000 | block7bits1)<<8 | (0b01111111 & block7bits0);
        char* tickChar = reinterpret_cast<char*>(&Nticks);
        H.push_back(tickChar[1]);
        H.push_back(tickChar[0]);
    }
    else if (Nticks>=ticksPerBeat*ticksPerBeat) {
        long block7bits2 = Nticks>>14  & 0x000000EF;
        long block7bits1 = Nticks>>7  & 0x000000EF;
        long block7bits0 = Nticks     & 0x000000EF;
        Nticks = (0b10000000 | block7bits2)<<16 | (0b10000000 | block7bits1)<<8 | (0b01111111 & block7bits0);
        char* tickChar = reinterpret_cast<char*>(&Nticks);
        H.push_back(tickChar[2]);
        H.push_back(tickChar[1]);
        H.push_back(tickChar[0]);
    }
    else if (Nticks>=ticksPerBeat*ticksPerBeat*ticksPerBeat) {
        long block7bits3 = Nticks>>21 & 0x000000EF;
        long block7bits2 = Nticks>>14 & 0x000000EF;
        long block7bits1 = Nticks>>7  & 0x000000EF;
        long block7bits0 = Nticks     & 0x000000EF;
        Nticks = (0b10000000 | block7bits3)<<24 | (0b10000000 | block7bits2)<<16 | (0b10000000 | block7bits1)<<8 | (0b01111111 & block7bits0);
        char* tickChar = reinterpret_cast<char*>(&Nticks);
        H.push_back(tickChar[3]);
        H.push_back(tickChar[2]);
        H.push_back(tickChar[1]);
        H.push_back(tickChar[0]);
    }
    
    return H;
}

void ssMidiFileIO::createMidiFileForExistentWavFiles(void) {
    
    ofDirectory *dirWav,*dirMidi;
    dirWav = new ofDirectory(ofxiPhoneGetDocumentsDirectory());
    dirWav->allowExt("wav");
    dirWav->sort();
    dirWav->listDir();
    bool midiAlreadyExists=false;
    string fileNameWav,fileNameMidi;
    for (int i = 0; i < dirWav->numFiles(); i++)
    {
        fileNameWav = ofSplitString(dirWav->getName(i),".wav")[0];
        dirMidi = new ofDirectory(ofxiPhoneGetDocumentsDirectory());
        dirMidi->allowExt("mid");
        dirMidi->sort();
        dirMidi->listDir();
        // check if correspondent midi file exists
        for (int j = 0; j <  dirMidi->numFiles(); j++)
        {
            fileNameMidi = ofSplitString(dirMidi->getName(j),".mid")[0];
            if (fileNameWav==fileNameMidi){
                midiAlreadyExists = true;
                break;
            }
        }
        if (!midiAlreadyExists)
        {
            myApp->loadWAVfile (fileNameWav);
            saveMidiFile(fileNameWav);
            midiAlreadyExists = false;
        }
        delete dirMidi;
    }
}

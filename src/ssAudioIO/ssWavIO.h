//
//  ssWavIO.h
//  test_ofx73
//
//  Created by Sérgio Ivan Lopes on 2/7/13.
//
//

#ifndef SSWAVIO_H
#define SSWAVIO_H

#include <cstring>
#include <iostream>
#include <fstream>
#include <vector>
#include "tmpFile.h"

using namespace std;

class ssWavIO  {

public:
    
    //--------------------------------------------------------------
    // constructors/desctructor
    //--------------------------------------------------------------
    ~ssWavIO();
    ssWavIO();
	ssWavIO(string tmpPath);

    //--------------------------------------------------------------
    // Load and Save Wav
	//--------------------------------------------------------------
    bool	load(string tmpPath);
	bool	read();
    bool	save();
    
    //--------------------------------------------------------------
    // GETS
    //--------------------------------------------------------------
    string	getPath() { return myPath;}
	bool    getIsLoaded();
    char  *	getSummary();
    int		getChannels();
    int		getSampleRate();
	long	getLengthInSamples();
	long	getLengthInBytes();

    //--------------------------------------------------------------
    // SETS
    //--------------------------------------------------------------
    void	setPath(string newPath);
    void	setChannels(int _nChannels);
    void	setSampleRate(int sampleRate);
	void	setLength(long length);
    void	setResolution(int length);
    
    void updateFloatDataBuffer(TmpFile *tmpFile,int posicao, int tamanho);

    // public buffers
    char  *	myData;
    float * myFloatData;
    
private:
    
    enum SoundFlags { NONE = 0, LOADED = 1 };
    
	string  myPath;
	int 	myChunkSize;
	int		mySubChunk1Size;
	short 	myFormat;
	short 	myChannels;
	int   	mySampleRate;
	int   	myByteRate;
	short 	myBlockAlign;
	short 	myBitsPerSample;
	int		myDataSize;
	unsigned char soundStatus;
};


#endif // SSWAVIO_H

//
//  ssWavIO.cpp
//  test_ofx73
//
//  Created by Sérgio Ivan Lopes on 2/7/13.
//
//

#include "ofMain.h"
#include "ssWavIO.h"
//--------------------------------------------------------------
// Default Constructor
//--------------------------------------------------------------
ssWavIO::ssWavIO()
{
    myData = NULL;
    myFloatData = NULL;
}

//--------------------------------------------------------------
// Constructor for direct File Reading
//--------------------------------------------------------------
ssWavIO::ssWavIO(string tmpPath)
{
    myPath = tmpPath;
    read();
}

//--------------------------------------------------------------
// Default Destructor
//--------------------------------------------------------------
ssWavIO::~ssWavIO()
{
    //delete myPath;
    if (myData!=NULL) delete[] myData;
    if (myFloatData!=NULL) delete[] myFloatData;
    
    myChunkSize = NULL;
    mySubChunk1Size = NULL;
    myFormat = NULL;
    myChannels = NULL;
    mySampleRate = NULL;
    myByteRate = NULL;
    myBlockAlign = NULL;
    myBitsPerSample = NULL;
    myDataSize = NULL;
}

//--------------------------------------------------------------
// Set File Path into class
//--------------------------------------------------------------
void ssWavIO::setPath(string tmpPath) {
    myPath = tmpPath;
}

//--------------------------------------------------------------
// Set Number of channels into class
//--------------------------------------------------------------
void ssWavIO::setChannels(int _nChannels){
    myChannels = _nChannels;
}

//--------------------------------------------------------------
// Set SampleRate into class
//--------------------------------------------------------------
void ssWavIO::setSampleRate(int _sampleRate){
    mySampleRate = _sampleRate;
}

//--------------------------------------------------------------
// Set File length in Bytes
//--------------------------------------------------------------
void ssWavIO::setLength(long _length) {
    myDataSize = _length*2;
}

//--------------------------------------------------------------
// Set Sample Resolution
//--------------------------------------------------------------
void ssWavIO::setResolution(int _res) {
    myBitsPerSample = _res;
}

//--------------------------------------------------------------
// Get Object Sample Rate
//--------------------------------------------------------------
int ssWavIO::getSampleRate(){
    return mySampleRate;
}

//--------------------------------------------------------------
// Get Length in samples
//--------------------------------------------------------------
long ssWavIO::getLengthInSamples()
{
	long length;
//	length = myDataSize*sizeof(char)/myBitsPerSample;
	length = myDataSize*0.5;
	return(length);
}
//--------------------------------------------------------------
// Get Length in bytes
//--------------------------------------------------------------
long ssWavIO::getLengthInBytes()
{
	long length;
	length = myDataSize;
	return(length);
}

//--------------------------------------------------------------
// Get file attributes
//--------------------------------------------------------------
char* ssWavIO::getSummary()
{
    char *summary = new char[250];
    sprintf(summary, " Format: %d\n Channels: %d\n SampleRate: %d\n ByteRate: %d\n BlockAlign: %d\n BitsPerSample: %d\n DataSize: %d\n", myFormat, myChannels, mySampleRate, myByteRate, myBlockAlign, myBitsPerSample, myDataSize);
    std::cout << myDataSize;
    return summary;
}

//--------------------------------------------------------------
// Get number of channels
//--------------------------------------------------------------
int ssWavIO::getChannels()
{
    return myChannels;
}

//--------------------------------------------------------------
// Check if file is already loaded
//--------------------------------------------------------------
bool ssWavIO::getIsLoaded() {
    if(soundStatus & LOADED)
        return true;
    else return false;
}

//--------------------------------------------------------------
// Load a Wav file given a file path
//--------------------------------------------------------------
bool ssWavIO::load(string tmpPath) {
    myPath = tmpPath;
	bool result = read();
	return result;
}

//--------------------------------------------------------------
// Read wav file into class
//--------------------------------------------------------------
bool ssWavIO::read()
{
    myPath = ofToDataPath(myPath,true).c_str();
    ifstream inFile( myPath.c_str(), ios::in | ios::binary);
    
    ofLog(OF_LOG_NOTICE, "Reading file %s",myPath.c_str());
    
    if(!inFile.is_open()) {
        ofLog(OF_LOG_ERROR,"Error opening file. File not loaded.");
        return false;
    }
    
    char id[4];
    inFile.read((char*) &id, 4);
    if(strncmp(id,"RIFF",4) != 0) {
        ofLog(OF_LOG_ERROR,"Error reading sample file. File is not a RIFF (.wav) file");
        return false;
    }
    
    inFile.seekg(4, ios::beg);
    inFile.read( (char*) &myChunkSize, 4 ); // read the ChunkSize
    
    inFile.seekg(16, ios::beg);
    inFile.read( (char*) &mySubChunk1Size, 4 ); // read the SubChunk1Size
    
    //inFile.seekg(20, ios::beg);
    inFile.read( (char*) &myFormat, sizeof(short) ); // read the file format.  This should be 1 for PCM
    if(myFormat != 1) {
        ofLog(OF_LOG_ERROR, "File format should be PCM, sample file failed to load.");
        return false;
    }
    
    //inFile.seekg(22, ios::beg);
    inFile.read( (char*) &myChannels, sizeof(short) ); // read the # of channels (1 or 2)
    
    //inFile.seekg(24, ios::beg);
    inFile.read( (char*) &mySampleRate, sizeof(int) ); // read the Samplerate
    
    //inFile.seekg(28, ios::beg);
    inFile.read( (char*) &myByteRate, sizeof(int) ); // read the byterate
    
    //inFile.seekg(32, ios::beg);
    inFile.read( (char*) &myBlockAlign, sizeof(short) ); // read the blockalign
    
    //inFile.seekg(34, ios::beg);
    inFile.read( (char*) &myBitsPerSample, sizeof(short) ); // read the bitsperSample
    
    inFile.seekg(40, ios::beg);
    inFile.read( (char*) &myDataSize, sizeof(int) ); // read the size of the data
    //cout << myDataSize << endl;
    
    // read the data chunk
    myData = new char[myDataSize];
    inFile.seekg(44, ios::beg);
    inFile.read(myData, myDataSize);
    
    inFile.close(); // close the input file
    
    /////////////////////////////////////////
    // Convert Input RAW data to a float Array
    /////////////////////////////////////////
    // Read data to a float vector
    myFloatData = new float[myDataSize/2];
    
    for (int i=0;i<myDataSize;i=i+2) {
        // Generate a integer sample based in the two Bytes per sample
        short MSByte = ((short) myData[i+1] << 8) & 0xFF00;
        short LSByte = ((short) myData[i]) & 0x00FF;
        short i16In = MSByte | LSByte;
        
        // Convert to Float
        float floatIn = (float) i16In * 1/32768; // PCM 2 Float
        // Save float value in a dedicated buffer
        myFloatData[i/2] = (float) floatIn;
    }
    
    soundStatus |= LOADED;
    
    return true; // this should probably be something more descriptive
}

//--------------------------------------------------------------
// Write the WAV file
//--------------------------------------------------------------
bool ssWavIO::save()
{
    // more WAVFILE info at : http://mathmatrix.narod.ru/Wavefmt.html

    // Prepare WAV Header Data  
    myChunkSize = myDataSize + 44 - 2;
    mySubChunk1Size = 16;
    myFormat = 0x01;
    myByteRate = myChannels*mySampleRate*myBitsPerSample/8;
    myBlockAlign = myChannels*myBitsPerSample/8;

    // Convert myFloatData into ui16 samples 
    myData = new char[myDataSize];
    for (int i=0;i<myDataSize;i=i+2)
        {
        // Convert to Float
        float aux = myFloatData[i/2] * 32768;
        short i16In = (short) aux ; // Float to ui16
        
        short MSB = i16In >> 8 & 0x00FF;
        short LSB = i16In & 0x00FF;
        
        myData[i]   = LSB;
        myData[i+1] = MSB;
        }
    
    // Open File
    ofToDataPath(myPath);
    fstream myFile (myPath.c_str(), ios::out | ios::binary);
    
    // write the wav file per the wav file format
    myFile.seekp (0, ios::beg);
    myFile.write ("RIFF", 4);
    myFile.write ((char*) &myChunkSize, 4);
    myFile.write ("WAVE", 4);
    myFile.write ("fmt ", 4);
    myFile.write ((char*) &mySubChunk1Size, 4);
    myFile.write ((char*) &myFormat, 2);
    myFile.write ((char*) &myChannels, 2);
    myFile.write ((char*) &mySampleRate, 4);
    myFile.write ((char*) &myByteRate, 4);
    myFile.write ((char*) &myBlockAlign, 2);
    myFile.write ((char*) &myBitsPerSample, 2);
    myFile.write ("data", 4);
    myFile.write ((char*) &myDataSize, 4);
    myFile.write (myData, myDataSize);
    
    return true;
}

//--------------------------------------------------------------
// Copy RAW data from tmpFile to myFloatData buffer
//--------------------------------------------------------------
void ssWavIO::updateFloatDataBuffer(TmpFile *tmpFile,int posicao, int tamanho)
{
    myFloatData = new float[tamanho];
    tmpFile->readBlock(myFloatData, posicao, tamanho);
}
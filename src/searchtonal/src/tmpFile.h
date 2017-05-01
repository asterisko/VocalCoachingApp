#ifndef TMP_FILE_H
#define TMP_FILE_H

#include <stdio.h>
#include <string>

#include "ofMain.h"

using namespace std;

class TmpFile {
public:
	TmpFile(string tmpfile_prefix) ;
	~TmpFile();
	int getSize(); 

	// MODO de Float
	float readFast(int posicao);
	bool writeBlockAtEnd(float *dados, int tamanho);
	bool writeBlock(float *dados, int posicao, int tamanho);
	int readBlock(float *dados, int posicao, int tamanho);
	bool trySize(int tamanho);
	bool setSizeZero(int tamanho);

	// MODO de Estrutura
	bool setStructBlockSize(int bsize, void *structDefault_);
	int getStructBlockSize();
	int readStruct(void *dados, int bloco, int nblocos=1);
	bool writeStruct(void *dados, int bloco, int nblocos=1);
	bool setStructSize(int nsize);

private:
	int size;
	int blockSize;
	string *fileTmp;
	FILE *ficheiro;
	void *structDefault;
	float* blocoZero;
	ofMutex *mutex;
	inline bool setSizeZeroInternal(int tamanho);
	bool setStructSizeInternal(int nsize);
	void apagaTmps();
};

#endif
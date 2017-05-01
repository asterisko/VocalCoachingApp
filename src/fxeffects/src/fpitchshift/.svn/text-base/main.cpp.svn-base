#include <iostream>
#include <math.h>

#include "fpitchshift.h"

#include "../utils/iowave/iowave.h"

void process()
{
	int i, Fs, nread, frameCount, frameSize;
	
	//Tamanho da frame + frequência de amostragem
	Fs = 22050;
	frameSize = 512;

	//------------------------------------  
	fpitchshift *f;
	f = new fpitchshift(frameSize, Fs);
	
	int sliderPitch; // [-100,100]
	sliderPitch = 50;
	
	float actPitchVal; //[0.5, 2]
	actPitchVal = (float)pow(2., (double)sliderPitch / 100.);
	//------------------------------------ 

	//Buffer de entrada
	float *inpBuffer;
	inpBuffer = new float[frameSize];
	for(i = frameSize - 1; i >= 0; --i) inpBuffer[i] = 0.0f;

	//Buffer de saida
	float *outBuffer;
	outBuffer = new float[frameSize];
	for(i = frameSize - 1; i >= 0; --i) outBuffer[i] = 0.0f;

	//IOWave
	IOWave *wav;
	wav = new IOWave();

	//Abre ficheiro de entrada
	if(!wav->abre_iofin("woman.wav")) { printf("Nao foi possivel abrir o ficheiro de entrada\n"); exit(1); }
	
	//Abre ficheiro de saida
	if(!wav->abre_iofout("woman_1_2OitavaUp.wav", Fs)) { printf("Nao foi possivel abrir o ficheiro de saida\n"); exit(1); }

	//Contador de frames
	frameCount = 1;
	
	//Lê as primeiras "frameSize" amostras
	nread = 0;
	nread = wav->ler_iofin(inpBuffer, frameSize); 
	if(nread != frameSize) { printf("Nao foi possivel ler do ficheiro\n"); exit(1); }
	
	while(nread == frameSize) 
	{		
		//---------------------------------------------
		f->process(inpBuffer, outBuffer, actPitchVal);
		//---------------------------------------------

		//Escreve no ficheiro de saida
		wav->escreve_iofout(outBuffer, frameSize);

		//Lê novas "frameSize" amostras
		nread = wav->ler_iofin(inpBuffer, frameSize); //Lê novas "frameSize" amostras
		
		//Se necessário faz o "padding" a zero
		if(nread < frameSize) {
			for(i = nread; i < frameSize; i++) inpBuffer[i] = 0.0f;
			f->process(inpBuffer, outBuffer, actPitchVal);
			wav->escreve_iofout(outBuffer, frameSize);
		}
		
		//Actualiza o número de frame lidas
		frameCount++; 
	}

	//Fecha os ficheiros
	wav->fecha_iofin();
	wav->fecha_iofout();

	delete[] inpBuffer; delete[] outBuffer;
	
	delete wav;
	delete f;
}

int main(int argc, char* argv[])
{
	process();
	return 0;
}	
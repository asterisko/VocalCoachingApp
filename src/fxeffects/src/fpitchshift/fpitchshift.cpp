#include "fpitchshift.h"

#include <math.h>
#include <iostream>

#ifndef M_PI_FLOAT
#define M_PI_FLOAT 3.14159265358979323846f
#endif

fpitchshift::fpitchshift(int NBINS_, int Fs_)
{
	int i;
	
	//Tamanhos
	NBINS   = 2 * NBINS_;
	NBINS2  = NBINS >> 1;
	NNBINS  = NBINS + NBINS2;
	NNNBINS = NBINS << 1;

	//Frequência de amostragem
	Fs = Fs_;

	//Factor de sobreposição
	overSamp = 4; //"overSamp" deve ser no minimo 4 e múltiplo inteiro de NBINS
	//Frequência por cada bin na grelha
	fPerBin = (float)Fs / (float)NBINS;
	//Passo de análise
	stepSize = (int)(NBINS / overSamp);
	//Atraso no processamento imposto por "osamp"
	inDelay = NBINS - stepSize; //Latência de entrada
	//Fase base esperada para o bin de ordem 1
	expectedPhase = 2.0f * M_PI_FLOAT * (float)stepSize / (float)NBINS;

	//Vector de acumulação
	acc = new float[NNNBINS];
	for(i = NNNBINS - 1; i >= 0; --i) acc[i] = 0.0f;

	//Vectores de magnitude e fase da análise
	analMagn = new float[NBINS2]; 
	analFreq = new float[NBINS2];
	for(i = NBINS2 - 1; i >= 0; --i) { 
		analMagn[i] = analFreq[i] = 0.0f; 
	}

	//Vectores de magnitude e fase da sintese		
	syntMagn = new float[NBINS2];
	syntFreq = new float[NBINS2];
	for(i = NBINS2 - 1; i >= 0; --i) { 
		syntMagn[i] = syntFreq[i] = 0.0f; 
	}

	//Histórico da fase da frame anterior
	prevPhase = new float[NBINS2];
	for(i = NBINS2 - 1; i >= 0; --i) prevPhase[i] = 0.0f;
	
	//Vector que guarda o somatório da fase
	sumPhase = new float[NBINS2];
	for(i = NBINS2 - 1; i >= 0; --i) sumPhase[i] = 0.0f;

	//Vectores para I\0
	FreqAnalysisData  = new float[NBINS];
	for(i = NBINS - 1; i >= 0; --i) 
		FreqAnalysisData[i] = 0.0f;
	FreqSynthesisData = new float[NBINS2];
	for(i = NBINS2 - 1; i >= 0; --i) 
		FreqSynthesisData[i] = 0.0f;

	//Vector que guarda a janela a utilizar
	freqWindowCoef = new float[NBINS];
	for(i = 0; i < NBINS; i++) 
		freqWindowCoef[i] = 0.5f * (1.0f - cos(2.0f * M_PI_FLOAT * (float)i / (float)NBINS));

	//Resultado da transformada ()
	fftworksp = new float[NNNBINS];
	for(i = NNNBINS - 1; i >= 0; --i) 

	//Inicializa atraso
	gRover = inDelay;
}

fpitchshift::~fpitchshift()
{
	//Processamento I\O
	delete[] FreqAnalysisData; delete[] FreqSynthesisData;
	
	//Análise	
	delete[] acc; delete[] analMagn; delete[] analFreq; delete[] prevPhase;

	//Síntese 
	delete[] syntMagn; delete[] syntFreq; delete[] sumPhase;

	//Transformada
	delete[] fftworksp;
}

void fpitchshift::init()
{
	int i;

	for(i = NBINS - 1; i >= 0; --i) 
		FreqAnalysisData[i] = 0.0f;

	for(i = NBINS2 - 1; i >= 0; --i) {
		analMagn[i] = analFreq[i] = syntMagn[i] = syntFreq[i] = 0.0f;
		FreqSynthesisData[i] = prevPhase[i] = sumPhase[i] = 0.0f;		
	}
	
	for(i = NNNBINS - 1; i >= 0; --i)  
		acc[i] = 0.0f;

	for(i = NNNBINS - 1; i >= 0; --i)
		fftworksp[i] = 0.0f;
		
	//Inicializa atraso
	gRover = inDelay;
}

void fpitchshift::process(float *indata, float *outdata, float shift)
{
	int i, k;

	for (i = 0; i < NBINS2; i++)
	{
		FreqAnalysisData[gRover] = indata[i];
		
		//JM 5Fev08 -> Limitação do sinal de saída
		tmpFloat = FreqSynthesisData[gRover-inDelay];
		if(tmpFloat > 0.85f)       outdata[i] = 0.85f;
		else if(tmpFloat < -0.85f) outdata[i] = -0.85f;
		else 		               outdata[i] = tmpFloat;

		gRover++;
		if (gRover >= NBINS) 
		{
			gRover = inDelay;
			for (k = 0; k < NBINS; k++) {
				fftworksp[2*k] = FreqAnalysisData[k] * freqWindowCoef[k];
				fftworksp[2*k+1] = 0.0f;
			}
			
			FFT(fftworksp, NBINS, -1);
			
			//---------------------------------------------//
			//                 Análise                     //
			//---------------------------------------------//
			for (k = 0; k < NBINS2; k++) {
				
				//-- De-interlace FFT --//
				re = fftworksp[2*k];
				im = fftworksp[2*k+1];

				//-- Calcula magnitude e fase --//
				tmpFloat1 = 2 * sqrt(re*re + im*im);
				tmpFloat2 = atan2(im, re);

				//-- Calcula diferença de fase --//
				tmpFloat3 = tmpFloat2 - prevPhase[k];
				prevPhase[k] = tmpFloat2;

				//-- Subtrai diferença de fase esperada --//
				tmpFloat3 -= k * expectedPhase;
				
				//-- Executa o "unwrapp" da fase --//
				tmpLong = (long)(tmpFloat3 / M_PI_FLOAT);
				if (tmpLong >= 0) 
					tmpLong += tmpLong&1;
				else 
					tmpLong -= tmpLong&1;
				tmpFloat3 -= M_PI_FLOAT * (float)tmpLong;

				//-- Desvio da frequência do bin --//
				tmpFloat3 = overSamp * tmpFloat3 / (2.0f * M_PI_FLOAT);

				//-- Verdadeira frequência dos parciais --//
				tmpFloat3 = (float)k * fPerBin + tmpFloat3 * fPerBin;

				//-- Armazena magnitude e frequência --//
				syntMagn[k] = 0.0f; syntFreq[k] = 0.0f;
				analMagn[k] = 0.0f; analMagn[k] = tmpFloat1;				
				analFreq[k] = 0.0f;	analFreq[k] = tmpFloat3;
			}
			
			//---------------------------------------------//
			//              Pitch shifting                 //
			//---------------------------------------------//
			//printf("Shiftei\n");
			tmpInt = 0;
			for (k = 0; k < NBINS2; k++) { 
				tmpInt = (int)(k * shift);
				if (tmpInt < NBINS2) { 
					syntMagn[tmpInt] += analMagn[k];  //Não preserva as formantes...
					syntFreq[tmpInt] = analFreq[k] * shift; 
				} 
			}			
			
			//---------------------------------------------//
			//                  Síntese                    //
			//---------------------------------------------//
			for (k = 0; k < NBINS2; k++) {	
				
				//-- Magnitude e frequência de síntese --//
				tmpFloat1 = syntMagn[k];
				tmpFloat3 = syntFreq[k];
				
				//-- Subtrai frequência central do bin --//
				tmpFloat3 -= (float) k * fPerBin;
				
				//-- Calcula desvio do bin a partir do desvio de frequência --//
				tmpFloat3 /= fPerBin;

				//--- Refazer pelo factor de sobreposição --//
				tmpFloat3 = 2.0f * M_PI_FLOAT * tmpFloat3 / (float)overSamp; //JM 2Jun07 

				//-- Adiciona a fase em avanço --//
				tmpFloat3 += (float) k * expectedPhase;

				//-- Acumula variação de fase para ter a fase do bin actual --//
				sumPhase[k] += tmpFloat3;
				tmpFloat2 = sumPhase[k];

				//-- Calcula parte real e imaginária e re-interleave --//
				fftworksp[2*k]   = tmpFloat1 * cos(tmpFloat2);
				fftworksp[2*k+1] = tmpFloat1 * sin(tmpFloat2);
			} 

			for (k = NBINS+1; k < NNNBINS; k++) 
				fftworksp[k] = 0.0f;

			FFT(fftworksp, NBINS, 1);

			for(k = 0; k < NBINS; k++)
				acc[k] += 2.0f * freqWindowCoef[k] * fftworksp[2*k] / (NBINS2 * overSamp);

			for (k = 0; k < stepSize; k++) 
				FreqSynthesisData[k] = acc[k];

			memmove(acc, acc + stepSize, NBINS * sizeof(float));

			for (k = 0; k < inDelay; k++) 
				FreqAnalysisData[k] = FreqAnalysisData[k + stepSize];
		}
	}
}

void fpitchshift::FFT(float *fftBuffer, long fftFrameSize, long sign)
{
	float wr, wi, arg, *p1, *p2, temp;
	float tr, ti, ur, ui, *p1r, *p1i, *p2r, *p2i;
	long i, bitm, p, le, le2, k;

	for (i = 2; i < 2*fftFrameSize-2; i += 2) {
		for (bitm = 2, p = 0; bitm < 2*fftFrameSize; bitm <<= 1) {
			if (i & bitm) p++;
			p <<= 1;
		}
		if (i < p) {
			p1 = fftBuffer+i; p2 = fftBuffer+p;
			temp = *p1; *(p1++) = *p2;
			*(p2++) = temp; temp = *p1;
			*p1 = *p2; *p2 = temp;
		}
	}
	for (k = 0, le = 2; k < (long)(logf((float)fftFrameSize)/log(2.0f)+0.5f); k++) {
		le <<= 1;
		le2 = le>>1;
		ur = 1.0;
		ui = 0.0;
		arg = M_PI_FLOAT / (le2>>1);
		wr = cos(arg);
		wi = sign*sin(arg);
		for (p = 0; p < le2; p += 2) {
			p1r = fftBuffer+p; p1i = p1r+1;
			p2r = p1r+le2; p2i = p2r+1;
			for (i = p; i < 2*fftFrameSize; i += le) {
				tr = *p2r * ur - *p2i * ui;
				ti = *p2r * ui + *p2i * ur;
				*p2r = *p1r - tr; *p2i = *p1i - ti;
				*p1r += tr; *p1i += ti;
				p1r += le; p1i += le;
				p2r += le; p2i += le;
			}
			tr = ur*wr - ui*wi;
			ui = ur*wi + ui*wr;
			ur = tr;
		}
	}
}
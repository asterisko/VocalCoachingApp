#ifndef FPITCHSHIFT_H
#define FPITCHSHIFT_H

class fpitchshift {

	public:
		fpitchshift(int NBINS_, int Fs_);
		~fpitchshift();

		void init();
		void process(float *indata, float *outdata, float shift);
	
	private:

		//Tamanhos + frequência de amostragem
		int Fs, NBINS, NBINS2, NNBINS, NNNBINS;

		//Elementos de uso geral
		int tmpInt;
		float tmpFloat;
		long tmpLong;
		float tmpFloat1, tmpFloat2, tmpFloat3;	

		//Processamento I\O
		float  *FreqAnalysisData, *FreqSynthesisData, *freqWindowCoef, *fftworksp;
		
		//Análise	
		int inDelay, stepSize, overSamp, gRover;
		float re, im, fPerBin, expectedPhase;
		float *analMagn, *analFreq, *prevPhase, *acc;

		//Síntese 
		float *syntMagn, *syntFreq, *sumPhase;

		//Funções
		inline void FFT(float *fftBuffer, long fftFrameSize, long sign);

};
#endif
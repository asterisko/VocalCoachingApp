#ifndef TPITCHSHIFTORIG_H
#define TPITCHSHIFTORIG_H

class STATSEG;
class WINDOW;
struct statframe;
class TRANSFORM;

class tpitchshiftorig
{
	public:
		tpitchshiftorig(int NBINS2_, int Fs_);
		~tpitchshiftorig();
		
		void init();	
		void process(float* indata, float* outdata, float shiftFactor);

	private:

		//Tamanhos + frequência de amostragem
		int Fs, NBINS, NBINS2, NNBINS, NNNBINS;
		
		//?
		bool MakeTrigger, MakeSpect;
		long tmpLong;
		int tmpInt1, tmpInt2, tmpInt3;
		float tmpFloat1, tmpFloat2, tmpFloat3;		
		double *tmpDoublePtr1, *tmpDoublePtr2, *tmpDoublePtr3;


		//?
		double binF0;
		float windowCoef;

		//Processamento I\O
		float  gain;
		float  *TimeAnalysisData;
		float  *TimeSynthesisData;
		double *audioData;
		float  *audioDataAlt;
		float  *timeWindowCoefNovo;
		float  **timeWindowArray;

		//Transformada
		STATSEG *out;
		statframe *sframe;
		TRANSFORM *transf;
		WINDOW *window;

		//Controlo de pitch shifting
		float periodShift, pitchRange;

		//Decisão vozeado/não vozeado
		bool currFrameVoiced;
		bool prevFrameVoiced;
		float voicingThres;
		float powerThres;
		float markSharpThresh;

		//Estimação de T0
		int T0Index, currT0, prevT0, numDesloc, numCandidates, halfwindow, centerwindow, centerbin, nbins, numPrevT0, offset, prevOffset, minF0skirt, maxBin;
		float maxT0Value, tmpT0Value, T0Value, difT0, skirtT0, meanPowerdB, maxF0;
		int *T0Candidate, *meanIndexT0, *prevT0Vector;
		float *T0CandidateValue, *meanMaxT0, *cepstrumWeight, *prevWeight;
		
		//Extracção das marcas de pitch de análise
		int realMarkIndex, analPitchMarks;
		float tmpT0, realMarkValue;
		int *pitchMarkIndex;
		float *pitchMarkSharp;

		//Extracção das marcas de pitch de sintese
		int firstPitchSampleIn, syntFirstPitchSampleIn, firstValidMark, syntPitchMarks;
		float syntPrevT0, syntCurrT0, syntDifT0;
		int *syntPitchMarkIndex, *mapPitchMark;

		//Sintese PSOLA
		int rangeOnTheRight, PManalLeft, PManalRight, PMsyntLeft, PMsyntRight;

		//Funções
		inline float calcSum(float *vector, int iIndex, int sIndex); //Cálculo do somatório de vector
		inline void  calcMax(float *vector, int sIndex, int iIndex, int *maxIndex, float *maxValue); //Cálculo do máximo de vector
		inline void  calcMin(float *vector, int sIndex, int iIndex, int *minIndex, float *minValue); //Cálculo do minimo de vector
		inline int fix(float a);
};
#endif
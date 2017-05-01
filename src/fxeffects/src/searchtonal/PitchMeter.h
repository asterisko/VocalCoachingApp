#ifndef _PITCHMETER_H
#define _PITCHMETER_H

#define SIDELOBES_DEFAULT 3


class TmpFile;
class STATSEG;
class WINDOW;
class TRANSFORM;
struct statframe;

class PitchMeter {

private:
	STATSEG *outer;
	TRANSFORM *stransf, *transf;
	statframe *segframe;
	WINDOW *window;
	int janela,num_bins;
	double *dados;

	// Traçado de T0
	float var_MeanF0,var_MaxF0,var_MinF0,var_stdDevF0;
	float var_phoRangeF0,var_majF0;
	float conv_F0;
	int fs;
	void resetF0Vars();
	void create_F0();

	// cálculo e síntese dos parciais
	static void *dummy; // serve para quando não se utilizam todos os termos das funções
	int *peaks, n_maxima, *maxima, truepeaks, *trueell;
	float *deltaell, *truedeltaell, *truemag, *truephi, *audioSynt, *audioSynti, *difphi1, *difphi2, *realTF, *imagTF, partials_G;
	float *newsussurro, *sussurro;


public:
	PitchMeter(int janela_, int num_bins_=-1);
	~PitchMeter();

	// Usado nas análises
	double* calculaCepstrumNorm(float *dados, int fs_); // usada no Cepstrograma
	double* calculaODFTNorm(float *dados_in, bool doTonal=false, int fs=0); // usada no espectro + espectrograma

	void setShiftBins(int shift_bins);
	
	// cálculo e síntese dos parciais
	void partialsFazResetNorm(float *dados_in, int fs); // para "preparar" o searchtonal -> perguntar ao professor
	int partialsPeaksNorm(float *dados_in, double peakEdgeMin, bool saveTF=false, int* &maxima_=(int*&)dummy, float* &deltaell_=(float*&)dummy);
	int partialsPeaksNorm2(double *powerDB, double *power,double peakEdgeMin);
	int partialsPeaksFino(int npartials0, float f0pitch0, int* &trueell_=(int*&)dummy, float* &truedeltaell_=(float*&)dummy, float* &truemag_=(float*&)dummy, int sidelobes=SIDELOBES_DEFAULT);
	int partialsPeaksFino(int fs, int* &trueell_=(int*&)dummy, float* &truedeltaell_=(float*&)dummy, float* &truemag_=(float*&)dummy);
	int partialsPeaksFino2(int fs, int* &trueell_, float* &truedeltaell_, float* &truemag_, int nharms);
	int partialsPeaksFino2(int npartials0,float f0pitch0, double *powerDB,int* &trueell_, float* &truedeltaell_, float* &truemag_, int sidelobes=SIDELOBES_DEFAULT);
	float partialsGetLastF0();
	void partialsFasesFino(float* &truephi_=(float*&)dummy, float* &difphi1_=(float*&)dummy, float* &difphi2_=(float*&)dummy, bool calcDPhase=true);
	enum tipoSintese {SYNT_MAG, SYNT_MAG_DB, SYNT_DIFF, SYNT_DIFF_DB, SYNT_CPLX, SOUND_PARCIAIS, SOUND_DIFF, SYNT_DIFF_DB_SMOOTH};
	float* partialsSyntTonal(int sidelobes=SIDELOBES_DEFAULT, float minVal=0.0f, float maxVal=120.0f, tipoSintese tps = SYNT_CPLX, float* &imagPower=(float*&)dummy);
	float* parciaisSyntSound(tipoSintese tps = SOUND_PARCIAIS, bool putWinfullSeno=true);

	// Cálculo da energia de um sinal
	double calcEnergyNorm(float *data, bool addFirstBin=true);
	bool partialsCalcEnergy(double &energyAmostras, double &energyHarm, double &energyDiff);
	statframe* getValue(double*,int fs);
	double *fazOverlap();
	statframe* getValueOverlap(int fs);
	float getF0harm();
	double* getPowerDB();
	double* getPower();
    double getFramePower_dB(); // ANDRE
	void fazReset();

	// Traçado de T0
	void calculaPitch(TmpFile* tmpfile, int fs_, bool hc=false, bool mp=false);
	void resetF0Array();
	float MeanF0();
	float MeanF0(int start, int end);
	float MaxF0();
	float MaxF0(int start, int end);
	float MinF0();
	float MinF0(int start, int end);
	float standard_deviationF0();
	float standard_deviationF0(int start, int end);
	float phonatory_range_F0();

	//JL 18/07/07
	float getMeanPower(); 
	float* meanPowerVal;
	void setValue(float value);
	float getMaxPower();
	float getMinPower();
	//
	//JL 5Set07
	double getGwindow();
	//

	int pitchSize;
	float *pitchVal;
	unsigned char *nharmsVal;
	float maxPower;
	float minPower;
	
	int shift_bins;

};

#endif

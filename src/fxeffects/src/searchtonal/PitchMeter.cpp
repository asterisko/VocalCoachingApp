#include "window.h"
#include "common.h"
#include "transform.h"
#include "segment.h"
#include "statseg.h"
#include "tmpFile.h"	// para aceder aos dados em ficheiro temporário

#include "PitchMeter.h"

#include "ssGlobals.h"

#define F0_MINIMO 10.0f
#define MIN_TOLERANCE_VALUE 1.2f

#define LOG_LEVEL LOG_WARN
#include "logging.h"

#ifndef PI_FLOAT
#define PI_FLOAT 3.1415926535897932384626433832795f
#endif
#ifndef PI2_FLOAT
#define PI2_FLOAT 6.283185307179586476925286766559f
#endif

PitchMeter::PitchMeter(int janela_, int num_bins_){

	janela	 = janela_;

	if(num_bins_==-1)
		num_bins = janela >> 1;
	else
		num_bins=num_bins_;
	shift_bins=num_bins;
	outer	 = new STATSEG(janela);
	segframe = new statframe();
	transf	 = new TRANSFORM(janela);
	window	 = new WINDOW(janela, SINE);
	segframe->janela = REGULAR;
	dados = new double[janela];
	nharmsVal = NULL;
	meanPowerVal = pitchVal = NULL;
	resetF0Array();
	fazReset();
	pitchSize = maxPower=0;
	// cálculo e síntese dos parciais
	trueell = maxima = NULL;
	truephi = audioSynt = realTF = NULL;
	sussurro = NULL;
	outer->resettonal();
}

PitchMeter::~PitchMeter() {
	resetF0Array();
	if(pitchVal != NULL)	 delete pitchVal;
	if(nharmsVal != NULL)	 delete nharmsVal;
	if(meanPowerVal != NULL) delete meanPowerVal;
	delete outer; delete transf; delete window; delete segframe; delete dados;
	if(maxima != NULL)	  { delete maxima;	  delete peaks;		   delete deltaell; }
	if(trueell != NULL)	  { delete trueell;	  delete truedeltaell; delete truemag;	}
	if(truephi != NULL)	  { delete truephi;	  delete difphi1;	   delete difphi2;	}
	if(audioSynt != NULL) { delete audioSynt; delete audioSynti; }
	if(realTF != NULL)	  { delete realTF;	  delete imagTF; }
	if(sussurro != NULL) { delete newsussurro; delete sussurro; }
}

float PitchMeter::getF0harm() {
	return segframe->sinusinfo.f0harm;
}

double PitchMeter::getFramePower_dB() {
    return outer->getFramePower_dB();
}

double* PitchMeter::getPowerDB(){
	return outer->getPowerdB();
}

double* PitchMeter::getPower(){
	return outer->getPower();
}

statframe* PitchMeter::getValue(double* samp, int fs) {
	outer->getdouble(samp);
	outer->dirsegtrans(*transf,*window,ODFT,REGULAR); // ajf 8/9/00 MDCT -> ODFT
	outer->transmag(janela);
    outer->searchtonalAnalysis(*transf, ODFT, *segframe, (float) fs, (float)fs*16, janela); // ajf 30dec06
    return segframe;
}

double* PitchMeter::fazOverlap() {
	memcpy(dados, dados + shift_bins, (janela-shift_bins)*sizeof(double));
	return dados + (janela-shift_bins);
}

statframe* PitchMeter::getValueOverlap(int fs) {
	outer->getdouble(dados);
	outer->dirsegtrans(*transf,*window,ODFT,REGULAR); // ajf 8/9/00 MDCT -> ODFT	 
	outer->transmag(janela);
	outer->searchtonalAnalysis(*transf, ODFT, *segframe, (float) fs, (float)fs*16, janela); // ajf 30dec06
	return segframe;
}

void PitchMeter::fazReset() {
	for(int i=0; i<janela; i++) dados[i] = 0.0;
	outer->resettonal();
}

double* PitchMeter::calculaCepstrumNorm(float *dados_in, int fs_) {
	int i;
	for(i=0;i<janela; i++) dados[i] = dados_in[i] * 32767.0;
	getValue(dados, fs_);
	return outer->get_recoeftf();
}

double* PitchMeter::calculaODFTNorm(float *dados_in, bool doTonal, int fs) {
	int i;
	for(i=0;i<janela; i++) dados[i] = dados_in[i] * 32767.0;
	outer->getdouble(dados);
	outer->dirsegtrans(*transf,*window,ODFT,REGULAR);
	outer->transmag(janela);
	// double m=0.0, *s = outer->getPowerdB(); for(i=0; i<num_bins; i++) m=s[i]>m?s[i]:m; printf("(%f)",m);
	if(doTonal) outer->searchtonalAnalysis(*transf, ODFT, *segframe, (float) fs, (float)fs*16, janela);
	return outer->getPowerdB();
}

void* PitchMeter::dummy = NULL;

void PitchMeter::partialsFazResetNorm(float *dados_in, int fs) {
	for(int i=0;i<janela; i++)
		dados[i] = dados_in[i] * 32767.0;
	outer->resettonal();
	outer->getdouble(dados);
	outer->dirsegtrans(*transf,*window,ODFT,REGULAR);
	outer->transmag(janela);
	outer->searchtonalAnalysis(*transf, ODFT, *segframe, (float) fs, (float)fs*16, janela);
}

int PitchMeter::partialsPeaksNorm(float *dados_in, double peakEdgeMin, bool saveTF, int* &maxima_, float* &deltaell_) {
	for(int i=0;i<janela; i++) dados[i] = dados_in[i] * 32767.0f;
	//outer->resettonal();
	outer->getdouble(dados);
	outer->dirsegtrans(*transf,*window,ODFT,REGULAR);
	outer->transmag(janela);

	// get Peaks (copiado de PeaksValeys)
	int i,ind, maxcount;
	double peakMag, leftDiff,rightDiff, *magnitude = outer->getPowerdB(), *tmpf1, *tmpf2;
	static int binlim_ant;
	if(saveTF) {
		if(realTF == NULL) {
			realTF = new float[num_bins];
			imagTF = new float[num_bins];
		}
		tmpf1 = outer->get_recoeftf();
		tmpf2 = outer->get_imcoeftf();
		// APAGAR
		//float soma=0;
		for(i=0;i<num_bins;i++) {
			realTF[i] = (float)tmpf1[i];
			imagTF[i] = (float)tmpf2[i];
		//	soma += realTF[i]*realTF[i] + imagTF[i]*imagTF[i];
		}
		//cerr << "soma: " << soma << endl;
	}
	// APAGAR
	/*
	cerr << "odft = [ ";
	for(i=0;i<num_bins;i++) cerr << realTF[i] << (imagTF[i]<0?"":"+") << imagTF[i] << "i, ";
	cerr << " ]"<<endl;
	*/
	/*
	cerr << "samples:" <<endl;
	for(i=0;i<janela;i++) cerr << i << " > " << (int)round(dados[i]) << endl;
	*/


	if(maxima == NULL) { // criar vectores e inicializar variáveis constantes
		peaks = new int[num_bins];
		maxima = new int[num_bins];
		deltaell = new float[num_bins];
		binlim_ant = num_bins-1;
	}
	maxcount = 0; n_maxima = 0; // "reset" aos vectores
	for(ind = 1; ind < binlim_ant; ind++) // corrigido de 2 para 1
		if(magnitude[ind-1]<magnitude[ind] && magnitude[ind+1] < magnitude[ind])
			peaks[maxcount++] = ind;
	for(i=0;i<maxcount;i++) {
		ind = peaks[i];
		peakMag = magnitude[ind];
		while(ind > 0 && magnitude[ind-1] <= magnitude[ind]) ind--;
		leftDiff = peakMag - magnitude[ind];
		ind = peaks[i];
		while(ind < binlim_ant && magnitude[ind+1] <= magnitude[ind]) ind++;
		rightDiff = peakMag - magnitude[ind];
		if(leftDiff > peakEdgeMin && rightDiff > peakEdgeMin && peakMag > 0.0) maxima[n_maxima++] = peaks[i];
	}
	//printf("maxima[%i]:(",n_maxima); for(i=0; i<n_maxima; i++) printf(" %i",maxima[i]); printf(")\n");
	//printf("bins replicados:("); for(i=1; i<n_maxima; i++) if(maxima[i-1]==maxima[i])printf(" %i",i); printf(")\n");

	double* power=outer->getPower();
	if(deltaell == NULL) deltaell = new float[num_bins];
	for(i=0; i<n_maxima; i++) deltaell[i] = outer->exactdeltaell((float)power[maxima[i]-1],(float)power[maxima[i]],(float)power[maxima[i]+1]);

	maxima_ = maxima;
	deltaell_ = deltaell;
	/* // APAGAR
	cerr << "n_maxima " << n_maxima << endl;
	for(i=0;i<n_maxima;i++) cerr << i+1<<" > " <<maxima[i] << endl;
	*/
	/*
	cerr << "deltaell: " << n_maxima << endl;
	for(i=0;i<n_maxima;i++) cerr << i+1<<" > " <<deltaell[i] << endl;
	*/
	return n_maxima;
}

int PitchMeter::partialsPeaksNorm2(double *powerDB, double *power,double peakEdgeMin) {
	double *magnitude=powerDB;
	
	// get Peaks (copiado de PeaksValeys)
	int i,ind, maxcount;
	double peakMag, leftDiff,rightDiff;
	static int binlim_ant;


	if(maxima == NULL) { // criar vectores e inicializar variáveis constantes
		peaks = new int[num_bins];
		maxima = new int[num_bins];
		deltaell = new float[num_bins];
		binlim_ant = num_bins-1;
	}
	maxcount = 0; n_maxima = 0; // "reset" aos vectores
	for(ind = 1; ind < binlim_ant; ind++) // corrigido de 2 para 1
		if(magnitude[ind-1]<magnitude[ind] && magnitude[ind+1] < magnitude[ind])
			peaks[maxcount++] = ind;
	for(i=0;i<maxcount;i++) {
		ind = peaks[i];
		peakMag = magnitude[ind];
		while(ind > 0 && magnitude[ind-1] <= magnitude[ind]) ind--;
		leftDiff = peakMag - magnitude[ind];
		ind = peaks[i];
		while(ind < binlim_ant && magnitude[ind+1] <= magnitude[ind]) ind++;
		rightDiff = peakMag - magnitude[ind];
		/*if(leftDiff > peakEdgeMin && rightDiff > peakEdgeMin && peakMag > 0.0) maxima[n_maxima++] = peaks[i];*/ // Alterado por Vítor Almeida, 31/10/2012
		if((leftDiff > peakEdgeMin || rightDiff > peakEdgeMin) && peakMag > 0.0) maxima[n_maxima++] = peaks[i];
	}
	//printf("maxima[%i]:(",n_maxima); for(i=0; i<n_maxima; i++) printf(" %i",maxima[i]); printf(")\n");
	//printf("bins replicados:("); for(i=1; i<n_maxima; i++) if(maxima[i-1]==maxima[i])printf(" %i",i); printf(")\n");

	//double* power=outer->getPower();
	if(deltaell == NULL) deltaell = new float[num_bins];
	for(i=0; i<n_maxima; i++) deltaell[i] = outer->exactdeltaell((float)power[maxima[i]-1],(float)power[maxima[i]],(float)power[maxima[i]+1]);

	/* // APAGAR
	cerr << "n_maxima " << n_maxima << endl;
	for(i=0;i<n_maxima;i++) cerr << i+1<<" > " <<maxima[i] << endl;
	*/
	/*
	cerr << "deltaell: " << n_maxima << endl;
	for(i=0;i<n_maxima;i++) cerr << i+1<<" > " <<deltaell[i] << endl;
	*/
	return n_maxima;
}


float PitchMeter::partialsGetLastF0() {
	return segframe->sinusinfo.f0harm;
}

// Esta função em princípio nunca é invocada
int PitchMeter::partialsPeaksFino(int fs, int* &trueell_, float* &truedeltaell_, float* &truemag_) {
	LOG(LOG_WARN,"A função de cálculo dos picos fino precisou de recorrer ao searchtonal")
	if(maxima==NULL) return 0;
	outer->searchtonalAnalysis(*transf, ODFT, *segframe, (float) fs, (float)fs*16, janela); // ajf 30dec06
	int nharms = segframe->sinusinfo.nharmonic > 0 ? segframe->sinusinfo.nharmonic + segframe->sinusinfo.npause : 0;
//	printf("Valores: nharms=%i, F0=%f, fs=%i\n",nharms, segframe->sinusinfo.f0harm,fs);
	int saida = partialsPeaksFino(nharms, segframe->sinusinfo.f0harm, trueell_, truedeltaell_, truemag_);
	return saida;
}

// Esta função em princípio nunca é invocada
int PitchMeter::partialsPeaksFino2(int fs, int* &trueell_, float* &truedeltaell_, float* &truemag_, int nharms_) {
	if(maxima==NULL) return 0;
	outer->searchtonalAnalysis(*transf, ODFT, *segframe, (float) fs, (float)fs*16, janela); // ajf 30dec06
	//int nharms = segframe->sinusinfo.nharmonic > 0 ? segframe->sinusinfo.nharmonic + segframe->sinusinfo.npause : 0;
//	printf("Valores: nharms=%i, F0=%f, fs=%i\n",nharms, segframe->sinusinfo.f0harm,fs);
	int nharms=nharms_, f0=segframe->sinusinfo.f0harm;
	if(f0==0) nharms=0;
	int saida = partialsPeaksFino(nharms,f0, trueell_, truedeltaell_, truemag_);
	return saida;
}

int PitchMeter::partialsPeaksFino(int npartials0, float f0pitch0, int* &trueell_, float* &truedeltaell_, float* &truemag_, int sidelobes) {
	if(maxima==NULL) return 0;
	int m, nmaxpartials;
	float tolerance;
	static float inv_janela;

	// APAGAR
	// f0pitch0 = 4.615f;
	// cerr << "f0pitch0: " << f0pitch0 << endl;

	if(trueell==NULL) { // criar vectores e inicializar variáveis constantes
		trueell = new int[num_bins];
		truedeltaell = new float[num_bins];
		truemag = new float[num_bins];
		partials_G = 0.5f*sin(0.5f*PI_FLOAT/janela);
		inv_janela = 1.0f / janela;
	}

	if(npartials0>0) {
		nmaxpartials = (int)((num_bins - sidelobes)/f0pitch0)-1;
		if(nmaxpartials<1) nmaxpartials=1;
	} else nmaxpartials=0;
	
	truepeaks = 0;
	tolerance = 0.25f * f0pitch0;
	if(tolerance < MIN_TOLERANCE_VALUE) tolerance = MIN_TOLERANCE_VALUE;

	int pointer = 0, max_maxima = n_maxima-1;
	float dtmp, difaft, difbef;
	static int frame=0;
/*
	cerr << "maxima = [ ";
	for(m=0; m<n_maxima; m++) cerr << maxima[m] << ", ";
	cerr << "]" << endl;
	cerr << "deltaell = [ ";
	for(m=0; m<n_maxima; m++) cerr << deltaell[m] << ", ";
	cerr << "]" << endl;
*/
	for(m=0; m<nmaxpartials; m++) {
		dtmp = f0pitch0 * (m+1);
		if(pointer >= max_maxima) break; 
		while((float)maxima[pointer] + deltaell[pointer] <= dtmp && pointer < max_maxima) pointer++;
		difaft = abs((float)maxima[pointer] + deltaell[pointer] - dtmp);
		difbef = pointer > 0 ? abs(dtmp - (float)maxima[pointer-1] - deltaell[pointer-1]) : 1E4f;
		//cerr << pointer << " " << truepeaks << " " << difaft << " " << difbef;
		if( difaft < difbef ) {
			if(difaft <= tolerance) {
				// mais tarde remover...
				//cerr << " B1";
				// if(pointer<0 || pointer >= nmaxpartials) { cerr << "ERRO 1 de ALGORITMO: " << pointer << " de " << nmaxpartials << endl; break; }
				trueell[truepeaks] = maxima[pointer];
				truedeltaell[truepeaks] = deltaell[pointer];
				pointer++; truepeaks++;
			}
		} else {
			if(difbef <= tolerance) {
				// mais tarde remover...
				//cerr << " B2";
				// if(pointer<1 || pointer >= nmaxpartials) { cerr << "ERRO 2 de ALGORITMO: " << pointer << " de " << nmaxpartials << endl; break; }
				trueell[truepeaks] = maxima[pointer-1];
				truedeltaell[truepeaks] = deltaell[pointer-1];
				truepeaks++;
			}
		}
		//cerr << endl;
	}
	//printf("Truepeaks[%i]:(",truepeaks); for(m=0; m<truepeaks; m++) printf(" %i",trueell[m]); printf(")\n");
	//printf("bins replicados: m=%i(",missing0); for(m=1; m<truepeaks; m++) if(trueell[m-1]==trueell[m]) printf(" %i",trueell[m]); printf(")\n");

	// truemag = getPSD(envodft, trueell, truedeltaell, N);
	double *envodft = outer->getPowerdB();
	static float LPZ = 1.0f/6.0f, HPZ = 1.0f - LPZ;
	float deltaL;
	for(m=0;m<truepeaks;m++) {
		deltaL = truedeltaell[m];
		if(deltaL < LPZ) {
			truemag[m] = (float)envodft[trueell[m]] - 20.0f * log10(partials_G * abs(abs(cos(PI_FLOAT * 
				(deltaL-0.5f)))/sin(PI_FLOAT * inv_janela *(1.0f - deltaL)) + janela));
		} else {
			if(deltaL > HPZ) truemag[m] = (float)envodft[trueell[m]] - 20.0f * log10(partials_G * 
				abs(abs(cos(PI_FLOAT * (deltaL-0.5f)))/sin(PI_FLOAT * inv_janela *(deltaL)) + janela));
			else truemag[m] = (float)envodft[trueell[m]] - 20 * log10(partials_G * cos(PI_FLOAT * (deltaL-0.5f)) * 
				abs ( 1.0f / sin(PI_FLOAT * inv_janela * (1.0f - deltaL)) + 1.0f / sin(PI_FLOAT * inv_janela * deltaL)));
		}
		// printf("%f ",truemag[m]);
	}
	// valores de saida
	trueell_ = trueell;
	truedeltaell_ = truedeltaell;
	truemag_ = truemag;

	// APAGAR
	// for(m=0;m<truepeaks;m++) cerr << m << ">" << trueell[m] << " "<< truedeltaell[m] << " " << truemag[m] << endl;
	// cerr << "TRUEPEAKS " << truepeaks << endl;
	return truepeaks;
}

int PitchMeter::partialsPeaksFino2(int npartials0, float f0pitch0, double *powerDB,int* &trueell_, float* &truedeltaell_, float* &truemag_, int sidelobes) {
	if(maxima==NULL) return 0;
	int m, nmaxpartials;
	float tolerance;
	static float inv_janela;

	// APAGAR
	// f0pitch0 = 4.615f;
	// cerr << "f0pitch0: " << f0pitch0 << endl;

	if(trueell==NULL) { // criar vectores e inicializar variáveis constantes
		trueell = new int[num_bins];
		truedeltaell = new float[num_bins];
		truemag = new float[num_bins];
		partials_G = 0.5f*sin(0.5f*PI_FLOAT/janela);
		inv_janela = 1.0f / janela;
	}

	if(npartials0>0) {
		nmaxpartials = (int)((num_bins - sidelobes)/f0pitch0)-1;
		if(nmaxpartials<1) nmaxpartials=1;
	} else nmaxpartials=0;
	
	truepeaks = 0;
	tolerance = 0.25f * f0pitch0;
	if(tolerance < MIN_TOLERANCE_VALUE) tolerance = MIN_TOLERANCE_VALUE;

	int pointer = 0, max_maxima = n_maxima-1;
	float dtmp, difaft, difbef;
	static int frame=0;
/*
	cerr << "maxima = [ ";
	for(m=0; m<n_maxima; m++) cerr << maxima[m] << ", ";
	cerr << "]" << endl;
	cerr << "deltaell = [ ";
	for(m=0; m<n_maxima; m++) cerr << deltaell[m] << ", ";
	cerr << "]" << endl;
*/
	for(m=0; m<nmaxpartials; m++) {
		dtmp = f0pitch0 * (m+1);
		if(pointer >= max_maxima) break; 
		while((float)maxima[pointer] + deltaell[pointer] <= dtmp && pointer < max_maxima) pointer++;
		difaft = abs((float)maxima[pointer] + deltaell[pointer] - dtmp);
		difbef = pointer > 0 ? abs(dtmp - (float)maxima[pointer-1] - deltaell[pointer-1]) : 1E4f;
		//cerr << pointer << " " << truepeaks << " " << difaft << " " << difbef;
		if( difaft < difbef ) {
			if(difaft <= tolerance) {
				// mais tarde remover...
				//cerr << " B1";
				// if(pointer<0 || pointer >= nmaxpartials) { cerr << "ERRO 1 de ALGORITMO: " << pointer << " de " << nmaxpartials << endl; break; }
				trueell[truepeaks] = maxima[pointer];
				truedeltaell[truepeaks] = deltaell[pointer];
				pointer++; truepeaks++;
			}
		} else {
			if(difbef <= tolerance) {
				// mais tarde remover...
				//cerr << " B2";
				// if(pointer<1 || pointer >= nmaxpartials) { cerr << "ERRO 2 de ALGORITMO: " << pointer << " de " << nmaxpartials << endl; break; }
				trueell[truepeaks] = maxima[pointer-1];
				truedeltaell[truepeaks] = deltaell[pointer-1];
				truepeaks++;
			}
		}
		//cerr << endl;
	}
	//printf("Truepeaks[%i]:(",truepeaks); for(m=0; m<truepeaks; m++) printf(" %i",trueell[m]); printf(")\n");
	//printf("bins replicados: m=%i(",missing0); for(m=1; m<truepeaks; m++) if(trueell[m-1]==trueell[m]) printf(" %i",trueell[m]); printf(")\n");

	// truemag = getPSD(envodft, trueell, truedeltaell, N);
	double *envodft = powerDB;
	static float LPZ = 1.0f/6.0f, HPZ = 1.0f - LPZ;
	float deltaL;
	for(m=0;m<truepeaks;m++) {
		deltaL = truedeltaell[m];
		if(deltaL < LPZ) {
			truemag[m] = (float)envodft[trueell[m]] - 20.0f * log10(partials_G * abs(abs(cos(PI_FLOAT * 
				(deltaL-0.5f)))/sin(PI_FLOAT * inv_janela *(1.0f - deltaL)) + janela));
		} else {
			if(deltaL > HPZ) truemag[m] = (float)envodft[trueell[m]] - 20.0f * log10(partials_G * 
				abs(abs(cos(PI_FLOAT * (deltaL-0.5f)))/sin(PI_FLOAT * inv_janela *(deltaL)) + janela));
			else truemag[m] = (float)envodft[trueell[m]] - 20 * log10(partials_G * cos(PI_FLOAT * (deltaL-0.5f)) * 
				abs ( 1.0f / sin(PI_FLOAT * inv_janela * (1.0f - deltaL)) + 1.0f / sin(PI_FLOAT * inv_janela * deltaL)));
		}
		// printf("%f ",truemag[m]);
	}
	// valores de saida
	trueell_ = trueell;
	truedeltaell_ = truedeltaell;
	truemag_ = truemag;

	// APAGAR
	// for(m=0;m<truepeaks;m++) cerr << m << ">" << trueell[m] << " "<< truedeltaell[m] << " " << truemag[m] << endl;
	// cerr << "TRUEPEAKS " << truepeaks << endl;
	return truepeaks;
}


void PitchMeter::partialsFasesFino(float* &truephi_, float* &difphi1_, float* &difphi2_, bool calcDPhase) {
	if(trueell==NULL) return;
	double* phaseODFT = outer->getPhase();
	float dtmp, newphi, curphase;
	static float deltanewphi;
	int m;
	if(truephi==NULL) {
		truephi = new float[num_bins];
		difphi1 = new float[num_bins];
		difphi2 = new float[num_bins];
		deltanewphi = PI_FLOAT * (1.0f - 1.0f / janela);
	}
	if(truepeaks>0) {
		// truephi = getphase(phaseodft, trueell, truedeltaell, N);
		for(m=0;m<truepeaks;m++) {
			truephi[m] = (float)phaseODFT[trueell[m]];
			if(truephi[m] > PI_FLOAT) truephi[m] -= PI2_FLOAT;
			if(truephi[m] < -PI_FLOAT) truephi[m] += PI2_FLOAT;
		}
		// for(m=0;m<truepeaks;m++) printf("[%f]",truephi[m]);

		// difphi = difphase2(phaseodft, trueell, N, sidelobes);
		if(calcDPhase) {
			for(m=0;m<truepeaks;m++) {
				newphi = (curphase = (float)phaseODFT[trueell[m]]) + deltanewphi;
				if(newphi > PI_FLOAT) newphi -= PI2_FLOAT;
				// % phase deviation of spectral lines ell-k <-> ell-1
				dtmp = (float)phaseODFT[trueell[m]-1] - newphi;
				if(dtmp > PI_FLOAT) dtmp -= PI2_FLOAT;
				if (dtmp < -PI_FLOAT) dtmp += PI2_FLOAT;
				difphi1[m] = dtmp;
				// % phase to be used above ell
				newphi = curphase - deltanewphi;
				if(newphi < -PI_FLOAT) newphi += PI2_FLOAT;
				//% phase deviation of spectral lines ell+2 <-> ell+k
				dtmp = (float)phaseODFT[trueell[m]+1] - newphi;
				if(dtmp > PI_FLOAT) dtmp -= PI2_FLOAT;
				if (dtmp < -PI_FLOAT) dtmp += PI2_FLOAT;
				difphi2[m] = dtmp;
				// printf("{%f,%f}",difphi1[m], difphi2[m]);
			}
		} else for(m=0;m<truepeaks;m++) difphi1[m] = difphi2[m] = 0.0f;
	}

	// APAGAR
	// for(m=0;m<truepeaks;m++) cerr << m << ">" << truephi[m] << " "<< difphi1[m] << " " << difphi2[m] << endl;

	truephi_ = truephi;
	difphi1_ = difphi1;
	difphi2_ = difphi2;
}

float* PitchMeter::partialsSyntTonal(int sidelobes, float minVal, float maxVal, tipoSintese tps, float* &imagPower) {
	if(truephi==NULL) return NULL;
	static int i,m;
	static float LPZ = 1.0f/6.0f, HPZ = 1.0f - LPZ, inv_20 = 1.0f/20.0f, inv_janela, janelaf;
	double *magnitude = outer->getPower();
	if(audioSynt == NULL) {
		audioSynt = new float[num_bins]; // part real e saida
		audioSynti = new float[num_bins]; // parte imaginária
		inv_janela = 1.0f/janela; // acelerar desempenho
		janelaf = (float)janela; // acelerar desempenho
	}
	for(i=0; i<num_bins; i++) audioSynti[i] = audioSynt[i]=0.0f;

	static float normag,tonalpeak;
	static int elle; static float deltaL, Phi, newphi;
	for(m=0; m<truepeaks; m++) {
		/* syntonal(truedata, trueell(s), truedeltaell(s), truemag(s), truephi(s), difphi(s,:), N, sidelobes);
		   syntonal(Datain,   elle,       deltaL,          PSD,        Phi,        difPhi,      N, nsidelobes) */
		// % This function synthesizes the complex representation of a single sinusoid
		elle = trueell[m]; deltaL = truedeltaell[m]; Phi = truephi[m];
		// % accurate magnitude value of the sinusoid
		tonalpeak = pow(10.0f,truemag[m] * inv_20);
		//	%synthesis of spectral line ell
		if(deltaL < LPZ) normag = partials_G * abs(janelaf + abs(cos(PI_FLOAT * (deltaL-0.5f)))/sin(PI_FLOAT * inv_janela * (1.0f - deltaL)));
		else { if(deltaL > HPZ) normag = partials_G * abs(abs(cos(PI_FLOAT * (deltaL-0.5f)))/sin(PI_FLOAT * inv_janela * deltaL) + janelaf);
			else normag = partials_G * cos(PI_FLOAT * (deltaL-0.5f)) * abs(1.0f / sin(PI_FLOAT * inv_janela * (1.0f - deltaL)) + 1.0f / sin(PI_FLOAT * inv_janela * deltaL)); }
		// % normag = PSD;
		newphi = Phi; // redundante
		if(newphi > PI_FLOAT) newphi -= PI2_FLOAT; // redundante
		if(newphi < -PI_FLOAT) newphi += PI2_FLOAT; // redundante
		audioSynt[elle] += tonalpeak * normag * cos(newphi);
		audioSynti[elle] += tonalpeak * normag * sin(newphi);
		// % phase to be used below ell
		newphi = Phi + PI_FLOAT * (1.0f - 1.0f * inv_janela) + difphi1[m];
		if(newphi > PI_FLOAT) newphi -= PI2_FLOAT;
		if(newphi < -PI_FLOAT) newphi += PI2_FLOAT;
		// %synthesis of spectral line ell-1
		if(deltaL < LPZ) normag = partials_G * abs(abs(cos(PI_FLOAT * (deltaL-0.5f)))/sin(PI_FLOAT * inv_janela *(1.0f+deltaL)) - janelaf);
		else normag = partials_G * cos(PI_FLOAT*(deltaL-0.5f)) * abs(1.0f/sin(PI_FLOAT * inv_janela *(1.0f+deltaL)) + 1.0f/sin( -PI_FLOAT * inv_janela * deltaL));
		audioSynt[elle-1] += tonalpeak * normag * cos(newphi);
		audioSynti[elle-1] += tonalpeak * normag * sin(newphi);
		// %synthesis of spectral lines ell-k <-> ell-2
		for(int k = 2; k <= 1+sidelobes; k++) {
			normag = partials_G * cos(PI_FLOAT * (deltaL-0.5f)) * abs(1.0f/sin(PI_FLOAT * inv_janela * (1.0f - deltaL - k)) + 1.0f/sin(PI_FLOAT * inv_janela * (deltaL + k)));
			if(elle-k >= 0) {
				audioSynt[elle-k] += tonalpeak * normag * cos(newphi);
				audioSynti[elle-k] += tonalpeak * normag * sin(newphi);
			}
		}
		// % phase to be used above ell
		newphi = Phi - PI_FLOAT * (1.0f - 1.0f * inv_janela)+difphi2[m];
		if(newphi > PI_FLOAT) newphi -= PI2_FLOAT;
		if(newphi < -PI_FLOAT) newphi += PI2_FLOAT;
		// %synthesis of spectral line ell+1
		if(deltaL > HPZ) normag = partials_G * abs(abs(cos(PI_FLOAT*(deltaL-0.5f)))/sin(PI_FLOAT * inv_janela * (2.0f-deltaL)) - janelaf);
		else normag = partials_G * cos(PI_FLOAT*(deltaL-0.5f)) * abs(1.0f/sin(PI_FLOAT * inv_janela * (2.0f-deltaL)) + 1.0f/sin(PI_FLOAT * inv_janela *(deltaL-1.0f)));
		audioSynt[elle+1] += tonalpeak * normag * cos(newphi);
		audioSynti[elle+1] += tonalpeak * normag * sin(newphi);
		// %synthesis of spectral lines ell+2 <-> ell+k
		for(int k = 2; k <= 1+sidelobes; k++) {
			normag = partials_G * cos(PI_FLOAT * (deltaL-0.5f)) * abs(1.0f/sin(PI_FLOAT * inv_janela * (1.0f - deltaL + k)) + 1.0f/sin(PI_FLOAT * inv_janela * (deltaL - k)));
			if(elle+k < num_bins) {
				audioSynt[elle+k] += tonalpeak * normag * cos(newphi);
				audioSynti[elle+k] += tonalpeak * normag * sin(newphi);
			}
		}
	}
	static float re,im,dtmp; static int num_binsm1;
	switch(tps) {
		case SYNT_MAG_DB:
		for(i=0; i<num_bins; i++) {
			audioSynt[i] = 10.0f*log10(audioSynt[i]*audioSynt[i] + audioSynti[i]*audioSynti[i]);
			if(audioSynt[i]<minVal) audioSynt[i] = minVal; // corrigir com máximos e mínimos de entrada
			if(audioSynt[i]>maxVal) audioSynt[i] = maxVal; // corrigir com máximos e mínimos de entrada
		}
		break;
	case SYNT_DIFF_DB:
		for(i=0; i<num_bins; i++) {
			//audioSynt[i] = 20.0f*log10(abs(sqrt((float)magnitude[i]) - sqrt(audioSynt[i]*audioSynt[i] + audioSynti[i]*audioSynti[i]))); // teste
			re = realTF[i]- audioSynt[i]; im = imagTF[i]- audioSynti[i];
			audioSynt[i] = 10.0f*log10(abs(re*re + im*im)); // teste
			if(audioSynt[i]<minVal) audioSynt[i] = minVal; // corrigir com máximos e mínimos de entrada
			if(audioSynt[i]>maxVal) audioSynt[i] = maxVal; // corrigir com máximos e mínimos de entrada
		}
		break;
	case SYNT_DIFF_DB_SMOOTH:
		if(sussurro == NULL) {
			sussurro = new float[num_bins];
			newsussurro = new float[num_bins];
		}
		realTF[0] = imagTF[0] = 0.0f;
		for(i=0; i<num_bins; i++) {
			re = realTF[i]- audioSynt[i]; im = imagTF[i]- audioSynti[i];
			sussurro[i]=re*re+im*im;
		}
		// Novas modificações 17Dez07 - smooth little peaks
		num_binsm1 = num_bins - 1;
		newsussurro[0] = sussurro[0];
		for(i=1;i<num_binsm1;i++) {
			dtmp = 3.0f * sussurro[i];
			if(sussurro[i-1]>dtmp && sussurro[i+1]>dtmp) {
				newsussurro[i] = 0.5f*(sussurro[i-1] + sussurro[i+1]);
				i++;
			}
			newsussurro[i] = sussurro[i];
		}
		newsussurro[num_binsm1] = sussurro[num_binsm1];
		for(i=0; i<num_bins; i++) {
			audioSynt[i] = 10.0f*log10(newsussurro[i]);
			if(audioSynt[i]<minVal) audioSynt[i] = minVal; // corrigir com máximos e mínimos de entrada
			if(audioSynt[i]>maxVal) audioSynt[i] = maxVal; // corrigir com máximos e mínimos de entrada
		}
		break;
		case SYNT_DIFF:
		for(i=0; i<num_bins; i++) {
			re = realTF[i]- audioSynt[i]; im = imagTF[i]- audioSynti[i];
			audioSynt[i] = abs(sqrt(re*re + im*im)); // teste
		}
		break;
		case SYNT_MAG:
		for(i=0; i<num_bins; i++) {
			audioSynt[i] = sqrt(audioSynt[i]*audioSynt[i] + audioSynti[i]*audioSynti[i]);
			if(audioSynt[i]<minVal) audioSynt[i] = minVal; // corrigir com máximos e mínimos de entrada
			if(audioSynt[i]>maxVal) audioSynt[i] = maxVal; // corrigir com máximos e mínimos de entrada
		}
		break;
		case SYNT_CPLX:	// para processamento posterior
		break;
	}
	imagPower = audioSynti;
	return audioSynt;
}

float* PitchMeter::parciaisSyntSound(tipoSintese tps, bool putWinfullSeno) {
	double *real = outer->get_recoeftf(), *imag = outer->get_imcoeftf();
	// nota: ver porque é que se tem de dividir por 2.0 ?
	float mult = (float)(window->getGwindow() * window->getGwindow() / (32767.0f * 2.0f)), *saida = (float *)dados;
	int i,j;
	switch(tps) {
		case SOUND_PARCIAIS:
			for(i=0; i<num_bins; i++) { 
				real[i] = audioSynt[i];
				imag[i] = audioSynti[i];
			}
		break;
		case SOUND_DIFF:
			for(i=0; i<num_bins; i++) {
				real[i] = realTF[i] - audioSynt[i];
				imag[i] = imagTF[i] - audioSynti[i];
			}
		break;
	}
	transf->invrealtransf(real,imag,ODFT);
	for(i=0,j=0; i<num_bins; i++) { dados[j++] = real[i]; dados[j++] = imag[i]; }
	if(putWinfullSeno) window->filterwin(dados,REGULAR);
	for(i=0,j=0; i<janela; i++) saida[i] = (float)dados[i] * mult;
	return saida;
}

void PitchMeter::calculaPitch(TmpFile* tmpfile, int fs_, bool hc, bool mp) {
	int i,j, novo_tam;
	float *converte,bin_min;
	double *dados;
	float *tmpPtr;
	unsigned char *tmpCharPtr;
	bool bufferIN=false;

	fs=fs_;
	bin_min = (float)janela/(float)fs*(float)F0_MINIMO;

	resetF0Vars();
	if(pitchSize == 0 && pitchVal != NULL) {
		LOG(LOG_DEBUG,"Erro: vector T0 criado e sem dados - a corrigir")
		delete pitchVal; pitchVal=NULL;
	}
	if(mp && pitchSize == 0 && meanPowerVal!=NULL){
		LOG(LOG_DEBUG,"Erro: vector meanPowerVal criado e sem dados - a corrigir")
		delete meanPowerVal;
		meanPowerVal=NULL;
	}
	if(hc && pitchSize == 0 && nharmsVal!=NULL){
		LOG(LOG_DEBUG,"Erro: vector nharmsVal criado e sem dados - a corrigir")
		delete nharmsVal;
		nharmsVal=NULL;
	}

	novo_tam = tmpfile->getSize() % shift_bins == 0 ? tmpfile->getSize()/shift_bins + 1 : tmpfile->getSize()/shift_bins + 2;
	if(pitchSize == novo_tam) return; // se audio não foi alterado, retorna
	
	if( novo_tam == 0) {  // não há audio a processar? apaga-se os vectores e retorna
		pitchSize = 0; 
		if(pitchVal != NULL) { delete pitchVal; pitchVal=NULL; }
		if(mp && meanPowerVal != NULL) { delete meanPowerVal; meanPowerVal=NULL; }
		if(hc && nharmsVal != NULL ) { delete nharmsVal; nharmsVal=NULL; }
		return;
	}

	if(pitchSize > novo_tam) { // audio foi reduzido ? recalcula tudo.
		pitchSize=0; 
		if(pitchVal != NULL) { delete pitchVal; pitchVal=NULL; }
		if(mp && meanPowerVal != NULL) { delete meanPowerVal; meanPowerVal=NULL; }
		if(hc && nharmsVal != NULL) { delete nharmsVal; nharmsVal=NULL; }
	}
	if(pitchSize>0) {	// há F0's já calculados? redimensiona-se o vector, senão cria-se novo
		if((tmpPtr = (float *)realloc(pitchVal, novo_tam * sizeof(float))) == NULL) {
			tmpPtr = new float[novo_tam]; 
			memcpy(tmpPtr, pitchVal, pitchSize * sizeof(float));
			delete pitchVal;
			pitchVal = tmpPtr;
			LOG(LOG_DEBUG,"Redimensionar vector F0, com novo vector")
		} else {
			pitchVal = tmpPtr;
			LOG(LOG_DEBUG,"Redimensionar vector F0, a partir dele mesmo")
		}
		if(hc) {
			if((tmpCharPtr = (unsigned char*)realloc(nharmsVal, novo_tam * sizeof(unsigned char))) == NULL) {
				tmpCharPtr = new unsigned char[novo_tam]; 
				memcpy(tmpCharPtr, nharmsVal, pitchSize * sizeof(unsigned char));
				delete pitchVal;
				pitchVal=NULL;
				nharmsVal = tmpCharPtr;
				LOG(LOG_DEBUG,"Redimensionar vector nharmonics, com novo vector")
			} else {
				nharmsVal = tmpCharPtr;
				LOG(LOG_DEBUG,"Redimensionar vector nharmonics, a partir dele mesmo")
			}
		}
		if(mp){
			if((tmpPtr = (float *)realloc(meanPowerVal, novo_tam * sizeof(float))) == NULL) {
				tmpPtr = new float[novo_tam]; 
				memcpy(tmpPtr, meanPowerVal, pitchSize * sizeof(float));
				delete meanPowerVal;
				meanPowerVal = tmpPtr;
				LOG(LOG_DEBUG,"Redimensionar vector meanPowerVal, com novo vector")
			} else {
				meanPowerVal = tmpPtr;
				LOG(LOG_DEBUG,"Redimensionar vector meanPowerVal, a partir dele mesmo")
			}
		}
	} else {
		pitchVal = new float[novo_tam];
		if(hc) nharmsVal = new unsigned char[novo_tam];
		if(mp) meanPowerVal = new float[novo_tam];
	}

	LOG(LOG_DEBUG,"Calcular vectores a partir da amostra %i até %i",pitchSize,novo_tam)
	fazReset(); // novo audio... novo reset

	statframe *segframe;
	bool fisrtMeanPowerVal=true;
	FILE *testeErro;
	for(i=pitchSize; i < novo_tam; i++) {
		dados = fazOverlap();
		converte = (float *) dados;
		tmpfile->readBlock(converte, i * shift_bins, shift_bins);
        
        
        
        scalarProd(converte,shift_bins,0.25); //SIL
        
        
		// if(i * num_bins >= tmpfile->getSize()) printf("POS: %i a %i com tam=%i",(i-1) * num_bins,(i+1) * num_bins-1,tmpfile->getSize());
		for(j=shift_bins-1;j>=0;j--) dados[j]=floor(converte[j] * 32767.0f+0.5f);
		segframe = getValueOverlap(fs);
		pitchVal[i] = segframe->sinusinfo.f0harm;
		//printf("{%1.2f %i]",pitchVal[i],i);
		if(hc) nharmsVal[i] = segframe->sinusinfo.nharmonic > 0 ? segframe->sinusinfo.nharmonic + segframe->sinusinfo.npause : 0;
		if(mp){
			meanPowerVal[i] = getMeanPower();
			if(fisrtMeanPowerVal){
				maxPower=meanPowerVal[i];
				minPower=meanPowerVal[i];
			} else {
				if(meanPowerVal[i]>maxPower)	maxPower=meanPowerVal[i];
				if(meanPowerVal[i]<minPower)	minPower=meanPowerVal[i];
			}
		}
#ifndef DISABLE_WINDOW_NORMALIZED
		 if(pitchVal[i]!=0.0f && pitchVal[i] < bin_min) pitchVal[i] = 0.0f;
#endif
	}
	// detecta_vozeado(novo_tam)
	pitchSize = novo_tam;
	create_F0();
}


void PitchMeter::create_F0() {

	conv_F0=(float)fs/(float)janela;
	resetF0Vars();
}

void PitchMeter::resetF0Array() {
	pitchSize = 0;
	if(pitchVal != NULL) { delete pitchVal; pitchVal=NULL; }
	if(meanPowerVal != NULL) {delete meanPowerVal; meanPowerVal=NULL;}
	create_F0();
}

void PitchMeter::resetF0Vars() {
	var_MeanF0 = 0.0f;
	var_MaxF0 = 0.0f;
	var_MinF0 = 0.0f;
	var_stdDevF0 = 0.0f;
	var_phoRangeF0=0.0f;
}

float PitchMeter::MeanF0() {
	return MeanF0(0,pitchSize);
}

float PitchMeter::MeanF0(int start, int end) {
	if(pitchSize == 0) return var_MeanF0=0.0f;
	if(start>end){
		int tmp=end;
		end=start;
		start=tmp;
	}
	if(end<0 || end>pitchSize) return 0.0f;
	if(start<0 || start>=end ) return 0.0f;
	if(end-start+1==pitchSize && var_MeanF0>0.0f) return var_MeanF0;

	double soma=0.0;
	float result;
	for(int i=start; i < end; i++){
		soma += pitchVal[i];
	}
	result = (float)(soma/(double)(end-start));
	LOG(LOG_INFO,"Media de F0: %f\t entre %d - %d",result,start,end);
	if(end-start+1==pitchSize) var_MeanF0=result*conv_F0;
	return result*conv_F0;
}

float PitchMeter::MaxF0() {
	return MaxF0(0,pitchSize);
}

float PitchMeter::MaxF0(int start, int end) { 
	if(pitchSize == 0) return var_MaxF0=0.0f;
	if(start>end){
		int tmp=end;
		end=start;
		start=tmp;
	}
	if(end<0 || end>pitchSize) return 0.0f;
	if(start<0 || start>=end ) return 0.0f;
	if(end-start+1==pitchSize && var_MaxF0 > 0.0f) return var_MaxF0;

	float result = pitchVal[start];
	for(int i=start+1; i < end; i++)
		if(pitchVal[i]>result) result = pitchVal[i];
	LOG(LOG_DEBUG,"Maximo de F0: %f\t entre %d - %d",result,start,end);
	if(end-start+1==pitchSize) var_MaxF0=result*conv_F0;
	return result*conv_F0;
}

float PitchMeter::MinF0() {
	return MinF0(0,pitchSize);
}

float PitchMeter::MinF0(int start, int end) {
	if(pitchSize == 0) return var_MinF0=0.0f;
	if(start>end){
		int tmp=end;
		end=start;
		start=tmp;
	}
	if(end<0 || end>pitchSize) return 0.0f;
	if(start<0 || start>=end ) return 0.0f;
	if(end-start+1==pitchSize && var_MinF0 > 0.0f) return var_MinF0;

	float result = pitchVal[start];
	for(int i=start+1; i < end; i++)
		if(pitchVal[i]<result && pitchVal[i]>0.0f) result = pitchVal[i];
	LOG(LOG_DEBUG,"Minimo de F0: %f\t entre %d - %d",result,start,end);
	if(end-start+1==pitchSize) var_MinF0=result*conv_F0;
	return result*conv_F0;
}


float PitchMeter::standard_deviationF0() {
	return standard_deviationF0(0,pitchSize);
}

float PitchMeter::standard_deviationF0(int start, int end) {
	if(pitchSize < 2) return var_stdDevF0=0.0f;
	if(start>end){
		int tmp=end;
		end=start;
		start=tmp;
	}
	if(end<0 || end>pitchSize) return 0.0f;
	if(start<0 || start>=end ) return 0.0f;
	
	double k,soma=0.0;
	float result;
	float mean=MeanF0(start,end);
	for(int i=start; i<end; i++) {
		k = abs(pitchVal[i]*conv_F0-mean);
		soma += k*k;
	}
	result = (float)(soma / (double)(end-start));
	LOG(LOG_DEBUG,"Desvio padrão de F0: %f\t entre %d - %d",result,start,end);
	if(end-start+1==pitchSize) var_stdDevF0=result;
	return result;
}


float PitchMeter::phonatory_range_F0() {
	if(pitchSize == 0) return var_phoRangeF0=0.0f;
	var_phoRangeF0 = (float)(12.0*log((double)(MaxF0()/MinF0()))/log(2.0));
	LOG(LOG_DEBUG,"Phonatory Freq Range: %f",var_phoRangeF0);
	return var_phoRangeF0;
}

float PitchMeter::getMeanPower(){

	double *power=outer->getPower();

	float mean=0;
	for(int i=0;i<num_bins;i++){
		mean+=(float)power[i];
	}
	mean/=num_bins;
	mean=sqrt(mean);

	return mean;
}

float PitchMeter::getMinPower(){
	return minPower;
}

float PitchMeter::getMaxPower(){
	return maxPower;
}
void PitchMeter::setValue(float value){
	outer->setValue(value);
}

double PitchMeter::getGwindow(){
	return window->getGwindow();
}

// Calcula e devolve o somatório da energia dos bins calculados a partir de amostras normalizadas
double PitchMeter::calcEnergyNorm(float *data, bool addFirstBin) {
	double saida=0.0, *power;
	int i;
	outer->getfloatNorm(data);
	outer->dirsegtrans(*transf,*window,ODFT,REGULAR);
	outer->transmag(janela);
	power = outer->getPower();
	for(i=addFirstBin?0:1; i<num_bins; i++) saida += power[i];
	return saida;
}

bool PitchMeter::partialsCalcEnergy(double &energyAmostras, double &energyHarm, double &energyDiff) {
	if(audioSynt == NULL || realTF == NULL) return false;
	float i,r,rh,ih,ea=0.0f,eh=0.0f,ed=0.0f;
	// Novas modificações 17Dez07

	realTF[0] = imagTF[0] = 0.0f;
	if(sussurro == NULL) {
		sussurro = new float[num_bins];
		newsussurro = new float[num_bins];
	}
	for(int k=0;k<num_bins;k++) {
		r=realTF[k]; i=imagTF[k]; ea += r*r + i*i;
		rh=audioSynt[k]; ih=audioSynti[k]; eh += rh*rh + ih*ih;
		r -= rh; i -= ih; sussurro[k] = r*r + i*i;
	}

	// Novas modificações 17Dez07 - smooth little peaks
	int num_binsm1 = num_bins - 1;
	float dtmp;
	newsussurro[0] = sussurro[0];
	for(int pp=1;pp<num_binsm1;pp++) {
		dtmp = 3.0f * sussurro[pp];
		if(sussurro[pp-1]>dtmp && sussurro[pp+1]>dtmp) {
			newsussurro[pp] = 0.5f*(sussurro[pp-1] + sussurro[pp+1]);
			pp++;
		}
		newsussurro[pp] = sussurro[pp];
	}
	newsussurro[num_binsm1] = sussurro[num_binsm1];
	for(int k=0;k<num_bins;k++) ed += newsussurro[k];

	//cerr << "HNR=" << log10(eh) - log10(ed) << endl;

	energyAmostras += ea; energyHarm += eh; energyDiff += ed;
	return true;
}

void PitchMeter::setShiftBins(int shift_bins_){
	shift_bins=shift_bins_;
}



#ifndef _STATSEG_
#define _STATSEG_

#include <iostream>
using namespace std;

#include "statseg.h"
#include "window.h"
#include "transform.h"

typedef void (TRANSFORM::*TRF)(double*, double*, TRFTYPE);

STATSEG::STATSEG(int length) : SEGMENT(length) // constroi base
{
	int i,j;

	nshort=1;
	daddsamp = new double[nwords];
	coeftf   = new complex[nwords];
	recoeftf   = new double[nwords2];
	imcoeftf   = new double[nwords2];
	lcoef    = new complex[nwords2];
	scoef    = new complex[nwords2];
	overlap  = new double[nwords2];
	tntyhz   = new double[nwords2];
	unqzcoef = new double[nwords2];
	/* ajf 24.08.00 */
	magni   = new double[nwords2];
	phase   = new double[nwords2];
	cepstrum   = new double[nwords2];
	flatcoef    = new complex[nwords2];
	syntcoef    = new complex[nwords2];
	rlcoef    = new double[nwords2];
	rscoef    = new double[nwords2];
	tmpdbl    = new double[nwords2];
	/* ajf 24.08.01 */
	logmag    = new double[nwords2];
	energy    = new double[nwords2];
	/* ajf 19jul05 */
	asrbwe    = new complex[nwords2]; // actual bandwidth extended signal
	asrphi    = new double[nwords4]; // N/4 partials at most
	asrmag    = new double[nwords4]; // N/4 partials at most
	asroldphi = new double[nwords4]; // N/4 partials at most
	asroldmag = new double[nwords4]; // N/4 partials at most
	asrliv    = new int[nwords4]; // N/4 partials at most
	for (i=0; i<nwords4; i++) asrliv[i]=-1;
	/* ajf 30dec06 */
	for (i=0; i<8; i++) pastF0[i]=0.0;
	npastF0=2; // NOTE: must be <= 8 // 4Dez07 
	tonalsinfo.ntonal=0;
	for (i=0; i<8; i++)
	{
		tonalsinfo.f0tonal[i]=0.0;
		tonalsinfo.phitonal[i]=0.0;
		tonalsinfo.magtonal[i]=1.0E-4;
	}
	nharmonicstructures=0;
	for (i=0; i<8; i++)
	{
		harmonicstructure[i].nharmonic=0;
		harmonicstructure[i].npause=0;
		harmonicstructure[i].pospause=0;
		harmonicstructure[i].f0harmonic=0.0;
		harmonicstructure[i].accpower=1.0E-4;
		for (j=0; j<128; j++)
		{
			harmonicstructure[i].phiharmonic[j]=0.0;
			harmonicstructure[i].magharmonic[j]=1.0E-4;
		}
	}
	//JM 25Mai07
	myPower = new double[nwords2];
	myPowerdB = new double[nwords2];
	myCepstrumEst = new double[8];
	myCepstrumMag = new double[8];
	value=0.035f;
	//value=0.555f;
	// New values from 4 Dez 07
	noisefloor = 20.0*log10(4.0*0.25*nwords); // ajf 03dec07
	//noisefloor = 20.0*log10(1.8*0.25*nwords); // Tiago 24jan12
}

STATSEG::STATSEG() : SEGMENT() // constroi base
{
	nshort=1;
	daddsamp  = 0;
	coeftf = 0;
	lcoef = scoef = 0;
	overlap =0;
	tntyhz =0;
	unqzcoef =0;
	/* ajf 24.08.00 */
	magni =0;
	phase =0;
	cepstrum =0;
	flatcoef =0;
	syntcoef =0;
	rlcoef = rscoef = tmpdbl = 0;
	/* ajf 24.08.01 */
	logmag =0;
	energy =0;
	/* ajf 19jul05 */
	asrbwe    = 0;
	asrphi    = 0;
	asrmag    = 0;
	asroldphi = 0;
	asroldmag = 0;
	asrliv    = 0;
	npastF0=3;
	//JM 25Mai07
	myPower = 0;
	myCepstrumEst = 0;
	myCepstrumMag = 0;
}

STATSEG::~STATSEG()
{
	delete[] daddsamp; delete[] coeftf; delete[] tntyhz; delete[] unqzcoef;
	delete[] lcoef; delete[] scoef; delete[] overlap; delete[] recoeftf;
	delete[] imcoeftf;
	/* ajf 24.08.00 */
	delete[] magni; delete[] phase; delete[] cepstrum; delete[] flatcoef;
	delete[] rlcoef; delete[] rscoef; delete[] tmpdbl; delete[] syntcoef;
	/* ajf 24.08.01 */
	delete[] logmag;
	delete[] energy;
	/* ajf 19jul05 */
	delete[] asrbwe; delete[] asrphi; delete[] asrmag; delete[] asroldphi; delete[] asroldmag; delete[] asrliv;
	//JM
	delete[] myPower; delete[] myCepstrumEst; delete[] myCepstrumMag; 
	//
	//     SEGMENT::~SEGMENT();  implicitelly called
}
/*
void STATSEG::getdouble()
{
int i;
switch(wordlength)
{
case  8 : for (i=0; i<nwords; i++)
*(daddsamp+i) = (double) (*(addsamp08+i)); break;
case 16 : for (i=0; i<nwords; i++)
*(daddsamp+i) = (double) (*(addsamp16+i)); break;
case 24 : for (i=0; i<nwords; i++)
*(daddsamp+i) = (double) (*(addsamp24+i)); break;
}

}
*/
void STATSEG::getdouble(double* input)
{
	int i;
	switch(wordlength)
	{
	case  8 : for (i=0; i<nwords; i++)
				  *(daddsamp+i) =  *(input+i); break;
	case 16 : for (i=0; i<nwords; i++)
				  *(daddsamp+i) = *(input+i); break;
	case 24 : for (i=0; i<nwords; i++)
				  *(daddsamp+i) = *(input+i); break;
	}

}

void STATSEG::getfloatNorm(float* input)
{
	int i;
	switch(wordlength)
	{
	case  8 : for (i=0; i<nwords; i++)
				  *(daddsamp+i) =  *(input+i) * 32767.0f; break;
	case 16 : for (i=0; i<nwords; i++)
				  *(daddsamp+i) = *(input+i) * 32767.0f; break;
	case 24 : for (i=0; i<nwords; i++)
				  *(daddsamp+i) = *(input+i) * 32767.0f; break;
	}
}

void STATSEG::putinteger()
{
	int i;
	switch(wordlength)
	{
	case  8 : for (i=0; i<nwords; i++)
				  *(addsamp08+i) = castchar  (*(daddsamp+i)); break;
	case 16 : for (i=0; i<nwords; i++)
				  *(addsamp16+i) = castshort (*(daddsamp+i)); break;
	case 24 : for (i=0; i<nwords; i++)
				  *(addsamp24+i) = castint   (*(daddsamp+i)); break;
	}
}

void STATSEG::getcomplex()
{
	for (int i=0; i<nwords; i++) *(coeftf+i) = complex(*(daddsamp+i), 0.0);

}

void STATSEG::loaddoubledir(int volume)
{
	for (int i=0; i<volume; i++)
	{
		*(recoeftf+i) = real(*(coeftf+2*i));
		*(imcoeftf+i) = real(*(coeftf+1+2*i));
	}
}

void STATSEG::storedoubledir(int volume)
{
	for (int i=0; i<volume; i++)
	{
		*(coeftf+i) = complex(*(recoeftf+i), *(imcoeftf+i));
	}
}

void STATSEG::loaddoubleinv(int volume)
{
	for (int i=0; i<volume; i++)
	{
		*(recoeftf+i) = real(*(coeftf+i));
		*(imcoeftf+i) = imag(*(coeftf+i));
	}
}

void STATSEG::storedoubleinv(int volume)
{
	for (int i=0; i<volume; i++)
	{
		*(coeftf+2*i) = complex ( *(recoeftf+i), 0.0);
		*(coeftf+2*i+1) = complex ( *(imcoeftf+i), 0.0);
	}
}

void STATSEG::putdouble()
{
	for (int i=0; i<nwords; i++) *(daddsamp+i) = real(*(coeftf+i));
}

STATSEG& STATSEG::operator=(const STATSEG& st)
{
	int i;
	if (nwords==0)
	{
		SEGMENT::operator=(st); // ver pag. 576 Bjarne
		daddsamp = new double[nwords];
		coeftf   = new complex[nwords];
		lcoef    = new complex[nwords2];
		scoef    = new complex[nwords2];
		overlap  = new double[nwords2];

		for (i=0; i<nwords; i++)
		{
			*(daddsamp+i) = *(st.daddsamp+i);
			*(coeftf+i) = *(st.coeftf+i);
		}
		return *this;

	}
	else
	{
		SEGMENT::operator=(st);
		for (i=0; i<nwords; i++)
		{
			*(daddsamp+i) = *(st.daddsamp+i);
			*(coeftf+i) = *(st.coeftf+i);
		}
		return *this;
	}
}

STATSEG& STATSEG::operator=(const SEGMENT& s)
{
	if (nwords==0)
	{
		SEGMENT(*this) = s;  // see alternative above
		daddsamp = new double [nwords];
		coeftf   = new complex[nwords];
		lcoef    = new complex[nwords2];
		scoef    = new complex[nwords2];
		overlap  = new double[nwords2];
		return *this;
	}
	else
	{
		SEGMENT(*this) = s;
		return *this;
	}
}

signed char STATSEG::castchar(double d)
{
	if (d>127.0 || d<-128.0)
	{cerr << "BIG char: " << d << endl; exit(0);} return (signed char)(floor(0.5+d));
}

short int STATSEG::castshort(double d)
{
	if (d>32767.0 || d<-32768.0)
	{cerr << "BIG short: " << d << endl;/* exit(0);*/}
	return short(MAX(-32768.0, MIN(32767.0, floor(0.5+d))));
}

int STATSEG::castint(double d)
{
	if (d>8388607.0 || d<-8388608.0)
	{cerr << "BIG int: " << d << endl; exit(0);} return  (int)(floor(0.5+d));
}

void STATSEG::transmag(int size)
{
	if (size==nwords)
	{
		for (int i=0; i<nwords2; i++)
		{
			*(daddsamp+i) = 1.0E-4+norm(*(lcoef+i));
			*(energy+i) = *(daddsamp+i);
			*(myPower+i) = *(energy+i); //JL 28/08/07
			*(logmag+i) = 10.0*log10(*(daddsamp+i));
			*(myPowerdB+i) = *(logmag+i); //JL 18/07/07
		}
	}
	else
	{
		for (int i=0; i<nwords2; i++)
		{
			*(daddsamp+i) = 1.0E-4+norm(*(scoef+i));
			*(energy+i) = *(daddsamp+i);
			*(logmag+i) = 10.0*log10(*(daddsamp+i));
		}
	}
}

void STATSEG::transphi(void)
{
	for (int i=0; i<nwords2; i++) *(daddsamp+i) = arg(*(lcoef+i));
}

float STATSEG::exactdeltaell(const float& magbef, const float& magmid, const float& magaft)
{

/*
 * Note that constants G, F and H are further divided by 2.0 because magnitudes are squared
 *
 */
     static float G=20/29.0/2.0, F=20/32.75/2.0, H=20/32.75/2.0, C=3.0/M_PI, sqrt3=sqrt(3.0);
     float edgelow, edgehig, Q, S, R;

/*
 * Note that 3.175 and 0.315 area squared because magnitudes are squared
 *
 */
     edgelow=magaft*3.175*3.175; // was 3.2454, see Feb/Mar/Apr 05 report
     edgehig=magaft*0.315*0.315; // was 0.3081, see Feb/Mar/Apr 05 report


     if (magbef > edgelow)      // deltaell is < 0.29 , compute Q
     {
	 Q = pow( magbef / magmid , F);
         return C*atan(sqrt3*((1.0-Q)/(1.0+Q)));
     }
     else
     {
        if (magbef < edgehig)  // deltaell is > 0.71 , compute S
        {
	    S = pow( magaft / magmid , H);
            return C*atan(sqrt3*S/(2.0-S));
        }
        else // compute R
        {
	    R = pow( magbef / magaft , G);
            return C*atan(sqrt3/(1.0+2.0*R));
        }
     }
}

//#include "pitch/version31jul07.cpp" // versão original
//#include "pitch/actualEnovo.cpp" // baseados SÓ na energia
//#include "pitch/lastSearchAn.cpp"  // Melhores resultados, baseado na energia e/ou maglog
//#include "pitch/version04Dez07.cpp" // penúltima versão

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// START of version27Dez11.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//#include "pitch/version27Dez11.cpp" // nova versão

// Código extra para adaptar a versão original
double treshTone=60.0;
double treshproxLim=1.1;
double treshEnergy=0.606;
int treshPartials = 1;
// NOTA: Os valores acima não estão a ser utilizados, apenas estão presentes por uma questão de compatibilidade
//       As modificações têm o sufixo: // FA ADAPTADO

int frameCnt=0;

//Tiago - Alterada para variável global por causa do ficheiro de debug (VOLTAR A REPOR QUANDO JÁ NÃO FOR NECESSÁRIO!!!)
static double tonalpos[256];

void STATSEG::searchtonalAnalysis(TRANSFORM& transform, TRFTYPE trftype, statframe& frame, float sfreq, float bitrate, int tamanho)
{
    /* ajf [19-23].06.05 */
    int i, j, k, t, hit, binlim, beg, fin, niter, idxf0, nbreaks, naccbreaks;
    int tmp, npitch, indtonal, pitchstp, pitchbrk;
    int nextmatch, stopmatch, ptr;
    static int minpartials=4;
    static int maxsinus=3;
    static int maxpartials; // ajf 23-08-01   35=4+31
    static int maxmissing=7; // ajf 21.06.05 was 3
    static int minmissing=3; // ajf 08.12.06
    double attbf, attaf, lastenergy, dtmp, dtmp1, dtmp2, accHNR;
    double pitchest, pitchacc, pitchnum, pitchden;
    static double edgemin=7.0; // 7 dB power domain ajf 18-07-03
    static double totpower, uncertainty;
    TRF transize = &TRANSFORM::invrealtransf; // AJF 03DEC06
        
    //	 FILE *fdebug=fopen("frame-data.txt", "a+");
    // // fprintf(fdebug, "\nframe: %d\n---------------------------------", frameCnt);
    
    double sumLogMag=0;
    int meanCnt=0;
    
    /*
     * fundamental frequency is only allowed till 2100 Hertz
     *
     */
    int ntonal;
    // int highpitch=floor(0.5+2100.0/(sfreq/(2.0*bark.wsize)));
    int highpitch=(int)floor(0.5+2100.0/(sfreq/tamanho)); // FA ADAPTADO
    maxpartials = minpartials + MIN(14, MAX(0, (int) floor(0.5+bitrate/sfreq*32.0/4.0-4.0)));
    //cout << "\nMASpartials" << maxpartials << "\n" << endl;
    
    /* NEW CODE 30dec06 */
    
    /*
     * set minimum and maximum lags for acceptable ranges of pitch frequencies
     *
     */
    int minlag = (int)MAX(8.0, nwords/highpitch);	// ajf 24nov07, was 18
    // JL 17fev08
    
    static int nf0values;
    static double f0estimate[8], f0cepsmagn[8], f0likelihood[8];
    static double tonalmag[256], proxlimit, weight=0.875;
    
    for (i=0; i<nwords2; i++) {tntyhz[i]=0.0;}
    
    tonalsinfo.ntonal=0;
    
    nf0values = 0;
    for (i=0; i<8; i++)
    {
        *(f0estimate+i)=1.0;
        *(f0cepsmagn+i)=0.0;
        *(f0likelihood+i)=0.0;
    }
    
    for (i=0; i<8; i++)
    {
        tonalsinfo.f0tonal[i]=0.0;
        tonalsinfo.phitonal[i]=0.0;
        tonalsinfo.magtonal[i]=1.0E-4;
    }
    
    nharmonicstructures=0;
    for (i=0; i<8; i++)
    {
        harmonicstructure[i].nharmonic=0;
        harmonicstructure[i].npause=0;
        harmonicstructure[i].pospause=0;
        harmonicstructure[i].f0harmonic=0.0;
        harmonicstructure[i].accpower=1.0E-4; // ajf 23dec06
        /* not really necessary
         for (j=0; j<128; j++)
         {
         harmonicstructure[i].phiharmonic[j]=0.0;
         harmonicstructure[i].magharmonic[j]=0.0;
         }
         */
    }
    
    ntonal=0;
    // binlim = bark.hufflim[bark.nhp-1];
    binlim = (int)(tamanho/2 - 1);  // FA ADAPTADO
    
    /*
     if (bark.wsize == nwords2) // long block
     {
     //transmag(nwords); // ajf 24-08-01 computes the magnitude and its log
     niter=1;
     }
     else // sequence of short blocks
     {
     if (bark.wsize != nwords2/nshort) {cerr<< "Error searchtonal\n";exit(0);}
     // transmag(bark.wsize >> 1); // ajf 20-06-03 has already been previously computed
     niter=nshort;
     return;
     }
     */   niter = 1; // FA ADAPTADO
    
    /*
     * Detects all relevant peaks in the spectrum (peak-peaking)
     *
     */
    if (niter==1)  // if it is a transient, resolved tonals are not expected
    {
        // compute the cepstrum of the current frame
        for (i=0; i<nwords2; i++)
        {
            *(recoeftf+i) = *(logmag+i);
            *(imcoeftf+i) = 0.0;
        }
        (transform.*transize)(recoeftf, imcoeftf, trftype);
        for (i=0; i<nwords2; i++)
        {
            *(daddsamp+2*i) = *(recoeftf+i);
            *(daddsamp+1+2*i) = *(imcoeftf+i);
        }
        
        // enhance and smooth cepstrum information STEP 1/3
        for (i=minlag; i<(nwords2-1); i++)
        {
            *(recoeftf+i) = *(daddsamp+i-1) + *(daddsamp+i) + *(daddsamp+i+1);
        }
        // enhance and smooth cepstrum information STEP 2/3
        for (i=minlag; i<(nwords2-1); i++)
        {
            dtmp1 = *(recoeftf+i-1) - *(recoeftf+i);
            dtmp2 = *(recoeftf+i+1) - *(recoeftf+i);
            dtmp = MIN(dtmp1, dtmp2);
            if (dtmp1>0 && dtmp2>0 && dtmp<0.25) // experimentally found on 16dec06
            {
                *(imcoeftf+i) = 0.5*(*(recoeftf+i-1) + *(recoeftf+i+1));
                i++;
            }
            *(imcoeftf+i) = *(recoeftf+i);
        }
        // enhance and smooth cepstrum information STEP 3/3
        for (i=minlag; i<(nwords2-1); i++)
        {
            *(recoeftf+i) = *(imcoeftf+i-1) + *(imcoeftf+i) + *(imcoeftf+i+1);
        }
        
        // update record of 8 strongest F0 estimates in the cepstrum (peaks only)
        i=minlag;
        //preparing to look for the next local maximum
        while (i<nwords2 && *(recoeftf+i) <= *(recoeftf+i-1)) i++;
        while (i<nwords2)
        {
            while (i<nwords2 && *(recoeftf+i) > *(recoeftf+i-1))
                i++;
           // i--; //SIL
            
            for (t=0; t<8; t++)
            {
                if (*(recoeftf+i) > *(f0cepsmagn+t)) // we just want to compare positive values
                {
                    for (j=7; j>t; j--)
                    {
                        *(f0cepsmagn+j) = *(f0cepsmagn+j-1);
                        *(f0estimate+j) = *(f0estimate+j-1);
                    }
                    *(f0cepsmagn+t) = *(recoeftf+i);
                    *(f0estimate+t) = nwords / (double)i;
                    if (nf0values < 8) nf0values++;
                    break; // exit loop for
                }
            }
            i++;
            // go to the next local minimum
            while (i<nwords2 && *(recoeftf+i) <= *(recoeftf+i-1)) i++;
        }
        /*
         for (i=0; i<nf0values; i++)
         {
         cout << i << "LAG  " << *(f0estimate+i) << " MAG " << *(f0cepsmagn+i)<< endl;
         }
         */
        
        
        /*
         * Sets i such that it can be used afterwards to look
         * for the next local maximum, ignoring any local maximum
         * at bin 1. The dB of the first local minimum is lastenergy
         *
         */
        lastenergy = *(logmag);
        if (*(logmag+1) > *(logmag)) // bin 0 looks a local minimum
        {
            i=3;
            if (*(logmag+2) <= *(logmag+1)) // ignores peak at bin 1
            {
                while (i<binlim && *(logmag+i) <= *(logmag+i-1)) i++;
                lastenergy = *(logmag+i-1); // next minimum after bin i
            }
        }
        else
        {
            i=2;
            while (i<binlim && *(logmag+i) <= *(logmag+i-1)) i++;
            lastenergy = *(logmag+i-1);
        }
        
        /*
         * Searches for all local maxima, one at a time, by checking dB on each edge
         *
         */
        for ( ; i<binlim; i++)
        {
            while (i<binlim && *(logmag+i) >= *(logmag+i-1)) i++;
            hit=i-1; i++;
            while (i<binlim && *(logmag+i) <= *(logmag+i-1)) i++;
            i--;
            attbf = *(logmag+hit) - lastenergy;
            attaf = *(logmag+hit) - *(logmag+i);
            
            sumLogMag += *(logmag+hit);
            meanCnt++;
            
            /*
             * 42 dB = 20log(0.5*1024/4)
             *
             */
            //if ((attbf > edgemin && attaf > edgemin) && *(logmag+hit) > 42.0) // see comment above
            //if ((attbf > edgemin || attaf > edgemin) && *(logmag+hit) > 42.0) // see comment above
            // // fprintf(fdebug, "\n\nattbf > edgemin = %f > %f\nattaf > edgemin = %f > %f\n*(logmag+hit) > noisefloor = %f > %f\n\n", attbf, edgemin, attaf, edgemin, *(logmag+hit), noisefloor);
            if ((attbf > edgemin || attaf > edgemin) && (*(logmag+hit) > noisefloor || *(logmag+hit) > sumLogMag/meanCnt + 13.25)) // see comment above
            {
                *(tntyhz+hit)=1.0;
                
                dtmp = exactdeltaell(*(energy+hit-1), *(energy+hit), *(energy+hit+1));
                
                *(tonalpos+ntonal) = dtmp+(double)hit;
                *(tonalmag+ntonal) = *(energy+hit);    // ajf 27nov07
                
                for (t=0; t<maxsinus; t++) // update record of maxsinus highest peaks
                {
                    if (*(logmag+hit) > *(tonalsinfo.magtonal+t))
                    {
                        for (j=maxsinus-1; j>t; j--)
                        {
                            tonalsinfo.f0tonal[j]=tonalsinfo.f0tonal[j-1];
                            tonalsinfo.magtonal[j]=tonalsinfo.magtonal[j-1];
                        }
                        *(tonalsinfo.f0tonal+t) = *(tonalpos+ntonal);
                        *(tonalsinfo.magtonal+t) = *(logmag+hit);  // here we store mag dB
                        if (tonalsinfo.ntonal<maxsinus) tonalsinfo.ntonal++;
                        break; // exit loop for
                    }
                }
                ntonal++;
            }
            lastenergy = *(logmag+i); // new local minimum
            i++; // prepares seach for next maximum
        }
    }
    
    /*
     * Estimate "pitch" only in the case of long windows (maximum spectral resolution)
     *
     */
    
    if (niter==1 && ntonal>0)
    {
        for (idxf0=0; idxf0<nf0values; idxf0++)
        {
            indtonal=0;
            nbreaks=0; // instantaneous number of breaks in detecting an harmonic structure
            naccbreaks=0; //  accumulated number of breaks in detecting an harmonic structure
            pitchest = *(f0estimate+idxf0);
            pitchnum = 0.0;
            pitchden = 0.0;
            pitchacc = 1.0E-4; //calcula para todos
            npitch=0;
            pitchstp=0;
            pitchbrk=0;
            nextmatch=npitch+1;
            stopmatch=nextmatch;
            dtmp=1.0E4;
            weight=0.875;
            
            proxlimit = MAX(1.1, 0.05*pitchest); // ajf 02dec07
            
            // // fprintf(fdebug, "\n\n(indtonal < ntonal) = %d < %d\n(npitch < maxpartials) = %d < %d\n\n", indtonal, ntonal, npitch, maxpartials);
            while ((indtonal < ntonal) && (npitch < maxpartials))
            {
                // // fprintf(fdebug, "\n\n(indtonal < ntonal) = %d < %d\n(npitch < maxpartials) = %d < %d\n\n", indtonal, ntonal, npitch, maxpartials);
                // force indtonal to be slighly on the right-hand side of the estimated pitch
                while (indtonal<ntonal && *(tonalpos+indtonal) < pitchest*nextmatch) indtonal++;
                if (indtonal==ntonal) indtonal--; // has reached the right-most tonal
                
                if (*(tonalpos+indtonal) > pitchest*nextmatch)
                {
                    dtmp = fabs(*(tonalpos+indtonal) - pitchest*nextmatch);
                    if (indtonal>0)
                    {
                        dtmp1 = fabs(pitchest*nextmatch - *(tonalpos+indtonal-1));
                        if (dtmp1 < dtmp) {indtonal--; dtmp=dtmp1;}
                    }
                }
                else // is <= i.e., has reached the right-most tonal
                {
                    dtmp = fabs(pitchest*nextmatch - *(tonalpos+indtonal));
                }
                
                // // fprintf(fdebug, "\n\ndtmp < proxlimit = %f < %f\n\n", dtmp, proxlimit);
                
                if (dtmp < proxlimit) // distance less than 1 bin
                {
                    npitch++;
                    // // fprintf(fdebug, "\n\nnpitch = %d\n\n", npitch);
                    pitchnum += nextmatch * *(tonalpos+indtonal);
                    pitchden += nextmatch*nextmatch;
                    pitchest  = pitchnum/pitchden*(1.0-weight) + *(f0estimate+idxf0)*weight;
                    weight *= 0.875;
                    pitchacc += *(tonalmag+indtonal);
                    nextmatch++; indtonal++;
                    stopmatch=nextmatch;
                }
                else // harmonic discontinuity
                {
                    nbreaks++;
                    naccbreaks++;
                    //if (nbreaks>1 || naccbreaks > 1) break; // exit loop while
                    if (nbreaks>1) break; // ajf 26nov07, exit loop while
                    while (indtonal < ntonal) // ajf 26nov07
                    {
                        nextmatch++; // ajf 26nov07
                        if ((nextmatch-stopmatch) > maxmissing) break; // ajf 26nov07, exit inner while
                        // force indtonal to be slighly on the right-hand side of the estimated pitch
                        while (indtonal<ntonal && *(tonalpos+indtonal) < pitchest*nextmatch) indtonal++;
                        if (indtonal==ntonal) indtonal--; // has reached the right-most tonal
                        
                        if (*(tonalpos+indtonal) > pitchest*nextmatch)
                        {
                            dtmp = fabs(*(tonalpos+indtonal) - pitchest*nextmatch);
                            if (indtonal>0)
                            {
                                dtmp1 = fabs(pitchest*nextmatch - *(tonalpos+indtonal-1));
                                if (dtmp1 < dtmp) {indtonal--; dtmp=dtmp1;}
                            }
                        }
                        else // is <= i.e., has reached the right-most tonal
                        {
                            dtmp = fabs(pitchest*nextmatch - *(tonalpos+indtonal));
                        }
                        
                        if (dtmp < proxlimit) // has recovered discontinuity
                        {
                            npitch++;
                            pitchnum += nextmatch * *(tonalpos+indtonal);
                            pitchden += nextmatch*nextmatch;
                            pitchest  = pitchnum/pitchden*(1.0-weight) + *(f0estimate+idxf0)*weight;
                            weight *= 0.875;
                            pitchacc += *(tonalmag+indtonal);
                            pitchstp  = nextmatch-stopmatch;
                            pitchbrk  = stopmatch;
                            if ((pitchstp <= minmissing) && ((npitch+pitchstp) < maxpartials)) // ignore break
                            {
                                nbreaks--;
                                // take into consideration the energy of the partials in the ignored break
                                /* ajf 29nov07 ignore energy of missing partials
                                 for (t=stopmatch; t<nextmatch; t++)
                                 {
                                 hit = (int)floor(pitchest*(double)t);
                                 //pitchacc += *(energy+hit);
                                 pitchacc += *(logmag+hit); // changed on 23dec06
                                 }
                                 ajf 29nov07 ignore energy of missing partials */
                                npitch += pitchstp;
                                pitchstp=0;
                            }
                            nextmatch++; indtonal++;
                            stopmatch=nextmatch;
                            break; // exit inner while
                        }
                    }
                    if ((nextmatch-stopmatch) > maxmissing) break; // ajf 26nov07, exit outer while
                }
            }
            harmonicstructure[idxf0].nharmonic  = npitch;
            harmonicstructure[idxf0].npause     = pitchstp;
            harmonicstructure[idxf0].pospause   = pitchbrk;
            if (pitchden>0.0) harmonicstructure[idxf0].f0harmonic = pitchnum/pitchden;
            //else harmonicstructure[idxf0].f0harmonic = 0.0;
            else harmonicstructure[idxf0].f0harmonic = *(f0estimate+idxf0); // ajf 29nov07
            harmonicstructure[idxf0].accpower   = pitchacc;
            *(f0likelihood+idxf0) = *(f0cepsmagn+idxf0); // ajf 02dec07 ajf 27nov07
            nharmonicstructures++;
            
            ////////////////////////////////
            
            /* ajf 26nov07
             // rank harmonic patterns according to decreasing power
             for (t=0; t<8; t++)
             {
             if (pitchacc == harmonicstructure[t].accpower) break; // do not repeat same solution
             if (pitchacc > harmonicstructure[t].accpower)
             {
             
             for (j=7; j>t; j--)
             {
             harmonicstructure[j].nharmonic  = harmonicstructure[j-1].nharmonic;
             harmonicstructure[j].npause     = harmonicstructure[j-1].npause;
             harmonicstructure[j].pospause   = harmonicstructure[j-1].pospause;
             harmonicstructure[j].f0harmonic = harmonicstructure[j-1].f0harmonic;
             harmonicstructure[j].accpower   = harmonicstructure[j-1].accpower;
             }
             harmonicstructure[t].nharmonic  = npitch;
             harmonicstructure[t].npause     = pitchstp;
             harmonicstructure[t].pospause   = pitchbrk;
             harmonicstructure[t].f0harmonic = pitchnum/pitchden;
             harmonicstructure[t].accpower   = pitchacc;
             if (nharmonicstructures < 8) nharmonicstructures++;
             break; // exit loop for
             }
             }
             */
        }
        
        /* 02dec07 */
        dtmp1 = harmonicstructure[0].accpower;
        for (t=1; t<nharmonicstructures; t++)
            if (harmonicstructure[t].accpower < dtmp1) dtmp1 = harmonicstructure[t].accpower;
        dtmp1 = 1.0/MAX(1.0, dtmp1);
        for (t=0; t<nharmonicstructures; t++)
            *(f0likelihood+t) *= log10(1.0 + harmonicstructure[t].accpower/dtmp1);  //t1
        //TODO: Alternativas para teste
        //*(f0likelihood+t) *= log10(1.0 + harmonicstructure[t].accpower*dtmp1); //t2
        //*(f0likelihood+t) *= log10(10.0 + harmonicstructure[t].accpower*dtmp1); //t3
        /* 02dec07 */
        
        /* 16nov07 */
        if (*(f0cepsmagn) > 0.0 && nf0values>1) uncertainty = pow(*(f0cepsmagn+1) / *(f0cepsmagn), 0.80);
        else uncertainty = 0.0;
        
        // compute likelihood of each F0 estimate using recent F0 history
        for (t=0; t<nharmonicstructures; t++)
        {
            dtmp1 = 0.0; dtmp2 = harmonicstructure[t].f0harmonic;
            for (j=0; j<npastF0; j++)
            {
                dtmp1 += fabs(dtmp2 - *(pastF0+j))/(1.0+MAX(dtmp2, *(pastF0+j)));
            }
            *(f0likelihood+t) *= fabs(1.0 - sqrt(dtmp1/npastF0)*uncertainty);
        }
        
        /* */
        
        // new alignment
        for (t=0; t<nharmonicstructures-1; t++)
        {
            for (j=t+1; j<nharmonicstructures; j++)
            {
                if (*(f0likelihood+j) > *(f0likelihood+t))
                {
                    tmp = harmonicstructure[t].nharmonic;
                    harmonicstructure[t].nharmonic = harmonicstructure[j].nharmonic;
                    harmonicstructure[j].nharmonic = tmp;
                    tmp = harmonicstructure[t].npause;
                    harmonicstructure[t].npause    = harmonicstructure[j].npause;
                    harmonicstructure[j].npause    = tmp;
                    tmp = harmonicstructure[t].pospause;
                    harmonicstructure[t].pospause  = harmonicstructure[j].pospause;
                    harmonicstructure[j].pospause  = tmp;
                    dtmp = harmonicstructure[t].f0harmonic;
                    harmonicstructure[t].f0harmonic = harmonicstructure[j].f0harmonic;
                    harmonicstructure[j].f0harmonic = dtmp;
                    dtmp = harmonicstructure[t].accpower;
                    harmonicstructure[t].accpower   = harmonicstructure[j].accpower;
                    harmonicstructure[j].accpower   = dtmp;
                    dtmp = *(f0likelihood+t);
                    *(f0likelihood+t) = *(f0likelihood+j);
                    *(f0likelihood+j) = dtmp;
                }
            }
        }
        
        //Tiago 06/01/2012 - avoid octave errors caused by subharmonic components detected as partials
        double accMagf01=0, accMagf02=0, totAccMag=0, localPeak;
        int harmInd, n;
        
        for(n=1; n*harmonicstructure[0].f0harmonic<256; n++) {
            if(n<=harmonicstructure[0].nharmonic+1){
                //			// // fprintf(fdebug, "\n\n--------------------------------------\n%f\n--------------------------------------\n\n", n*harmonicstructure[0].f0harmonic);
                if(n*harmonicstructure[0].f0harmonic-(int)(n*harmonicstructure[0].f0harmonic)>=0.5)
                    harmInd=(int)ceil(n*harmonicstructure[0].f0harmonic);
                else
                    harmInd=(int)(n*harmonicstructure[0].f0harmonic);
                
                //find local peak to assure we are adding the right energy component within the 4 neighbours of the selected spectrum index
                localPeak=*(logmag+harmInd-2);
                //			// // fprintf(fdebug,"\nE[-2]=%f", localPeak);
                for(int a=-2; a<2; a++) {
                    //				// // fprintf(fdebug,"\nE[%d]=%f", a+1, *(logmag+harmInd+a+1));
                    if(*(logmag+harmInd+a+1) > localPeak)
                        localPeak=*(logmag+harmInd+a+1);
                }
                
                //			// // fprintf(fdebug, "\nlocalPeak=%f\n", localPeak);
                
                totAccMag+=localPeak;
                if(n%2==0)
                    accMagf02+=localPeak;
                else
                    accMagf01+=localPeak;
            }
        }
        
		//	// // fprintf(fdebug, "harmonicstructure[0].f0harmonic=%f\ntotAccMag=%f\naccMagf01=%f\naccMagf02=%f\n", harmonicstructure[0].f0harmonic, totAccMag, accMagf01, accMagf02);
        
        //if((secondPeak/firstPeak)-1>0.12 && (accMagf02/accMagf01)-1>0.18)
        if((accMagf02/totAccMag)>0.54 && (accMagf02/accMagf01)-1>0.257)
            harmonicstructure[0].f0harmonic *= 2;
        
        /*
         for (t=0; t<nharmonicstructures; t++)
         {
         cout << "Struct " << t << " npitch " << harmonicstructure[t].nharmonic << " npause " <<
         harmonicstructure[t].npause
         << " pospause " << harmonicstructure[t].pospause << " f0 " << harmonicstructure[t].f0harmonic
         << " accpower " << harmonicstructure[t].accpower << " likelihood " << *(f0likelihood+t)
         << endl;
         }
         */
        
        // //	 for(int i=0; i<8; i++) {
        // //	    if(*(f0estimate+i)!=0)
		// // fprintf(fdebug, "\n*(f0estimate+%d)=%fHz ", i, *(f0estimate+i)*sfreq/tamanho);
        // //	}
        // // fprintf(fdebug, "\n");
        
        // //	  for(int i=0; i<256; i++) {
        //	    if(*(tonalpos+i)!=0) //// // fprintf(fdebug, "%f\n", *(tonalpos+i)*sfreq/tamanho);
		// // fprintf(fdebug, "\n*(tonalpos+%d)=%fHz ", i, *(tonalpos+i)*sfreq/tamanho);
        // //	 }
        // // fprintf(fdebug, "\n");
        
        
        /*	 for(int i=0; i<harmonicstructure[0].nharmonic; i++)
         // // fprintf(f, "harmonicstructure[%d].f0harmonic=%f ", i, harmonicstructure[i].f0harmonic); */
        
        // // fprintf(fdebug, "F0SELEC: %f\n", harmonicstructure[0].f0harmonic);
        
        // // fprintf(fdebug, "\nharmonicstructure[0].nharmonic=%d\nharmonicstructure[0].f0harmonic=%f\nframe.sinusinfo.nharmonic=%d\nframe.sinusinfo.f0harm=%f\n\n", harmonicstructure[0].nharmonic, harmonicstructure[0].f0harmonic*sfreq/tamanho, frame.sinusinfo.nharmonic, frame.sinusinfo.f0harm*sfreq/tamanho);
        
        if (harmonicstructure[0].nharmonic > 0)
        {
            // plus one because the main lobe is 3 bins (one on each side of the middle)
            
            // number of partials used to evaluate the Harmonic-to-Noise-Ratio (HNR)
            t = harmonicstructure[0].nharmonic+harmonicstructure[0].npause;
            // last bin of the last partial of the harmonic structure
            fin = MIN(nwords2-1, 1+(int)floor(harmonicstructure[0].f0harmonic*(double)t));
            
            // first partial whose left bin is >=3
            k=1;
            while ((int)floor(harmonicstructure[0].f0harmonic*(double)k) < 4 && (k < t) ) k++;
            beg = (int)floor(harmonicstructure[0].f0harmonic*(double)k) - 1;
            totpower = 1.0;
            
            // it is important to start at bin>=3 because with low level signals, DC may be strong
            for (j=beg; j<=fin; j++) totpower += *(energy+j); // ajf 28nov07
            dtmp2=totpower; // just save this value
            
            //  the following is a trick to avoid the influence of DC in many cases
            accHNR = totpower; ptr=0;
            for (; k<=t; k++)
            {
                hit = (int)floor(harmonicstructure[0].f0harmonic*(double)k);
                beg=hit-1; fin=MIN(nwords2-1, hit+1);
                while (ptr<beg) ptr++;
                while (ptr<=fin){ accHNR -= *(energy+ptr++); }
            }
            
            dtmp1 = totpower;
            for (j=0; j<beg; j++) dtmp1 += *(energy+j); // ajf 02dec07, include up to DC
            
            // ajf 02dec07
            // rationale is to avoid negative effect of noise that raises to the right
            beg = fin+1;
            fin = nwords2;
            for (j=beg; j<fin; j++) dtmp1 += *(energy+j); // ajf 02dec07, include up to Nyquist
            //tmp = 10.0*log10(dtmp1) > noisefloor+20.0;
            tmp = 10.0*log10(dtmp1) > noisefloor+12.0; // Tiago 24jan12
            
            dtmp2 = harmonicstructure[0].accpower; // ajf 02dec07
            /* ajf 30nov07
             cout <<"\nPower test: " << harmonicstructure[0].accpower << " 60% TOT " << 0.6*totpower
             << " power: " << totpower << " RATIO: " << harmonicstructure[0].accpower/totpower << endl;
             */
            // ajf 29nov07, NOTE: factors 0.6 and 0.4 may be further adjusted
            // the minimum number of partials required in a harmonic structure is 3
            // for general purpose pitch detection, the number of 3 should be relaxed to 1
            //if (harmonicstructure[0].accpower >= 0.6*totpower && accHNR < 0.4*dtmp2 && harmonicstructure[0].nharmonic > 3)
            //if (dtmp2 >= 0.18*dtmp1 && accHNR < 0.35*totpower && harmonicstructure[0].nharmonic > 1 && tmp)  //JL & AJF 15Fev08, nharmonic > 1 is better
            
            int cond1 = dtmp2 >= 0.064*dtmp1; //0.064 0.18
            //	int cond2 = accHNR < 0.35*totpower;
            //	int cond1 = dtmp2 >= 0.18*dtmp1;
            int cond2 = accHNR < 0.55*totpower; //0.55 0.35
            int cond3 = harmonicstructure[0].nharmonic > 1;
            int cond = cond1+cond2+cond3+tmp;
            
            if(frameCnt>2){
                // // fprintf(fdebug, "\tTeste de condições:\n\tdtmp2 >= 0.18*dtmp1=%d\n\taccHNR < 0.35*totpower=%d\n\tharmonicstructure[0].nharmonic > 1=%d\n\t10.0*log10(dtmp1) > noisefloor+20.0=%d\n\n", cond1, cond2, cond3, tmp);
                // // fprintf(fdebug, "\tdtmp2=%f | dtmp1=%f | accHNR=%f | totpower=%f | 10.0*log10(dtmp1) > noisefloor+27.0 = %f > %f\n\n", 10*log10(dtmp2), 10*log10(dtmp1), 10*log10(accHNR), 10*log10(totpower), 10.0*log10(dtmp1), noisefloor+27.0);
            }
            
            if (cond == 4)  //JL & AJF 15Fev08, nharmonic > 1 is better
            {
                frame.sinusinfo.nharmonic=harmonicstructure[0].nharmonic;
                
                /*
                 Filipe, Jose: nas nossa aplicacoes, os campos (frame.sinusinfo.f0harm.word e
                 frame.sinusinfo.f0harm.bits) devem ser substituidos por um so (frame.sinusinfo.f0harm)
                 sem necessidade de quantificacao
                 */
                
                frame.sinusinfo.f0harm=harmonicstructure[0].f0harmonic;
                frame.sinusinfo.npause=harmonicstructure[0].npause;
                frame.sinusinfo.pospause=harmonicstructure[0].pospause;
            }
            else
            {
                // // fprintf(fdebug, "FALHA!!!\n/***********************************************************/\n\n");
                
                harmonicstructure[0].nharmonic = 0;
                harmonicstructure[0].f0harmonic = 0.0;
                frame.sinusinfo.nharmonic=0;
                frame.sinusinfo.f0harm=harmonicstructure[0].f0harmonic;
                frame.sinusinfo.npause=0;
                frame.sinusinfo.pospause=0;
            }
        }
        else
        {
            // // fprintf(fdebug, "FALHA!!!\n/***********************************************************/\n\n");
            
            harmonicstructure[0].f0harmonic = 0.0;
            frame.sinusinfo.nharmonic=0;
            frame.sinusinfo.f0harm=harmonicstructure[0].f0harmonic;
            frame.sinusinfo.npause=0;
            frame.sinusinfo.pospause=0;
        }
        
        frame.sinusinfo.ntonal=0;
        tonalsinfo.ntonal=0; // old variables, used ainda em sunttonal
    }
    else
    {
        // // fprintf(fdebug, "FALHA!!!\n/***********************************************************/\n\n");
        
        frame.sinusinfo.nharmonic=0;
        frame.sinusinfo.ntonal=0;
        harmonicstructure[0].nharmonic = 0;
        harmonicstructure[0].f0harmonic = 0.0;
        frame.sinusinfo.f0harm=harmonicstructure[0].f0harmonic;
    }
    if (harmonicstructure[0].nharmonic > 0.0)
    {
        // ajf 28nov07, keep memory of recent pitch (ignore 0.0 values)
        for(j=0; j<npastF0-1; j++) *(pastF0+j) = *(pastF0+j+1);
        *(pastF0+npastF0-1) = harmonicstructure[0].f0harmonic;
        //for(j=0; j<npastF0; j++) cout << "pastF0 " << j << " " << *(pastF0+j) << endl;
    }
    
    //	FILE *f = fopen("f0-st2.csv", "a+");
	// // fprintf(f, "%f\n", frame.sinusinfo.f0harm);
    //	fclose(f);
    //	fclose(fdebug);
    
    //	FILE *fspectro = fopen("F0Spec2.csv", "a+");
	
    //	for(int i=0; i<tamanho; i++)
	// // fprintf(fspectro, "%f,", *(logmag+i));
    
	// // fprintf(fspectro, "%f\n", frame.sinusinfo.f0harm);
    //	fclose(fspectro);
    
	frameCnt++;
    
    /*
     for(j=0; j<npastF0; j++) cout << "pastF0 " << j << " " << *(pastF0+j) << endl;
     
     
     cout << "Parciais: " << harmonicstructure[0].nharmonic << " F0: " << harmonicstructure[0].f0harmonic
     << " pausa: " << harmonicstructure[0].npause << " pos_pausa: " << harmonicstructure[0].pospause << endl << endl;
     */
    // cerr << harmonicstructure[0].f0harmonic << endl; // FA - comentario retirado
    
    
    /* NEW CODE 30dec06 */
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// END of version27Dez11.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void STATSEG::dirsegtrans (TRANSFORM& transform, WINDOW& window,
						   TRFTYPE trftype, WSWITCH wswitch)
{
	int i, j, len, len2, len4, start, stop;
	TRF transize = &TRANSFORM::dirrealtransf;

	if ((len=transform.size()) > nwords)    // cuidado com precedencia
	{cerr << "STATSEG::dirsegtrans_1" << endl; exit(0);}
	len2 = len >> 1;
	if (len == nwords)
	{
		nshort=1;
		if (window.size() != nwords) {cerr << "STATSEG::dirsegtrans_2" << endl; exit(0);}
		window.filterwin(daddsamp, wswitch);
		for (i=0; i<len2; i++) //2Ago2007JL n é necessário int i
		{
			*(recoeftf+i) = *(daddsamp+2*i);
			*(imcoeftf+i) = *(daddsamp+2*i+1);
		}
		(transform.*transize)(recoeftf, imcoeftf, trftype); // ajf 5/9/00
		for (i=0; i<len2; i++)
		{
			*(lcoef+i) = complex(*(recoeftf+i), *(imcoeftf+i));
		}
	}
	else
	{		
		if ((nshort = nwords/len) !=2 && nshort!=4 && nshort!=8)
		{cerr << "STATSEG::dirsegtrans_3" << endl; exit(0);}
		len4 = len2 >> 1;				// mirror edges of MDCT
		for (i=0; i<nshort; i++)
		{
			start=nwords4-len4+i*len2; stop=start+len;
			if (window.size() != len)
			{cerr << "STATSEG::dirsegtrans_4" << endl; exit(0);}
			for (j=0; start<stop; j++, start++) *(tmpdbl+j) = *(daddsamp+start); 
			window.filterwin(tmpdbl, REGULAR);
			for (j=0; j<len2; j++)
			{
				*(recoeftf+j) = *(tmpdbl+2*j);
				*(imcoeftf+j) = *(tmpdbl+1+2*j);
			}
			(transform.*transize)(recoeftf, imcoeftf, trftype);
			start=i*len2; stop=start+len2;
			for (j=0; start<stop; j++, start++) *(scoef+start) = complex(*(recoeftf+j), *(imcoeftf+j));
		}
	}
}


void STATSEG::resettonal()
{
	int i;

	//JL 07Set07 - syntcoef não é utilizado
	//for (i=0; i<nwords2; i++) *(syntcoef+i)=complex(0.0, 0.0);

	//JL 07Set07 - reset aos valores F0 anteriores
	for(i=0; i<npastF0; i++) *(pastF0+i) = 0.0;

	//Tiago 02Jan11 - counter de frames p/ debug
	frameCnt=0;
	for(i=0; i<256; i++)
		tonalpos[i]=0;
}

void STATSEG::setValue(float value_){ //JL 02Ago07 - para possiblitar a modificação do threshold de vozeamento
	value=value_;
}


#endif

#ifndef _COMMON_
#define _COMMON_

#include "Defines.h"

#define MIN(A,B) ( (A) < (B) ? (A) : (B) )
#define MAX(A,B) ( (A) > (B) ? (A) : (B) )

#define BITSPERSAMPLE 16 // possible values: 8, 16, 24 bits

typedef signed char SAMPLE08;
typedef short int   SAMPLE16;
typedef int         SAMPLE24;

//  C++ 2.0
//  COMPILER PROBLEM: it recognizes "char" and "signed char"
//  but not "signed char*" wich is considered the same as "char*"
//  e.g try signed char* pt; pt = new signed char;
//  This and other problems are solved in current version 3.01

enum TRFTYPE { DFT, ODFT, MDCT};
enum WINTYPE { RECTANGULAR, SINE, OPTISINE, TDAC2, TDAC4, TDAC8, OPTISINE_FULL};
// extern char* WNAMES[6];
enum WSWITCH { REGULAR, WSTART, WSTOP, WSHORT};

struct settings
{
	int nchan;     // number of channels (1...5)
	int segsize;   // SEGMENT size, must be power of 2
	WINTYPE window;// window type and switching
	float bitrate; // total bitrate
	float sfreq;   // sampling frequency
	char* inpfile; // input audio data filename
	char* outfile; // output audio data filename
};
/*
struct huffnode
{
	int value;	// original value
	ulong count;	// frequency of occurences of "value",
	ulong binword;	// actual huffman code, ENCODER ONLY
	char nbits;	// length in bits of the huffman code, ENCODER ONLY
	huffnode* left;	// next branch of the tree on the left side
	huffnode* right;// next branch of the tree on the rigth side
}; */
/*
struct huffunit
{
	ulong hufword; // NOTE: first bit on the left !!!
	char hufbits;
};
*/
struct sinusoids // ver pag 520 Bjarne
{
          int nharmonic;	// FA
          float f0harm;
 //         int phisinusqz[128];
 //         int magsinusqz[128];
          int npause;
          int pospause;

          int ntonal;
 //         float f0tonal[8];
 //         int phitonalqz[8];
 //         int magtonalqz[8];
		  /*
		  *	VFA - 19-06-2012
		  */
		  int nFormants;
		  float formantsList[8];
		  /*
		  *	VFA - fim
		  */
};


struct statframe
{
        WSWITCH janela; // define tipo de janela

//	int nsect; // define numero de factores de escala e coeficientes // FA
//	int sect[128][2]; // distribuicao das tabelas de HUFFMAN pelas particoes

        sinusoids sinusinfo; // info sobre sinusoides isoladas ou harmonicas

//	int shortseq; // sequencia de factores de escala para blocos curtos
//	int slopeseq; // indice de declive da sequencia de cepstra blocos curtos ajf 13-07-03

//	int cepscoefs[32];
//	int ncepscoefs; // numero de coeficientes cepstrais
//	float cepsbin[32];

        // usa informacao de sinusinfo
//	int nmagsinusbin; // numero de coeficientes magnitudes sinusoides
//	float magsinusbin[256];

//	int coef[1024]; //era 512
//	int ncoefbin; // numero de codigos de coeficientes
//	float coefbin[2048]; // > 1024 porque inclui ESC codes // FA

//        int totbitceps;

//        int totbitsin; // inclui bits fase + bits magnitude

//        int totbitcoef;
};

#endif

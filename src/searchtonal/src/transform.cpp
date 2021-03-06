#ifndef _TRANSFORM_
#define _TRANSFORM_

#include <iostream>
using namespace std;

#include "transform.h"

TRANSFORM::TRANSFORM(int numberbins)
{
     BNBINS = numberbins;
     NBINS = numberbins>>1;
     NBINS2 = NBINS >> 1; NBINS4 = NBINS2 >> 1;
     initransf();
}

void TRANSFORM::initransf()
{
     int i, dv, ic, pos, final, *flag;
     int k, butfly, group;
     double arg;

     nstg = (int)(floor(0.5+log10((double)(NBINS))/log10(2.0)));
     if (NBINS>1024 || NBINS!=(1<<nstg))
     {cerr << "ERROR: TRANSFORM::init:" << nstg << endl; exit(0);}
     flag = new int[NBINS];
     rev = new int[NBINS-2];

     nchg=0; for (i=0; i<NBINS; i++) flag[i]=0;
     for (i=1; i<NBINS-1; i++)
     {
	  if (flag[i-1]==0)
	  {
	       dv=NBINS2; ic=1; final=0; pos=i;
	       for (int k=0; k<nstg; k++)
	       {
		    if ((pos/dv) >= 1)
		    {
			 pos-=dv; final+=ic;
		    }
		    dv >>= 1; ic <<= 1;
	       }
	       if (i!=final)
	       {
		    rev[nchg]=i;
		    rev[NBINS2+nchg-1]=final;
		    flag[final-1]=1;
		    nchg++;

	       }
	  }
     }
     delete[] flag;

     redirargdft  = new double[NBINS-1];
     imdirargdft  = new double[NBINS-1];
     reinvargdft  = new double[NBINS-1];
     iminvargdft  = new double[NBINS-1];

     redirargodft  = new double[NBINS-1];
     imdirargodft  = new double[NBINS-1];
     reinvargodft  = new double[NBINS-1];
     iminvargodft  = new double[NBINS-1];

/*
 * estes vectores representam os estagios de pos-processamento
 * no caso da transformada directa e o estagio de pre-processamento
 * no caso da transformada inversa, de modo a permitir o calculo de
 * uma transformada real de comprimento BNBINS atraves de uma
 * transformada complexa de comprimento NBINS
 *
 */

     reargodft  = new double[NBINS2];
     imargodft = new double[NBINS2];
     reargdft  = new double[NBINS2];
     imargdft = new double[NBINS2];


/*
 * o vector seguinte e' necessario no estagio de premultiplicacao
 * que permite passar do domi'nio IMDCT para o de IODFT, e tambem no
 * estagio de posmultiplicacao que permite passar do dominio ODFT
 * para o dominio MDCT.
 *
 */

     reargmdct  = new double[NBINS]; // duas vezes NBINS !
     imargmdct  = new double[NBINS];


/*
 * iniciliza vectores transformada directa (DIT)
 *
 */
     group=NBINS; butfly=1; pos=0;
     for (i=0; i<nstg; i++)
     {
       group >>= 1;

       for (k=0; k<butfly; k++)
       {
         arg=M_PI*(double)(2*k+1)/(double)(2*butfly);
         redirargodft[pos+k] = cos(arg);
         imdirargodft[pos+k] = -sin(arg);
         arg=M_PI*(double)(2*k)/(double)(2*butfly);
         redirargdft[pos+k] = cos(arg);
         imdirargdft[pos+k] = -sin(arg);
       }
       pos += butfly;
       butfly <<= 1;
     }


/*
 * iniciliza vectores transformada inversa (DIF)
 *
 */
     butfly=NBINS; group=1; pos=0;
     for (i=0; i<nstg; i++)
     {
        butfly >>= 1;

       for (k=0; k<butfly; k++)
       {
         arg=M_PI*(double)(2*k+1)/(double)(2*butfly);
         reinvargodft[pos+k] = cos(arg);
         iminvargodft[pos+k] = sin(arg);
         arg=M_PI*(double)(2*k)/(double)(2*butfly);
         reinvargdft[pos+k] = cos(arg);
         iminvargdft[pos+k] = sin(arg);
       }
       pos += butfly;
       group <<= 1;
     }

/*
 * inicializa vectores de passagem entre transformada complexa e real
 * NOTA: poder-se-ia ainda poupar 1/4 do comprimento destes vectores
 *
 */
     for (i=0; i<NBINS2; i++)
     {
        arg=M_PI*(double)(2*i+1)/(double)(BNBINS);
        reargodft[i] = cos(arg);
        imargodft[i] = sin(arg);
        arg=M_PI*(double)(2*i)/(double)(BNBINS);
        reargdft[i] = cos(arg);
        imargdft[i] = sin(arg);

     }

/*
 * Inicializa vectores de passagem entre dominio IMDCT para o de IODFT
 * e de passagem ODFT -> MDCT
 *
 */
     for (i=0; i<NBINS; i++)
     {
        arg=M_PI*(double)((2*i+1)*(1+NBINS))/(double)(2*BNBINS);/*??*/
        reargmdct[i] = cos(arg);
        imargmdct[i] = sin(arg);
     }



}

void TRANSFORM::dirrealtransf(double* redata, double* imdata, TRFTYPE transtype)
{
  double retemp, imtemp, *reptr, *imptr, *lrearg, *limarg;
  double *retmptr1, *imtmptr1, *retmptr2, *imtmptr2;
  double rex1, imx1, rex2, imx2;
  int i,j,k;
  int butfly,group;

    if(transtype==MDCT)
    {
          // passagem do dominio ODFT para MDCT

          reptr = reargmdct; imptr = imargmdct;
          retmptr1 = redata; imtmptr1 = imdata;
          for (k=0; k<NBINS; k++)
          {
             retemp = *(retmptr1);
             *(retmptr1) = *(retmptr1) * *(reptr) + *(imtmptr1) * *(imptr);
             *(imtmptr1) = *(imtmptr1) * *(reptr++) - retemp * *(imptr++);
             retmptr1++; imtmptr1++;
          }
	  return;
    }
// ajf 5/9/00 para simular ODFT2MDCT
/*
 * operac,a~o de "bit reversal"
 *
 */
  for (i=0; i<nchg; i++)
  {
     retemp=redata[rev[i]];
     imtemp=imdata[rev[i]];
     redata[rev[i]]=redata[rev[NBINS2+i-1]];
     imdata[rev[i]]=imdata[rev[NBINS2+i-1]];
     redata[rev[NBINS2+i-1]]=retemp;
     imdata[rev[NBINS2+i-1]]=imtemp;
  }


  switch(transtype)
  {
    default:
	  cerr << "Unknown Transform type (DFT considered)" << endl;
    case DFT:
          reptr = redirargdft; imptr = imdirargdft;
	  break;
    case ODFT:
    case MDCT:
          reptr = redirargodft; imptr = imdirargodft;
	  break;
  }

  retmptr1 = redata; retmptr2 = redata + 1;
  imtmptr1 = imdata; imtmptr2 = imdata + 1;
  for (j=0; j<(NBINS2); j++)
  {


    retemp = *(retmptr2) * *(reptr) - *(imtmptr2) * *(imptr);
    imtemp = *(retmptr2) * *(imptr) + *(imtmptr2) * *(reptr);

    *(retmptr2)  = *(retmptr1) - retemp;
    *(imtmptr2)  = *(imtmptr1) - imtemp;

    *(retmptr1) += retemp;
    *(imtmptr1) += imtemp;

    retmptr1+=2; imtmptr1+=2;
    retmptr2+=2; imtmptr2+=2;
  }
  reptr++; imptr++;
  group=NBINS2; butfly = 2;

  for (i=1; i< (nstg-1) ; i++)
  {
    group >>= 1;

    retmptr1 = redata; retmptr2 = redata + butfly;
    imtmptr1 = imdata; imtmptr2 = imdata + butfly;
    for (j=0; j<group; j++)
    {
      lrearg=reptr; limarg=imptr;

      for (k=0; k<butfly; k++)
      {

        retemp = *(retmptr2) * *(lrearg) - *(imtmptr2) * *(limarg);
        imtemp = *(retmptr2) * *(limarg++) + *(imtmptr2) * *(lrearg++);

        *(retmptr2++)  = *(retmptr1) - retemp;
        *(imtmptr2++)  = *(imtmptr1) - imtemp;

        *(retmptr1++) += retemp;
        *(imtmptr1++) += imtemp;
      }

      retmptr1+=butfly; retmptr2+=butfly;
      imtmptr1+=butfly; imtmptr2+=butfly;

    }
    reptr += butfly; imptr += butfly;
    butfly <<= 1;
  }
  retmptr1 = redata; retmptr2 = retmptr1 + NBINS2;
  imtmptr1 = imdata; imtmptr2 = imtmptr1 + NBINS2;

  for (k=0; k<NBINS2; k++)
  {

        retemp = *(retmptr2) * *(reptr) - *(imtmptr2) * *(imptr);
        imtemp = *(retmptr2) * *(imptr++) + *(imtmptr2) * *(reptr++);

        *(retmptr2++)  = *(retmptr1) - retemp;
        *(imtmptr2++)  = *(imtmptr1) - imtemp;

        *(retmptr1++) += retemp;
        *(imtmptr1++) += imtemp;

  }



  switch(transtype)
  {
    default:
    case DFT:
          /*
           * Pos-processamento para converter transformada real numa complexa
           *
           */
           lrearg = reargdft+1; limarg = imargdft+1;

           retmptr1 = redata; retmptr2 = redata+NBINS-1;
           imtmptr1 = imdata; imtmptr2 = imdata+NBINS-1;

           imtemp = *(retmptr1) - *(imtmptr1);
           *(retmptr1) = *(retmptr1) + *(imtmptr1); // k=0
           *(imtmptr1) = imtemp; // k=N isto e' PI
// notar que valor de PI sai na parte imaginaria de "data"
           retmptr1++; imtmptr1++;

           for (k=1; k<NBINS2; k++)
           {
              rex1=0.5*( *(retmptr1) + *(retmptr2)); // X1(k)
              imx1=0.5*( *(imtmptr1) - *(imtmptr2));

              rex2=0.5*( *(imtmptr1) + *(imtmptr2)); // X2(k)
              imx2=0.5*( *(retmptr2) - *(retmptr1));

              retemp = rex2 * *(lrearg) + imx2 * *(limarg);
              imtemp = imx2 * *(lrearg++) - rex2 * *(limarg++);

              *(retmptr1++) = rex1 + retemp; // X(k)
              *(imtmptr1++) = imx1 + imtemp;

              *(retmptr2--) = rex1 - retemp; // X(N/2-k)
              *(imtmptr2--) = imtemp - imx1;
           }
           *(imtmptr1) *= -1; //  X(N/2)
	  break;
    case ODFT:
          /*
           * Pos-processamento para converter transformada real numa complexa
           *
           */
           lrearg = reargodft; limarg = imargodft;

           retmptr1 = redata; retmptr2 = redata+NBINS-1;
           imtmptr1 = imdata; imtmptr2 = imdata+NBINS-1;

           for (k=0; k<NBINS2; k++)
           {
              rex1=0.5*( *(retmptr1) + *(retmptr2)); /* conta de * 0.5 ira' implicita na janela */
              imx1=0.5*( *(imtmptr1) - *(imtmptr2));

              rex2=0.5*( *(imtmptr1) + *(imtmptr2));
              imx2=0.5*( *(retmptr2) - *(retmptr1));

              retemp = rex2 * *(lrearg) + imx2 * *(limarg);
              imtemp = imx2 * *(lrearg++) - rex2 * *(limarg++);

              *(retmptr1++) = rex1 + retemp;
              *(imtmptr1++) = imx1 + imtemp;

              *(retmptr2--) = rex1 - retemp;
              *(imtmptr2--) = imtemp - imx1;
           }
	  break;
  }
}

void TRANSFORM::invrealtransf(double* redata, double* imdata, TRFTYPE transtype)
{

  double retemp, imtemp, *reptr, *imptr, *lrearg, *limarg;
  double *retmptr1, *imtmptr1, *retmptr2, *imtmptr2;
  double rex1, imx1, rex2, imx2;
  int i,j,k;
  int butfly,group;

  if(transtype==MDCT)
  {
          reptr = reargmdct; imptr = imargmdct;
          retmptr1 = redata; imtmptr1 = imdata;
          for (k=0; k<NBINS; k++)
          {
             *(imtmptr1++) = *(retmptr1) * *(imptr++);
             *(retmptr1++) *= *(reptr++);
          }
	  return;   // ajf 5/9/00 para simular IMDCT2IODFT
  }
  switch(transtype)
  {

    case ODFT:
          // Pre-processamento para obter no final x1(n) + j x2(n)

          reptr = reargodft; imptr = imargodft;
          retmptr1 = redata; retmptr2 = redata+NBINS-1;
          imtmptr1 = imdata; imtmptr2 = imdata+NBINS-1;

          for (k=0; k<NBINS2; k++)
          {
             rex1 = *(retmptr1) + *(retmptr2); // X1(k)
             imx1 = *(imtmptr1) - *(imtmptr2);

             retemp = *(retmptr1) - *(retmptr2); // X2(k)
             imtemp = *(imtmptr1) + *(imtmptr2);

             rex2 = retemp * *(reptr) - imtemp * *(imptr);
             imx2 = imtemp * *(reptr++) + retemp * *(imptr++);

             *(retmptr1++) = rex1 - imx2 ; // X1(k) + j X2(k)
             *(imtmptr1++) = imx1 + rex2 ;

             *(retmptr2--) = rex1 + imx2; // X1(N-k-1) + j X2(N-k-1)
             *(imtmptr2--) = rex2 - imx1;
          }
          reptr = reinvargodft; imptr = iminvargodft;
	  break;

    case DFT:
          // Pre-processamento para obter no final x1(n) + j x2(n)

          reptr = reargdft+1; imptr = imargdft+1;
          retmptr1 = redata; retmptr2 = redata+NBINS-1;
          imtmptr1 = imdata; imtmptr2 = imdata+NBINS-1;

          imtemp = *(retmptr1) - *(imtmptr1);
          *(retmptr1) = *(retmptr1) + *(imtmptr1); // k=0
          *(imtmptr1) = imtemp;
          retmptr1++; imtmptr1++;

          for (k=1; k<NBINS2; k++)
          {
             rex1 = *(retmptr1) + *(retmptr2); // X1(k)
             imx1 = *(imtmptr1) - *(imtmptr2);

             retemp = *(retmptr1) - *(retmptr2); // X2(k)
             imtemp = *(imtmptr1) + *(imtmptr2);

             rex2 = retemp * *(reptr) - imtemp * *(imptr);
             imx2 = imtemp * *(reptr++) + retemp * *(imptr++);

             *(retmptr1++) = rex1 - imx2 ; // X1(k) + j X2(k)
             *(imtmptr1++) = imx1 + rex2 ;

             *(retmptr2--) = rex1 + imx2; // X1(N-k) + j X2(N-k)
             *(imtmptr2--) = rex2 - imx1;
          }
          *(retmptr1) *= 2; // X1(N/2) + j X2(N/2)
          *(imtmptr1) *= -2;
          reptr = reinvargdft; imptr = iminvargdft;
	  break;
    default:
	  cerr << "Unknown Transform type (DFT considered)" << endl;
  }


/*
 * transformada inversa pela DIF
 *
 */
  retmptr1 = redata; retmptr2 = retmptr1 + NBINS2;
  imtmptr1 = imdata; imtmptr2 = imtmptr1 + NBINS2;

  for (k=0; k<NBINS2; k++)
  {
        retemp = *(retmptr1) - *(retmptr2);
        imtemp = *(imtmptr1) - *(imtmptr2);

        *(retmptr1++) += *(retmptr2);
        *(imtmptr1++) += *(imtmptr2);

        *(retmptr2++) = retemp * *(reptr) - imtemp * *(imptr);
        *(imtmptr2++) = retemp * *(imptr++) + imtemp * *(reptr++);
  }

  butfly=NBINS2; group=2;

  for (i=1; i< (nstg-1) ; i++)
  {
    butfly >>= 1;

    retmptr1 = redata; retmptr2 = retmptr1 + butfly;
    imtmptr1 = imdata; imtmptr2 = imtmptr1 + butfly;
    for (j=0; j<group; j++)
    {
      lrearg=reptr; limarg=imptr;

      for (k=0; k<butfly; k++)
      {
        retemp = *(retmptr1) - *(retmptr2);
        imtemp = *(imtmptr1) - *(imtmptr2);

        *(retmptr1++) += *(retmptr2);
        *(imtmptr1++) += *(imtmptr2);

        *(retmptr2++) = retemp * *(lrearg) - imtemp * *(limarg);
        *(imtmptr2++) = retemp * *(limarg++) + imtemp * *(lrearg++);
      }
      retmptr1+=butfly; retmptr2+=butfly;
      imtmptr1+=butfly; imtmptr2+=butfly;
    }
    reptr += butfly; imptr += butfly;
    group <<= 1;
  }

  retmptr1 = redata; retmptr2 = redata + 1;
  imtmptr1 = imdata; imtmptr2 = imdata + 1;
  for (j=0; j<NBINS2; j++)
  {

        retemp = *(retmptr1) - *(retmptr2);
        imtemp = *(imtmptr1) - *(imtmptr2);

        *(retmptr1) += *(retmptr2);
        *(imtmptr1) += *(imtmptr2);

        *(retmptr2) = retemp * *(reptr) - imtemp * *(imptr);
        *(imtmptr2) = retemp * *(imptr) + imtemp * *(reptr);

        retmptr1+=2; imtmptr1+=2;
        retmptr2+=2; imtmptr2+=2;
  }

/*
 * operac,a~o de "bit reversal", e' desnecessaria na implementac,a~o do C31 ja'
 * que e conseguida automaticamente na transferencia de vectores. Deve acontecer
 * neste ponto do co'digo.
 *
 */
  for (i=0; i<nchg; i++)
  {
     retemp=redata[rev[i]];
     imtemp=imdata[rev[i]];
     redata[rev[i]]=redata[rev[NBINS2+i-1]];
     imdata[rev[i]]=imdata[rev[NBINS2+i-1]];
     redata[rev[NBINS2+i-1]]=retemp;
     imdata[rev[NBINS2+i-1]]=imtemp;
  }


/*
 * esta divisa~o deve estar embebida na multiplicac,a~o pela
 * coeficientes da janela temporal, quando se fizer a implementac,a~o no C31
 */

  for (i=0; i<NBINS; i++) *(redata+i) /= (BNBINS);
  for (i=0; i<NBINS; i++) *(imdata+i) /= (BNBINS);
}

TRANSFORM::~TRANSFORM()
{
     delete[] rev;

     delete[] redirargdft, imdirargdft, reinvargdft, iminvargdft;
     delete[] redirargodft, imdirargodft, reinvargodft, iminvargodft;
     delete[] reargmdct, imargmdct, reargodft, imargodft, reargdft, imargdft;
}
#endif

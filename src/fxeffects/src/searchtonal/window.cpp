#ifndef _WINDOW_
#define _WINDOW_

#include "window.h"
#include <iostream>
using namespace std;

WINDOW::WINDOW(int len, WINTYPE wintype)
{
	double inv_Gwindow;
     int i, slen, top;
	 Gwindow=0.0;	//JL 05Set2007 Gwindow
     length = len;
     windowtype = wintype;
     regularwindow = new double[length];

     switch(wintype)
	 {
	case RECTANGULAR:
	   for (i=0; i<length; i++) Gwindow+=regularwindow[i]=1.0; //JL 05Set2007 Gwindow
	   break;
	case SINE:
	case OPTISINE:
	    for (i=0; i<length; i++)
			Gwindow+=regularwindow[i]=M_SQRT2*sin(M_PI*(0.5+i)/length);
	   break;
	case OPTISINE_FULL:
	   for (i=0; i<length; i++)
			Gwindow+=regularwindow[i]=M_SQRT2*sin(M_PI*(0.5+i)/length); //JL 05Set2007 Gwindow
	   break;
        default:
        switch(wintype)
        {
		case TDAC2: slen = len/2; break;
		case TDAC4: slen = len/4; break;
		case TDAC8: slen = len/8; break;
		default: {cerr << "ERROR WINDOW::WINDOW\n"; exit(0);}
		break;
        }
           startswitch = new double[length];
           stopswitch  = new double[length];

	   for (i=0; i<length/4; i++)
	   {
		*(regularwindow+i)=M_SQRT2*sin(M_PI*(i+0.5)/(double)(length)); 
		*(regularwindow+length-1-i)= *(regularwindow+i); 
		*(regularwindow+length/2-1-i)= *(regularwindow+length/2+i)=
			sqrt(2.0- *(regularwindow+i) * *(regularwindow+i));
	   }

           for (i=0; i<length/2; i++)
	      startswitch[i]=regularwindow[i];

	   top = 3*length/4-slen/4;
           for (; i<top; i++) startswitch[i]= M_SQRT2;

	   top = 3*length/4;
           for (; i<top; i++)
	   {
		startswitch[3*length/2-i-1]=M_SQRT2*
			sin(M_PI*(i+0.5-3*length/4+slen/4)/(double)(slen));
		startswitch[i]= sqrt(2.0- *(startswitch+3*length/2-i-1)*
			*(startswitch+3*length/2-i-1));
	   }
	   i=3*length/4+slen/4;
           for (; i<length; i++) startswitch[i]=0.0;

/*
 * startswitch reversed in time
 */

           for (i=0; i<length; i++)
	      stopswitch[i]=startswitch[length-1-i];

		for (i=0; i<length; i++) Gwindow+=regularwindow[i];
	   break;

     }
#ifndef DISABLE_WINDOW_NORMALIZED
		Gwindow = 1.0E6 / (32767.0 * M_SQRT2 * (double)(length)/Gwindow);
#else
		Gwindow = 1.0f;
#endif
		inv_Gwindow = 1.0 / Gwindow;
		for (i=0; i<length; i++) regularwindow[i] *= inv_Gwindow; // normalizar a janela seno

}

WINDOW::~WINDOW()
{
     delete[] regularwindow;
     if (windowtype >= TDAC2) {delete[] startswitch; delete[] stopswitch;}
}

void WINDOW::filterwin(double* array, WSWITCH wswitch) const
{
   if (wswitch > REGULAR && windowtype < TDAC2)
   {cerr << "ERROR WINDOW::filterwin_2" << endl; exit(0);}

   switch(wswitch)
   {
      case REGULAR:
           {
              for (int i=0; i<length; i++) *(array+i) *= *(regularwindow+i);
              //for (int j=0; j<length; j++) cout << "FilterWIN: " << j << " " << *(array+j) << endl; 
	      break;
	   }
      case WSTART:
           {
              for (int i=0; i<length; i++) *(array+i) *= *(startswitch+i);
	      break;
	   }
      case WSTOP:
           {
              for (int i=0; i<length; i++) *(array+i) *= *(stopswitch+i);
	      break;
	   }

   }
}

void WINDOW::filterwin(complex* array, WSWITCH wswitch) const
{
   if (wswitch > REGULAR && windowtype < TDAC2)
   {cerr << "ERROR WINDOW::filterwin_2" << endl; exit(0);}

   switch(wswitch)
   {
      case REGULAR:
         {
            for (int i=0; i<length; i++) *(array+i) *= *(regularwindow+i);
	    break;
	 }
      case WSTART:
         {
            for (int i=0; i<length; i++) *(array+i) *= *(startswitch+i);
	    break;
	 }
      case WSTOP:
         {
            for (int i=0; i<length; i++) *(array+i) *= *(stopswitch+i);
	    break;
	  }

   }
}

double WINDOW::getGwindow(){
	return Gwindow;
}
#endif

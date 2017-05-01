#ifndef _SEGMENT_
#define _SEGMENT_

#include <math.h>
#include <iostream>

using namespace std;

#include "segment.h"

//typedef int (read_segment::*PRIF)(char*, int);
//typedef int (write_segment::*PWOF)(char*, int);
int SEGMENT::wordlength = BITSPERSAMPLE; // defines static entity

int SEGMENT::inputsamples(const float* input, int shift)
{
     int i, result;
//     PRIF prif = &read_segment::read;

     if (shift>=nwords) // renova buffer totalmente
     {
        switch(wordlength)
	{
	  case  8 :
	  {
	      for (i=0; i<nwords; i++) addsamp08[i] = (SAMPLE08)*(input+i);
              result = nwords;
//	  result = (input.*prif)((char*)addsamp08, nwords*sizeof(SAMPLE08));
//	  result = result/sizeof(SAMPLE08);
//	  if (result<nwords) for (i=result; i<nwords; i++) addsamp08[i]=0;
	      return result;
	  }

	  case 16 :
	  {
	      for (i=0; i<nwords; i++) addsamp16[i] = (SAMPLE16)*(input+i);
              result = nwords;
//	  result = (input.*prif)((char*)addsamp16, nwords*sizeof(SAMPLE16));
//	  result = result/sizeof(SAMPLE16);
//	  if (result<nwords) for (i=result; i<nwords; i++) addsamp16[i]=0;	     
		  return result;
		  
	  }

	  case 24 :
	  {
	      for (i=0; i<nwords; i++) addsamp24[i] =(SAMPLE24) *(input+i);
              result = nwords;
//	  result = (input.*prif)((char*)addsamp24, nwords*sizeof(SAMPLE24));
//	  result = result/sizeof(SAMPLE24);
//	  if (result<nwords) for (i=result; i<nwords; i++) addsamp24[i]=0;
	      return result;
	  }
	}
     }
     else // refreshes buffer partially keeping old samples
     {
        int i,j,result;
	switch(wordlength)
	{
	  case  8 :
	  {
	      for (i=0, j=shift; i<nwords-shift; i++, j++)
	      {   *(addsamp08+i) = *(addsamp08+j);   }
	      for (i=0, j=nwords-shift; i<shift; i++, j++) addsamp08[j] = (SAMPLE08)*(input+i);
              result = shift;
//	  result = (input.*prif)((char*)(addsamp08+nwords-shift),
//		    shift*sizeof(SAMPLE08));
//	  result = result/sizeof(SAMPLE08);
//	  if (result<shift)
//	      for (i=nwords-shift+result; i<nwords; i++) addsamp08[i]=0;
	      return result;
	  }

	  case 16 :
	  {
	      for (i=0, j=shift; i<nwords-shift; i++, j++)
	      {   *(addsamp16+i) = *(addsamp16+j);   }
	      for (i=0, j=nwords-shift; i<shift; i++, j++) addsamp16[j] = (SAMPLE16) *(input+i);
              result = shift;
//	  result = (input.*prif)((char*)(addsamp16+nwords-shift),
//		    shift*sizeof(SAMPLE16));
//	  result = result/sizeof(SAMPLE16);
//	  if (result<shift)
//	      for (i=nwords-shift+result; i<nwords; i++) addsamp16[i]=0;
//		  printf("((%i,%i)) ",input[1],addsamp16[1] );
	      return result;
	  }

	  case 24 :
	  {
	      for (i=0, j=shift; i<nwords-shift; i++, j++)
	      {   *(addsamp24+i) = *(addsamp24+j);   }
	      for (i=0, j=nwords-shift; i<shift; i++, j++) addsamp24[j] =(SAMPLE24) *(input+i);
              result = shift;
//	  result = (input.*prif)((char*)(addsamp24+nwords-shift),
//		    shift*sizeof(SAMPLE24));
//	  result = result/sizeof(SAMPLE24);
//	  if (result<shift)
//	      for (i=nwords-shift+result; i<nwords; i++) addsamp24[i]=0;
	      return result;
	  }
	}
     }
     return 0; // never reaches here
}

/*
int SEGMENT::outputsamples(write_segment& output, int nsamples)
{
     int result;
     PWOF pwof = &write_segment::write;

     if (nsamples>nwords)
     {cerr << "EXCESSIVE N_SAMPLES: " << nsamples << endl; exit(0);}

     switch(wordlength)
     {
	case  8 :
	{
	result = (output.*pwof)((char*)addsamp08, nsamples*sizeof(SAMPLE08));
	return result/sizeof(SAMPLE08);
	}
	case 16 :
	{
	result = (output.*pwof)((char*)addsamp16, nsamples*sizeof(SAMPLE16));
	return result/sizeof(SAMPLE16);
	}
	case 24 :
	{
	result = (output.*pwof)((char*)addsamp24, nsamples*sizeof(SAMPLE24));
	return result/sizeof(SAMPLE24);
	}
     }
     return 0; // never reaches here
}
*/

double SEGMENT::transient(int start, int stop)
{
     int i, j, first;
     double result, predicted;
     static double lpc[6]={1.0, -1.74, 1.57, -1.27, 0.73, -0.24};

     if (start>stop || stop>nwords)
     {cerr << "EXCESSIVE RANGE: " << start << " " << stop << endl; exit(0);}

     result=0.0;
     switch(wordlength)
     {
	 case  8 :
		   for (i=start; i<stop; i++)
		   result += (double)(*(addsamp08+i)) * (double)(*(addsamp08+i));
		   break;
	 case 16 :
		   for (i=start; i<stop; i++)
		   {
		      predicted=0.0;
		      first=MAX(0, i-5);
		      for (j=first; j<=i; j++)
			predicted += (double)(*(addsamp16+j))*lpc[i-j];
		        //result += predicted * predicted;
		        result += fabs(predicted);
		   }
		   break;
	 case 24 :
		   for (i=start; i<stop; i++)
		   result += (double)(*(addsamp24+i)) * (double)(*(addsamp24+i));
		   break;
	 default :
		   cerr << "SAMPLE LENGTH NOT VALID: " << wordlength << endl;
                   exit(0);
     }
     return result;
}

void SEGMENT::copydata(const SEGMENT& s)
{
     if (nwords>s.nwords) {cerr<<"Excessive length: "<<nwords<<endl; exit(0);}
     for (int i=0; i<nwords; i++) 
	 {
		   *(addsamp16+i) = *(s.addsamp16+i);
		   //cout << i << " addsamp16 " << *(addsamp16+i) << endl;

	 }
}

SEGMENT::SEGMENT(int length)
{
     int i;

     nwords = length;
     nwords2 = nwords >> 1; nwords4 = nwords2 >> 1;

     switch(wordlength)
     {
	 case  8 :
		   addsamp08 = new SAMPLE08[nwords];
	           for (i=0; i<nwords; i++) *(addsamp08+i)=0;
		   break;
	 case 16 :
		   addsamp16 = new SAMPLE16[nwords];
	           for (i=0; i<nwords; i++) *(addsamp16+i)=0;
		   break;
	 case 24 :
		   addsamp24 = new SAMPLE24[nwords];
	           for (i=0; i<nwords; i++) *(addsamp24+i)=0;
		   break;
	 default :
		   cerr << "SAMPLE LENGTH NOT VALID: " << wordlength << endl;
                   exit(0);
     }
}

SEGMENT::SEGMENT()
{
     nwords = 0;

     switch(wordlength)
     {
	 case  8 : addsamp08 = 0; break;
	 case 16 : addsamp16 = 0; break;
	 case 24 : addsamp24 = 0; break;
	 default :
	 {cerr << "SAMPLE LENGTH NOT VALID: " << wordlength << endl; exit(0);}
     }
}

SEGMENT::~SEGMENT()
{
     if (nwords > 0) switch(wordlength)
     {
	  case  8 : delete[] addsamp08; break;
	  case 16 : delete[] addsamp16; break;
	  case 24 : delete[] addsamp24; break;
     }
}

SEGMENT& SEGMENT::operator=(const SEGMENT& s)
{
  int i;
  if (nwords==0)
  {
     nwords = s.nwords;

     switch(wordlength)
     {
	 case  8 : {addsamp08 = new SAMPLE08[nwords];
		   for (i=0; i<nwords; i++)
		   *(addsamp08+i) = *(s.addsamp08+i);}break;
	 case 16 : {addsamp16 = new SAMPLE16[nwords];
		   for (i=0; i<nwords; i++)
		   *(addsamp16+i) = *(s.addsamp16+i);}break;
	 case 24 : {addsamp24 = new SAMPLE24[nwords];
		   for (i=0; i<nwords; i++)
		   *(addsamp24+i) = *(s.addsamp24+i);}break;
     }
  }
  else
  {
     if (nwords!=s.nwords) {cerr << "DIFFERENT segment lengths: " <<
			    nwords << " " << s.nwords << endl; exit(0);}
     switch(wordlength)
     {
          case  8 : {for (i=0; i<nwords; i++)
		    *(addsamp08+i) = *(s.addsamp08+i);}break;
          case 16 : {for (i=0; i<nwords; i++)
		    *(addsamp16+i) = *(s.addsamp16+i);}break;
          case 24 : {for (i=0; i<nwords; i++)
		    *(addsamp24+i) = *(s.addsamp24+i);}break;
     }
  }
  return *this;
}
#endif

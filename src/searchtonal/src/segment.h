#ifndef _SEGMENT_H
#define _SEGMENT_H

/*
 * CLASS segment
 * Insures only the ginary writing and reading
 *
 */

class BARKSCALE;
class WINDOW;
class STATSEG;
#include "common.h"
//#include "read_segment.h"
//#include "write_segment.h"

class SEGMENT
{

protected: // enable access to derived classes, Bjarne 564
     union
     {
        SAMPLE08* addsamp08;
        SAMPLE16* addsamp16;
        SAMPLE24* addsamp24;
     };

     static int wordlength;
     int nwords, nwords2, nwords4;

public:
      SEGMENT();
      SEGMENT(int);
      ~SEGMENT();
      int  inputsamples(const float*, int);
//      int  outputsamples(SAMPLE16*, int);
      double transient(int, int);

      void copydata(const SEGMENT&);
      SEGMENT& operator=(const SEGMENT&);
};

#endif

#ifndef _TRANSFORM_H
#define _TRANSFORM_H

/*
 * CLASS transform
 * fast computation of the DFT, ODFT and MDCT. Operations are "in place"
 * over complex vectors
 *
 */

#include <math.h>
#include "common.h"

class TRANSFORM
{

private:
     int* rev;
     double *redirargdft;
     double *imdirargdft;
     double *reinvargdft;
     double *iminvargdft;
     double *redirargodft;
     double *imdirargodft;
     double *reinvargodft;
     double *iminvargodft;
     double *reargmdct;
     double *imargmdct;
     double *reargodft;
     double *imargodft;
     double *reargdft;
     double *imargdft;
     int BNBINS, NBINS, NBINS2, NBINS4;
     int nstg, nchg;

     void initransf();

public:
     TRANSFORM(int =1024); // means by default length is 1024
     ~TRANSFORM();

      void dirrealtransf(double*, double*, TRFTYPE =ODFT);
      void invrealtransf(double*, double*, TRFTYPE =ODFT);

      inline int size() const {return BNBINS;} // Bjarne, 148
};
#endif

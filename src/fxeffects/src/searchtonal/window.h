#ifndef _WINDOW_H
#define _WINDOW_H

// To add normalization, comment the line bellow (FA) 06Dez07
//#define DISABLE_WINDOW_NORMALIZED

/*
 * CLASS window
 * Creates window of chosen lenght and type 
 * window switching is admitted in ratios of 2, 4 and 8
 *
 */

#include <math.h>
#include "complex.h"
#include "common.h"

class WINDOW
{

protected:			// see pag. 564 C++
     int length;
     WINTYPE windowtype;
     double *regularwindow, *startswitch, *stopswitch;
	 double Gwindow;

public:
     WINDOW(int, WINTYPE =RECTANGULAR);
     ~WINDOW();
     inline int size() const {return length;}
     inline WINTYPE type() const {return windowtype;}
	 double getGwindow();
		
     void filterwin(double*, WSWITCH) const; // Bjarne, 149
     void filterwin(complex*, WSWITCH) const;
};

#endif

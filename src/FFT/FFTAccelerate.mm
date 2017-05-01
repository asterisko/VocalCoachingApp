/*
 *  FFTAccelerate.cpp

 
 Copyright (C) 2012 Tom Hoddes
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */
#include "FFTAccelerate.h"
#include <stdio.h>
#include <stdlib.h>
#include <Accelerate/Accelerate.h>
//#include <vector.h>
#include <vector> // ANDRE
#include <math.h>

#include "ofMain.h"

#define N                  10    /* This is a power of 2 defining  the length of the FFTs */

void FFTAccelerate::doFFTReal(float samples[], float amp[], int numSamples)
{
	int i;
	vDSP_Length log2n = log2f(numSamples);

    //Convert float array of reals samples to COMPLEX_SPLIT array A
	vDSP_ctoz((COMPLEX*)samples,2,&A,1,numSamples/2);

    //Perform FFT using fftSetup and A
    //Results are returned in A
	vDSP_fft_zrip(fftSetup, &A, 1, log2n, FFT_FORWARD);

    //Convert COMPLEX_SPLIT A result to float array to be returned
    amp[0] = A.realp[0]/(numSamples*2);
	for(i=1;i<numSamples;i++)
        amp[i]=sqrt(A.realp[i]*A.realp[i]+A.imagp[i]*A.imagp[i])/numSamples;
}

//Constructor
FFTAccelerate::FFTAccelerate (int numSamples)
{
	vDSP_Length log2n = log2f(numSamples);
	fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
	int nOver2 = numSamples/2;
	A.realp = (float *) malloc(nOver2*sizeof(float));
	A.imagp = (float *) malloc(nOver2*sizeof(float));
}


//Destructor
FFTAccelerate::~FFTAccelerate ()
{
	free(A.realp);
	free(A.imagp);
    vDSP_destroy_fftsetup(fftSetup);
}

void FFTAccelerate::testFFT()
{
//    COMPLEX_SPLIT   _A;
    FFTSetup        setupReal;
    uint32_t        log2n;
    uint32_t        n, nOver2;
    int32_t         stride;
    uint32_t        i;
    float          *originalReal, *obtainedReal;
    float           scale;
    
    // Set the size of FFT
    log2n = N;
    n = 1 << log2n;
    
    stride = 1;
    nOver2 = n / 2;
    
    printf("1D real FFT of length log2 ( %d ) = %d\n\n", n, log2n);
    
    // Allocate memory for the input operands and check its availability, use the vector version to get 16-byte alignment.
    A.realp = (float *) malloc(nOver2 * sizeof(float));
    A.imagp = (float *) malloc(nOver2 * sizeof(float));
    originalReal = (float *) malloc(n * sizeof(float));
    obtainedReal = (float *) malloc(n * sizeof(float));
    
    if (originalReal == NULL || A.realp == NULL || A.imagp == NULL) {
        printf("\nmalloc failed to allocate memory for  the real FFT section of the sample.\n");
        exit(0);
    }
    
    // Generate an input signal in the real domain.
    for (i = 0; i < n; i++)
        originalReal[i] = (float) (i + 1);
    
    // Look at the real signal as an interleaved complex vector  by casting it.
    // Then call the transformation function vDSP_ctoz to get a split complex vector,
    // which for a real signal, divides into an even-odd configuration.
    vDSP_ctoz((COMPLEX *) originalReal, 2, &A, 1, nOver2);
    
    // Set up the required memory for the FFT routines and check  it availability. */
    setupReal = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    if (setupReal == NULL) {
        printf("\nFFT_Setup failed to allocate enough memory  for the real FFT.\n");
        exit(0);
    }
    // Carry out a Forward and Inverse FFT transform.
    vDSP_fft_zrip(setupReal, &A, stride, log2n, FFT_FORWARD);
    vDSP_fft_zrip(setupReal, &A, stride, log2n, FFT_INVERSE);
    
    // Verify correctness of the results, but first scale it by  2n
    scale = (float) 1.0 / (2 * n);
    
    vDSP_vsmul(A.realp, 1, &scale, A.realp, 1, nOver2);
    vDSP_vsmul(A.imagp, 1, &scale, A.imagp, 1, nOver2);
    
    // The output signal is now in a split real form.  Use the  function vDSP_ztoc to get a split real vector.
    vDSP_ztoc(&A, 1, (COMPLEX *) obtainedReal, 2, nOver2);
    
    // Check for accuracy by looking at the inverse transform  results.
    compare(originalReal, obtainedReal, n);
    
    // Free the allocated memory.
    vDSP_destroy_fftsetup(setupReal);
    free(obtainedReal);
    free(originalReal);
    free(A.realp);
    free(A.imagp);
}


void FFTAccelerate::testConv()
{
    float       *signal, *filter, *result;
    int32_t     signalStride, filterStride, resultStride;
    uint32_t    lenSignal, filterLength, resultLength;
    uint32_t    i;
    
    filterLength = 256;
    resultLength = 2048;
    lenSignal = ((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    
    signalStride = filterStride = resultStride = 1;
    
    printf("\nConvolution ( resultLength = %d, filterLength = %d )\n\n", resultLength, filterLength);
    
    // Allocate memory for the input operands and check its availability.
    signal = (float *) malloc(lenSignal * sizeof(float));
    filter = (float *) malloc(filterLength * sizeof(float));
    result = (float *) malloc(resultLength * sizeof(float));
    
    if (signal == NULL || filter == NULL || result == NULL) {
        printf("\nmalloc failed to allocate memory for the convolution sample.\n");
        exit(0);
    }

    // Set the input signal of length "lenSignal" to  [1,...,1].
    for (i = 0; i < lenSignal; i++)
        signal[i] = 1.0;
    
    // Set the filter of length "filterLength" to [1,...,1].
    for (i = 0; i < filterLength; i++)
        filter[i] = 1.0;
    
    // Correlation.
    vDSP_conv(signal, signalStride, filter, filterStride, result, resultStride, resultLength, filterLength);
    
    // Carry out a convolution.
    filterStride = -1;
    vDSP_conv(signal, signalStride, filter + filterLength - 1, filterStride, result, resultStride, resultLength, filterLength);
    
    // Free allocated memory.
    free(signal);
    free(filter);
    free(result);
}

void FFTAccelerate::compare(float *original, float *computed, long length)
{
    int             i;
    float           error = original[0] - computed[0];
    float           max = error;
    float           min = error;
    float           mean = 0.0;
    float           sd_radicand = 0.0;
    
    for (i = 0; i < length; i++) {
        error = original[i] - computed[i];
        // printf("%f %f %f\n", original[i], computed[i], error);
        max = (max < error) ? error : max;
        min = (min > error) ? error : min;
        mean += (error / length);
        sd_radicand += ((error * error) / (float) length);
    }
    
    printf("Max error: %f  Min error: %f  Mean: %f  Std Dev: %f\n",
           max, min, mean, sqrt(sd_radicand));
}

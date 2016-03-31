/***********************************************************************
Mex gateway to the ANI code. Usually, IPEMProcessAuditoryModel.m is used
to auto-generate mex wrapper code to call this function. Due to difficulties
with auto-generating the code in Matlab 7, the wrapper script was implemented in 
IPEMProcessAuditoryModelSafe and IPEMProcessAuditoryModel.m (which primarily checks
the validity of the input parameters, was left as a .m file.

Implemented by Stefan Tomic with copied code from 
IPEMProcessModel_external.cpp by Koen Tanghe

*************************************************************************/
#include "mex.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  /* Declare C variables for the Matlab arguments and set to defaults */
  long theNumOfChannels = -1;
  double theFirstFreq = -1.0;
  double theFreqDist = -1.0;
  char* theInputFileName = NULL;
  char* theInputFilePath = NULL;
  char* theOutputFileName = NULL;
  char* theOutputFilePath = NULL;
  double theSampleFrequency = -1.0;
  long theSoundFileFormat = -1;

  double *output;

  theNumOfChannels =  mxGetScalar(prhs[0]);
  theFirstFreq = mxGetScalar(prhs[1]);
  theFreqDist = mxGetScalar(prhs[2]);
  theInputFileName = mxArrayToString(prhs[3]);
  theInputFilePath = mxArrayToString(prhs[4]);
  theOutputFileName = mxArrayToString(prhs[5]);
  theOutputFilePath = mxArrayToString(prhs[6]);
  theSampleFrequency = mxGetScalar(prhs[7]);
  theSoundFileFormat = (long)mxGetScalar(prhs[8]);


  IPEMAuditoryModel_Setup( theNumOfChannels,
			   theFirstFreq,
			   theFreqDist,
			   theInputFileName,
			   theInputFilePath,
			   theOutputFileName,
			   theOutputFilePath,
			   theSampleFrequency,
			   theSoundFileFormat);


  
  plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
  output = mxGetPr(plhs[0]);
  /* Start processing */
  *output = (double) IPEMAuditoryModel_Process();
  
  /* Free memory for strings */
  mxFree(theInputFileName);
  mxFree(theInputFilePath);
  mxFree(theOutputFileName);
  mxFree(theOutputFilePath);
  
  
}

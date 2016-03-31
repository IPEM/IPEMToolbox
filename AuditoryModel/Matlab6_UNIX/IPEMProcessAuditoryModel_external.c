// -----------------------------------------------------------------------------
//  IPEMProcessAuditoryModel_external.cpp				Koen Tanghe - 19991117
// -----------------------------------------------------------------------------
//  This is the implementation file for IPEMProcessAuditoryModel_external.h.
//  It implements the interface between the Matlab file IPEMProcessAuditoryModel.m
//  and the C++ Class IPEMAuditoryModel for calculating an auditory nerve image
//  from a soundfile.
// -----------------------------------------------------------------------------

/*------------------------------------------------------------------------------
    IPEM Toolbox - Toolbox for perception-based music analysis 
    Copyright (C) 2005 Ghent University 
    
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
------------------------------------------------------------------------------*/

/* Edited by Stefan Tomic (sttomic@ucdavis.edu) to compile as C code
   This was done to simplify compilation in Linux
   3/3/2005
 */


// Includes
// --------
#include "IPEMAuditoryModel.h"
#include <stdio.h>


// Includes
// --------
#include "IPEMProcessAuditoryModel_external.h"

// -----------------------------------------------------------------------------
//	MIPEMProcessAuditoryModel
// -----------------------------------------------------------------------------

mxArray * MIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe(int nargout_,
									mxArray * inNumOfChannels,
									mxArray * inFirstFreq,
									mxArray * inFreqDist,
									mxArray * inInputFileName,
									mxArray * inInputFilePath,
									mxArray * inOutputFileName,
									mxArray * inOutputFilePath,
									mxArray * inSampleFrequency,
									mxArray * inSoundFileFormat)
{
	// Declare C variables for the Matlab arguments and set to defaults
	long theNumOfChannels = -1;
	double theFirstFreq = -1.0;
	double theFreqDist = -1.0;
	char* theInputFileName = NULL;
	char* theInputFilePath = NULL;
	char* theOutputFileName = NULL;
	char* theOutputFilePath = NULL;
	double theSampleFrequency = -1.0;
	long theSoundFileFormat = -1;

	// Convert Matlab arguments to C arguments
	// Dimension/type checking should already be done !!!
	theNumOfChannels = (long)mxGetScalar(inNumOfChannels);
	theFirstFreq = mxGetScalar(inFirstFreq);
	theFreqDist = mxGetScalar(inFreqDist);
	theInputFileName = mxArrayToString(inInputFileName);
	theInputFilePath = mxArrayToString(inInputFilePath);
	theOutputFileName = mxArrayToString(inOutputFileName);
	theOutputFilePath = mxArrayToString(inOutputFilePath);
	theSampleFrequency = mxGetScalar(inSampleFrequency);
	theSoundFileFormat = (long)mxGetScalar(inSoundFileFormat);

#ifdef _DEBUG

	// Show the arguments
	printf("theNumOfChannels = %li\n",theNumOfChannels);
	printf("theFirstFreq = %lf\n",theFirstFreq);
	printf("theFreqDist = %lf\n",theFreqDist);
	printf("theInputFileName = %s\n",theInputFileName);
	printf("theInputFilePath = %s\n",theInputFilePath);
	printf("theOutputFileName = %s\n",theOutputFileName);
	printf("theOutputFilePath = %s\n",theOutputFilePath);
	printf("theSampleFrequency = %lf\n",theSampleFrequency);
	printf("theSoundFileFormat = %li\n",theSoundFileFormat);

#endif

	// Setup the model
	IPEMAuditoryModel_Setup( theNumOfChannels,
				 theFirstFreq,
				 theFreqDist,
				 theInputFileName,
				 theInputFilePath,
				 theOutputFileName,
				 theOutputFilePath,
				 theSampleFrequency,
				 theSoundFileFormat);
       





	// Start processing
	long theResult = IPEMAuditoryModel_Process();

	// Free memory for strings
	mxFree(theInputFileName);
	mxFree(theInputFilePath);
	mxFree(theOutputFileName);
	mxFree(theOutputFilePath);
	
	// Return the result to Matlab
	return mlfScalar(theResult);
}




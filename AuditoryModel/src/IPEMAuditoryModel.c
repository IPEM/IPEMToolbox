// -----------------------------------------------------------------------------
//  IPEMAuditoryModel.cpp								Koen Tanghe - 19990528
// -----------------------------------------------------------------------------
//  Implementation file for IPEMAuditoryModel.hpp
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
#include <string.h>


// Externals
// ---------
// The ONE and ONLY interface point towards the "audiprog" algorithm.
// We are NOT using an inclusion of the audiprog.h header file here, because
// this would introduce all the global variables of the C-modules in this module
// (which is something we don't want to do)
long AudiProg (long inNumOfChannels, double inFirstFreq, double inFreqDist,
			const char* inInputFileName, const char* inInputFilePath,
			const char* inOutputFileName, const char* inOutputFilePath,
			double inSampleFrequency, long inSoundFileFormat);



void IPEMAuditoryModel_SetDefaults();


// Constants
// ---------
const long	cDefNumOfChannels = 40;
const double	cDefFirstFreq = 2.0;
const double	cDefFreqDist = 0.5;
const char*	cDefInputFileName = "input.wav";
const char*	cDefOutputFileName = "e8n00bin";
const double	cDefSampleFrequency = 20050;
const long	cDefSoundFileFormat = sffWav;

// -----------------------------------------------------------------------------
//	IPEMAuditoryModel
// -----------------------------------------------------------------------------
// A default value for any of the arguments can be requested:
//  - if -1 is specified (for a numeric value)
//  - if NULL is specified (for a string)
// Was the constructor of the original cpp file (S.T.)
IPEMAuditoryModel_Setup(long inNumOfChannels,
									double inFirstFreq,
									double inFreqDist,
									const char* inInputFileName,
									const char* inInputFilePath,
									const char* inOutputFileName,
									const char* inOutputFilePath,
									double inSampleFrequency,
									long inSoundFileFormat)
{
	// Start with default values
	IPEMAuditoryModel_SetDefaults();

	// Now set what was specified (could also be a request for the default value)
	if (inNumOfChannels != -1)	mNumOfChannels = inNumOfChannels;
	if (inFirstFreq != -1.0)	mFirstFreq = inFirstFreq;
  	if (inFreqDist != -1.0)		mFreqDist = inFreqDist;
	if ((inInputFileName != NULL) && (strlen(inInputFileName) != 0))	strcpy(mInputFileName,inInputFileName);
	if ((inInputFilePath != NULL)	&& (strlen(inInputFilePath) != 0))	strcpy(mInputFilePath,inInputFilePath);
	if ((inOutputFileName != NULL) && (strlen(inOutputFileName) != 0))	strcpy(mOutputFileName,inOutputFileName);
	if ((inOutputFilePath != NULL) && (strlen(inOutputFilePath) != 0))	strcpy(mOutputFilePath,inOutputFilePath);
	if (inSampleFrequency != -1.0)	mSampleFrequency = inSampleFrequency;
	if (inSoundFileFormat != -1) mSoundFileFormat = inSoundFileFormat;
}


// -----------------------------------------------------------------------------
//	Process
// -----------------------------------------------------------------------------

long IPEMAuditoryModel_Process()
{
  // Call the original AudiProg-module
  // (this starts the computation, if everyting is allright)*/
  	return AudiProg(mNumOfChannels, mFirstFreq, mFreqDist,
			mInputFileName, mInputFilePath,
			mOutputFileName, mOutputFilePath,
			mSampleFrequency, (mSoundFileFormat == sffWav) ? 2 : 3 /* ? */);


 
}

// -----------------------------------------------------------------------------
//	SetDefaults
// -----------------------------------------------------------------------------

void IPEMAuditoryModel_SetDefaults()
{
	mNumOfChannels = cDefNumOfChannels;
	mFirstFreq = cDefFirstFreq;
  	mFreqDist = cDefFreqDist;
	strcpy(mInputFileName,cDefInputFileName);
	mInputFilePath[0] = '\0';
	strcpy(mOutputFileName,cDefOutputFileName);
	mOutputFilePath[0] = '\0';
	mSampleFrequency = cDefSampleFrequency;
	mSoundFileFormat = cDefSoundFileFormat;
}

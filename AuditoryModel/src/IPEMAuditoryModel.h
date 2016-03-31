// --------------------------------------------------------------------------------
//  IPEMAuditoryModel.h									Koen Tanghe - 19990526
// --------------------------------------------------------------------------------
//  This class implements a simulation of the human ear and is just a wrapper for 
//  the (partly adapted) C-files coded by the Speech Processing Department of the 
//  University of Ghent (Prof. J-P Martens).
//
//  How it works:
//
//  sound file ---> Auditory Model ---> envelope file
//
//  The sound file is processed into a file representing the envelopes of the
//  neural firing probabilities for different frequency bands (channels).
//  The number of columns in the output file equals the number of channels.
// --------------------------------------------------------------------------------

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




#pragma once

#include <stdlib.h>


/*these variables become globals now, since we are using C instead of C++
  and we want to use them across more than one function */	
enum {sffWav = 0, SffSnd };

long	mNumOfChannels;
double	mFirstFreq;
double	mFreqDist;
char	mInputFileName[256];
char	mInputFilePath[256];
char	mOutputFileName[256];
char	mOutputFilePath[256];
double	mSampleFrequency;
long	mSoundFileFormat;




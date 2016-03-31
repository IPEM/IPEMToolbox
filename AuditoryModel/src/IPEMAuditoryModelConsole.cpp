// -----------------------------------------------------------------------------
//  IPEMAuditoryModelConsole.cpp						Koen Tanghe - 19991108
// -----------------------------------------------------------------------------
// This file implements a console application around the IPEMAuditoryModel class.
//
// The program can be used in two ways:
//	- interactive mode: 
//		The program aks the user for the needed parameters in an interactive
//		DOS-like session (standard input/output).
//		Use "IPEMAuditoryModelConsole -i" to start an interactive session.
//	- command line:
//		The parameters are specified using command line arguments.
//		The following switches are supported:
//			-nc		number of channels
//			-f1		frequency of first channel
//			-fd		frequency distance between adjecent channels
//			-if		input file name
//			-id		input file path
//			-of		output file name
//			-od		output file path
//			-ss		signal's sampling frequency
//			-ff		sound file format (either 0 for wav, or 1 for snd)
//			-i		start interactive session (see above)
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

// Includes
#include "IPEMAuditoryModel.h" //name extension changed from .hpp to .h by S.T. for compatibility with the C version for linux
#include <stdio.h>
#include <string.h>

// -----------------------------------------------------------------------------
//	DoInteractiveSession
// -----------------------------------------------------------------------------
// Allows the user to enter the parameters for the model through an interactive
// session
bool DoInteractiveSession (long& outNumOfChannels,
							double& outFirstFreq, double& outFreqDist,
							char* outInputFileName, char* outInputFilePath,
							char* outOutputFileName, char* outOutputFilePath,
							double& outSampleFrequency, long& outSoundFileFormat)
{
	// Note: this is a working 'quick-and-dirty' version.
	// When the time is right or the needs are high, this could be improved...
	char theBuffer[256];
	printf("\n");
	printf("Number of channels: ");
	gets(theBuffer);
	if (strlen(theBuffer) != 0) outNumOfChannels = atol(theBuffer);
	printf("Frequency of first channel (cbu): ");
	gets(theBuffer);
	if (strlen(theBuffer) != 0) outFirstFreq = atof(theBuffer);
	printf("Frequency distance between adjecent channels (cbu): ");
	gets(theBuffer);
	if (strlen(theBuffer) != 0) outFreqDist = atof(theBuffer);
	printf("Name of input file: ");
	gets(theBuffer);
	if (strlen(theBuffer) != 0) strcpy(outInputFileName,theBuffer);
	printf("Path to input file: ");
	gets(theBuffer);
	if (strlen(theBuffer) != 0) strcpy(outInputFilePath,theBuffer);
	printf("Name of output file: ");
	gets(theBuffer);
	if (strlen(theBuffer) != 0) strcpy(outOutputFileName,theBuffer);
	printf("Path to output file: ");
	gets(theBuffer);
	if (strlen(theBuffer) != 0) strcpy(outOutputFileName,theBuffer);
	printf("Signal's sample frequency (Hz): ");
	gets(theBuffer);
	if (strlen(theBuffer) != 0) outSampleFrequency = atof(theBuffer);
	printf("Signal's file format (0 = wav, 1 = snd): ");
	gets(theBuffer);
	if (strlen(theBuffer) != 0)
	{
		long theValue = atol(theBuffer);
		if (theValue == 1)	outSoundFileFormat = IPEMAuditoryModel::sffSnd;
		else				outSoundFileFormat = IPEMAuditoryModel::sffWav;
	}

	return true;
}

// -----------------------------------------------------------------------------
//	ShowCorrectUsage
// -----------------------------------------------------------------------------
// Extracts the parameters for the model from the command line
void ShowCorrectUsage (const char* inApplicationName)
{
	// TO DO: mention default values! (ask from AuditoryModel ?)
	printf("\n");
	printf("ERORR: incorrect usage !\n");
	printf("Correct usage is like this:\n");
	printf("%s [options]\n",inApplicationName);
	printf("where options can be any combination of the following:\n");
	printf(" -nc integer    number of channels (max. 40)\n");
	printf(" -f1 double     first channel frequency (cbu)\n");
	printf(" -fd double     distance between channel frequencies (cbu)\n");
	printf(" -if string     name of the input file\n");
	printf(" -id string     path to the input file\n");
	printf(" -of string     name of the output file\n");
	printf(" -od string     path to the output file\n");
	printf(" -fs double     signal's sample frequency (Hz)\n");
	printf(" -ff string     signal's file format (either wav or snd)\n");
	printf("If you do not specify a certain option, the default is used.\n");
	printf("Use '%s -i' to start an interactive session.\n",inApplicationName);
	printf("(Version of 19991108)");
}

// -----------------------------------------------------------------------------
//	DoCommandLineParsing
// -----------------------------------------------------------------------------
// Extracts the parameters for the model from the command line
bool DoCommandLineParsing (int inNumOfArguments, char* inArguments[],
							long& outNumOfChannels,
							double& outFirstFreq, double& outFreqDist,
							char* outInputFileName, char* outInputFilePath,
							char* outOutputFileName, char* outOutputFilePath,
							double& outSampleFrequency, long& outSoundFileFormat)
{
	bool theResult = true;

	// Should have even number of arguments (not counting the program's name)
	if (((inNumOfArguments - 1)%2) != 0) theResult = false;
	else
	{
		// Loop through all the arguments
		int theIndex = 1;
		while ((theIndex < inNumOfArguments) && theResult)
		{
			// Get the next argument and analyze it
			char* theArgument = inArguments[theIndex++];
			if (strcmp(theArgument,"-nc") == 0)
			{
				outNumOfChannels = atol(inArguments[theIndex++]);
			}
			else if (strcmp(theArgument,"-f1") == 0)
			{
				outFirstFreq = atof(inArguments[theIndex++]);
			}
			else if (strcmp(theArgument,"-fd") == 0)
			{
				outFreqDist = atof(inArguments[theIndex++]);
			}
			else if (strcmp(theArgument,"-if") == 0)
			{
				strcpy(outInputFileName,inArguments[theIndex++]);
			}
			else if (strcmp(theArgument,"-id") == 0)
			{
				strcpy(outInputFilePath,inArguments[theIndex++]);
			}
			else if (strcmp(theArgument,"-of") == 0)
			{
				strcpy(outOutputFileName,inArguments[theIndex++]);
			}
			else if (strcmp(theArgument,"-od") == 0)
			{
				strcpy(outOutputFilePath,inArguments[theIndex++]);
			}
			else if (strcmp(theArgument,"-fs") == 0)
			{	
				outSampleFrequency = atof(inArguments[theIndex++]);
			}
			else if (strcmp(theArgument,"-ff") == 0)
			{
				if (strcmp(inArguments[theIndex],"wav") == 0) outSoundFileFormat = IPEMAuditoryModel::sffWav;
				else if (strcmp(inArguments[theIndex],"snd") == 0) outSoundFileFormat = IPEMAuditoryModel::sffSnd;
				else
					theResult = false;
				theIndex++;
			}
			else
				theResult = false;	// error !
		}
	}
	if (theResult == false) ShowCorrectUsage((const char*)(inArguments[0]));
	return theResult;
}

// -----------------------------------------------------------------------------
//	main
// -----------------------------------------------------------------------------
int main (int inNumOfArguments, char* inArguments[])
{
	// Setup the parameters to use their default values
	long theNumOfChannels = -1;
	double theFirstFrequency = -1.0;
	double theFrequencyDistance = -1.0;
	char theInputFileName[256]; theInputFileName[0] = '\0';
	char theInputFilePath[256]; theInputFilePath[0] = '\0';
	char theOutputFileName[256]; theOutputFileName[0] = '\0';
	char theOutputFilePath[256]; theOutputFilePath[0] = '\0';
	double theSampleFrequency = -1.0;
	long theSoundFileFormat = -1;

	// Capture arguments (either interactive or from command line)
	bool theParametersAreOK = false;
	if ((inNumOfArguments == 2) && (strcmp(inArguments[1],"-i") == 0))
		theParametersAreOK = DoInteractiveSession(theNumOfChannels,
						theFirstFrequency, theFrequencyDistance,
						theInputFileName, theInputFilePath,
						theOutputFileName, theOutputFilePath,
						theSampleFrequency, theSoundFileFormat);
	else
		theParametersAreOK = DoCommandLineParsing(inNumOfArguments,inArguments,
						theNumOfChannels,
						theFirstFrequency, theFrequencyDistance,
						theInputFileName, theInputFilePath,
						theOutputFileName, theOutputFilePath,
						theSampleFrequency, theSoundFileFormat);

	// If something went wrong, quit now
	if (!theParametersAreOK) return -1;




	// Create a model from our data
	IPEMAuditoryModel theModel(theNumOfChannels,
						theFirstFrequency, theFrequencyDistance,
						theInputFileName, theInputFilePath,
						theOutputFileName, theOutputFilePath,
						theSampleFrequency, theSoundFileFormat);

	// Start the computations and return the result
	// (model object is automatically destroyed upon leaving this function)
	return theModel.Process();
}



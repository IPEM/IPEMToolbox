function [outANI,outANIFreq,outANIFilterFreqs] = IPEMCalcANI (varargin)
% Usage:
%   [outANI,outANIFreq,outANIFilterFreqs] = ...
%     IPEMCalcANI (inSignal,inSampleFreq,inAuditoryModelPath,...
%                  inPlotFlag,inDownsamplingFactor,...
%                  inNumOfChannels,inFirstCBU,inCBUStep)
%
% Description:
%   This function calculates the auditory nerve image for the given signal.
%
% Input arguments:
%   inSignal = the sound signal to be processed
%   inSampleFreq = the sample frequency of the input signal (in Hz)
%   inAuditoryModelPath = path to the working directory for the auditory model
%                         if empty or not specified, IPEMRootDir('code')\Temp
%                         is used by default
%   inPlotFlag = if non-zero, plots the ANI
%                if empty or not specified, 0 is used by default
%   inDownsamplingFactor = the integer factor by which the outcome of the
%                          auditory model is downsampled
%                          (use 1 for no downsampling)
%                          if empty or not specified, 4 is used by default
%   inNumOfChannels = number of channels to use
%                     if empty or not specified, 40 is used by default
%   inFirstCBU = frequency of first channel (in critical band units)
%                if empty or not specified, 2.0 is used by default
%   inCBUStep = frequency difference between channels (in cbu)
%               if empty or not specified, 0.5 is used by default
%
% Output:
%   outANI = a matrix of size [N M] representing the auditory nerve image,
%            where N is the number of channels (currently 40) and
%                  M is the number of samples
%   outANIFreq = sample freq of ANI (in Hz)
%   outANIFilterFreqs = center frequencies used by the auditory model (in Hz)
%
% Remarks:
%   The outcome of the auditory model normally has a sample frequency of
%   11025 Hz, but for most calculations this can be downsampled to a lower
%   value (11025/4 is the default).
%
% Example:
%   [ANI,ANIFreq,ANIFilterFreqs] = IPEMCalcANI(Signal,SampleFreq,[],1);
%
% Authors:
%   Koen Tanghe - 20010129
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% IPEM Toolbox - Toolbox for perception-based music analysis 
% Copyright (C) 2005 Ghent University
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
% ------------------------------------------------------------------------------

% Elementary feedback
fprintf(1,'Start of IPEMCalcANI...\n');

% Handle input arguments
[inSignal,inSampleFreq,inAuditoryModelPath,inPlotFlag,inDownsamplingFactor,...
    inNumOfChannels,inFirstCBU,inCBUStep] = ...
    IPEMHandleInputArguments(varargin,3,{[],[],fullfile(IPEMRootDir('code'),'Temp'),0,4,40,2.0,0.5});

% Additional checking
if or(isempty(inSignal),isempty(inSampleFreq))
   fprintf(2,['ERROR: You must specify an input signal with its sample frequency\n' ...
              '       as the first 2 arguments.\n']);
   return;
end;

% Check for mono signal and transpose if needed
if (size(inSignal,1) ~= 1)
   if (size(inSignal,2) ~= 1)
      fprintf(2,'ERROR: Can only process single channel (mono) signals.');
      return;
   else
       inSignal = inSignal';
   end;
end;

% Store the current directory and change it to the path of the auditory model
OldPath = cd;
cd(inAuditoryModelPath);

% Resample the sound if needed, and add silence before and after of 20 ms (for auditory model)
NewSampleFreq = 22050;
NZeros = round(0.020/(1/NewSampleFreq));
theZeros = zeros(1,NZeros);
if (inSampleFreq ~= NewSampleFreq)
   NewSound = [theZeros resample(inSignal,NewSampleFreq,inSampleFreq) theZeros];
else
   NewSound = [theZeros inSignal theZeros];
end

% Write sound to a temp file
wavwrite(NewSound,NewSampleFreq,16,'input.wav');

% Let the auditory model process the sound
% (samplefreq. 22050 Hz, input.wav as input file, nerve_image.ani as output file)
Result = IPEMProcessAuditoryModel('input.wav','','nerve_image.ani','',NewSampleFreq,inNumOfChannels,inFirstCBU,inCBUStep);
if (Result ~= 0)
    cd(OldPath);
    error('Error while processing file with IPEMProcessAuditoryModel...');
end;

% Load the result of the auditory model and reset the current directory
outANI = textread('nerve_image.ani','%f');
outANI = reshape(outANI,inNumOfChannels,length(outANI)/inNumOfChannels);
outANIFilterFreqs = dlmread('FilterFrequencies.txt',' ');
outANIFilterFreqs = 1000*outANIFilterFreqs;
outANIFreq = NewSampleFreq/2;

% Remove first and last samples added because of auditory model
outANI = outANI(:,1+round(NZeros/2):end-round(NZeros/2));

% Delete temporary files
delete('decim.dat');
delete('eef.dat');
delete('FilterFrequencies.txt');
delete('filters.dat');
delete('input.wav');
delete('lpf.dat');
delete('nerve_image.ani');
delete('omef.dat');
delete('outfile.dat');

% Reset original path
cd(OldPath);

fprintf(1,'Ended dll, ready for downsampling if needed...\n');

% Use downsampling if needed
if (inDownsamplingFactor ~= 1)
   outANI = resample(outANI',1,inDownsamplingFactor)';
   outANIFreq = outANIFreq/inDownsamplingFactor;
end;

% Plot if needed
if (inPlotFlag)
    HFig = figure;
    IPEMPlotMultiChannel(outANI,outANIFreq,'Auditory Nerve Image (ANI)','Time (in s)',...
        'Auditory channels (center freqs. in Hz)',14,outANIFilterFreqs,3);
    IPEMSetFigureLayout(HFig);
end;

% Elementary feedback
fprintf(1,'...end of IPEMCalcANI.\n');

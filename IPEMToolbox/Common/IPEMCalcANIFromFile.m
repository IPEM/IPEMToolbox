function [outANI,outANIFreq,outANIFilterFreqs] = IPEMCalcANIFromFile (varargin)
% Usage:
%   [outANI,outANIFreq,outANIFilterFreqs] = ...
%     IPEMCalcANIFromFile (inFileName,inFilePath,inAuditoryModelPath,...
%                          inPlotFlag,inDownsamplingFactor,...
%                          inNumOfChannels,inFirstCBU,inCBUStep)
%
% Description:
%   This function calculates the auditory nerve image for the given sound file.
%
% Input arguments:
%   inFileName = the sound file to be processed
%   inFilePath = the path to the sound file
%                if empty or not specified, IPEMRootDir('input')\Sounds
%                is used by default
%   inAuditoryModelPath = path to the working directory for the auditory model
%                         if empty or not specified, IPEMRootDir('code')\Temp
%                         is used by default)
%   inPlotFlag = if non-zero or empty, plots the ANI
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
%   outANI = a matrix of size [N M] representing the auditory nerve images,
%            where N is the number of channels (currently 40) and
%                  M is the number of samples
%   outANIFreq = sample freq of ANI
%   outANIFilterFreqs = center frequencies used by the auditory model
%
% Remarks:
%   The outcome of the auditory model normally has a sample frequency of
%   11025 Hz, but for most calculations this can be downsampled to a lower
%   value (11025/4 is the default).
%
% Example:
%   [ANI,ANIFreq,ANIFilterFreqs] = IPEMCalcANIFromFile ('music.wav',[],[],1);
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
fprintf(1,'Start of IPEMCalcANIFromFile...\n');

% Handle input arguments
[inFileName,inFilePath,inAuditoryModelPath,inPlotFlag,inDownsamplingFactor,inNumOfChannels,inFirstCBU,inCBUStep] = ...
    IPEMHandleInputArguments(varargin,2,{[],fullfile(IPEMRootDir('input'),'Sounds'),[],0,4,40,2.0,0.5});

% Additional checking
if (isempty(inFileName))
   fprintf(2,'ERROR: You must specify a the name of a sound file as the first argument.\n');
   return;
end;

% Setup file with path
theFile = fullfile(inFilePath,inFileName);

% Determine type of sound file and read according to that type
theSpec = IPEMStripFileSpecification(theFile);
if strcmpi(theSpec.Extension,'wav')
    [theSound,theFreq,theBits] = wavread(theFile);
elseif strcmpi(theSpec.Extension,'snd')
    [theSound,theFreq,theBits] = auread(theFile);
else
   fprintf(2,'ERROR: Sound file must be a .wav or .snd file!\n');
   return;
end;

% Now calculate the ANI from this signal
[outANI,outANIFreq,outANIFilterFreqs] = IPEMCalcANI(theSound,theFreq,inAuditoryModelPath,...
    inPlotFlag,inDownsamplingFactor,inNumOfChannels,inFirstCBU,inCBUStep);

% Elementary feedback
fprintf(1,'...end of IPEMCalcANIFromFile.\n');

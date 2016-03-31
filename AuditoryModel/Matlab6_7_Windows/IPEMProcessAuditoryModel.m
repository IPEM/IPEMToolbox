function outResult = IPEMProcessAuditoryModel (varargin)
% Usage:
%   IPEMProcessAuditoryModel(inInputFileName,inInputFilePath,...
%                            inOutputFileName,inOutputFilePath,...
%                            inSampleFrequency,inNumOfChannels,...
%                            inFirstFreq,inFreqDist)
%
% Description:
%   Matlab interface function towards the auditory model developed by the
%   Department of Speech Processing of the Ghent University, partly adapted
%   by the IPEM.
%   This function takes a sound file and generates a file containing the auditory
%   nerve image corresponding to this sound file.
%
% Input arguments:
%   inInputFileName = name of the file to process (only .wav files)
%   inInputFilePath = directory path to the input file
%                     if empty or not specified, '' is used by default
%   inOutputFileName = name for the output file
%                      if empty or not specified, 'nerve_image.ani' is used by default
%   inOutputFilePath = directory path to the output file
%                      if empty or not specified, '' is used by default
%   inSampleFrequency = sample frequency of the wave file (in Hz)
%                       if empty or not specified, 22050 is used by default
%   inNumOfChannels = number of auditory channels
%                     if empty or not specified, 40 is used by default
%   inFirstFreq = center frequency for the first auditory channel (in cbu)
%                 if empty or not specified, 2.0 is used by default
%   inFreqDist = distance between center frequencies of two adjecent auditory channels (in cbu)
%                if empty or not specified, 0.5 is used by default
%
% Output:
%   outResult = if zero, processing was ok
%               otherwise, something went wrong...
%
% Authors:
%   Koen Tanghe - 19991118
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

% Handle input arguments
[inInputFileName, inInputFilePath, inOutputFileName,inOutputFilePath,...
        inSampleFrequency,inNumOfChannels, inFirstFreq, inFreqDist] = ...
    IPEMHandleInputArguments(varargin,2,{'input.wav','','nerve_image.ani','',22050,40,2.0,0.5});

% Check types
if (~ischar(inInputFileName) | ~ischar(inInputFilePath) | ~ischar(inOutputFileName) ...
    | ~ischar(inOutputFilePath) | ~isnumeric(inSampleFrequency) | ~isnumeric(inNumOfChannels) ...
    | ~isnumeric(inFirstFreq) | ~isnumeric(inFreqDist))
    disp('Some arguments are not of the correct type...');
    outResult = -1;
    return;
end

% Check dimensions
if ((size(inInputFileName,1) ~= 1) | ((size(inInputFilePath,1) ~= 1) & ~isempty(inInputFilePath)) ...
        | (size(inOutputFileName) ~= 1) | ((size(inOutputFilePath) ~= 1) & ~isempty(inOutputFilePath)) ...
        | ~isequal(size(inSampleFrequency),[1,1]) | ~isequal(size(inNumOfChannels),[1,1]) ...
        | ~isequal(size(inFirstFreq),[1,1]) | ~isequal(size(inFreqDist),[1,1]))
    disp('Some arguments do not have the correct dimensions...');
    outResult = -1; 
    return;
end

% Process "safely" with the auditory model
outResult = IPEMProcessAuditoryModelSafe (...
    inNumOfChannels,inFirstFreq,inFreqDist,...
    inInputFileName,inInputFilePath,inOutputFileName,inOutputFilePath,...
    inSampleFrequency,-1);


% ------------------------------------------------------------------------------
%  "Safe" subfunction towards the actual C++/C/mex interface code.
%  Implemented externally.
%  See source code or documentation in IPEMAuditoryModel.hpp/cpp for detailed
%  explanation of the input arguments.
% ------------------------------------------------------------------------------
function outResult = IPEMProcessAuditoryModelSafe (...
    inNumOfChannels,inFirstFreq,inFreqDist,...
    inInputFileName,inInputFilePath,inOutputFileName,inOutputFilePath,...
    inSampleFrequency,inSoundFileFormat)
%#external

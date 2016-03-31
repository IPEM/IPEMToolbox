function [outSignalSegments,outSampleFreq] = IPEMSnipSoundFile (varargin)
% Usage:
%   [outSignalSegments,outSampleFreq] = ...
%     IPEMSnipSoundFile(inFileName,inFilePath,inTimeSegments,...
%                       inWriteSegments,inOutputPath)
%
% Description:
%   Snips the sound file into segments.
%
% Input arguments:
%   inFileName = name of the sound file
%   inFilePath = location of the sound file
%                if empty or not specified, IPEMRootDir('input')\Sounds is
%                used by default
%   inTimeSegments = time segments for cutting up the input signal (in s)
%                    (each row contains the start and end of a time segment)
%                    if this is a positive scalar, the signal is divided into
%                    inTimeSegments parts of equal size + an additional segment
%                    containing the remaining part of the signal (which will
%                    contain less than inTimeSegments samples)
%                    if this is a negative scalar, the signal is divided into
%                    -inTimeSegments parts where some segments will contain
%                    1 sample more than other segments
%   inWriteSegments = if non-zero, the segments are written to separate sound
%                     files in inOutputPath (the name of the files is the
%                     original name appended with the number of the segment)
%                     if empty or not specified, 0 is used by default
%   inOutputPath = ouput path used when sound files are written
%                  if empty or not specified, the same directory as the sound
%                  file is used by default
%
% Output:
%   outSignalSegments = the wanted signal segments
%   outSampleFreq = sample frequency of the original sound file (and segments)
%                   (in Hz)
%
% Example:
%   IPEMSnipSoundFile('dnb_drumloop_1patt.wav',[],-16,'E:\Koen\Data\Temp');
%
% Authors:
%   Koen Tanghe - 20000419
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
[inFileName,inFilePath,inTimeSegments,inWriteSegments,inOutputPath] = ...
    IPEMHandleInputArguments(varargin,4,{[],fullfile(IPEMRootDir('input'),'Sounds'),[],0,[]});

% Read the sound file
[s,fs] = IPEMReadSoundFile(inFileName,inFilePath);
outSampleFreq = fs;

% Extract segments
outSignalSegments = IPEMExtractSegments(s,fs,inTimeSegments);
NumOfSegments = size(outSignalSegments,1);

% Write segments to separate sound files if needed
if (inWriteSegments ~= 0)
    
    % Get original file specification
    File = fullfile(inFilePath,inFileName);
    Parts = IPEMStripFileSpecification(File);
    
    % Setup base file
    if isempty(inOutputPath)
        BaseFile = fullfile(Parts.Path,Parts.Name);
    else
        BaseFile = fullfile(inOutputPath,Parts.Name);
    end
    
    % Write segments
    for i = 1:NumOfSegments
        wavwrite(outSignalSegments{i},fs,sprintf('%s%d',BaseFile,i));
    end
end

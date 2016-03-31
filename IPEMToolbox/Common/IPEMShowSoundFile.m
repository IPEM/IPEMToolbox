function IPEMShowSoundFile(varargin)
% Usage:
%   IPEMShowSoundFile(inFileName,inFilePath,inNewFigureFlag)
%
% Description:
%   This function shows the waveform of the specified sound file.
%   Only .wav and .snd sound files are supported.
%
% Input arguments:
%   inFileName = the name of the sound file
%   inFilePath = the path to the sound file
%                if empty or not specified, IPEMRootDir('input')\Sounds is used
%                by default
%   inFigureFlag = if non-zero or not specified, a new figure is created
%                  if 0, the graph will be shown in the current (sub)plot
%
% Example:
%   IPEMShowSoundFile('music.wav',[],0);
%
% Authors:
%   Koen Tanghe - 20000209
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
[inFileName,inFilePath,inNewFigureFlag] = ...
    IPEMHandleInputArguments(varargin,2,{[],fullfile(IPEMRootDir('input'),'Sounds'),1});

% Check for file name
if isempty(inFileName)
   fprintf(2,'ERROR: Specify a file name as first argument!');
   return;
end;

% Setup file with path
theFile = fullfile(inFilePath,inFileName);

% Determine type of sound file and read according to that type
theFileNameLength = length(inFileName);
theExtension = inFileName(max(1,theFileNameLength-3):theFileNameLength);
if or(strcmp(theExtension,'.wav'), strcmp(theExtension,'.WAV'))
   [theSound,theFreq,theBits] = wavread(theFile);
elseif or(strcmp(theExtension,'.snd'), strcmp(theExtension,'.SND'))
   [theSound,theFreq,theBits] = auread(theFile);
else
   fprintf(2,'ERROR: Sound file must be a .wav or .snd file!\n');
   return;
end;

% Show the sound
if (inNewFigureFlag ~= 0) figure; end;
theTime = ((1:length(theSound))-1)/theFreq;
plot(theTime,theSound);
axis([0 (length(theSound)-1)/theFreq -1 1]);
xlabel('Time (in s)');
ylabel('Amplitude');
title(inFileName);

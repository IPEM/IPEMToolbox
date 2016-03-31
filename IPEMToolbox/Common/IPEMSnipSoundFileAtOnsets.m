function IPEMSnipSoundFileAtOnsets (varargin)
% Usage:
%   IPEMSnipSoundFileAtOnsets (inFileName,inFilePath,inOutputPath)
%
% Description:
%   Calculates the onsets for the specified sound file and cuts the sound file
%   into new sound segments at these onset times.
%
% Input arguments:
%   inFileName = name of the sound file
%   inFilePath = location of the sound file
%                if empty or not specified, IPEMRootDir('input')\Sounds is
%                used by default
%   inOutputPath = path where the sound segments should be stored
%                  if empty or not specified, the same directory as the sound
%                  file is used by default
%
% Example:
%   IPEMSnipSoundFileAtOnsets('dnb_drumloop_1patt.wav',[],...
%                             'E:\Koen\SnippedSamples');
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
[inFileName,inFilePath,inOutputPath] = ...
    IPEMHandleInputArguments(varargin,2,{[],fullfile(IPEMRootDir('input'),'Sounds'),[]});

% Setup the complete file specification
SoundFile = fullfile(inFilePath,inFileName);

% If inOutputPath is empty, use same location as sound file
theSpec = IPEMStripFileSpecification(SoundFile);
if isempty(inOutputPath)
   inOutputPath = theSpec.Path;
end;

% Feedback of file that is being processed
fprintf(1,'Cutting sound file [%s] into pieces, and storing\n the resulting segments in directory [%s]\n',...
          SoundFile,inOutputPath);
      
% Read the sound
[SoundSignal,SampleFreq,Bits] = wavread(SoundFile);

% Calculate onsets
[OnsetSignal,OnsetFreq] = IPEMCalcOnsets (SoundSignal, SampleFreq);
Ts = (find(OnsetSignal > 0)-1)/OnsetFreq;
Tsmp = round(Ts*SampleFreq+1);

% Cut up the sound file
theOutFile = fullfile(inOutputPath,sprintf('%s_%05d.wav',theSpec.Name,0));
wavwrite(SoundSignal(1:Tsmp(1)-1),SampleFreq,Bits,theOutFile);
for i = 1:(length(Tsmp)-1)
   theOutFile = fullfile(inOutputPath,sprintf('%s_%05d.wav',theSpec.Name,i));
   wavwrite(SoundSignal(Tsmp(i):Tsmp(i+1)-1),SampleFreq,Bits,theOutFile);
end;
theOutFile = fullfile(inOutputPath,sprintf('%s_%05d.wav',theSpec.Name,i+1));
wavwrite(SoundSignal(Tsmp(i+1):length(SoundSignal)),SampleFreq,Bits,theOutFile);

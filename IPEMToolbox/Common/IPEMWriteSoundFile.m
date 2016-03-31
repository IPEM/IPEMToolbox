function outResult = IPEMWriteSoundFile (varargin)
% Usage:
%   outResult = IPEMWriteSoundFile(inSignal,inSampleFreq,inFileName,...
%                                  inFilePath,inSection)
%
% Description:
%   Writes (part of) a sound signal to file.
%
% Input arguments:
%   inSignal = sound signal (each row represents a channel)
%   inSampleFreq = sample frequency of sound signal (in Hz)
%   inFileName = name for the sound file (with extension)
%                if empty or not specified, the standard "Write file" dialog box
%                can be used to select a sound file to write to
%   inFilePath = path for the sound file
%                if empty or not specified, IPEMRootDir('input')\Sounds is used
%                by default
%   inSection = section of the sound signal to be written, given as [start end]
%               (in s)
%               if empty or not specified, the entire sound signal is written
%
% Output:
%   outResult = usually 1
%               0 if the user pressed 'Cancel' when selecting a sound file
%
% Remarks:
%   The 'end' in the section specification is exclusive:
%   if you want to write the first second of a sound signal sampled at 1000 Hz,
%   you should specify [0 1] for inSection (and not [0 0.999]). This will read
%   samples 1 to 1000, which is a full second (the sample at time 1 s is not
%   written!).
%
%   Always writes 16-bit.
%
% Example:
%   IPEMWriteSoundFile(s,fs,'test.wav');
%
% Authors:
%   Koen Tanghe - 20040323
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

% Check input arguments
[inSignal,inSampleFreq,inFileName,inFilePath,inSection] = ...
    IPEMHandleInputArguments(varargin,3,{[],[],[],fullfile(IPEMRootDir('input'),'Sounds'),[]});

% Use standard "write file" dialog
if isempty(inFileName)
    OldPath = cd;
    cd(inFilePath);
    [inFileName,inFilePath] = uiputfile('*.wav;*.snd;*.au','Select a sound file to write:');
    cd(OldPath);
    % If user pressed 'Cancel', set result to 0 and return
    if (inFileName == 0)
        outResult = 0;
        return;
    end
end

% Check section
L = size(inSignal,2);
if isempty(inSection)
    Section = [1 L];
else
    Section = round([inSection(1) inSection(2)-1/inSampleFreq]*inSampleFreq+1);
    if or(any(Section > [L L]),any(Section < [1 1]))
        error(sprintf('ERROR: Illegal section (sound signal duration is %f s)',L/inSampleFreq));
    end
end

% Setup the complete sound file specification, check extension and write to file
theFile = fullfile(inFilePath,inFileName);
theParts = IPEMStripFileSpecification(theFile);
theExtension = lower(theParts.Extension);
if (strcmp(theExtension,'wav'))
    wavwrite(inSignal(:,Section(1):Section(2))',inSampleFreq,theFile);
elseif or(strcmp(theExtension,'snd'),strcmp(theExtension,'au'))
    auwrite(inSignal(:,Section(1):Section(2))',inSampleFreq,theFile);
else
    error('ERROR: Sound file extension should be .wav, .snd or .au');
end;  
outResult = 1;

function [Ts,Tsmp] = IPEMDoOnsets(varargin)
% Usage:
%   [Ts,Tsmp] = IPEMDoOnsets(inFileName,inFilePath,inPlotFlag);
%
% Description:
%   Convenience function for detecting onsets in a sound signal.
%   The onset times are also written to a text file.
%
% Input arguments:
%   inFileName = name of the sound file to process (with extension!)
%   inFilePath = path to the directory where the sound file is located
%                if empty or not specified, IPEMRootDir('input')\Sounds is used
%                by default
%   inPlotFlag = if non-zero, plots are generated (no plots if zero)
%                if empty or not specified, 0 is used by default
%
% Output:
%   Ts = onset times in seconds
%   Tsmp = onset times in samples
%
%   Additionally, a text file containing info about the detected onsets is
%   stored in the same directory as the sound file. It has the same name as the
%   sound file without extension, but followed by '_onsets.txt'.
%
% Example:
%   [Ts,Tsmp] = IPEMDoOnsets('music.wav');
%
% Authors:
%   Koen Tanghe - 20011107
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
[inFileName,inFilePath,inPlotFlag] = IPEMHandleInputArguments(varargin,2,{[],fullfile(IPEMRootDir('input'),'Sounds'),0});

% Setup the complete file specification
SoundFile = fullfile(inFilePath,inFileName);
StrippedName = IPEMStripFileSpecification(SoundFile);
FilePath = StrippedName.Path;
FileName = StrippedName.Name;

% Feedback of file that is being processed
disp(strcat('Processing file [',SoundFile,']...   '));

% Read the sound
[SoundSignal,SampleFreq,Bits] = wavread(SoundFile);
TotalTime = length(SoundSignal)/SampleFreq;

% Process... (and plot if needed)
[OnsetSignal,OnsetFreq] = IPEMCalcOnsets(SoundSignal,SampleFreq,inPlotFlag);
clear SoundSignal;

% ...and output the onset times
Ts = (find(OnsetSignal > 0)-1)/OnsetFreq;
Tsmp = round(Ts*SampleFreq+1);

% Storage and feedback
Nr = 1:length(Ts);
IOI = [Ts(2:length(Ts)) TotalTime] - Ts(1:length(Ts));
Likeliness = OnsetSignal(find(OnsetSignal>0));
OnsetFile = fullfile(FilePath,[FileName '_onsets.txt']);
fprintf(1,'The following file contains the onset results:\n');
fprintf(1,'%s\n',OnsetFile);
OnsetFileHandle = fopen(OnsetFile,'w');
fprintf(OnsetFileHandle,'FILE: [%s]\n',SoundFile);
fprintf(OnsetFileHandle,'DATE: [%s]\n',datestr(now));
fprintf(OnsetFileHandle,'\n');
fprintf(OnsetFileHandle,'Number   Time (s)   Interval (s)   Time (samples)   Likeliness\n');
fprintf(OnsetFileHandle,'------   --------   ------------   --------------   ----------\n');
fprintf(OnsetFileHandle,'%3d      %6.3f     %6.3f         %8d         %6.3f\n', ...
                        [Nr;Ts;IOI;Tsmp;Likeliness]);
fclose(OnsetFileHandle);

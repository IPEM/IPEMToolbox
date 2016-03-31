function outAMNoise = IPEMConvertToAMNoise (varargin)
% Usage:
%   outAMNoise = ...
%     IPEMConvertToAMNoise(inSignal,inSampleFreq,inWantedSampleFreq,...
%                          inPlaySound,inNoiseBand)
%
% Description:
%   Converts a signal to amplitude modulated noise (the given signal is used
%   as modulator) and plays back the sound (optionally).
%   Can be used for a quick listening to envelope-like signals.
%
% Input arguments:
%   inSignal = signal to convert to AM noise
%   inSampleFreq = sample frequency of incoming signal (in Hz)
%   inWantedSampleFreq = wanted sample frequency for the resulting AM noise
%                        (in Hz)
%                        if empty or not specified, 22050 is used by default
%   inPlaySound = if empty, non-zero or not specified, the AM noise will be
%                 played back
%                 otherwise, no sound is produced
%   inNoiseBand = two element row vector specifiying the wanted the noise band
%                 (in Hz)
%                 if empty or not specified, broad band noise is used by default
%
% Output:
%   outAMNoise = the resulting amplitude modulated noise
%
% Example:
%   AMNoise = IPEMConvertToAMNoise(RMS,RMSFreq,22050,1);
%
% Authors:
%   Koen Tanghe - 20010221
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
[inSignal,inSampleFreq,inWantedSampleFreq,inPlaySound,inNoiseBand] = ...
    IPEMHandleInputArguments(varargin,3,{[],[],22050,1,[]});

% Calculate modulation signal and apply it to white noise
Modulation = resample(inSignal,round(inWantedSampleFreq),round(inSampleFreq));
if isempty(inNoiseBand)
    theNoise = rand(1,size(Modulation,2))*2-1;
else
    theNoise = IPEMGenerateBandPassedNoise(inNoiseBand,size(Modulation,2)/inWantedSampleFreq,inWantedSampleFreq);
    theNoise = IPEMNormalize(theNoise);
end
outAMNoise = theNoise.*Modulation;

% Play sound if needed
if (inPlaySound)
    s = IPEMAdaptLevel(outAMNoise,-20);
    wavplay(s,inWantedSampleFreq,'sync');
end;

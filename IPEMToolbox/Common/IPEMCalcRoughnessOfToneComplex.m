function [outSignal,outSignalFreq,outRoughness,outRoughnessFreq] = ...
   IPEMCalcRoughnessOfToneComplex (varargin)
% Usage:
%   [outSignal,outSignalFreq,outRoughness,outRoughnessFreq] = ...
%     IPEMCalcRoughnessOfToneComplex(inBaseFreq,inOctaveRatio,
%                                    inNumOfHarmonics,inDuration,inPlotFlag)
%
% Description:
%   Calculates the roughness for a superposition of two complex tones
%   having inNumOfHarmonics harmonics:
%   - a constant one with fundamental frequency inBaseFreq
%   - one with linearly increasing fundamental frequency
%     (from inBaseFreq to inBaseFreq*inOctaveRatio)
%   Any octave ratio can be specified.
%
% Input arguments:
%   inBaseFreq = fundamental frequency for the tone complex (in Hz)
%   inOctaveRatio = frequency ratio for the octave
%   inNumOfHarmonics = total number of harmonics for each tone complex
%   inDuration = duration of the signal (in s)
%   inPlotFlag = if non-zero, plots are generated
%                if empty or not specified, 1 is used by default
%
% Output:
%   outSignal = signal that was analyzed
%   outSignalFreq = sample frequency for outSignal (in Hz)
%   outRoughness = roughness calculated for the signal
%   outRoughnessFreq = sample frequency for outRoughness (in Hz)
%
% Example:
%   [s,fs,r,rfreq] = IPEMCalcRoughnessOfToneComplex(440,2,5,5);
%
% Authors:
%   Koen Tanghe - 20050120
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
[inBaseFreq,inOctaveRatio,inNumOfHarmonics,inDuration,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,5,{[],[],[],[],1});

% Setup some basic parameters
outSignalFreq = 22050;
t = 0:1/outSignalFreq:inDuration;

% Build the constant signal
s1 = zeros(1,length(t));
for i = 1:inNumOfHarmonics
   s1 = s1 + sin(2*pi*inBaseFreq*i*t);
end;

% Build the chirp signal
s2 = zeros(1,length(t));
for i = 1:inNumOfHarmonics
   s2 = s2 + chirp(t,inBaseFreq*i,inDuration,inBaseFreq*i*inOctaveRatio,'linear');
end;

% Add the two signals together
outSignal = s1 + s2;

% Smooth ends over 20 ms
outSignal = IPEMFadeLinear(outSignal,outSignalFreq,0.020);

% Insert 100 ms silence at the start and end
outSignal = [zeros(1,round(0.1*outSignalFreq)) outSignal zeros(1,round(0.1*outSignalFreq))];

% Adjust the overall signal level
outSignal = IPEMAdaptLevel(outSignal,-20);

% Calculate the auditory nerve image
[ANI,ANIFreq,ANIFilterFreqs] = IPEMCalcANI(outSignal,outSignalFreq,[],0);

% Calculate the roughness
[outRoughness,outRoughnessFreq] = IPEMRoughnessFFT(ANI,ANIFreq,ANIFilterFreqs,[],[],inPlotFlag);

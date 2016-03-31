function outSignal = IPEMHarmonicTone (varargin)
% Usage:
%   outSignal = IPEMHarmonicTone (inFundamentalFreq,inDuration,inSampleFreq,...
%                                 inPhaseFlag,indBLevel,inNumOfHarmonics)
%
% Description:
%   This function generates a tone with a number of harmonics.
%   The amplitudes of the harmonics vary as 1/N (N = number of harmonic).
%
% Input arguments:
%   inFundamentalFreq = the main frequency in Herz
%   inDuration = the duration (in s)
%                if empty or not specified, 1 is used by default
%   inSampleFreq = the desired sample frequency for the output signal (in Hz)
%                  if empty or not specified, 22050 is used by default
%   inPhaseFlag = for choosing whether random phase has to be used or not
%                 (1 to use random phase, 0 otherwise)
%                 if empty or not specified, 1 is used by default
%   indBLevel = dB level of generated tone (in dB)
%               if empty or not specified, no level adjustment is performed
%   inNumOfHarmonics = number of harmonics (including fundamental frequency)
%                      if empty or not specified, 10 is used by default
%
% Output:
%   outSignal = the signal for the tone
%
% Example:
%   Signal = IPEMHarmonicTone(440,1,22050,1,-20,5);
%
% Authors:
%   Koen Tanghe - 20010116
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
[inFundamentalFreq,inDuration,inSampleFreq,inPhaseFlag,indBLevel,inNumOfHarmonics] = ...
    IPEMHandleInputArguments(varargin,2,{[],1,22050,1,[],10});

% Initialize
N = round(inDuration*inSampleFreq);
t = (0:N-1)/inSampleFreq;
outSignal = zeros(1,N);

% Generate partials
MaxHarmonic = floor(inSampleFreq/2/inFundamentalFreq);
N = min(inNumOfHarmonics,MaxHarmonic);
for i = 1:N
    theFreq = inFundamentalFreq*i;
    outSignal = outSignal + (1/i)*sin(2*pi*theFreq*t + inPhaseFlag*rand(1)*pi);
end

% Adjust level if needed
if ~isempty(indBLevel)
    outSignal = IPEMAdaptLevel(outSignal,indBLevel);
end

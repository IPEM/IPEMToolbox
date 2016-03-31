function outSignal = IPEMShepardTone(varargin)
% Usage:
%   outSignal = IPEMShepardTone(inMainFreq,inDuration,inSampleFreq,...
%                               inPhaseFlag,indBLevel)
%
% Description:
%   This function generates a Shepard tone.
%
% Input arguments:
%   inMainFreq = the main frequency (in Hz)
%   inDuration = the duration (in s)
%                if empty or not specified, 1 is used by default
%   inSampleFreq = the desired sample frequency for the output signal (in Hz)
%                  if empty or not specified, 22050 is used by default
%   inPhaseFlag = for choosing whether random phase is to be used or not
%                 (1 to use random phase, 0 otherwise)
%                 if empty or not specified, 1 is used by default
%   indBLevel = dB level of generated tone (in dB)
%               if empty or not specified, no level adjustment is performed
%
% Output:
%   outSignal = the signal for the tone
%
% Example:
%   Signal = IPEMShepardTone(440,1,22050,1,-20);
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
[inMainFreq,inDuration,inSampleFreq,inPhaseFlag,indBLevel] = ...
    IPEMHandleInputArguments(varargin,2,{[],1,22050,1,[]});

% Frequency range
theMinFreq = 15;
theMaxFreq = inSampleFreq/2;

% Setup initial values
N = round(inDuration*inSampleFreq);
outSignal = zeros(1,N);
theTime = (0 : N-1)/inSampleFreq;

% Set bell shape parameters
BellCenterFreq = 1000;
BellMinFreq = 100;

% Calculate lower part
theFreq = inMainFreq;
while theFreq > theMinFreq
   theAmpl = IPEMBellShape(log(theFreq/BellCenterFreq),0,log(BellCenterFreq/BellMinFreq),1);
   outSignal = outSignal + theAmpl*sin(2*pi*theFreq*theTime + inPhaseFlag*rand(1)*pi);
   theFreq = theFreq/2.0;
end

% Calculate upper part
theFreq = inMainFreq*2.0;
while theFreq < theMaxFreq
   theAmpl = IPEMBellShape(log(theFreq/BellCenterFreq),0,log(BellCenterFreq/BellMinFreq),1);
   outSignal = outSignal + theAmpl*sin(2*pi*theFreq*theTime + inPhaseFlag*rand(1)*pi);
   theFreq = theFreq*2.0;
end

% Adjust level if needed
if ~isempty(indBLevel)
    outSignal = IPEMAdaptLevel(outSignal,indBLevel);
end

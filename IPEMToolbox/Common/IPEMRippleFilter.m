function outSignal = IPEMRippleFilter(inSignal,inSampleFreq,inDelay,inAttenuation,inSync)
% Usage:
%   outSignal = IPEMRippleFilter(inSignal,inSampleFreq,inDelay,...
%                                inAttenuation,inSync)
%
% Description:
%   Filters the incoming signal with a ripple filter according to the following
%   scheme:
%
%        OUT = IN / (1 + inAttenuation * z^(-m) )
%        where m = round(inDelay*inSampleFreq)
%
%   In the frequency domain, this produces a rippled frequency response,
%   in which either the peaks (if inSync == 1) or the valleys (if inSync == 0)
%   of the ripples are at frequencies n.F0 (F0 = 1/inDelay).
%
% Input arguments:
%   inSignal = input signal (each row represents a channel)
%   inSampleFreq = input signal sample frequency (in Hz)
%   inDelay = delay of feedback branch (in s)
%   inAttenuation = attenuation ratio (0 to 1)
%   inSync = if 1, the ripple's peaks are at frequencies n/delay
%            if 0, the ripple's valleys are at frequencies n/delay
%
% Output:
%   outSignal = the filtered signal
%
% Example:
%   Signal = IPEMRippleFilter(Signal,SampleFreq,1/100,0.95,1);
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

% Get delay in samples
n = round(inDelay*inSampleFreq);

% Setup filter data
B = 1;
A = zeros(1,n+1);
A(1) = 1;
if (inSync == 1)
   A(n+1) = -inAttenuation;
else
   A(n+1) = +inAttenuation;
end;

% Filter
outSignal = filter(B,A,inSignal')';

function [outEnvelope,outEnvelopeFreq] = IPEMEnvelopeFollower(varargin)
% Usage:
%   [outEnvelope,outEnvelopeFreq] = ...
%      IPEMEnvelopeFollower(inSignal,inSignalFreq,inAttackTime,inReleaseTime,...
%                           inPlotFlag);
%
% Description:
%   Does envelope following on a signal.
%
% Input arguments:
%   inSignal = one-dimensional input signal
%   inSignalFreq = sample frequency for inSignal (in Hz)
%   inAttackTime = time it takes to reach 0.5 for a 0 to 1 step signal (in s)
%   inReleaseTime = time it takes to reach 0.5 for a 1 to 0 step signal (in s)
%                   if not specified or empty, inAttackTime is used by default
%   inPlotFlag = if not specified or empty, 0 is used by default
%
% Output:
%   outEnvelope = envelope signal
%   outEnvelopeFreq = sample frequency for outEnvelope (same as inSignalFreq)
%
% Remarks:
%   Uses one-pole low-pass filters with different coefficients for attack and
%   release on the absolute value of the signal. The attack and release times
%   are specified as "half-value times".
%
% Example:
%   fs = 44100;
%   s = zeros(1,fs*5);
%   s(fs:fs*3) = 1;
%   IPEMEnvelopeFollower(s,fs,0.010,0.020,1);
%
% Authors:
%   Koen Tanghe - 20030403
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

% Handle input parameters
[inSignal,inSignalFreq,inAttackTime,inReleaseTime,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,4,{[],[],[],[],0});
if (isempty(inReleaseTime))
    inReleaseTime = inAttackTime;
end

% Setup half decay factors
if (inAttackTime ~= 0)
    fAttack = 2^(-1/(inAttackTime*inSignalFreq));
else
    fAttack = 0;
end
if (inReleaseTime ~= 0)
    fRelease = 2^(-1/(inReleaseTime*inSignalFreq));
else
    fRelease = 0;
end

% Perform envelope extraction
N = length(inSignal);
outEnvelope = zeros(1,N);
outEnvelopeFreq = inSignalFreq;
e = 0;
for i = 1:N
    a = abs(inSignal(i));
    if (a > e)
        e = a + fAttack*(e - a);
    else
        e = a + fRelease*(e - a);
    end
    outEnvelope(i) = e;
end

% Plot results if requested
if (inPlotFlag)
    t = (0:N-1)/inSignalFreq;
    figure;
    plot(t,inSignal);
    hold on;
    plot(t,outEnvelope,'red');
    hold off;
    axis tight;
    xlabel('Time (in s)');
    ylabel('Amplitude');
    legend({'signal','envelope'},1);
    title('Envelope of signal');
end
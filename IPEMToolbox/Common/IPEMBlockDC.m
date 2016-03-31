function [outSignal,outSignalFreq] = IPEMBlockDC(varargin)
% Usage:
%   [outSignal,outSignalFreq] = ...
%     IPEMBlockDC(inSignal,inSignalFreq,inCutoffFreq,inPlotFlag)
%
% Description:
%   Blocks DC (very low frequencies).
%	Based on the formula:
%		y(n) = g * ( x(n) - x(n-1) ) + R * y(n-1)
%	where
%		R = 1 - (2*PI*Fc/Fs)
%       g = (1 + R)/2 (for gain correction)
%		Fc = cutoff frequency in Hz (-3 dB point)
%		Fs = sample frequency in Hz
%
% Input arguments:
%   inSignal = one dimensional input signal
%   inSignalFreq = sample frequency of inSignal (in Hz)
%   inCutoffFreq = -3 dB cutoff frequency for HP filter (in Hz)
%   inPlotFlag = if non-zero, plots are generated
%                if not specified or empty, 0 is used by default
%
% Output:
%   outSignal = Processed signal.
%   outSignalFreq = Sample frequency of output signal (same as input) (in Hz).
%
% Example:
%   [s2,fs2] = IPEMBlockDC(s,fs,50,1);
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
[inSignal,inSignalFreq,inCutoffFreq,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,4,{[],[],[],0});

% Setup filter
R = 1 - 2*pi*inCutoffFreq/inSignalFreq;
g = (1 + R)/2;
B = g*[1 -1];
A = [1 -R];

% Apply filter
outSignal = filter(B,A,inSignal);
outSignalFreq = inSignalFreq;

% Show plots if needed
if (inPlotFlag)
    T = (0:length(inSignal)-1)/inSignalFreq;
    figure;
    subplot(211);
    plot(T,inSignal);
    ylabel('Original');
    title('DC blocking of signal');
    subplot(212);
    plot(T,outSignal);
    ylabel('After DC blocker');
    xlabel('Time (in s)');
end

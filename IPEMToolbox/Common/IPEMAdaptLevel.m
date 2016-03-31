function outSignal = IPEMAdaptLevel (inSignal,indB)
% Usage:
%   outSignal = IPEMAdaptLevel (inSignal,indB)
%
% Description:
%   This function adapts the RMS power level of the (multi-channel) signal
%   to the specified dB level. Channels are represented by rows.
%
% Input arguments:
%   inSignal = the input signal (each row represents a channel)
%   indB = wanted level (0 is maximum level without clipping, -20 is reasonable)
%
% Output:
%   outSignal = the adapted signal
%
% Remarks:
%   The reference value of 0 dB is the level of a square wave with amplitude 1
%   Thus, a sine wave with amplitude 1 yields -3.01 dB.
%
% Example:
%   Signal = IPEMAdaptLevel(Signal,-6);
%
% Authors:
%   Marc Leman
%   Koen Tanghe - 20000626
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

% Calculate current RMS value
[Rows Cols] = size(inSignal);
theRMS = sqrt(sum(inSignal.^2,2)/Cols);

% Calculate factor to use for adapting the signal
theFactor = 10.^(indB/20 - log10(theRMS));

% Finally adapt the signal
outSignal = zeros(Rows,Cols);
for i = 1:Rows
   outSignal(i,:) = inSignal(i,:)*theFactor(i);
end;

% Relations between amplitude, Root Mean Square and decibel level:
% ----------------------------------------------------------------
% Ampl*f     <=>    RMS*f     <=>     dB level + 20*log10(f)
%
% Ampl/2     <=>    RMS/2     <=>     dB level - 6.02
 

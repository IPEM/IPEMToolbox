function outRMSLevel = IPEMGetLevel (varargin)
% Usage:
%   outRMSLevel = IPEMGetLevel(inSignal,inUseDecibels)
%
% Description:
%   Calculates the average RMS power level of a signal in dB (or not).
%
% Input arguments:
%   inSignal = signal to be analyzed
%   inUseDecibels = if non-zero, dB units are used instead of plain RMS
%                   if empty or not specified, 1 is used by default
%
% Output:
%   outRMSLevel = average RMS level (in dB if inUseDecibels is non-zero)
%
% Remarks:
%   The reference value of 0 dB is the level of a square wave with amplitude 1.
%   Thus, a sine wave with amplitude 1 yields -3.01 dB.
%
% Example:
%   RMSLevel = IPEMGetLevel(Signal);
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

% Handle input arguments
[inSignal,inUseDecibels] = IPEMHandleInputArguments(varargin,2,{[],1});

% Calculate RMS power level
[Rows Cols] = size(inSignal);
outRMSLevel = sqrt(sum(inSignal.^2,2)/Cols);
if (inUseDecibels)
    outRMSLevel = 20*log10(outRMSLevel);
end

function outClickSignal = IPEMConvertToClickSound(varargin)
% Usage:
%   outClickSignal = IPEMConvertToClickSound(inClickTimes,inWantedSampleFreq,...
%                                            inTimeRange,inAmplitudes)
%
% Description:
%   Converts a sequence of times into a click sound signal.
%
% Input arguments:
%   inClickTimes = Times where a click should be generated (in s).
%   inWantedSampleFreq = Sample frequency of the output signal (in Hz).
%   inTimeRange = Time range for which clicks should be generated (only times
%                 from inClickTimes that fall into this range will be used).
%                 Specified as [min max] (in s).
%                 If empty or not specified, the full range will be used.
%   inAmplitudes = Amplitudes corresponding to the click times.
%                  Should be in [0...1] range.
%                  If this is a single scalar, this value will be used for all
%                  click times.
%                  If empty or not specified, 1 is used by default.
%
% Output:
%   outClickSignal = The click sound signal.
%
% Remarks:
%   The clicks are very simple 0 to 1 transitions (Dirac pulses).
%   The end time of the time range is exclusive.
%
% Example:
%   s = IPEMConvertToClickSound(0:0.5:5,44100,[1 4],0.8);
%
% Authors:
%   Koen Tanghe - 20040423
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
[inClickTimes,inWantedSampleFreq,inTimeRange,inAmplitudes] = IPEMHandleInputArguments(varargin,3,{[],[],[],1});
if (isempty(inTimeRange))
    inTimeRange = [0 max(inClickTimes)];
end

% Only use click times in time range
T = inClickTimes;
I = find((T >= inTimeRange(1))&(T <= inTimeRange(2)-1/inWantedSampleFreq));

% Setup the amplitudes
if (length(inAmplitudes) == 1)
    A = ones(1,length(I))*inAmplitudes;
else
    A = inAmplitudes(I);
end

% Now generate the samples
N = round((inTimeRange(2)-inTimeRange(1))*inWantedSampleFreq);
outClickSignal = zeros(1,N);
outClickSignal(round((inClickTimes(I)-inTimeRange(1))*inWantedSampleFreq)+1) = A;

function outMask = IPEMCreateMask(varargin)
% Usage:
%   outMask = IPEMCreateMask(inTime,inStartTimes,inAmplitudes,inDecayPeriod,...
%                            inFractionAtDecayPeriod)
%
% Description:
%   This function creates an exponentially decaying mask from the given start
%   times and amplitudes.
%
% Input arguments:
%   inTime = the time span for which a mask is needed (in samples !)
%   inStartTimes = the start times of the masking events (in samples !)
%   inAmplitudes = the amplitudes of the masking events
%   inDecayPeriod = the time (in samples !) it takes before a single mask reaches
%                   inFractionAtDecayPeriod of its initial amplitude
%   inFractionAtDecayPeriod = fraction of original amplitude at inDecayPeriod
%                             if empty or not specified, 0.5 is used by default
%                             (i.e. half decay time)
%  
% Output:
%   outMask = the requested mask
%
% Remarks:
%   The relation between a decay time (DT) + fraction at decay time (DF)
%   specification and a half decay time (HDT) specification is as follows:
%     HDT = DT*log(0.5)/log(DF)
%
% Example:
%   Mask = IPEMCreateMask(1:1000,[20 250 400 860 900],[1 0.5 1 0.5 1],100);
%     or
%   fs = 22050; t = 0:1/fs:5-1/fs;
%   Mask = IPEMCreateMask(t,[1 2 3],[1 0.5 1],0.2);
%
% Authors:
%   Koen Tanghe - 20040106
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
[inTime,inStartTimes,inAmplitudes,inDecayPeriod,inFractionAtDecayPeriod] = ...
    IPEMHandleInputArguments(varargin,5,{[],[],[],[],0.5});

% Initialize output
outMask = zeros(size(inTime));
if (inDecayPeriod <= 0)
    return;
end

% Superpose all masks
for i = 1:length(inStartTimes)
   theMask = OneMask(inTime,inStartTimes(i),inAmplitudes(i),inDecayPeriod,inFractionAtDecayPeriod);
   theIndices = find(theMask > outMask);
   outMask(theIndices) = theMask(theIndices);
end;


% ----- local subroutine -----

function outY = OneMask(inTime,inStartTime,inAmplitude,inDecayPeriod,inFractionAtDecayPeriod)

Alpha = -log(inFractionAtDecayPeriod);

outY = zeros(size(inTime));
theMasked = find(inTime >= inStartTime);
if ~isempty(theMasked)
   outY(theMasked) = inAmplitude*exp(-(inTime(theMasked)-inStartTime)/inDecayPeriod*Alpha);
end

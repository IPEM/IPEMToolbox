function [outLeftIndex, outRightIndex] = IPEMFindNearestMinima(inSignal,inPeakIndex)
% Usage:
%   [outLeftIndex, outRightIndex] = IPEMFindNearestMinima(inSignal,inPeakIndex)
%
% Description:
%   Finds the nearest minima to the left and the right of the specified peak.
%   Peaks can be found with IPEMFindAllPeaks.
%
% Input arguments:
%   inSignal = the signal to analyze
%   inPeakIndex = index in inSignal of a peak
%
% Output:
%   outLeftIndex = the index of the nearest miminum to the left of the peak
%                  if no real minimum was found, 1 is returned  
%   outRightIndex = the index of the nearest miminum to the right of the peak
%                   if no real minimum was found, length(inSignal) is returned
%
% Example:
%   [LeftIndex,RightIndex] = IPEMFindNearestMinima(Signal,PeakIndex);
%
% Authors:
%   Koen Tanghe - 20000208
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

% Get some relevant data from the input
N = length(inSignal);

% Find the nearest minimum to the left
thePreviousValue = inSignal(inPeakIndex);
outLeftIndex = 0;
for i = (inPeakIndex-1):-1:1
   if (inSignal(i) > thePreviousValue)
      outLeftIndex = i+1;
      break;
   else
      thePreviousValue = inSignal(i);
      outLeftIndex = i;
   end;
end 

% Find the nearest minimum to the right
thePreviousValue = inSignal(inPeakIndex);
outRightIndex = 0;
for i = (inPeakIndex+1):N
   if (inSignal(i) > thePreviousValue)
      outRightIndex = i-1;
      break;
   else
      thePreviousValue = inSignal(i);
      outRightIndex = i;
   end;
end



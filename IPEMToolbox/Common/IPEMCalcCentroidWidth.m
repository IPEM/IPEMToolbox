function [outWidth,outWidthFreq] = IPEMCalcCentroidWidth (varargin)
% Usage:
%   [outWidth,outWidthFreq] =
%     IPEMCalcCentroidWidth(inWeights,inWeightFreq,
%                           inFrameWidth,inFrameInterval,
%                           inDistances,inCentroid,
%                           inPlotFlag)
%
% Description:
%   Calculates the weighted difference between the spectral components and the
%   (already) calculated centroid of the given multi-channel signal.
%
% Input arguments:
%   inWeights = a matrix (of size [N M]) in which each column represents weight
%               data at a given moment in time
%   inWeightFreq = frequency at which the weight data is sampled (in Hz)
%   inFrameWidth = width of 1 frame (in s)
%   inFrameInterval = interval between successive frames (in s)
%   inDistances = a vector of size [N 1], representing distances for each weight
%                 if empty or not specified, (1:N)' is used
%   inCentroid = this provides the centroid for the data that was
%                calculated with IPEMCalcCentroid, using the same parameters
%                if empty or not specified, the centroid itself is calculated
%                in this function
%   inPlotFlag = if non-zero, plots three curves:
%                the centroid itself (central line), plus both the centroid + the
%                centroid width and the centroid - the centroid width
%                if empty or not specified, 0 is used by default
%
% Output:
%   outWidth = the calculated width
%   outWidthFreq = sample frequency of the width
%
% Example:
%   [Width,WidthFreq] = IPEMCalcCentroidWidth(ANI,ANIFreq,0.05,0.01,...
%                                             ANIFilterFreqs);
%
% Authors:
%   Koen Tanghe - 20010221
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
[inWeights,inWeightFreq,inFrameWidth,inFrameInterval,inDistances,inCentroid,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,5,{[],[],[],[],[],[],0});

% Get size of input
[theRows,theColumns] = size(inWeights);

% Additional argument checking
if isempty(inDistances)
   inDistances = (1:theRows)';
else
   if (size(inDistances,1) ~= theRows)
      fprintf(2,'ERROR: number of distances must be same as number of weights\n');
      return;
   end;
end;
if isempty(inCentroid)
   % If the centroid was not calculated before, do this first
   [inCentroid,theCentroidFreq] = IPEMCalcCentroid(inWeights,inWeightFreq,inFrameWidth,inFrameInterval,inDistances,0);
end;

% Get frame step and width
theStep = max(1,round(inFrameInterval*inWeightFreq));
theWidth = max(1,round(inFrameWidth*inWeightFreq));

% Initialize and calculate centroid width:
% weighted average of differences between spectral components and centroid
outWidth = zeros(1,floor((theColumns-theWidth+1)/theStep));
theCounter = 1;
for t = 1:theStep:(theColumns-theWidth+1)
   theSum = 0;
   theWeightedSumOfDifferences = 0;
   for i = t:(t+theWidth-1)
      theSum = theSum + sum(inWeights(:,i));
      theWeightedSumOfDifferences = theWeightedSumOfDifferences ...
         + abs(inDistances-inCentroid(theCounter))'*inWeights(:,i);
   end;
   outWidth(theCounter) = theWeightedSumOfDifferences/theSum;
   theCounter = theCounter + 1;
end;
outWidthFreq = inWeightFreq/theStep;

% Plot if needed
if (inPlotFlag ~= 0)
   figure;
   subplot(211);
   theInputTime = (0:theColumns-1)/inWeightFreq;
   imagesc(theInputTime,1:theRows,inWeights);
   colormap(1-gray);
   axis xy;
   subplot(212);
   t = 0:1/outWidthFreq:(length(outWidth)-1)/outWidthFreq;
   plot(t,inCentroid-outWidth/2,'r',...
        t,inCentroid,'b', ...
        t,inCentroid+outWidth/2,'r');
   axis([0 max(t) min(inDistances) max(inDistances)]);
   title('Centroid Width');
   xlabel('time (s)')
end;


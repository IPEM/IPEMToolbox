function [outCentroid,outCentroidFreq] = IPEMCalcCentroid (varargin)
% Usage:
%   outCentroid = IPEMCalcCentroid (inWeights,inWeightFreq,...
%                                   inFrameWidth,inFrameInterval,inDistances,...
%                                   inPlotFlag)
%
% Description:
%   Calculates the centroid for the given (time-varying) weights and their
%   (constant) distances.
%   This can be used to calculate the (time-varying) centroid of the spectrum
%   of a musical signal.
%
% Input arguments:
%   inWeights = a matrix (of size [N M]) in which each column represents weight
%               data at a given moment in time
%   inWeightFreq = frequency at which the weight data is sampled (in Hz)
%   inFrameWidth = width of 1 frame (in s)
%   inFrameInterval = interval between successive frames (in s)
%   inDistances = a vector of size [N 1], representing distances for each weight
%                 if empty or not specified, (1:N)' is used
%   inPlotFlag = if non-zero, plots the centroid
%                if empty or not specified, 0 is used by default
%
% Output:
%   outCentroid = the (time-varying) centroid of the weights
%   outCentroidFreq = sample frequency for centroid
%
% Example:
%   [Centroid,CentroidFreq] = IPEMCalcCentroid(ANI,ANIFreq,0.05,0.01,...
%                                              ANIFilterFreqs);
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

% Handle arguments
error(nargchk(4,6,nargin));
inWeights = varargin{1};
inWeightFreq = varargin{2};
inFrameWidth = varargin{3};
inFrameInterval = varargin{4};
if (nargin >= 5)
   inDistances = varargin{5};
else
   inDistances = [];
end;
if (nargin == 6)
   inPlotFlag = varargin{6};
else
   inPlotFlag = [];
end;
   
% Get size of input
[theRows,theColumns] = size(inWeights);

% Check arguments
if isempty(inDistances)
   inDistances = (1:theRows)';
else
   if (size(inDistances,1) ~= theRows)
      fprintf(2,'ERROR: number of distances must be same as number of weights\n');
      return;
   end;
end;
if isempty(inPlotFlag)
   inPlotFlag = 0;
end;

% Get step and width
theStep = max(1,round(inFrameInterval*inWeightFreq));
theWidth = max(1,round(inFrameWidth*inWeightFreq));

% Initialize and calculate centroid
outCentroid = zeros(1,floor((theColumns-theWidth+1)/theStep));
theCounter = 1;
for t = 1:theStep:(theColumns-theWidth+1)
   theSum = 0;
   theWeightedSum = 0;
   for i = t:(t+theWidth-1)
      theSum = theSum + sum(inWeights(:,i));
      theWeightedSum = theWeightedSum + inDistances'*inWeights(:,i);
   end;
   outCentroid(theCounter) = theWeightedSum/theSum;
   theCounter = theCounter + 1;
end;
outCentroidFreq = inWeightFreq/theStep;

% Plot if needed
if (inPlotFlag ~= 0)
   figure;
   subplot(211);
   theInputTime = (0:theColumns-1)/inWeightFreq;
   imagesc(theInputTime,1:theRows,inWeights);
   colormap(1-gray);
   axis xy;
   subplot(212);
   t = 0:1/outCentroidFreq:(length(outCentroid)-1)/outCentroidFreq;
   plot(t,outCentroid);
   axis([0 (length(outCentroid)-1)/outCentroidFreq min(inDistances) max(inDistances)]);
   title('Centroid');
   xlabel('time (s)')
end;

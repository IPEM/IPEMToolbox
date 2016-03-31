function [outZCR,outZCRFreq] = IPEMCalcZeroCrossingRate (varargin)
% Usage:
%   [outZCR,outZCRFreq] = 
%     IPEMCalcZeroCrossingRate(inSignal,inSignalFreq,
%                              inFrameWidth,inFrameInterval,
%                              inZeroTolerance,inPlotFlag)
%
% Description:
%   Calculates the number of zero-crossings per second for successive frames.
%
% Input arguments:
%   inSignal = signal to be analyzed
%   inSignalFreq = sample frequency of inSignal
%   inFrameWidth = width of 1 frame (in s)
%   inFrameInterval = interval between successive frames (in s)
%   inZeroTolerance = defines a region around zero where zero-crossings are not
%                     counted (useful for noisy parts of the signal)
%                     if empty or not specified, 0 is used by default
%   inPlotFlag = if non-zero, plots the ZCR
%                if not specified or empty, 1 is used by default
%
% Output:
%   outZCR = number of zero-crossings per second for each frame
%   outZCRFreq = sample frequency of outZCR
%
% Example:
%   [ZCR,ZCRFreq] = IPEMCalcZeroCrossingRate(s,fs,0.05,0.01,0.001);
%
% Authors:
%   Koen Tanghe - 20001012
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
inSignal = varargin{1};
inSignalFreq = varargin{2};
inFrameWidth = varargin{3};
inFrameInterval = varargin{4};
if (nargin >= 5)
    inZeroTolerance = varargin{5};
else
    inZeroTolerance = [];
end;
if (nargin == 6)
    inPlotFlag = varargin{6};
else
    inPlotFlag = [];
end;

% Get size of input
[theRows,theColumns] = size(inSignal);

% Check arguments
if isempty(inZeroTolerance)
    inZeroTolerance = 0;
end;
if isempty(inPlotFlag)
    inPlotFlag = 1;
end;

% Get step and width
theStep = max(1,round(inFrameInterval*inSignalFreq));
theWidth = max(1,round(inFrameWidth*inSignalFreq));

% Initialize and calculate zero-crossing rate
outZCR = zeros(theRows,floor((theColumns-theWidth+1)/theStep));
theCounter = 1;
for t = 1:theStep:(theColumns-theWidth+1)
    outZCR(:,theCounter) = IPEMCountZeroCrossings(inSignal(:,t:t+theWidth-1),inZeroTolerance)...
        /(theWidth/inSignalFreq);
    theCounter = theCounter + 1;
end;
outZCRFreq = inSignalFreq/theStep;

% Plot if needed
if (inPlotFlag ~= 0)
    figure;
    subplot(211);
    theInputTime = (0:theColumns-1)/inSignalFreq;
    if (theRows == 1)
        plot(theInputTime,inSignal);
        axis tight;
    else
        imagesc(theInputTime,1:theRows,inSignal);
        colormap(1-gray);
        axis xy;
    end;
    subplot(212);
    t = 0:1/outZCRFreq:(length(outZCR)-1)/outZCRFreq;
    if (theRows == 1)
        plot(t,outZCR);
        axis tight;
    else
        imagesc(t,1:theRows,outZCR);
        colormap(1-gray);
        axis xy;
    end;
    title('Zero-Crossing Rate');
    xlabel('time (s)')
end;


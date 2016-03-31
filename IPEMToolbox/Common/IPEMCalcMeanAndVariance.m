function [outMean,outVariance,outFreq] = IPEMCalcMeanAndVariance (varargin)
% Usage:
%   [outMean,outVariance,outFreq] = 
%     IPEMCalcMeanAndVariance(inSignal,inSampleFreq,
%                             inFrameWidth,inFrameInterval,
%                             inPlotFlag,inPlotTitle)
%
% Description:
%   Calculates 'running' mean and variance of multi-channel signal:
%   for each channel, the mean and variance is calculated within succesive
%   frames.
%
% Input arguments:
%   inSignal = signal to be analyzed
%   inSampleFreq = sample frequency of the input signal (in Hz)
%   inFrameWidth = width of 1 frame (in s)
%   inFrameInterval = interval between successive frames (in s)
%   inPlotFlag = if non-zero, plots are generated
%                if not specified or empty, 1 is used by default
%   inPlotTitle = title for the plot
%                 if not specified or empty, no title is shown
%
% Output:
%   outMean = 'running' mean of inSignal
%   outVariance = 'running' variance of inSignal
%   outFreq = sample frequency for both outMean and outVariance
%
% Example:
%   [Mean,Variance,Freq] = IPEMCalcMeanAndVariance(RMS,RMSFreq,0.05,0.01,1,...
%                                                  'RMS');
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
inSampleFreq = varargin{2};
inFrameWidth = varargin{3};
inFrameInterval = varargin{4};
if (nargin >= 5)
    inPlotFlag = varargin{5};
else
    inPlotFlag = [];
end;
if (nargin == 6)
    inTitle = varargin{6};
else
    inTitle = [];
end;

% Check arguments
if isempty(inPlotFlag)
    inPlotFlag = 1;
end;

% Get size of input
[theRows,theColumns] = size(inSignal);

% Get frame step and width
theStep = max(1,round(inFrameInterval*inSampleFreq));
theWidth = max(1,round(inFrameWidth*inSampleFreq));

% For each channel, calculate the mean and variance within succesive frames
outMean = zeros(theRows,floor((theColumns-theWidth+1)/theStep));
outVariance = zeros(theRows,floor((theColumns-theWidth+1)/theStep));
theCounter = 1;
for t = 1:theStep:(theColumns-theWidth+1)
    outMean(:,theCounter) = mean(inSignal(:,t:t+theWidth-1),2);
    outVariance(:,theCounter) = diag(cov(inSignal(:,t:t+theWidth-1)'));
    theCounter = theCounter + 1;
end;
outFreq = inSampleFreq/theStep;

% Plot if needed
if (inPlotFlag ~= 0)
    theInputTime = (0:theColumns-1)/inSampleFreq;
    theOutputTime = (0:size(outMean,2)-1)/outFreq;
    
    figure;
    subplot(311);
    if (theRows == 1)
        plot(theInputTime,inSignal);
        axis tight;
    else
        imagesc(theInputTime,1:theRows,inSignal);
        colormap(1-gray);
        axis xy;
        ylabel('channel');
    end;
    if ~isempty(inTitle)
        title(inTitle);
    end;
    
    subplot(312);
    if (theRows == 1)
        plot(theOutputTime,outMean);
        axis tight;
        ylabel('Mean');
    else
        imagesc(theOutputTime,1:theRows,outMean);
        colormap(1-gray);
        axis xy;
        title('Mean');
        ylabel('channel');
    end;
    
    subplot(313);
    if (theRows == 1)
        plot(theOutputTime,outVariance);
        axis tight;
        ylabel('Variance');
    else
        imagesc(theOutputTime,1:theRows,outVariance);
        colormap(1-gray);
        axis xy;
        title('Variance');
        ylabel('channel');
    end;
    xlabel('time (s)');
end;


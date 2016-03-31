function [outRMSSignal,outRMSFreq] = IPEMCalcRMS (varargin)
% Usage:
%   [outRMSSignal,outRMSFreq] = IPEMCalcRMS (inSignal,inSampleFreq,inFrameWidth,
%                                            inFrameInterval,inPlotFlag)
%
% Description:
%   This function calculates the running RMS value of the given signal:
%   an RMS value is generated every inFrameInterval seconds over a period of  
%   inFrameWidth seconds.
%
% Input arguments:
%   inSignal = the input signal (if this is a matrix, RMS values are calculated
%              for each channel (ie. row) in the signal)
%   inSampleFreq = the sample frequency of the input signal (in Hz)
%   inFrameWidth = the period over which the RMS is calculated (in s)
%   inFrameInterval = the period between two successive frames (in s)
%   inPlotFlag = if non-zero, plots are generated
%                if not specified or empty, 0 is used by default
%
% Output:
%   outRMSSignal = the running RMS value of the signal
%   outRMSFreq = the sample frequency of the RMS signal
%
% Example:
%   [RMSSignal,RMSFreq] = IPEMCalcRMS(ANI,ANIFreq,0.050,0.010);
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
[inSignal,inSampleFreq,inFrameWidth,inFrameInterval,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,5,{[],[],[],[],0});

% Get the dimensions of the input signal
[N,M] = size(inSignal);

% Convert time units to sample units
theStep = round(inFrameInterval/(1/inSampleFreq));
theWidth = round(inFrameWidth/(1/inSampleFreq));

% Init the output
outRMSSignal = zeros(N,round((M-theWidth+1)/theStep));

% Step through the signal and calculate the RMS value for each frame in each channel
k = 1;
for i = 1:theStep:M-theWidth+1,
    outRMSSignal(:,k) = sqrt(sum(inSignal(:,i:i+theWidth-1).^2,2)/theWidth);
    k = k + 1;
end;

% Also return the effective sample frequency of the output signal
outRMSFreq = inSampleFreq/theStep;

% Plot if needed
if (inPlotFlag ~= 0)
    theInputTime = (0:(M-1))/inSampleFreq;
    theOutputTime = (0:(size(outRMSSignal,2)-1))/outRMSFreq;
    theChannels = 1:N;
    
    figure;
    subplot(211);
    if (N == 1)
        plot(theInputTime,inSignal);
        axis tight;
    else
        imagesc(theInputTime,theChannels,inSignal);
        colormap(1-gray);
        axis xy;
        ylabel('Channel');
    end;
    title('Original signal levels');
    subplot(212);
    if (N == 1)
        plot(theOutputTime,outRMSSignal);
        axis tight;
    else
        imagesc(theOutputTime,theChannels,outRMSSignal);
        colormap(1-gray);
        axis xy;
        ylabel('Channel');
    end;
    title('RMS levels');
    xlabel('Time (in s)');
end;

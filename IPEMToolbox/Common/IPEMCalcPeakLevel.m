function [outPeakSignal,outPeakFreq] = IPEMCalcPeakLevel (varargin)
% Usage:
%   [outPeakSignal,outPeakFreq] = ...
%     IPEMCalcPeakLevel(inSignal,inSampleFreq,inFrameWidth,
%                       inFrameInterval,inUseAbs,inPlotFlag)
%
% Description:
%   This function calculates the running maximum of the given signal:
%   a maximum is generated every inFrameInterval seconds over a period of  
%   inFrameWidth seconds.
%
% Input arguments:
%   inSignal = the input signal (if this is a matrix, peak values are calculated
%              for each channel (ie. row) in the signal)
%   inSampleFreq = the sample frequency of the input signal (in Hz)
%   inFrameWidth = the period over which the maximum is calculated (in s)
%   inFrameInterval = the period between two successive frames (in s)
%   inUseAbs = if non-zero, abs(inSignal) is used instead of the original input
%              if not specified or empty, 1 is used by default
%   inPlotFlag = if non-zero, plots are generated
%                if not specified or empty, 0 is used by default
%
% Output:
%   outPeakSignal = the running maximum value of the signal
%   outPeakFreq = the sample frequency of the maximum signal
%
% Example:
%   [s,fs] = IPEMReadSoundFile;
%   [Max,MaxFreq] = IPEMCalcPeakLevel(s,fs,0.020,0.010,1,1);
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
[inSignal,inSampleFreq,inFrameWidth,inFrameInterval,inUseAbs,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,5,{[],[],[],[],1,0});

% Get the dimensions of the input signal
[N,M] = size(inSignal);

% Convert time units to sample units
theStep = round(inFrameInterval/(1/inSampleFreq));
theWidth = round(inFrameWidth/(1/inSampleFreq));

% Init the output
outPeakSignal = zeros(N,round((M-theWidth+1)/theStep));

% Step through the signal and calculate the max value for each frame in each channel
k = 1;
if (inUseAbs)
	for i = 1:theStep:M-theWidth+1,
		outPeakSignal(:,k) = max(abs(inSignal(:,i:i+theWidth-1)),[],2);
		k = k + 1;
	end;
else
	for i = 1:theStep:M-theWidth+1,
		outPeakSignal(:,k) = max(inSignal(:,i:i+theWidth-1),[],2);
		k = k + 1;
	end;
end

% Also return the effective sample frequency of the output signal
outPeakFreq = inSampleFreq/theStep;

% Plot if needed
if (inPlotFlag ~= 0)
    theInputTime = (0:(M-1))/inSampleFreq;
    theOutputTime = (0:(size(outPeakSignal,2)-1))/outPeakFreq;
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
        plot(theOutputTime,outPeakSignal);
        axis tight;
    else
        imagesc(theOutputTime,theChannels,outPeakSignal);
        colormap(1-gray);
        axis xy;
        ylabel('Channel');
    end;
    if (inUseAbs)
		title('Peak levels (using absolute values of signal)');
	else
		title('Peak levels (using original signal)');
	end
    xlabel('Time (in s)');
end;

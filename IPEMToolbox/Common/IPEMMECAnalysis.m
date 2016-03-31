function [outValues,outValuesFreq,outPeriods] = IPEMMECAnalysis(varargin)
% Usage:
%   [outValues,outValuesFreq,outPeriods] = ...
%     IPEMMECAnalysis(inSignal,inSampleFreq,inMinPeriod,inMaxPeriod,...
%                     inStepSize,inHalfDecayTime,inPlotFlag)
%
% Description:
%   Performs a periodicity analysis of a (multi-channel) signal using the
%   Minimal Energy Change algorithm. This part calculates the difference
%   values. Use IPEMMECFindBestPeriods to find the best matching periods.
%
% Input arguments:
%   inSignal = (multi-channel) signal to be analyzed
%   inSampleFreq = sample frequency of inSignal (in Hz)
%   inMinPeriod = minimum period to look for (in s)
%                 if empty, 1/inSampleFreq is used by default
%   inMaxPeriod = maximum period to look for (in s)
%   inStepSize = interval between successive evaluations (in s)
%                if empty or not specified, 1/inSampleFreq is used by default
%                (this corresponds to a step size of 1 sample)
%   inHalfDecayTime = half decay time for leaky integration (in s)
%                     if empty or not specified, no integration is performed
%                     (this corresponds to inHalfDecayTime = 0)
%   inPlotFlag = if non-zero, plot will be generated
%                if empty or not specified, 0 is used by default
%
% Output:
%   outValues = cell array containing the calculated values for each channel
%               and for each period at each evaluated moment
%               (outValues{i}(j,k) represents the value calculated for the j-th
%               period at the time corresponding with index k for channel i)
%   outValuesFreq = sample frequency of outValues (in Hz)
%   outPeriods = column vector containing the periods for which values were
%                calculated (in s)
%
% Example:
%   [Values,ValuesFreq,Periods] = IPEMMECAnalysis(RMS,RMSFreq,0.5,5,[],1.5);
%
% Authors:
%   Koen Tanghe - 20010225
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

% Feedback
fprintf(1,'Start of MEC analysis...\n');

% Handle input arguments
[inSignal,inSampleFreq,inMinPeriod,inMaxPeriod,inStepSize,inHalfDecayTime,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,5,{[],[],[],[],[],0,0});

% Additional argument handling
if isempty(inStepSize)
    inStepSize = 1/inSampleFreq;
end
if isempty(inMinPeriod)
    inMinPeriod = 1/inSampleFreq;
end

% Get values in samples
MinPeriod = round(inSampleFreq*inMinPeriod);
MaxPeriod = round(inSampleFreq*inMaxPeriod);
StepSize = round(inSampleFreq*inStepSize);

% Initialize some variables
N = size(inSignal,2);
NumOfChannels = size(inSignal,1);
outValues = cell(NumOfChannels,1);
outValuesFreq = inSampleFreq/StepSize;
outPeriods = (MinPeriod:MaxPeriod)'/inSampleFreq;
NPrefixZeros = MaxPeriod;
Signal = [zeros(NumOfChannels,NPrefixZeros) inSignal];
NNew = N + NPrefixZeros;
Values = zeros(MaxPeriod-MinPeriod+1,length(NPrefixZeros+1:StepSize:NNew));

% Perform analysis for all channels
for Channel = 1:NumOfChannels
    
    % Feedback
    fprintf(1,'Channel %d (',Channel);
    
    % Start analysis (could be vectorized for faster execution)
    FeedbackTimeFactor = StepSize/inSampleFreq;
    Count = 0;
    for i = NPrefixZeros+1:StepSize:NNew
        
        % Calculate differences
        Count = Count + 1;
        for Period = MinPeriod:MaxPeriod
            Values(Period-MinPeriod+1,Count) = (Signal(Channel,i) - Signal(Channel,i-Period));
        end
        
        % Give some feedback
        if (mod(Count,100) == 0) fprintf(1,'%.2f ',Count*FeedbackTimeFactor); end;
    end
    
    % We're interested in the absolute value of the differences
    Values = abs(Values);
    
    % Perform leaky integration (if needed)
    if (inHalfDecayTime ~= 0)
        Values = IPEMLeakyIntegration(Values,outValuesFreq,inHalfDecayTime);
    end
    
    % Assign to output if needed
    outValues{Channel} = Values;
    
    % Feedback
    fprintf(1,'done)\n');
    
    % Plot if needed
    if (inPlotFlag)
        Time = (0:size(Values,2)-1)/outValuesFreq;
        figure;
        imagesc(Time,outPeriods,Values);
        axis xy;
        colormap(1-gray);
        colorbar;
        axis([Time(1) Time(end) 0 outPeriods(end)]);
        if (NumOfChannels == 1)
            title('Differences values over time');
        else
            title(sprintf('Differences values over time for channel %d',Channel));
        end
        xlabel('Time (s)');
        ylabel('Difference values');
    end
    
end

% Feedback
fprintf(1,'Done.\n');

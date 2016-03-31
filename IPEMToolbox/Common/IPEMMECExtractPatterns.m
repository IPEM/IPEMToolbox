function [outPatterns,outPatternLengths,outPatternFreq] = IPEMMECExtractPatterns (varargin)
% Usage:
%   [outPatterns,outPatternLenghts,outPatternFreq] = ...
%     IPEMMECExtractPatterns(inAnalyzedSignal,inSampleFreq,inPeriods,...
%                            inBestPeriodIndices,inAnalysisFreq,...
%                            inRescalePatterns,inPlotFlag);
%
% Description:
%   Extracts the best pattern from the original signal using the results
%   of an IPEMMECAnalysis run.
%
% Input arguments:
%   inAnalyzedSignal = (multi-channel) signal that was used for IPEMMECAnalysis
%   inSampleFreq = sample frequency of inAnalyzedSignal (in Hz)
%   inPeriods = column vector with the periods that were evaluated (in s)
%   inBestPeriodIndices = 2D matrix containing the indices in inPeriods of the
%                         best periods (each row represents a channel)
%                         (if inBestPeriodIndices is single-channel while
%                         inAnalyzedSignal is multi-channel, inBestPeriodIndices
%                         is used for each channel)
%   inAnalysisFreq = sample frequency of the IPEMMECAnalysis output (in Hz)
%   inRescalePatterns = if non-zero, the patterns are rescaled between 0 and 1
%                       if empty or not specified, 0 is used by default
%   inPlotFlag = if non-zero, plots are generated
%                if empty or not specified, 0 is used by default
%
% Output:
%   outPatterns = cell array containing the extracted patterns for each channel
%                 at each moment in time
%                 (outPatterns{i}(j,k) represents the j-th sample of the pattern
%                 extracted at the time corresponding with index k for channel i)
%   outPatternLengths = 2D array containing the length of the patterns in
%                       outPatterns (in samples) (each row represents a channel)
%   outPatternFreq = sample frequency of outPatterns (same as inAnalysisFreq)
%                    (each pattern itself is of course sampled at inSampleFreq)
%
% Remarks:
%   The input arguments inPeriods, inBestPeriodIndices and inAnalysisFreq are
%   direct results of IPEMMECAnalysis and IPEMMECFindBestPeriods.
%
% Example:
%   [P,PLengths,PFreq] = ...
%     IPEMMECExtractPatterns(RMS,RMSFreq,Periods,BestPeriodIndices,...
%                            AnalysisFreq,0,1);
%
% Authors:
%   Koen Tanghe - 20010925
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
fprintf(1,'Start of MEC pattern extraction... ');

% Handle input arguments
[inAnalyzedSignal,inSampleFreq,inPeriods,inBestPeriodIndices,inAnalysisFreq,inRescalePatterns,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,5,{[],[],[],[],[],0,0});

% Get periods in samples
MinPeriod = round(inSampleFreq*inPeriods(1));
MaxPeriod = round(inSampleFreq*inPeriods(end));
StepSize = round(inSampleFreq/inAnalysisFreq);

% Initialize some variables
NumOfChannels = size(inAnalyzedSignal,1);
MaxNumSamples = MaxPeriod;
[M,N] = size(inBestPeriodIndices);
if ((NumOfChannels ~= 1)&(M == 1))
    inBestPeriodIndices = repmat(inBestPeriodIndices,NumOfChannels,1);
end
outPatterns = cell(NumOfChannels,1);
outPatternLengths = round(inPeriods(inBestPeriodIndices)*inSampleFreq); % (rounding for perfect conversion from float to integer)
outPatternLengths = reshape(outPatternLengths,NumOfChannels,N);
outPatternFreq = inAnalysisFreq;
NPrefixZeros = MaxPeriod;
Signal = [zeros(NumOfChannels,NPrefixZeros) inAnalyzedSignal];
NNew = N + NPrefixZeros;

% Extract the patterns from all channels
for Channel = 1:NumOfChannels
    
    Pattern = zeros(MaxNumSamples,N);
    for i = 1:N
        % Extract pattern
        End = NPrefixZeros + (i-1)*StepSize;
        CurrentPattern = Signal(Channel,End-outPatternLengths(Channel,i)+1:End);
        
        % Rescale if needed
        if (inRescalePatterns) CurrentPattern = IPEMRescale(CurrentPattern,0,1); end
        
        % Rotate to account for phase
        Pattern(1:length(CurrentPattern),i) = IPEMRotateMatrix(CurrentPattern',End-NPrefixZeros,0);
    end
    outPatterns{Channel,1} = Pattern;
    
    % Plot if needed
    if (inPlotFlag)
        figure;
        Time = (0:N-1)./outPatternFreq;
        Periods = (inPeriods(end)-inPeriods(end-1))*(1:MaxNumSamples);
        imagesc(Time,Periods,outPatterns{Channel,1});
        axis xy;
        colormap(1-gray);
        colorbar;
        hold on;
        plot(Time,inPeriods(inBestPeriodIndices(Channel,:)),'red');
        hold off;
        if (NumOfChannels == 1)
            title('Extracted patterns');
        else
            title(sprintf('Extracted patterns for channel %d',Channel));
        end
        xlabel('Time (s)');
        ylabel('Pattern and duration (s)');
    end
    
end

% Feedback
fprintf(1,'Done.\n');

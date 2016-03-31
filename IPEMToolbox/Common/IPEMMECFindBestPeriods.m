function [outBestPeriodIndices,outSampleFreq] = IPEMMECFindBestPeriods(varargin)
% Usage:
%   [outBestPeriodIndices,outSampleFreq] = ...
%     IPEMMECAnalysis(inValues,inValuesFreq,inPeriods,inPlotFlag,...
%                     inMergeType,inDecisionType)
%
% Description:
%   Finds the best matching periods corresponding to the given values obtainded
%   from IPEMMECAnalysis.
%
% Input arguments:
%   inValues = cell array containing difference values from IPEMMECAnalysis
%   inValuesFreq = sample frequency for inValues
%   inPeriods = periods corresponding to the rows of the elements in inValues
%               (in s)
%   inPlotFlag = if non-zero, plot will be generated
%                if empty or not specified, 0 is used by default
%   inMergeType = type of merging in case of multi-channel input
%                 supported types are:
%                 'sum' = decision is made on sum of given values
%                 'separate' = decision is made for each channel separately
%                 if empty or not specified, 'sum' is used by default
%   inDecisionType = type of decision used to find the best matching periods
%                    supported types are:
%                    'min' = period corresponding to smallest difference value
%                    if empty or not specified, 'min' is used by default
%
% Output:
%   outBestPeriodIndices = indices corresponding to the best matching periods
%                          (so Periods(outBestPeriodIndices(i,j),1) is the best
%                          matching period for channel i at moment j, where
%                          Periods is the row matrix from IPEMMECAnalysis)
%   outSampleFreq = sample frequency of outBestPeriodIndices
%
% Remarks:
%   For a single channel inValues, the merge type has no influence of course.
%
% Example:
%   [Best,BestFreq] = IPEMMECAnalysis(Values,ValuesFreq,Periods,1);
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

% Handle input arguments
[inValues,inValuesFreq,inPeriods,inPlotFlag,inMergeType,inDecisionType] = ...
    IPEMHandleInputArguments(varargin,4,{[],[],[],0,'sum','min'});

% Get sizes
NumOfChannels = size(inValues,1);
N = size(inValues{1},2);
outSampleFreq = inValuesFreq;

% Find best periods
if strcmpi(inMergeType,'sum')
    
    % Handle sum of channels
    outBestPeriodIndices = zeros(1,N);
    Values = zeros(size(inValues{1}));
    for i = 1:NumOfChannels
        Values = Values + inValues{i};
    end
    outBestPeriodIndices(1,:) = FindIndices(Values,inDecisionType);
    
    % Plot if needed
    if (inPlotFlag)
        HFig = figure;
        Time = (0:N-1)/outSampleFreq;
        imagesc(Time,inPeriods,Values);
        axis xy;
        colormap(1-gray);
        colorbar;
        hold on;
        plot(Time,inPeriods(outBestPeriodIndices(1,:)),'red');
        axis([Time(1) Time(end) 0 inPeriods(end)]);
        title('Best periods over time');
        xlabel('Time (s)');
        ylabel('Best period (s)');
        hold off;
    end
    
elseif strcmpi(inMergeType,'separate')
    
    % Handle each channel separately
    outBestPeriodIndices = zeros(NumOfChannels,N);
    for i = 1:NumOfChannels
        outBestPeriodIndices(i,:) = FindIndices(inValues{i},inDecisionType);
        
        % Plot if needed
        if (inPlotFlag)
            HFig = figure;
            Time = (0:N-1)/outSampleFreq;
            imagesc(Time,inPeriods,inValues{i});
            axis xy;
            colormap(1-gray);
            colorbar;
            hold on;
            plot(Time,inPeriods(outBestPeriodIndices(i,:)),'red');
            axis([Time(1) Time(end) 0 inPeriods(end)]);
            title(sprintf('Best periods over time for channel %d',i));
            xlabel('Time (s)');
            ylabel('Best period (s)');
            hold off;
        end
    end
    
else
    
    error('ERROR: unsupported merge type used');
    
end

% ------------------------------------------------------------------------------

function outIndices = FindIndices(inValues,inDecisionType)
% Finds indices of best matching periods depending on single channel
% inValues and inDecisionType

if strcmpi(inDecisionType,'min')
    [MinValues,outIndices(1,:)] = min(inValues);
else
    error('ERROR: unsupported decision type used');
end

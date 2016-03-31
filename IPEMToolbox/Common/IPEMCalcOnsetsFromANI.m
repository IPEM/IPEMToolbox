function [outOnsetSignal, outOnsetFreq] = IPEMCalcOnsetsFromANI(varargin)
% Usage:
%   [outOnsetSignal,outOnsetFreq] =
%     IPEMCalcOnsetsFromANI(inANI,inANIFreq,inPlotFlag)
%
% Description:
%   This function calculates the onsets for a given signal represented by its 
%   auditory nerve image, using an integrate-and-fire neural net layer.
%
% Input arguments:
%   inANI = auditory nerve image to be processed
%   inANIFreq = sample frequency of auditory nerve image (in Hz)
%   inPlotFlag = if non-zero, a plot is generated at the end
%                if empty or not specified, 1 is used by default
%
% Output:
%   outOnsetSignal = signal having a non-zero value for an onset, and zero
%                    otherwise (the higher the non-zero value, the more our
%                    system is convinced that the onset is really an onset)
% 
% Example:
%   [OnsetSignal,OnsetFreq] = IPEMCalcOnsetsFromANI(ANI,ANIFreq);
%
% Authors:
%   Koen Tanghe - 20010122
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
[inANI,inANIFreq,inPlotFlag] = IPEMHandleInputArguments(varargin,3,{[],[],1});


% Calculate RMS signal
% --------------------
fprintf(1,'Calculating RMS signals of ANI...\n');
[RMS,RMSFreq] = IPEMCalcRMS(inANI,inANIFreq,0.029,0.0058);
clear inANI;


% Pre-filter RMS signal with a low-pass filter to eliminate small peaks
% ---------------------------------------------------------------------
fprintf(1,'Filtering RMS signals...\n');

% Setup LP filter
theCutOffFreq = 15; % Hz
[LPF_B, LPF_A] = butter(2,theCutOffFreq/(RMSFreq/2));
theFilteredRMS = filter(LPF_B,LPF_A,RMS')';

% Calculate delay of filtering
[H,T] = impz(LPF_B,LPF_A);
theDelayInSamples = find(H == max(H))-1;
theDelay = theDelayInSamples/RMSFreq;
fprintf(1,'(delay of filtered RMS signals is %.3f s)\n',theDelay);

if 1
    % Show the effect of filtering
    figure;
    Time = (0:size(RMS,2)-1)/RMSFreq;
    theChannel = 1:10:size(RMS,1);
    subplot(211); plot(Time,RMS(theChannel,:)');
    axis([0 max(Time) 0 Inf]);
    title('RMS values over some channels');
    subplot(212); plot(Time,theFilteredRMS(theChannel,:)');
    axis([0 max(Time) 0 Inf]);
    xlabel('Time (s)');
    title('Filtered RMS values over some channels');
    IPEMSetFigureLayout;
end   

RMS = theFilteredRMS(:,theDelayInSamples+1:size(theFilteredRMS,2));
clear theFilteredRMS;


% Detect relevant peaks in RMS signal of each channel
% ------------------------------------------------------------------------------
fprintf(1,'Detecting relevant peaks in channels...\n');
[Onsets,OnsetsFreq] = IPEMOnsetPeakDetection(RMS,RMSFreq,1);
clear RMS;


% Calculate onset pattern using integrate-and-fire NN
% ------------------------------------------------------------------------------
fprintf(1,'Calculating onset pattern using integrate-and-fire NN...\n');
UpsOnsets = resample(Onsets',16,1)'; % upsample
UpsOnsetsFreq = OnsetsFreq*16;
clear Onsets;
[OnsPatt,OnsPattFreq] = IPEMOnsetPattern(UpsOnsets,UpsOnsetsFreq);
clear UpsOnsets;

% Filter onset pattern
% ------------------------------------------------------------------------------
fprintf(1,'Filtering onset pattern...\n');
[FilteredOnsPatt,FilteredOnsPattFreq] = IPEMOnsetPatternFilter(OnsPatt,OnsPattFreq);
clear OnsPatt;

% Output the results
fprintf(1,'-> Finished calculating onsets\n');
outOnsetSignal = FilteredOnsPatt;
outOnsetFreq = FilteredOnsPattFreq;

% Plot if needed
if (inPlotFlag ~= 0)
   figure;
   plot((0:length(outOnsetSignal)-1)/outOnsetFreq,outOnsetSignal);
   axis([0 (length(outOnsetSignal)-1)/outOnsetFreq 0 1.25]);
   xlabel('Time (s)');
   ylabel('Detected onsets');
end

function [outChords,outToneCenters,outContextuality1,outContextuality2,outContextuality3] = IPEMContextualityIndex(varargin)
% Usage:
%   [outChords,outToneCenters,...
%    outContextuality1,outContextuality2,outContextuality3] = ...
%     IPEMContextualityIndex(inPeriodicityPitch,inSampleFreq,inPeriods,...
%                            inSnapShot,inHalfDecayChords,...
%                            inHalfDecayToneCenters,inEnlargement,inPlotFlag)
%
% Description:
%   This function calculates the contextuality index. Two methods are used:
%   - inspection: compares fixed chord images with running chord images
%                 and running tone center images
%   - comparison: compares running chord images with running tone center images
%
% Input arguments:
%   inPeriodicityPitch = periodicity pitch image
%   inSampleFreq = sample frequency of the input signal (in Hz)
%   inPeriods = periods of periodicity analysis (in s)
%   inSnapShot = time where the snapshot should be taken (in s)
%                if negative, the time is taken at abs(inSnapShot) from the end
%                of the sample
%                if empty or not specified, the time of the last sample is used
%                by default
%   inHalfDecayChords = half decay time for leaky integration into chord image
%                       if empty or not specified, 0.1 is used by default
%   inHalfDecayToneCenters = half decay time for leaky integration into tone
%                            center image
%                            if empty or not specified, 1.5 is used by default
%   inEnlargement = time by which the input signal is enlarged (in s) 
%                   if -1, 2*inHalfDecayToneCenters is used
%                   if empty or not specified, 0 is used by default
%   inPlotFlag = if non-zero, plots are generated
%                if empty or not specified, 0 is used by default
%
% Output:
%   outChords = local integration of inPeriodicityPitch into chord image
%   outToneCenters = global integration of inPeriodicityPitch into tone center
%                    image
%   outContextuality1 = correspondence between chord taken at snapshot position
%                       and running chord image
%   outContextuality2 = correspondence between chord taken at snapshot position
%                       and running tone center image
%   outContextuality3 = correspondence between running chord image and running
%                       tone center image
%
% Remarks:
%   Sample frequency of output signals is the same as inSampleFreq.
%
% Example:
%   [Chords,ToneCenters,Contextuality1,Contextuality2,Contextuality3] = ...
%     IPEMContextualityIndex(PP,PPFreq,PPPeriods);
%
% Authors:
%   Marc Leman - 19991221 (originally made)
%   Koen Tanghe - 20010129 (minor code changes + documentation)
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
[inPeriodicityPitch,inSampleFreq,inPeriods,inSnapShot,inHalfDecayChords,inHalfDecayToneCenters,inEnlargement,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,4,{[],[],[],[],0.1,1.5,0,0});
if (inEnlargement == -1)
    inEnlargement = 2*inHalfDecayToneCenters;
end
if isempty(inSnapShot)
    inSnapShot = (size(inPeriodicityPitch,2)-1)/inSampleFreq;
end

% Init some vars
if (inSnapShot >= 0)
    inSnapShotSamples = round(inSnapShot*inSampleFreq)+1;
else
    inSnapShotSamples = size(inPeriodicityPitch,2) - abs(round(inSnapShot*inSampleFreq));
end
[Rows,Columns] = size(inPeriodicityPitch);

% Perform leaky integration
outChords = IPEMLeakyIntegration(inPeriodicityPitch,inSampleFreq,inHalfDecayChords,inEnlargement,0);
outToneCenters = IPEMLeakyIntegration(inPeriodicityPitch,inSampleFreq,inHalfDecayToneCenters,inEnlargement,0);

% Calculate contextualities
outContextuality1 = [];
outContextuality2 = [];
outContextuality3 = [];
[ws,wf] = warning; warning('off'); % TBC - I hate this, and it should be avoided, but it's the only way to turn off the corrcoef warnings generated by this function...
for i = 1:size(outToneCenters,2)
    value1 = corrcoef(outChords(:,i),outChords(:,inSnapShotSamples));
    value2 = corrcoef(outToneCenters(:,i),outChords(:,inSnapShotSamples));
    value3 = corrcoef(outToneCenters(:,i),outChords(:,i));
    outContextuality1 = [outContextuality1 value1(1,2)];
    outContextuality2 = [outContextuality2 value2(1,2)];
    outContextuality3 = [outContextuality3 value3(1,2)];
end 
warning(ws); warning(wf); % Restore previous warning state and frequency

% Generate figures if needed
if (inPlotFlag)
    
    T = (0:size(outChords,2)-1)/inSampleFreq;
    
    % Pitch images
    figure;
    
    subplot(311);
    imagesc(T,inPeriods,[inPeriodicityPitch zeros(Rows,length(T)-Columns)]);
    title('Periodicity pitch');
    axis xy;
    axis([min(T) max(T) -inf inf]);
    ylabel('Period (in s)');
    
    subplot(312);
    imagesc(T,inPeriods,outChords);
    title('Local pitch image');
    axis xy;
    axis([min(T) max(T) -inf inf]);
    ylabel('Period (in s)');
    
    subplot(313);
    imagesc(T,inPeriods,outToneCenters);
    title('Global pitch image');
    axis xy;
    axis([min(T) max(T) -inf inf]);
    ylabel('Period (in s)');
    
    xlabel('Time (in s)');
    colormap(1-gray);
    IPEMSetFigureLayout;
    
    % Contextuality curves
    figure;
    
    subplot(311);
    plot(T,outContextuality1);
    axis([min(T) max(T) -1 1]);
    ylabel('Corr. coeff.');
    title('Local inspection');
    
    subplot(312);
    plot(T,outContextuality2);
    axis([min(T) max(T) -1 1]);
    ylabel('Corr. coeff.');
    title('Global inspection');
    
    subplot(313);
    plot(T,outContextuality3);
    axis([min(T) max(T) -1 1]);
    ylabel('Corr. coeff.');
    title('Comparison');
    
    xlabel('Time (in s)');
    colormap(1-gray);
    IPEMSetFigureLayout;
end

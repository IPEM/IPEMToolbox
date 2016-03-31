function [outOriginalSound,outResynthesizedSound,outSampleFreq,outDetectedPeriods,outIndividualSounds] = ...
    IPEMDemoStartMEC(varargin)
% Usage:
%   [outOriginalSound,outResynthesizedSound,outSampleFreq,outDetectedPeriods,...
%    outIndividualSounds] = ...
%     IPEMDemoStartMEC(inSoundFile,inSoundFilePath,inMinPeriod,inMaxPeriod,...
%                      inSelectionTime,inStep,inHalfDecayTime,...
%                      inResynthDuration,inRescalePatterns,...
%                      inPatternIntegrationTime,inEnhanceContrast,...
%                      inSaveMECResults,inUseMode);
%
% Description:
%   Starts an entire MEC analysis and resynthesis run for the given sound file.
%
% Input arguments:
%   inSoundFile = sound file to be processed
%   inSoundFilePath = path to the sound file
%                     if empty or not specified, IPEMRootDir('input')\Sounds
%                     is used by default
%   inMinPeriod = minimum period to look for (in s)
%                 if empty or not specified, 0.5 is used by default
%   inMaxPeriod = maximum period to look for (in s)
%                 if empty or not specified, 5 is used by default
%   inSelectionTime = selected moment in time to extract current pattern (in s)
%                     if empty or not specified, 3 is used by default
%   inStep = integer specifying number of samples between successive
%            calculations
%            if empty or not specified, 1 is used by default (every sample)
%   inHalfDecayTime = half decay time for leaky integration of energy
%                     differences (in s)
%                     if empty or not specified, 1.5 is used by default
%   inResynthDuration = duration (in s) of resynthesized sound
%                       if empty or not specified, 10 is used by default
%   inRescalePatterns = if non-zero, patterns are rescaled between 0 and 1
%                       if empty or not specified, 0 is used by default
%   inPatternIntegrationTime = half decay time for leaky integration of patterns
%                              (in s)
%                              if empty or not specified, 0 is used by default
%   inEnhanceContrast = if non-zero, the "contrast" in the resynthesized sound
%                       is enhanced (see IPEMMECSynthesis for more details on
%                       how this is done)
%                       if empty or not specified, 0 is used by default
%   inSaveMECResults = if non-zero, intermediate results of the analysis that
%                      are necessary for later resynthesis, are saved to a .mat
%                      file
%                      if zero, empty or not specified, results are not saved
%   inAnalysisType = if 1, the RMS of the sound signal is used
%                    if 2, the RMS of 10 ANI ch. (summed diff. values) is used
%                    if 3, the RMS of 10 ANI ch. (separate diff. values) is used
%                    if empty or not specified, 1 is used by default
%
% Output:
%   outOriginalSound = original sound
%   outResynthesizedSound = resynthesized sound
%   outSampleFreq = sample frequency for all returned sounds (Hz)
%   outDetectedPeriods = detected periods in each channel (in s)
%   outIndividualSounds = individual resynthesized sounds per channel
%
% Remarks:
%   If saving of intermediate results is requested, data is saved to a .mat file
%   with the name 'MEC_xxx.mat', where xxx is the name of the sound file without
%   extension. The location of this file will be IPEMRootDir('output').
%
% Example:
%   [s,ss,fs,periods,sschan] = ...
%     IPEMDemoStartMEC('ligeti.wav',[],0.4,5,3,2,1.5,10,1,0.5,1,1,1);
%
% Authors:
%   Koen Tanghe - 20020222
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
[inSoundFile,inSoundFilePath,inMinPeriod,inMaxPeriod,inSelectionTime,inStep,inHalfDecayTime,...
        inResynthDuration,inRescalePatterns,inPatternIntegrationTime,inEnhanceContrast,inSaveMECResults,inUseMode] = ...
    IPEMHandleInputArguments(varargin,2,{[],[],0.5,5,1,1,1.5,10,0,0,0,0,1});
if ~ismember(inUseMode,[1 2 3])
    error('ERROR: illegal use mode parameter (should be 1, 2 or 3)');
end

% Read sound file and let it hear
[s,fs] = IPEMReadSoundFile(inSoundFile,inSoundFilePath);
sound(s,fs);

ANIFilterFreqs = [];
NoiseBands = [];
switch (inUseMode)
case 1
    % Calculate RMS of sound signal
    [RMS,RMSFreq] = IPEMCalcRMS(s,fs,0.020,0.010,1);
case {2,3}
    % Calculate ANI of sound signal
    [ANI,ANIFreq,ANIFilterFreqs] = IPEMCalcANI(s,fs,[],1,[],10,3,1.5);
    NoiseBands = ANIFilterFreqs*[0.75 1.25];
    
    % Calculate RMS of ANI
    [RMS,RMSFreq] = IPEMCalcRMS(ANI,ANIFreq,0.020,0.010,0);
    OrgFreq = RMSFreq;
    figure;
    IPEMPlotMultiChannel(RMS,RMSFreq,'RMS in each channel','Time (in s)','Auditory channels (center freqs. in Hz)',14,ANIFilterFreqs,1);
end

% Analyze RMS signal using MEC
[Values,ValuesFreq,Periods] = IPEMMECAnalysis(RMS,RMSFreq,inMinPeriod,inMaxPeriod,inStep/RMSFreq,1.5,0);

% Find the best periods
switch (inUseMode)
case {1,2}
    [BestPeriodIndices,AnalysisFreq] = IPEMMECFindBestPeriods(Values,ValuesFreq,Periods,0,'sum','min');
    HFig = figure;
    plot((0:length(BestPeriodIndices)-1)/AnalysisFreq,Periods(BestPeriodIndices));
    axis([-inf inf 0 Periods(end)]);
    xlabel('Time (in s)');
    ylabel('Best period (in s)');
    title('Best period over time');
case 3
    [BestPeriodIndices,AnalysisFreq] = IPEMMECFindBestPeriods(Values,ValuesFreq,Periods,0,'separate','min');
    HFig = figure;
    IPEMPlotMultiChannel(Periods(BestPeriodIndices),AnalysisFreq,'Best period over time for each channel','Time (in s)','Auditory channels (center freqs. in Hz)',14,ANIFilterFreqs,1);
end

% Extract patterns for all channels and integrate if needed
if (inPatternIntegrationTime == 0)
    [P,PLengths,PFreq] = IPEMMECExtractPatterns(RMS,RMSFreq,Periods,BestPeriodIndices,AnalysisFreq,inRescalePatterns,1);
else
    [P,PLengths,PFreq] = IPEMMECExtractPatterns(RMS,RMSFreq,Periods,BestPeriodIndices,AnalysisFreq,inRescalePatterns,0);
    fprintf(1,'Integrating patterns... ');
    P = IntegratePatterns(P,PFreq,inPatternIntegrationTime,Periods,BestPeriodIndices,RMSFreq);
    fprintf(1,'Done.\n');
end

% Set layout
IPEMSetFigureLayout('all');

% Save intermediate results if requested
if (inSaveMECResults)
    [Path,Name] = fileparts(inSoundFile);
    IPEMMECSaveResults(sprintf('MEC_%s.mat',Name),IPEMRootDir('output'),s,fs,Periods,BestPeriodIndices,AnalysisFreq,...
        P,PLengths,PFreq,RMSFreq,NoiseBands,ANIFilterFreqs);
end

% Resynthesize sound
[outResynthesizedSound,outDetectedPeriods,outIndividualSounds] = ...
    IPEMMECSynthesis(P,PLengths,PFreq,RMSFreq,inSelectionTime,inResynthDuration,fs,NoiseBands,-20,1,[],1);

% Play the resynthesized sound
wavplay(outResynthesizedSound,fs,'async');

% Set layout for all figures
IPEMSetFigureLayout('all');

% Return output
outOriginalSound = s;
outSampleFreq = fs;

% ------------------------------------------------------------------------------

function outP = IntegratePatterns (inP,inPFreq,inPatternIntegrationTime,inPeriods,inBestPeriodIndices,inOriginalFreq)
% Local sub function for integrating (and plotting) the extracted patterns

% Integrate patterns
NumOfChannels = length(inP);
for i = 1:NumOfChannels
    outP{i} = IPEMLeakyIntegration(inP{i},inPFreq,inPatternIntegrationTime,[],0);
end

% Make best periods same for all channels if only one row was given
if (NumOfChannels ~= 1)&(size(inBestPeriodIndices,1) == 1)
    inBestPeriodIndices = repmat(inBestPeriodIndices,NumOfChannels,1);
end

% Plot figures
Time = (0:size(inP{1},2)-1)/inPFreq;
MaxNumSamples = round(inPeriods(end)*inOriginalFreq); % (rounding just for perfect conversion of real to integer)
Periods = (inPeriods(end)-inPeriods(end-1))*(1:MaxNumSamples);
for Channel = 1:length(inP)
    
    figure;
    
    subplot(211);
    imagesc(Time,Periods,inP{Channel});
    colormap(1-gray);
    colorbar;
    hold on;
    plot(Time,inPeriods(inBestPeriodIndices(Channel,:)),'red');
    hold off;
    axis xy;
    if (length(inP) == 1) title('Original extracted patterns');
    else          title(sprintf('Original extracted patterns for channel %d',Channel));
    end
    ylabel('Pattern and duration (s)');
    
    subplot(212);
    imagesc(Time,Periods,outP{Channel});
    colormap(1-gray);
    colorbar;
    hold on;
    plot(Time,inPeriods(inBestPeriodIndices(Channel,:)),'red');
    hold off;
    axis xy;
    if (length(inP) == 1) title('Integrated extracted patterns');
    else          title(sprintf('Integrated extracted patterns for channel %d',Channel));
    end
    xlabel('Time (s)');
    ylabel('Pattern and duration (s)');
end

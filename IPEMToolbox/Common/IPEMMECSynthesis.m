function [outResynthesizedSound,outDetectedPeriods,outIndividualSounds] = IPEMMECSynthesis(varargin)
% Usage:
%   [outResynthesizedSound,outDetectedPeriods,outIndividualSounds] = ...
%     IPEMMECSynthesis(inPatterns,inPatternLengths,inPatternFreq,...
%                      inOriginalSignalFreq,inSelectionTime,inDuration,...
%                      inOutputFreq,inNoiseBands,indBLevel,inEnhanceContrast,...
%                      inReSynthWidth,inPlotFlag);
%
% Description:
%   Generates an AM modulated noise signal constructed from a repetition of the
%   pattern found at the specified time moment.
%
% Input arguments:
%   inPatterns = the patterns extracted from the original signal
%   inPatternLengths = the lengths of the patterns in inPatterns (in samples) 
%   inPatternFreq = sample frequency for inPatterns (in Hz)
%   inOriginalSignalFreq = sample frequency of the contents of the patterns
%                          (in Hz)
%   inSelectionTime = moment in time specifying the pattern to be used (in s)
%   inDuration = wanted duration of the synthesized sound (in s)
%                if empty or not specified, 3 times the maximum pattern length
%                is used by default
%   inOutputFreq = wanted sample frequency (in Hz)
%                  if empty or not specified, 22050 is used by default
%   inNoiseBands = 2 column matrix with wanted noise bands, one row per channel
%                  (in Hz)
%                  if empty or not specified, broad band noise is used by default
%   indBLevel = wanted dB level for the resynthesized sound (in dB)
%               if empty or not specified, -20 dB is used by default
%   inEnhanceContrast = if non-zero, the pattern used for modulation of a noise
%                       band is first reshaped according to:
%                       ((P/max(abs(P))).^3)*max(abs(P))
%                       if empty or not specified, 0 is used by default
%   inReSynthWidth = if non-zero, specifies the width of one piece of
%                    resynthesized noise in samples
%                    (see IPEMGenerateBandPassedNoise for more details)
%                    if empty or not specified, the entire wanted duration
%                    is used by default
%   inPlotFlag = if non-zero, plot are generated
%                if empty or not specified, 0 is used by default
%
% Output:
%   outResynthesizedSound = the resynthesized sound
%   outDetectedPeriods = duration of the periodic patterns that were used in
%                        each channel (in s)
%   outIndividualSounds = resynthesized sounds per channel
%
% Example:
%   [ss,periods,sschan] = IPEMMECSynthesis(P,PL,PFreq,RMSFreq,3,10,22050);
%
% Authors:
%   Marc Leman - 20000907 (original prototype version)
%   Koen Tanghe - 20010926 (code generalization + documentation)
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
fprintf(1,'Start of MEC resynthesis...\n');

% Handle input arguments
[inPatterns,inPatternLengths,inPatternFreq,inOriginalSignalFreq,inSelectionTime,inDuration,inOutputFreq,...
        inNoiseBands,indBLevel,inEnhanceContrast,inReSynthWidth,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,6,{[],[],[],[],[],[],22050,[],-20,0,[],0});

% Initialize some variables and perform additional argument checking
NumOfChannels = size(inPatternLengths,1);
TimeIndex = round(inSelectionTime*inPatternFreq)+1;
outIndividualSounds = [];
if isempty(inDuration)
    inDuration = 3*size(inPatterns{1},1)/inOriginalSignalFreq;
end
if isempty(inNoiseBands)
    inNoiseBands = repmat([0 inOutputFreq/2],NumOfChannels,1);
end

% Handle all channels
for Channel = 1:NumOfChannels
    
    % Feedback
    fprintf(1,'Channel %d... ',Channel);
    
    % Get the selected pattern
    Pattern = inPatterns{Channel}(1:inPatternLengths(Channel,TimeIndex),TimeIndex)';
    PatternDuration = length(Pattern)/inOriginalSignalFreq;
    outDetectedPeriods(Channel) = PatternDuration;
    
    % Repeat pattern and interpolate to obtain modulation signal
    RepPattern = repmat(Pattern,1,ceil(inDuration/PatternDuration));
    RPL = length(RepPattern);
    ML = round(RPL*inOutputFreq/inOriginalSignalFreq);
    Modulation = interp1((0:RPL-1)/inOriginalSignalFreq,RepPattern,(0:ML-1)/inOutputFreq);
    Modulation = Modulation(1:round(inDuration*inOutputFreq));
    
    % Generate noise signal
    theNoise = IPEMGenerateBandPassedNoise(inNoiseBands(Channel,:),inDuration,inOutputFreq,-20,inReSynthWidth);
    
    % Enhance contrast if requested
    if (inEnhanceContrast)
        theNorm = max(abs(Modulation));
        if (theNorm)
            Modulation = ((Modulation/theNorm).^3)*theNorm;
        end
    end
    
    % Modulate noise with repeated pattern
    outIndividualSounds(Channel,:) = Modulation.*theNoise;
    
    % Feedback
    fprintf(1,'Done.\n');
end

% Mix all sounds together and adapt level
outResynthesizedSound = IPEMAdaptLevel(sum(outIndividualSounds,1),indBLevel);

% Plot if needed
if (inPlotFlag)
    if (NumOfChannels ~= 1)
        figure;
        IPEMPlotMultiChannel(outIndividualSounds,inOutputFreq,'Resynthesized sounds','Time (in s)','Channels',14,[],[],[],[],2);
    end
    figure;
    plot((0:length(outResynthesizedSound )-1)/inOutputFreq,outResynthesizedSound );
    title('Resynthesized sound');
    xlabel('Time (in s)');
end

% Feedback
fprintf(1,'Done.\n');

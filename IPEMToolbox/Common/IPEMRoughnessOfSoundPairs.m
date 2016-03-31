function [outMeanRoughness,outSortedList,outRoughness,outRoughnessFreq,outUsedSection] = ...
    IPEMRoughnessOfSoundPairs (varargin)
% Usage:
%   [outMeanRoughness,outSortedList,outRoughness,outRoughnessFreq,...
%    outUsedSection] = ...
%      IPEMRoughnessOfSoundPairs(inFiles,inPaths,inSection,...
%                                inSaveSoundCombinations,inOutputPath,...
%                                inUseReference,inPlotFlag)
%
% Description:
%   Calculates roughness of 2-by-2 combinations of sounds.
%
% Input arguments:
%   inFiles = set of sound files to be analyzed (cell array of strings)
%   inPaths = paths for the sound files
%             either a cell array of strings containing a path for each sound
%             file, or a single character array containing one path for all
%             sound files
%             if empty or not specified, IPEMRootDir('input')\Sounds is used
%             by default
%   inSection = section of the sound to be used (given as [start end] in s,
%               where Inf for the end parameter means the minimum of all sound
%               file lengths)
%               if empty or not specified, the (minimum of the) full length of
%               the sounds is used by default
%   inSaveSoundCombinations = if non-zero, the sound combinations are saved to
%                             inOutputPath
%                             if empty or not specified, 1 is used by default
%   inOutputPath = path where the sound combinations should be stored
%                  if empty or not specified, IPEMRootDir('output') is used
%                  by default
%   inUseReference = if non-zero, a reference value is used depending on the dB
%                    level (see IPEMGetRoughnessFFTReference)
%                    if empty or not specified, 0 is used by default 
%   inPlotFlag = if non-zero, plots outRoughness as a 2D map
%                if empty or not specified, 1 is used by default
%
% Output:
%   outMeanRoughness = mean of outRoughness over the complete section
%   outSortedList = sound combinations sorted according to roughness:
%                      column 1 = roughness
%                      columns 2 and 3 = number of the first resp. second sound
%   outRoughness = 3D matrix containing the calculated roughness over the
%                  combinations of sounds, where element outRoughness(i,j,:) 
%                  are the roughness values calculated over the combination
%                  of sound i with sound j
%   outRoughnessFreq = sample frequency of outRoughness (Hz)
%   outUsedSection = section of the sound that was eventually used
%                    (same as inSection, except when inSection(2) = Inf)
%
% Remarks:
%   1. The sound signals (say s1 and s2) are mixed as follows:
%        s1 = IPEMAdaptLevel(s1,-20); s2 = IPEMAdaptLevel(s2,-20);
%        s = IPEMAdaptLevel(s1+s2,-20);
%   2. All sound files should be of the same sample frequency...
%
% Example:
%   theFiles = {'sound1.wav','sound2.wav','sound3.wav'};
%   thePaths = {'E:\Koen\Data','e:\Koen\Data','e:\Koen\Data\Sounds\New'};
%   [MeanRoughness,SortedList] = ...
%     IPEMRoughnessOfSoundPairs(theFiles,thePaths,[0.2 Inf]);
%
% Authors:
%   Koen Tanghe - 20011004
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
[inFiles,inPaths,inSection,inSaveSoundCombinations,inOutputPath,inUseReference,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,1,{[],fullfile(IPEMRootDir('input'),'Sounds'),[],1,IPEMRootDir('output'),0,1});

% Additional checking
if isempty(inFiles)
    error('ERROR: You should specify the files you want to analyze !');
end

% Check length of sound files with section
NSounds = length(inFiles);
if iscell(inPaths)
    NPaths = length(inPaths);
    if (NPaths ~= NSounds)
        error('ERROR: Number of sounds and number of paths is not the same !');
    end
else
    NPaths = 1;
end
for i = 1:NSounds
    if (NPaths == 1)
        Path = inPaths;
    else
        Path = inPaths{i};
    end
    [empty,SampleFreqs(i),theSize] = IPEMReadSoundFile(inFiles{i},Path,'size');
    Durations(i) = theSize(1)/SampleFreqs(i);
    [aaa,Names{i}] = fileparts(inFiles{i});
end
MinDur = min(Durations);
if isempty(inSection)
    inSection = [0 MinDur];
else
    if (inSection(2) == Inf)
        inSection(2) = MinDur;
    end
    if ((inSection <= MinDur) ~= [1 1])
        error(sprintf(['ERROR: the section you specified is invalid for some of the selected sound files\n' ...
                       '       (the shortest sound file is %5.3f s long)'],MinDur));
    end
end
outUsedSection = inSection;

% Check for equal sample frequency
if (length(unique(SampleFreqs)) ~= 1)
    error('ERROR: All sound files should have the same sample frequency...');
end

% Setup output path if needed
if (inSaveSoundCombinations)
    IPEMEnsureDirectory(inOutputPath);
end

% Start calculations for all combinations
SectionStr = sprintf('[%5.3f-%5.3f]',inSection(1),inSection(2));
for i = 1:NSounds
    
    for j = i:NSounds
        
        % Read the sounds
        if (NPaths == 1)
            Path1 = inPaths;
            Path2 = inPaths;
        else
            Path1 = inPaths{i};
            Path2 = inPaths{j};
        end
        [s1,fs] = IPEMReadSoundFile(inFiles{i},Path1,inSection);
        [s2,fs] = IPEMReadSoundFile(inFiles{j},Path2,inSection);
        
        % Adapt the levels and setup the combination
        s1 = IPEMAdaptLevel(s1,-20);
        s2 = IPEMAdaptLevel(s2,-20);
        s = IPEMAdaptLevel(s1+s2,-20);
        
        % For keeping track whether clipping occured or not...
        if ((max(s) > 1) | (min(s) < -1)) Clipping(i,j) = 1; else Clipping(i,j) = 0; end;
        
        % Get the level and the reference value for this level if needed
        if  (inUseReference)
            L = IPEMGetLevel(s);
            RoughnessRef = IPEMGetRoughnessFFTReference(L,length(s)/fs);
        else
            RoughnessRef = 1;
        end
        
        % Write combinations to a wav file if needed
        if (inSaveSoundCombinations)
            OutputFileName = sprintf('Roughness_%s_%s_%s.wav',Names{i},Names{j},SectionStr);
            OutputFile = fullfile(inOutputPath,OutputFileName);
            wavwrite(s,fs,OutputFile);
        end
        
        % Calc ANI and from there roughness
        [ANI,ANIFreq,ANIFilterFreqs] = IPEMCalcANI(s,fs,[],0);
        [Roughness,outRoughnessFreq] = IPEMRoughnessFFT(ANI,ANIFreq,ANIFilterFreqs,[],[],0);
        Roughness = Roughness/RoughnessRef;
        
        % Store Roughness values over combination and also the mean
        outRoughness(i,j,:) = Roughness;
        outRoughness(j,i,:) = Roughness;
        
    end
    
end
outMeanRoughness = mean(outRoughness,3);

% Sort combinations according to Roughness
Count = 1;
for i = 1:NSounds
    for j = i:NSounds
        RoughnessPairs(Count,:) = [outMeanRoughness(i,j) i j];
        Count = Count + 1;
    end
end
outSortedList = sortrows(RoughnessPairs,1);

% Plot results if needed
if (inPlotFlag)
    
    % Show clipping map if clipping occured
    if (max(max(Clipping)) == 1)
        figure;
        himage = image(Clipping+1);
        title('Clipping occured for the sound pairs at the black spots');
        colormap([1 1 1 ; 0 0 0]);
        haxis = get(himage,'Parent');
        set(haxis,'XTickMode','manual');
        set(haxis,'XTick',1:NSounds);
        set(haxis,'YTickMode','manual');
        set(haxis,'YTick',1:NSounds);
    end
    
    % Show Roughness map
    h = figure;
    himage = imagesc(outMeanRoughness);
    haxis = get(himage,'Parent');
    colormap(1-gray);
    colorbar;
    xlabel('Sound1');
    ylabel('Sound2');
    title(sprintf('Roughness for pairs of sounds (%s to %s s)',num2str(inSection(1)),num2str(inSection(2))));
    IPEMSetFigureLayout;
    ColorThreshold = (max(max(outMeanRoughness))+min(min(outMeanRoughness)))/2;
    for i=1:NSounds 
        for j=1:NSounds 
            htext = text(i,j,sprintf('%.3g',outMeanRoughness(i,j)),'fontsize',6);
            if (outMeanRoughness(i,j) > ColorThreshold)
                set(htext,'color',[1 1 1]);
            end
        end
    end
    set(haxis,'XTickMode','manual');
    set(haxis,'XTick',1:NSounds);
    set(haxis,'YTickMode','manual');
    set(haxis,'YTick',1:NSounds);
    
end

function IPEMDemoMECRhythmExtraction
% Usage:
%   IPEMDemoMECRhythmExtraction
%
% Description:
%   Starts the demonstration of the MEC algorithm used for the extraction of
%   rhythmic patterns in sound.
%
% Authors:
%   Koen Tanghe - 20020912
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

StopDemo = 0;
while (~StopDemo)
    
    % Show introduction
    clc;
    fprintf(1,'Demo: Rhythmic pattern extraction in sounds using MEC algorithm\n');
    fprintf(1,'===============================================================\n');
    fprintf(1,'\n');
    fprintf(1,'This demo is an application of the MEC algorithm of the IPEM Toolbox.\n');
    fprintf(1,'It takes a sound fragment and performs a MEC analysis to detect\n');
    fprintf(1,'the most prominent period in the signal.\n');
    fprintf(1,'This is done by analysing the RMS signal of several auditory channels\n');
    fprintf(1,'(or of the sound signal itself) with the MEC algorithm.\n');
    fprintf(1,'It also extracts the pattern it finds with that "best period",\n');
    fprintf(1,'and uses it to resynthesize the rhythmic pattern using AM modulated\n');
    fprintf(1,'bandpassed noise.\n');
    fprintf(1,'\n');
    fprintf(1,'In the directory containing this demo,\n');
    fprintf(1,'%s,\n',fileparts(which('IPEMDemoMECRhythmExtraction.m')));
    fprintf(1,'you will find a few sound files to start with:\n');
    fprintf(1,'- BartokScherzoSuiteOp14.wav:\n');
    fprintf(1,'  beginning of the second movement ''Scherzo'' from ''Suite op.14''\n');
    fprintf(1,'  by Béla Bartók (piano).\n');
    fprintf(1,'- TomWaitsBigInJapan.wav:\n');
    fprintf(1,'  fragment from ''Big in Japan'' by Tom Waits (voice, drums,\n');
    fprintf(1,'  bass, electric guitar)\n');
    fprintf(1,'- PhotekTheLightening.wav:\n');
    fprintf(1,'  fragment from ''The Lightnening (Digital Remix)''\n');
    fprintf(1,'  by Photek (electronic, drum and bass)\n');
    fprintf(1,'\n');
    
    % Let user decide what to do next
    Result = menu('Choose what you want to do:',...
        'Test a sound file', ...
        'End this demo');
    if isempty(Result)
        StopDemo = 1;
    else
        switch (Result)
        case 1,
            StartInteract;
        case 2,
            StopDemo = 1;
        end
    end
    close all;
end

% ------------------------------------------------------------------------------

function StartInteract
% Lets user process his/her own sounds

Steps = { ...
        'Step 1: select a sound file' ; ...
        'Step 2: specify some parameters for the MEC analysis' ; ...
        'Step 3: start the MEC analysis and extract the patterns' ; ...
        'Step 4: select a moment in time for resynthesis' };

clc;
fprintf(1,'Test a sound file\n');
fprintf(1,'=================\n');
fprintf(1,'\n');
fprintf(1,'This part of the demo consists of the following steps:\n');
for i = 1:size(Steps,1)
    fprintf(1,'  %s\n',Steps{i});
end
fprintf(1,'Press a key to proceed...\n');
pause;

% Step1
% -----
% Text
clc;
fprintf(1,'%s\n',Steps{1});
fprintf(1,'%s\n\n',repmat('-',1,length(Steps{1})));
fprintf(1,'Please select the sound file you would like to use.\n');
fprintf(1,'Remember that the analysis will only give relevant results\n');
fprintf(1,'if the sound does indeed contain some repetitive pattern...\n');

% Action
OldDir = cd;
SoundsDir = fullfile(IPEMRootDir('input'),'Sounds');
if (IPEMEnsureDirectory(SoundsDir,0))
    cd(SoundsDir);
end
[File,FilePath] = uigetfile('*.wav', 'Select sound file:');
cd(OldDir);
if (File == 0)
    return;
end;


% Step2
% -----
% Text and action
clc;
fprintf(1,'%s\n',Steps{2});
fprintf(1,'%s\n\n',repmat('-',1,length(Steps{2})));
fprintf(1,'The sound file you just selected will be analyzed using the MEC algorithm.\n\n');

fprintf(1,'You can now specify the range of periods that should be searched by this\n');
fprintf(1,'algorithm. Specify a minimum and maximum period in seconds.\n');
fprintf(1,'If don''t enter a value, the shown default value will be used.\n');
fprintf(1,'The larger the range, the slower the analysis will be.\n');
MinPeriod = input('Minimum period (default is 0.5 s) ? ');
MaxPeriod = input('Maximum period (default is 4 s) ? ');
if isempty(MinPeriod) MinPeriod = 0.5; end;
if isempty(MaxPeriod) MaxPeriod = 4; end;
fprintf(1,'\n');

fprintf(1,'Choose what you want MEC to analyze:\n');
fprintf(1,'(1) the RMS of the sound signal\n');
fprintf(1,'(2) the RMS of 10 auditory channels (summed diff. values)\n');
fprintf(1,'(3) the RMS of 10 auditory channels (separate diff. values)\n');
UseMode = -1;
while ~ismember(UseMode,[1 2 3])
    UseMode = input('Your choice (1, 2 or 3, default is 1) ? ');
    if isempty(UseMode) UseMode = 1; end;
end    
fprintf(1,'\n');

fprintf(1,'You can also specify a speed-up factor n which is used to step through the\n');
fprintf(1,'analyzed signal at a higher pace (values are calculated every n samples)\n');
Step = 0;
while ((Step <= 0) | (Step ~= round(Step)))
    Step = input('Speed-up factor (positive integer, default is 1) ? ');
    if isempty(Step) Step = 1; end;
end    
fprintf(1,'\n');

fprintf(1,'The patterns can be integrated over time after the analysis and extraction.\n');
fprintf(1,'This accounts for a build-up effect of the patterns and eliminates small\n');
fprintf(1,'fluctuations in favor of a more stable pattern.\n');
PatternIntegration = -1;
while (PatternIntegration < 0)
    PatternIntegration = input('Pattern integration time (in s, default is 0: no integration) ? ');
    if isempty(PatternIntegration) PatternIntegration = 0; end;
end    
fprintf(1,'\n');


% Step3
% -------------------------------------------------------
% Text
clc;
fprintf(1,'%s\n',Steps{3});
fprintf(1,'%s\n\n',repmat('-',1,length(Steps{3})));
fprintf(1,'The MEC algorithm will now look for the best period over time in the sound signal.\n');
switch (UseMode)
case 1
    fprintf(1,'The analysis starts off with the calculation of the RMS of the sound signal\n');
    fprintf(1,'using IPEMCalcRMS. The RMS signal is then fed into IPEMMECAnalysis, and using\n');
    fprintf(1,'the best periods coming out of this analysis, IPEMMECExtractPatterns further\n');
    fprintf(1,'extracts the corresponding patterns from the RMS signal.\n');
case 2
    fprintf(1,'The analysis starts off with the calculation of the auditory nerve image of\n');
    fprintf(1,'the sound signal using IPEMCalcANI.\n');
    fprintf(1,'Then the RMS of the resulting ANI is calculated with IPEMCalcRMS and this multi-\n');
    fprintf(1,'channel signal is fed into IPEMMECAnalysis.\n');
    fprintf(1,'The best periods are calculated from the summed difference values over all channels.\n');
    fprintf(1,'IPEMMECExtractPatterns then extracts the patterns from the RMS signals, using\n');
    fprintf(1,'the same best periods for all channels.\n');
case 3
    fprintf(1,'The analysis starts off with the calculation of the auditory nerve image of\n');
    fprintf(1,'the sound signal using IPEMCalcANI.\n');
    fprintf(1,'Then the RMS of the resulting ANI is calculated with IPEMCalcRMS and this multi-\n');
    fprintf(1,'channel signal is fed into IPEMMECAnalysis.\n');
    fprintf(1,'The best periods are calculated for each channel separately.\n');
    fprintf(1,'IPEMMECExtractPatterns then extracts the patterns from the RMS signals, using\n');
    fprintf(1,'the best periods found for each channel.\n');
end
fprintf(1,'All of the above mentioned functions are part of the IPEM Toolbox.\n');
fprintf(1,'For more details about their different parameters, see help.\n');
fprintf(1,'\n');
fprintf(1,'Press a key to start the analysis...\n');
fprintf(1,'Note: this may take some time (especially when using auditory nerve images)...\n\n');
pause;

% Action

% Read sound file and let it hear
[s,fs] = IPEMReadSoundFile(File,FilePath);
sound(s,fs);

ANIFilterFreqs = [];
NoiseBands = [];
switch (UseMode)
case 1
    % Calculate RMS of sound signal
    [RMS,RMSFreq] = IPEMCalcRMS(s,fs,0.020,0.010,1);
case {2,3}
    % Calculate ANI of sound signal
    [ANI,ANIFreq,ANIFilterFreqs] = IPEMCalcANI(s,fs,[],1,[],10,3,1.5);
    NoiseBands = ANIFilterFreqs*[0.75 1.25];
    
    % Calculate RMS of ANI
    [RMS,RMSFreq] = IPEMCalcRMS(ANI,ANIFreq,0.020,0.010,0);
    figure;
    IPEMPlotMultiChannel(RMS,RMSFreq,'RMS in each channel','Time (in s)','Auditory channels (center freqs. in Hz)',14,ANIFilterFreqs,1);
end

% Analyze RMS signal using MEC
[Values,ValuesFreq,Periods] = IPEMMECAnalysis(RMS,RMSFreq,MinPeriod,MaxPeriod,Step/RMSFreq,1.5,0);

% Find the best periods
switch (UseMode)
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
if (~PatternIntegration)
    [P,PLengths,PFreq] = IPEMMECExtractPatterns(RMS,RMSFreq,Periods,BestPeriodIndices,AnalysisFreq,0,1);
else
    [P,PLengths,PFreq] = IPEMMECExtractPatterns(RMS,RMSFreq,Periods,BestPeriodIndices,AnalysisFreq,0,0);
    fprintf(1,'Integrating patterns... ');
    P = IntegratePatterns(P,PFreq,PatternIntegration,Periods,BestPeriodIndices,RMSFreq);
    fprintf(1,'Done.\n');
end

% Set layout
IPEMSetFigureLayout('all');

% More text
clc;
fprintf(1,'\n');
fprintf(1,'The generated figures show the following information:\n');
switch (UseMode)
case 1
    fprintf(1,'- the RMS of the sound signal\n');
    fprintf(1,'- the best period (over time) found by the MEC analysis\n');
    if (PatternIntegration)
        fprintf(1,'- the integrated extracted patterns (over time)\n');
    else
        fprintf(1,'- the extracted patterns (over time)\n');
    end
case {2,3}
    fprintf(1,'- the auditory nerve image (ANI) of the sound signal\n');
    fprintf(1,'- the RMS of the ANI\n');
    fprintf(1,'- the best period (over time) found by the MEC analysis\n');
    if (PatternIntegration)
        fprintf(1,'- the integrated extracted patterns (over time) for each channel (several figures)\n');
    else
        fprintf(1,'- the extracted patterns (over time) for each channel (several figures)\n');
    end
end
fprintf(1,'\n');
fprintf(1,'Press a key to continue...\n');
pause;

% Step4
% -------------------------------------------------------
% Text
clc;
fprintf(1,'%s\n',Steps{4});
fprintf(1,'%s\n\n',repmat('-',1,length(Steps{3})));

% Show instructions
UIText(UseMode);

if 0
    IPEMMECSaveResults('MECResults.mat',IPEMRootDir('output'),...
        s,fs,Periods,BestPeriodIndices,AnalysisFreq,...
        P,PLengths,PFreq,RMSFreq,NoiseBands,ANIFilterFreqs);
end

% Start ReSynthUI
UIData = struct(...
    'Sound',s,'SampleFreq',fs,'Periods',Periods,'BestPeriodIndices',BestPeriodIndices,'AnalysisFreq',AnalysisFreq,...
    'P',{P},'PLengths',PLengths,'PFreq',PFreq,'OriginalFreq',RMSFreq,'NoiseBands',NoiseBands);
switch (UseMode)
case 1,
    UIData = setfield(UIData,'ANIFilterFreqs',[]);
case {2,3}
    UIData = setfield(UIData,'ANIFilterFreqs',ANIFilterFreqs);
end
IPEMMECReSynthUI('Start',UIData);


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

% ------------------------------------------------------------------------------

function UIText(inUseMode)
% Local subfunction for displaying the text for the user interface

fprintf(1,'You can now select a moment in time for which you would like to use\n');
fprintf(1,'the extracted pattern to resynthesize the rhythmic pattern.\n');
fprintf(1,'The resynthesis is done by modulating different noisebands with\n');
fprintf(1,'the extracted pattern of the corresponding channel.\n');
if (inUseMode)
    fprintf(1,'Since you chose to use the RMS of the sound signal itself, broad band noise\n');
    fprintf(1,'will be used as carrier signal.\n');
end
fprintf(1,'This AM noise is then repeated several times so that the resulting\n');
fprintf(1,'sound sequence becomes as long as the original sound.\n\n');
fprintf(1,'Note that since the generated sound is simply a repetition of the\n');
fprintf(1,'extracted pattern, it might not be aligned with all parts of the\n');
fprintf(1,'entire sound file, especially when pauses occur or tempo changes...\n');
fprintf(1,'\n');

% Show instructions
fprintf(1,'Click somewhere in the figure to select a moment in time for which the\n');
fprintf(1,'extracted pattern(s) should be used to resynthesize a rhythm.\n');
fprintf(1,'Then press ''resynthesize for selected time'' to perform the resynthesis.\n');
fprintf(1,'After that, the buttons ''Play all channels'' and ''Play selected channel''\n');
fprintf(1,'will be enabled to let you hear the sound that was last synthesized.\n\n');
fprintf(1,'If you want to stop resynthesizing, press a key instead of clicking in the figure.\n\n');

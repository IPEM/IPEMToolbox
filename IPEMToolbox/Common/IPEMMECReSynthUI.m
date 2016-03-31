function IPEMMECReSynthUI(varargin)
% Usage:
%   IPEMMECReSynthUI(inAction,inData)
%
% Description:
%   User Interface callback function for interactively handling the resynthesis
%   of MEC analysis results.
%
% Input arguments:
%   inAction = string representing the type of action to take
%              (should be 'Start' when launched)
%   inData = struct containing the data needed by the interface
%            contains the following fields:
%              Sound = original sound
%              SampleFreq = sample frequency of Sound
%              Periods = periods that were analyzed
%              BestPeriodIndices = indices for detected best periods
%              AnalysisFreq = sample frequency of BestPeriodIndices
%              P = extracted patterns (see remark below)
%              PLengths = lenghts of the patterns in P
%              PFreq = sample frequency of P (same as AnalysisFreq)
%              OriginalFreq = sample frequency of contents of P
%              NoiseBands = noise bands to use for resynthesis
%              ANIFilterFreqs = filter frequencies
%                               (empty in case of non-ANI data)
%
% Remarks:
%   1. For more info on the data stored in inData, see input and output
%      arguments of the functions IPEMMECAnalysis, IPEMMECExtractPatterns,
%      IPEMMECSynthesis.
%   2. For the 'P' field, you have to specify P between curly braces:
%      DataStruct = struct('Sound',s,'SampleFreq',fs,....,'P',{P},...);
%      This is because of Matlab's way of handling cell arrays in struct
%      definitions.
%
% Example:
%   UIData = struct('Sound',s,'SampleFreq',fs,'Periods',Periods,...
%                   'BestPeriodIndices',BestPeriodIndices,'AnalysisFreq',Freq,...
%                   'P',{P},'PLengths',PLengths,'PFreq',PFreq,'OriginalFreq',...
%                   RMSFreq,'NoiseBands',NoiseBands,'ANIFilterFreqs',[]);
%   IPEMMECReSynthUI('Start',UIData);
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

% Handle input arguments
[Action,D] = IPEMHandleInputArguments(varargin,2,{'Start',[]});

% Perform the wanted action
switch (Action)

case 'Start'
    
    % Data figure
    if (~isempty(D.ANIFilterFreqs))
        HFig = figure;
        if (size(D.BestPeriodIndices,1)==1)
            D.BestPeriodIndices = repmat(D.BestPeriodIndices,length(D.ANIFilterFreqs),1);
        end
        IPEMPlotMultiChannel(D.Periods(D.BestPeriodIndices),D.AnalysisFreq,'Best period over time for each channel','Time (in s)','Auditory channels (center freqs. in Hz)',14,D.ANIFilterFreqs,1);
    else
        HFig = figure;
        plot((0:length(D.BestPeriodIndices)-1)/D.AnalysisFreq,D.Periods(D.BestPeriodIndices));
        axis([-inf inf 0 D.Periods(end)]);
        xlabel('Time (in s)');
        ylabel('Best period (in s)');
        title('Best period over time');
    end
    set(HFig,'Tag','IPEMECReSynthUIData');
    IPEMSetFigureLayout(HFig);
    
    % Variables
    LastTime = -1;
    SelectedChannel = 1;
    SelectedTime = 0;
    ReSynthSound = [];
    IndividualReSynthSounds = [];
    
    % Setup ui
    open('IPEMMECReSynthUI.fig');
    HUIFig = findobj(0,'Tag','IPEMMECReSynthUI');
    ud = D;
    LocalData = struct(...
        'LastTime',LastTime,'SelectedTime',SelectedTime,'SelectedChannel',SelectedChannel,...
        'ReSynthSound',ReSynthSound,'IndividualReSynthSounds',IndividualReSynthSounds);
    fn = fieldnames(LocalData);
    values = struct2cell(LocalData);
    for i = 1:length(fn)
        ud = setfield(ud,fn{i},values{i});
    end
    set(HUIFig,'UserData',ud);
    IPEMMECReSynthUI('UpdateAllData');
    
    % Interface to data figure
    Proceed = 0;
    MaxTime = (length(ud.Sound)-1)/ud.SampleFreq;
    DataChanged = 0;
    while (~Proceed)
        % Set input to wanted figure
        figure(HFig);
        
        % Get user input
        [x,y,Result] = ginput(1);
        
        % Check result
        HUIFig = findobj(0,'Tag','IPEMMECReSynthUI');
        if isempty(Result) | (Result < 1) | (Result > 3)
            Proceed = 1;
        else
            if (x >= 0) & (x <= MaxTime)
                SelectedTime = x;
                ud = get(HUIFig,'UserData');
                ud.SelectedTime = SelectedTime;
                set(HUIFig,'UserData',ud);
                DataChanged = 1;
            end;
            if (length(ud.P) ~= 1)
                if (y >= 1) & (y < (length(ud.P)+1))
                    SelectedChannel = floor(y);
                    ud = get(HUIFig,'UserData');
                    ud.SelectedChannel = SelectedChannel;
                    set(HUIFig,'UserData',ud);
                    DataChanged = 1;
                end
            end;
            if (DataChanged)
                 IPEMMECReSynthUI('UpdateAllData');
            end
        end
        
    end    
    
    close(HUIFig);
    close(HFig);
    
case 'ReSynth'
    HUIFig = findobj(0,'Tag','IPEMMECReSynthUI');
    ud = get(HUIFig,'UserData');
    [ud.ReSynthSound,UsedPeriods,ud.IndividualReSynthSounds] = IPEMMECSynthesis(...
        ud.P,ud.PLengths,ud.PFreq,ud.OriginalFreq,ud.SelectedTime,...
        length(ud.Sound)/ud.SampleFreq,ud.SampleFreq,ud.NoiseBands,-20,1,4096,0);
    ud.LastTime = ud.SelectedTime;
    set(HUIFig,'UserData',ud);
    IPEMMECReSynthUI('UpdateAllData');
    
case 'PlayAll'
    HUIFig = findobj(0,'Tag','IPEMMECReSynthUI');
    ud = get(HUIFig,'UserData');
    theSound = [(ud.Sound)' (ud.ReSynthSound)'];
    wavplay(theSound,ud.SampleFreq,'sync');

case 'PlayChannel'
    HUIFig = findobj(0,'Tag','IPEMMECReSynthUI');
    ud = get(HUIFig,'UserData');
    ChannelSound = IPEMAdaptLevel((ud.IndividualReSynthSounds(ud.SelectedChannel,:)),-20);
    theSound = [(ud.Sound)' ChannelSound'];
    wavplay(theSound,ud.SampleFreq,'sync');

case 'UpdateAllData'
    HUIFig = findobj(0,'Tag','IPEMMECReSynthUI');
    ud = get(HUIFig,'UserData');
    set(findobj(HUIFig,'Tag','SelectedChannel'),'String',sprintf('%d',ud.SelectedChannel));
    set(findobj(HUIFig,'Tag','SelectedTime'),'String',sprintf('%.3f',ud.SelectedTime));
    if (ud.LastTime == -1)
        set(findobj(HUIFig,'Tag','LastTime'),'String','-');
        set(findobj(HUIFig,'Tag','PlayAll'),'Enable','Off');
        set(findobj(HUIFig,'Tag','PlayChannel'),'Enable','Off');
    else
        set(findobj(HUIFig,'Tag','LastTime'),'String',sprintf('%.3f',ud.LastTime));
        set(findobj(HUIFig,'Tag','PlayAll'),'Enable','On');
        set(findobj(HUIFig,'Tag','PlayChannel'),'Enable','On');
    end
    if (~ischar(ud.LastTime) & (ud.LastTime == ud.SelectedTime))
        set(findobj(HUIFig,'Tag','ReSynth'),'Enable','Off');
    else
        set(findobj(HUIFig,'Tag','ReSynth'),'Enable','On');
    end
    
end

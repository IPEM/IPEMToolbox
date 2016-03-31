function IPEMAnimateSlices(varargin)
% Usage:
%   IPEMAnimateSlices(inSignal,inSampleFreq,XAxisLabel,YAxisLabel,...
%                     inXData,inXRange,inYRange,inTimeRange,...
%                     inTimeStep,inAnimationInterval,inScales,inGraphicsHandle)
%
% Description:
%   Displays animated plots of a 2D matrix where each column represents a slice
%   of data at a certain moment in time.
%   Could be used as an alternative to a surf plot...
%
% Input arguments:
%   inSignal = 2D vector in which each column contains a slice of data
%   inSampleFreq = sample frequency of inSignal (in Hz)
%   inXAxisLabel = label to display on the X axis of the plot
%                  if empty or not specified '' is used by default
%   inYAxisLabel = label to display on the Y axis of the plot
%                  if empty or not specified '' is used by default
%   inXData = vector containing the values that correspond with each row of the
%             2D vector
%             if empty or not specified, 1:size(inSignal,1) is used by default
%   inXRange = X range for which values need to be displayed in each plot
%              specified as a vector [LowXValue HighXValue]
%              if empty or not specified, [min(inXData) max(XData)] is used
%              by default
%   inYRange = Y range for which values will be visible in the plot, specified
%              as a vector [MinYValue MaxYValue]
%              if empty or not specified, [min(min(inSignal)) max(max(inSignal))]
%              is used by default
%   inTimeRange = time range that should be animated, specified as a vector
%                 [StartTime EndTime] (in s)
%                 if empty or not specified, the entire signal is animated
%                 by default (so: [0 (size(inSignal,2)-1)/inSampleFreq])
%   inTimeStep = time step to use for stepping through the animated data (in s)
%                if empty or not specified, 1/inSampleFreq is used by default
%   inAnimationInterval = time to wait between two successive plots in
%                         the animation (in s)
%                         if -1, real-time is used
%                         if empty or not specified, 0 is used by default
%   inScales = 2 element cell vector specifying the type of scale to use for the
%              X and Y axis specified as {XType YType}, where XType and YType can
%              be either 'linear' or 'log'
%              if empty or not specified, {'linear' 'linear'} is used by default
%   inGraphicsHandle = handle of a subplot or a figure in which the animation
%                      should be shown
%                      if empty or not specified, a new subplot in a new figure
%                      will be used by default
%
% Remarks:
%   Keys that can be pressed in the figure while the plot is animated:
%   '+' = forward
%   '-' = backward
%   ' ' = pause
%   'x' = exit
%
% Example:
%   [s,fs] = IPEMReadSoundFile('schum1.wav');
%   [S,T,F] = IPEMCalcSpectrogram(s,fs,0.040,0.010);
%   IPEMAnimateSlices(abs(S),1/T(2),'Frequency (in Hz)','Amplitude',F);
%
% Authors:
%   Koen Tanghe - 20021021
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
[inSignal,inSampleFreq,inXAxisLabel,inYAxisLabel,inXData,inXRange,inYRange,inTimeRange,...
        inTimeStep,inAnimationInterval,inScales,inGraphicsHandle] = ...
    IPEMHandleInputArguments(varargin,3,{[],[],'','',[],[],[],[],[],0,{'linear' 'linear'},[]});

% Additional argument checking
if isempty(inXData)
    inXData = 1:size(inSignal,1);
end
if  isempty(inXRange)
    inXRange = [min(inXData) max(inXData)];
end
if isempty(inYRange)
    inYRange = [min(min(inSignal)) max(max(inSignal))];
end
if isempty(inTimeRange)
    inTimeRange = [0 (size(inSignal,2)-1)/inSampleFreq];
end
if isempty(inTimeStep)
    inTimeStep = 1/inSampleFreq;
end
if isempty(inGraphicsHandle)
    HFig = figure;
    HSubplot = subplot(1,1,1);
else
    if isequal(get(inGraphicsHandle,'Type'),'figure')
        HFig = inGraphicsHandle;
        HSubplot = subplot(1,1,1);
    elseif isequal(get(inGraphicsHandle,'Type'),'axes')
        HSubplot = inGraphicsHandle;
        HFig = get(HSubplot,'Parent');
    else
        fprintf(2,'ERROR: supplied graphics handle does not correspond to a valid figure or subplot\n');
        return;
    end
end

% Initialize some variables
IndStart = max(1,round(inTimeRange(1)*inSampleFreq)+1);
IndStop = min(size(inSignal,2),round(inTimeRange(2)*inSampleFreq)+1);
Step = round(inTimeStep*inSampleFreq);
LowInd = find(inXData <= inXRange(1));
HighInd = find(inXData >= inXRange(2));
if ~isempty(LowInd)
    IndMinX = LowInd(end);
else
    IndMinX = 1;
end
if ~isempty(HighInd)
    IndMaxX = HighInd(1);
else
    IndMaxX = length(inXData);
end
XRange = inXData(IndMinX:IndMaxX);
MinY = inYRange(1);
MaxY = inYRange(2);

% Start animation
set(HFig,'doublebuffer','on'); % avoid flickering
set(HFig,'KeyPressFcn',' '); % avoid key press to switch to command window
HPlot = plot(XRange,inSignal(IndMinX:IndMaxX,IndStart));
axis([XRange(1) XRange(end) MinY MaxY]);
HAxes = get(HPlot,'parent');
set(HAxes,'XScale',inScales{1});
set(HAxes,'YScale',inScales{2});
set(HAxes,'TickDir','out');
set(HAxes,'Box','off');
xlabel(inXAxisLabel);
ylabel(inYAxisLabel);
HTitle = title('');
IPEMSetFigureLayout(HFig);
i = IndStart;
Incr = +Step;
StepMode = 0;
StartTime = clock;
PreviousTime = StartTime;
while (1)
    i = max(IndStart,min(i,IndStop));
    set(HPlot,'YData',inSignal(IndMinX:IndMaxX,i));
    set(HTitle,'String',sprintf('Time = %.3f s',(i-1)/inSampleFreq));
    drawnow;
    Key = lower(get(HFig,'CurrentCharacter'));
    set(HFig,'CurrentCharacter',char(0)); % reset current character
    switch Key,
    case '-', % backward
        Incr = -Step;
        if ((inAnimationInterval ~= -1) | StepMode)
            i = i + Incr;
        end
    case '+', % forward
        Incr = +Step;
        if ((inAnimationInterval ~= -1) | StepMode)
            i = i + Incr;
        end
    case ' ', % pause
        StepMode = 1-StepMode;
        StartTime = clock;
    case 'x', % exit
        break;
    otherwise,
        if (~StepMode)
            if (inAnimationInterval == -1)
                NewStartTime = clock;
                T = etime(NewStartTime,StartTime);
                if (Incr > 0)
                    i = min(max(i + round(T*inSampleFreq),IndStart),IndStop);
                else
                    i = min(max(i - round(T*inSampleFreq),IndStart),IndStop);
                end
                StartTime = NewStartTime;
            else
                while (etime(clock,PreviousTime) < inAnimationInterval) end;
                PreviousTime = clock;
                i = i + Incr;
            end
        end
    end
end
set(HFig,'KeyPressFcn','');

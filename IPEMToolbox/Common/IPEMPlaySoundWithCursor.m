function IPEMPlaySoundWithCursor(varargin)
% Usage:
%   IPEMPlaySoundWithCursor(inSignal,inSignalFreq,inAxisHandles,inTimeRange,
%                           inTimeOffset,inSpeedFactor)
%
% Description:
%   Plays the given sound signal while showing a moving cursor in the given axes.
%
% Input arguments:
%   inSignal = Sound signal.
%   inSignalFreq = Sample frequency of inSignal (in Hz).
%   inAxisHandles = Handles of the axes for which a pointer should be shown.
%                   If empty or not specified, all axes of the current figure
%                   will be used by default (if no current figure, -1 is used).
%                   If -1, the sound file is drawn in a new figure.
%   inTimeRange = Range of playback in the form [starttime endtime] (in s).
%                 If emtpy or not specified, the entire signal will be used.
%   inTimeOffset = Time offset of first sample (in s). This is useful when the
%                  given signal is part of a larger signal.
%                  If empty or not specified, 0 is used by default.
%   inSpeedFactor = Factor by which the sound should be sped up (>1) or slowed
%                   down (<1). If empty or not specified, 1 is used by default.
%
% Remarks:
%   The plots associated with the given handles are supposed to have an x-axis
%   that has a time scale in seconds.
%
% Example:
%   IPEMCalcRMS(s,fs,0.040,0.020,1);
%   IPEMPlaySoundWithCursor(s,fs);
%
% Authors:
%   Koen Tanghe - 20040330
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
[inSignal,inSampleFreq,inAxisHandles,inTimeRange,inTimeOffset,inSpeedFactor] = ...
    IPEMHandleInputArguments(varargin,3,{[],[],[],[],0,1});

% Get appropriate figure (and axes)
if (isempty(inAxisHandles) | (inAxisHandles == -1))
    HFig = [];
    if (isempty(inAxisHandles))
        HFig = get(0,'CurrentFigure');
    end
    if isempty(HFig)
        HFig = figure;
        t = (0:size(inSignal,2)-1)/inSampleFreq + inTimeOffset;
        plot(t,inSignal);
        xlabel('Time (s)');
        ylabel('Amplitude');
        axis([t(1) t(end) -1 1]);
    end
    inAxisHandles = get(HFig,'Children');
else
    HFig = get(inAxisHandles(1),'Parent');
end
N = length(inAxisHandles);

% Get correct time range
FullRange = [0 (size(inSignal,2)-1)/inSampleFreq] + inTimeOffset;
if isempty(inTimeRange)
    StartTime = FullRange(1);
    EndTime = FullRange(2);
elseif (inTimeRange(2) == inf)
    StartTime = inTimeRange(1);
    EndTime = FullRange(2);
else
    StartTime = inTimeRange(1);
    EndTime = inTimeRange(2);
end
Duration = EndTime-StartTime;
StartTimeSamples = round((StartTime-inTimeOffset)*inSampleFreq+1);
EndTimeSamples = round((EndTime-inTimeOffset)*inSampleFreq+1);

% Prepare axis and figure
for i = 1:N
    YLimits = get(inAxisHandles(i),'YLim');
    axes(inAxisHandles(i));
    h(i) = line([0 0],YLimits,'Color',[0.5 0.1 0.1],'EraseMode','xor');
end

% Start drawing the pointer in the figure while the sound is playing
PlayDuration = Duration/inSpeedFactor;
figure(HFig);
sound(inSignal(:,StartTimeSamples:EndTimeSamples)',inSampleFreq*inSpeedFactor);
tic;
while (toc < PlayDuration)
    t = StartTime + toc*inSpeedFactor;
    set(h,'XData',[t t]);
    drawnow;
end

% Clean up axes and figures
for i = 1:N
    delete(h(i));
end

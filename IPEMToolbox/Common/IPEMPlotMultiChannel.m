function IPEMPlotMultiChannel (varargin)
% Usage:
%   IPEMPlotMultiChannel(inData,inSampleFreq,inTitle,inXLabel,inYLabel,...
%                        inFontSize,inChannelLabels,inChannelLabelStep,...
%                        inMinY,inMaxY,inType,inTimeOffset,inYScaleFactor)
%
% Description:
%   Plots a multi-channel signal.
%
% Input arguments:
%   inData = the multi-channel signal (each row represents a channel)
%   inSampleFreq = sample frequency of the data (in Hz)
%                  if empty or not specified, 1 is used by default
%   inTitle = title for the plot
%             if empty or not specified, '' is used by default
%   inXLabel = name for the X-values
%              if empty or not specified, '' is used by default
%   inYLabel = name for the Y-values
%              if empty or not specified, '' is used by default
%   inFontSize = size of the font to be used for title (size of axes labels will
%                be set to inFontSize-2)
%                if empty or not specified, no special fontsize is set by default
%   inChannelLabels = labels for the rows of the multi-channel data
%                     if empty or not specified, 1:Rows(inData) is used
%                     by default
%   inChannelLabelStep = step size for displaying the labels of the channels:
%                        labels 1:inChannelLabelStep:NumOfRows will be used
%                        as ticks
%                        if -1, the initial automatic tick division is kept
%                        if empty or not specified, 1 is used by default
%   inMinY = minimum Y-value to be used for scaling the line plot of a channel
%            if empty or not specified min(min(inData)) is used by default
%   inMaxY = maximum Y-value to be used for scaling the line plot of a channel
%            if empty or not specified max(max(inData)) is used by default
%   inType = plot type to use:
%              0 : uses line plots for each channel, starting from tick label
%              1 : uses imagesc
%              2 : uses line plots for each channel, centered around tick label
%            if empty or not specified, 0 is used by default
%   inTimeOffset = time offset to use for the first sample (in s): the first
%                  sample will be assumed to be taken at time inTimeOffset
%                  if empty or not specified, 0 is used by default
%   inYScaleFactor = factor to be used on the Y values (can be used to scale the 
%                    range of Y values to better show the signal dynamics)
%                    if empty or not specified, 1 is used by default
%
% Output:
%   A graph in the current subplot of the current figure.
%
% Example:
%   IPEMPlotMultiChannel(ANI,ANIFreq,'Auditory nerve image','Time (in s)',...
%        'Auditory channels (center freqs. in Hz)',14,ANIFilterFreqs,3);
%
% Authors:
%   Koen Tanghe - 20040322
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
[inData,inSampleFreq,inTitle,inXLabel,inYLabel,inFontSize,inChannelLabels, ...
        inChannelLabelStep,inMinY,inMaxY,inType,inTimeOffset,inYScaleFactor] = ...
    IPEMHandleInputArguments(varargin,2,{[],1,'','','',[],[],-1,[],[],0,0,1});

% Additional checking
[Rows,Cols] = size(inData);
if isempty(inData)
    return;
end
if isempty(inChannelLabels)
    inChannelLabels = 1:Rows;
end
if isempty(inMinY)
    inMinY = min(min(inData));
end
if isempty(inMaxY)
    inMaxY = max(max(inData));
end

% Setup some values for displaying the data
PlotTimeScale = (0:(Cols-1))/inSampleFreq + inTimeOffset;
Scale = abs(inMaxY-inMinY)/inYScaleFactor;

% Show plot of correct type
if ((inType == 0) | (inType == 2))
    
    % Layout constants
    Height = 0.9;
    Offset = Height/2;
    if (inType == 0)
        Offset = 0;
    end
    
    % Plot the data using different line plots
    for i = 1:Rows
        if (Scale ~= 0)
            plot(PlotTimeScale,i + Height*(inData(i,:)-inMinY)/Scale - Offset);
        else
            plot(PlotTimeScale,i + Height*(inData(i,:)-inMinY - Offset));
        end;
        hold on;
    end
    axis([0 max(PlotTimeScale) 1-Offset-0.1 Rows+Height-Offset+0.1]);
    
elseif (inType == 1)
    
    % Plot the data using imagesc
    imagesc(PlotTimeScale,1:Rows,inData);
    colormap(1-gray);
    axis xy;
    axis tight;
    
else
    % Plot type unknown...
    fprintf(2,'ERROR: Unsupported plot type...\n');
    return;
end

% Setup ticks and their labels
if (inChannelLabelStep == -1)
    % Keep initial automatic tick division
    Ticks = get(gca,'YTick');
    set(gca,'YTickLabelMode','manual');
    set(gca,'YTickMode','manual');
    ValidTicks = Ticks(find((Ticks >= 1) & (Ticks <= Rows)));
    set(gca,'YTick',ValidTicks);
    set(gca,'YTickLabel',inChannelLabels(ValidTicks));
else
    % Setup ticks ourselves
    Ticks = 1:inChannelLabelStep:Rows;
    set(gca,'YTickLabelMode','manual');
    set(gca,'YTickMode','manual');
    set(gca,'YTick',Ticks);
    set(gca,'YTickLabel',inChannelLabels(Ticks));
end

% Setup the axes and their labels
set(gca,'TickDir','out');
set(gca,'Box','off');
set(gca,'DrawMode','fast');
hold off;
HXL = xlabel(inXLabel);
HYL = ylabel(inYLabel);
HT = title(inTitle);
if ~isempty(inFontSize)
    set(HXL,'FontSize',inFontSize-2);
    set(HYL,'FontSize',inFontSize-2);
    set(HT,'FontSize',inFontSize);
end


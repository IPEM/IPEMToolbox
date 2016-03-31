function [outOnsetResults,outOnsetResultsFreq] = IPEMOnsetPeakDetection (varargin)
% Usage:
%   [outOnsetResults,outOnsetResultsFreq] = ...
%     IPEMOnsetPeakDetection (inSignal,inSampleFreq,inPlotFlag)
%
% Description:
%   Returns a pattern having a non-zero value on moments of possible onset peaks
%
% Input arguments:
%   inSignal = a matrix of size [N,M] where N is the number of channels and
%              M is the length in samples
%   inSampleFreq = sample frequency of the incoming signal (in Hz)
%   inPlotFlag = if non-zero, plots are generated
%                if empty or not specified, 0 is used by default
%
% Output:
%   outOnsetResults = a matrix of size [N,M] with a value between 0 and 1
%                     (non-zero where an onset occurs, and proportional to the 
%                     importance of the onset)
%   outOnsetResultsFreq = sample frequency of the result (same as inSampleFreq)
%
% Example:
%   [OnsetResults,OnsetResultsFreq] = IPEMOnsetPeakDetection(Signal,SampleFreq);
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
[inSignal,inSampleFreq,inPlotFlag] = IPEMHandleInputArguments(varargin,3,{[],[],0});

% Set to non-zero for debugging
myDebug = 0;

% For each channel, find the essential peaks 
[N M] = size(inSignal);
outOnsetResults = zeros(N,M);
outOnsetResultsFreq = inSampleFreq;
for i = 1:N
   theInput = inSignal(i,:);
   [indices importances] = IPEMOnsetPeakDetection1Channel(theInput,inSampleFreq);
   outOnsetResults(i,indices) = importances;

   % Show results for some channels (if debugging)
   if 0 %and(myDebug ~= 0,mod(i,4) == 1)
      theInputTime = (0:(M-1))/inSampleFreq;
      theOutputTime = (0:(size(outOnsetResults,2)-1))/outOnsetResultsFreq;
      
      figure;
      subplot(211);
      plot(theInputTime,theInput);
      axis tight;
      title(['signal in channel ' num2str(i)]);
      xlabel('time (s)');
      ylabel('level');
      subplot(212);
      plot(theOutputTime,outOnsetResults(i,:));
      axis([0 max(theOutputTime) 0 1]);
      title('peaks');
      xlabel('time (s)');
      ylabel('level');
   end;
end

% Only plot for debug
if (inPlotFlag)
   figure;
   subplot(211);
   theInputTime = (0:(M-1))/inSampleFreq;
   imagesc(theInputTime,1:N,inSignal);
   colormap(1-gray);
   axis xy;
   title('Results of IPEMOnsetDetection');
   xlabel('Time (s)');
   ylabel('Channel');
   subplot(212);
   IPEMPlotMultiChannel(outOnsetResults,outOnsetResultsFreq,'','Time (s)','Channel',[],[],[],[],[],0);
end

function [outPeakIndices, outImportances] = IPEMOnsetPeakDetection1Channel(inSignal,inSampleFreq)
% Usage:
%   [outPeakIndices, outImportances] = ...
%     IPEMOnsetPeakDetection1Channel(inSignal,inSampleFreq)
%
% Description:
%   Returns the indices of the "important" peaks in the input signal,
%   together with an indication of the "importance" of the peak.
%
% Input arguments:
%   inSignal = the signal to be scanned for peaks
%   inSampleFreq = the sample frequency of the signal (in Hz)
%
% Output:
%   outPeakIndices = indices within the input signal where the peaks are found
%   outImportance = value between 0 and 1 showing the "importance" of a peak
%
% Example:
%   [PeakIndices,Importances] = ...
%     IPEMOnsetPeakDetection1Channel(Signal,SampleFreq);
%
% Authors:
%   Koen Tanghe - 20000510
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

% Use one of the peak detection methods below
[outPeakIndices, outImportances] = Peak4(inSignal,inSampleFreq);


% ---------- From here down are the different peak detection routines ------------

function [outPeakIndices, outImportances] = Peak1 (inSignal,inSampleFreq)
% Thresholding of the difference in dB-value between successive samples

Threshold = 1;
N = length(inSignal);
theValues = 20*(log10(inSignal(2:N))-log10(inSignal(1:N-1)));
outPeakIndices = find(theValues > Threshold)+1;
outImportances = ones(1,length(outPeakIndices));

% ----------

function [outPeakIndices, outImportances] = Peak2 (inSignal,inSampleFreq)

% Parameters
WindowSize1InSeconds = 0.045; % in seconds, for comparing neighboring peaks amongst each other
WindowSize2InSeconds = 0.25; % in seconds, for comparing peaks with the local environment

% Convert parameters to samples
WindowSize1 = round(WindowSize1InSeconds*inSampleFreq);
WindowSize2 = round(WindowSize2InSeconds*inSampleFreq);
HalfWidth1 = round(WindowSize1/2);
HalfWidth2 = round(WindowSize2/2);

% Find all peaks in the signal
inSignal = IPEMClip(inSignal,0.06,[],0.05,[]);
outPeakIndices = IPEMFindAllPeaks(inSignal);
N = length(inSignal);
thePeaks = zeros(1,N);
thePeaks(outPeakIndices) = inSignal(outPeakIndices);

% For each peak, check if we really want to keep it
for i = 1:length(outPeakIndices)

   theIndex = outPeakIndices(i);

   % Compare with nearest peaks
   Left = max(1,theIndex-HalfWidth1);
   Right = min(N,theIndex+HalfWidth1);
   theMax = max(thePeaks(Left:Right));
   if thePeaks(theIndex) < theMax
      thePeaks(theIndex) = 0; % remove this peak if there's a bigger one
   else
      % Compare with values in environment
      Left = max(1,theIndex-HalfWidth2);
      Right = min(N,theIndex+HalfWidth2);
      RMS = sqrt(sum(inSignal(Left:Right).^2)/(Right-Left+1));
      if thePeaks(theIndex) < RMS*1.1
         thePeaks(theIndex) = 0; % remove this peak if it's not significant
      else
         thePeaks(theIndex) = (thePeaks(theIndex)-RMS)/RMS;
      end
   end
end
outPeakIndices = find(thePeaks > 0); % first get the indices,
outImportances = thePeaks(outPeakIndices); % then get the importances...
%outImportances = outImportances/max(outImportances); % ...and bring them between 0 and 1
%outImportances = min(outImportances*1.5,ones(1,length(outImportances))); % reduce effect of extra large peaks
outImportances = IPEMClip(outImportances,0,1,[],[]);

% Plot for debug
if 1
   figure;
   theTime = (0:(length(inSignal)-1))/inSampleFreq;
   subplot(211);
   plot(theTime,inSignal);
   axis([0 max(theTime) 0 (max(inSignal)+0.001)]);
   subplot(212);
   theImportances = zeros(1,N);
   theImportances(outPeakIndices) = outImportances;
   plot(theTime,theImportances);
   axis([0 max(theTime) 0 1]);
end;

% ----------

function [outPeakIndices, outImportances] = Peak3 (inSignal,inSampleFreq)
% Uses median filter

% Parameters
WindowSizeInSeconds = 0.3; % in seconds, for median filter

% Convert to samples
WindowsSize = round(WindowSizeInSeconds*inSampleFreq);

% Smoothen everything below a certain value (0.05 is spontaneous firing probability)
inSignal = IPEMClip(inSignal,0.06,[],0.05,[]);

% Filter the incoming signal with a median filter...
theFilteredSignal = medfilt1(inSignal',WindowsSize)';

% ...and calculate the difference with the original signal
% (this should give us the peaks)
theDifference = inSignal - theFilteredSignal;
theDifference = IPEMClip(theDifference,0.015,[],0,[]); % only interested in "big enough" values

% Find all peaks
outPeakIndices = IPEMFindAllPeaks(inSignal);
outImportances = 2*theDifference(outPeakIndices)./theFilteredSignal(outPeakIndices);
outImportances = IPEMClip(outImportances,0,1,[],[]);

% Plot for debug
if 1
   N = length(inSignal);
   figure;
   theTime = (0:(N-1))/inSampleFreq;
   subplot(211);
   plot(theTime,[inSignal' theFilteredSignal' theDifference']);
   axis tight;
   subplot(212);
   theImportances = zeros(1,N);
   theImportances(outPeakIndices) = outImportances;
   plot(theTime,theImportances);
   axis([0 max(theTime) 0 1]);
end;

% -----------

function [outPeakIndices, outImportances] = Peak4 (inSignal,inSampleFreq)
% Uses median filter

% Parameters
WindowSize1InSeconds = 0.07; % in seconds, for comparing peaks amongst each other
WindowSize2InSeconds = 0.5; % in seconds, for median filter
N = length(inSignal);

% Convert to samples
WindowSize1 = round(WindowSize1InSeconds*inSampleFreq);
HalfWidth1 = WindowSize1/2;
WindowSize2 = round(WindowSize2InSeconds*inSampleFreq);

% Cutoff everything below a certain value (0.05 is spontaneous firing probability)
inSignal = IPEMClip(inSignal,0.06,[],0.05,[]);

% Filter the incoming signal with a median filter...
theFilteredSignal = medfilt1(inSignal',round(WindowSize2))';

% ...and calculate the difference with the original signal
% (this should give us the peak levels)
theDifference = inSignal - theFilteredSignal;

% Find all peaks
thePeakIndices = IPEMFindAllPeaks(inSignal);

% Check if value of minimum to left of peak is low enough to consider the peak
% to be really a peak
if 1
   for i = 1:length(thePeakIndices)
      theIndex = thePeakIndices(i);
      [LeftIndex,RightIndex] = IPEMFindNearestMinima(inSignal,theIndex);
      if (inSignal(LeftIndex) > 0.9*inSignal(theIndex))
         thePeakIndices(i) = 0;
      end;
   end;
end;
outPeakIndices = thePeakIndices(find(thePeakIndices > 0));
clear thePeakIndices;

% Get the peak value signal
thePeaks = zeros(1,N);
thePeaks(outPeakIndices) = inSignal(outPeakIndices);

% Use masking signal
theTime = 0:1/inSampleFreq:(N-1)/inSampleFreq;
theMaskSignal = IPEMCreateMask(theTime,outPeakIndices/inSampleFreq,thePeaks(outPeakIndices),0.2);
theMaskedIndices = find(theMaskSignal > thePeaks);
thePeaks(theMaskedIndices) = 0;
outPeakIndices = find(thePeaks > 0);

% Look for bigger peaks in neigborhood
% For each peak, check if we really want to keep it
for i = 1:length(outPeakIndices)

   theIndex = outPeakIndices(i);

   % Compare with nearest peaks
   Left = max(1,theIndex-HalfWidth1);
   Right = min(N,theIndex+HalfWidth1);
   theMax = max(thePeaks(Left:Right));
   if thePeaks(theIndex) < theMax
      thePeaks(theIndex) = 0; % remove this peak if there's a bigger one
   else
      if 1
         % Compare with median values
         theMedianValue = theFilteredSignal(theIndex);
         if thePeaks(theIndex) < 1.2*theMedianValue %1.1
            thePeaks(theIndex) = 0; % remove this peak if it's not significant
         else
            thePeaks(theIndex) = theDifference(theIndex)/theMedianValue;
         end
      elseif 0
         % Compare with nearest minimum to the left
         [LeftIndex,RightIndex] = IPEMFindNearestMinima(inSignal,theIndex);
         theLeftMinimumValue = inSignal(LeftIndex);
         if thePeaks(theIndex) < 1.2*theLeftMinimumValue
            thePeaks(theIndex) = 0;
         else
            thePeaks(theIndex) = (inSignal(theIndex)-theLeftMinimumValue)/theLeftMinimumValue;
         end
      else
         % Compare with mean of median and nearest left minimum
         theMedianValue = theFilteredSignal(theIndex);
         [LeftIndex,RightIndex] = IPEMFindNearestMinima(inSignal,theIndex);
         theLeftMinimumValue = inSignal(LeftIndex);
         if thePeaks(theIndex) < 1.2*mean([theMedianValue theLeftMinimumValue]) %1.1
            thePeaks(theIndex) = 0; % remove this peak if it's not significant
         else
            thePeaks(theIndex) = theDifference(theIndex)/theMedianValue;
         end
      end
   end
end

outPeakIndices = find(thePeaks > 0); % first get the indices,
outImportances = thePeaks(outPeakIndices); % then get the importances...
outImportances = 2*outImportances; % raise with a factor
outImportances = IPEMClip(outImportances,0,1,[],[]); % clip between 0 and 1

% Plot for debug
if 0
   figure;
   theTime = (0:(N-1))/inSampleFreq;
   subplot(211);
   plot(theTime,[inSignal' theFilteredSignal' theDifference' theMaskSignal']);
   axis tight;
   subplot(212);
   theImportances = zeros(1,N);
   theImportances(outPeakIndices) = outImportances;
   plot(theTime,theImportances);
   axis([0 max(theTime) 0 1]);
end;



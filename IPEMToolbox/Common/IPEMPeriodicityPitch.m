function [outSignal,outSampleFreq,outPeriods,outFANI] = IPEMPeriodicityPitch (varargin)
% Usage:
%   [outSignal,outSampleFreq,outPeriods,outFANI] = IPEMPeriodicityPitch ...
%                       (inMatrix,inSampleFreq,inLowFrequency,...
%                        inFrameWidth,inFrameStepSize,inPlotFlag)
%
% Description:
%   This function calculates the periodicity pitch of a matrix containing 
%   neural firing patterns in different auditory channels. 
%   It is based on the idea that periodicity pitch is calculated as the summed
%   autocorrelation over bandpass filtered fluctuations in auditory channels. 
%   Due to the fact that the output of the auditory model gives the envelopes
%   of the neural firing probabilities (< 1250 Hz) it suffices to use a low-pass
%   filter in order to obtain the pitch e.g. between 80 - 1250 Hz.
%   Only the lowest frequency can be changed by inLowFrequency.
%
% Input arguments:
%   inMatrix = the input signal is a matrix of size [N M] where
%                N is the number of auditory channels (<= 40) and 
%                M is the number of samples
%              the input signal is the output of the auditory model (ANI).
%   inSampleFreq = sample frequency of the input signal (in Hz)
%   inLowFrequency = cutoff frequency (in Hz) of a first order lowpass filter
%                    applied before calculating the autocorrelation
%                    if empty or not specified, 80 is used by default
%   inFrameWidth = width of the frame used for the accumulation of the
%                  autocorrelation (in s)
%                  if empty or not specified, 0.064 is used by default
%   inFrameStepSize = stepsize or timeinterval between two inFrameWidths (in s)
%                   if empty or not specified, 0.010 is used by default
%   inPlotFlag = if non-zero, plots are generated
%                if empty or not specified, 0 is used by default
%
% Output:
%   outSignal = periodicity pitch: a matrix of size
%               inFrameWidth * length(inMatrix) / outSampleFreq 
%   outSampleFreq = sampling rate, equal to inSampleFreq/inFrameStepSize (in Hz)
%   outPeriods = analyzed periods (in s)
%   outFANI = bandpass filtered auditory nerve images (at the original sample
%             frequency)
%
% Remarks:
%   As for any frame-based function, the first value of the output signal is the
%   value calculated for the first complete frame in the input signal.
%   This means the following:
%   if you have an input signal of length 1 s at a sample frequency of 1000 Hz,
%   a frame width of 0.050 s, and a frame step size of 0.010 s,
%   then there will be ceil(((1 - 0.050)*1000 + 1)/(0.010*1000)) = 96 values in
%   the output signal, where the first value corresponds to the first complete
%   frame (the interval 0 to 0.050 s)
%
% Example:
%   [PP,PPFreq,PPPeriods,PPFANI] = IPEMPeriodicityPitch(ANI,ANIFreq);
%
% Authors:
%   Marc Leman - 20011204 (originally made)
%   Koen Tanghe - 20050119
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

% Elementary feedback
fprintf(1,'Start of IPEMPeriodicityPitch...\n');

% Handle input arguments
[inMatrix,inSampleFreq,inLowFrequency,inFrameWidth,inFrameStepSize,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,3,{[],[],80,0.064,0.010,0});

% Additional checking
if isempty(inMatrix),
   fprintf(2,'ERROR: You must specify the name of the input signal as the first argument\n');
   return;  
else
   %check if columns is in the range of the auditory model (<=40)
   [inMatrixRows,inMatrixColumns]=size(inMatrix);
   if (inMatrixRows > 40) 
      fprintf(2,'ERROR: Rows > 40\n');
      return;
   end 
   fprintf(1,'Size of input signal is [%d,%d]\n', inMatrixRows,inMatrixColumns);
end

% Produce some feedback
fprintf(1,'inSampleFreq    = %.2f Hz\n', inSampleFreq);
fprintf(1,'inLowFrequency  = %d Hz\n', inLowFrequency);
fprintf(1,'inFrameWidth    = %1.3f s\n', inFrameWidth);
fprintf(1,'inFrameStepSize = %1.3f s\n', inFrameStepSize);
fprintf(1,'inPlotFlag      = %d\n', inPlotFlag);

% Setup some parameters
HalfSampleFreq = inSampleFreq/2;
FrameWidth = round(inFrameWidth * inSampleFreq);
FrameWidth2 = FrameWidth*2;
FrameStepSize = round(inFrameStepSize * inSampleFreq);
outSampleFreq = inSampleFreq/FrameStepSize;
outPeriods = 0:1/inSampleFreq:(FrameWidth/inSampleFreq -1/inSampleFreq);

fprintf(1,'outSampleFreq   = %.2f Hz\n', outSampleFreq);

% Filtering: uses a second order low-pass filter
fprintf(1,'Filtering ANI using a second-order lowpass filter at %d Hz ... ',...
   inLowFrequency);
[B,A] = butter(2,inLowFrequency/HalfSampleFreq);
fANI = filter(B,A,inMatrix')';
[fANIRows,fANIColumns] = size(fANI);

% Calculate the delay introduced by the filter:
% get the impulse response of the filter and measure the time distance (in samples)
% between the peak of the original signal and the filtered signal
% (i.e. the max of the impulse response)
[H,T] = impz(B,A);
[theMax,theMaxIndex] = max(H);
clear H; clear T;
theDelay = theMaxIndex-1;

% Calculate the FANI by subtracting the shifted fANI from the original signal
FANI = inMatrix(:,1:inMatrixColumns-theDelay)-fANI(:,theDelay+1:fANIColumns);
[FANIRows,FANIColumns] = size(FANI);

% Remove negative values from FANI
FANI = IPEMClip(FANI,0,[],[],[]);

fprintf(1,'Done.\n');

% KT - wouldn't it be better to:
%      1. use a well-designed band pass filter for the section above instead of the subtraction ?
%      2. do the filtering outside of this function, so that it can be used as a general 
%         periodicity analysis function using auto-correlation ?

% Calculation of pitch
fprintf(1,'Calculating periodicity using autocorrelation... ');
ACOR = zeros(FrameWidth,length(1:FrameStepSize:FANIColumns-FrameWidth2));
counter = 1;
theZeroes = zeros(1,FrameWidth);
for i = 1:FrameStepSize:FANIColumns-FrameWidth2+1,
   
   % Produce some feedback while calculating
   if mod(counter,25) == 0
      fprintf(1,'.',counter);
   end
   
   % Calculate a running autocorrelation with length 2*FrameWidth for each channel
   % and sum up.
   SumAutoCorr = zeros(1,FrameWidth);
   for j = 1:FANIRows,
      % The first vector is [zeros part1], the second vector is [part1 part2], and the
      % correlation is calculated from lags -FrameWidth to +FrameWidth
      % In Matlab 5.3.1, we only needed the first part of the resulting vector.
      % In Matlab 6.0 (only version supported as of now), we need the flipped second part
      % (due to changes in Matlab's xcorr function...)
      AutoCorr = xcorr([theZeroes FANI(j,i:i+FrameWidth-1)],FANI(j,i:i+FrameWidth2-1),FrameWidth);
      SumAutoCorr = SumAutoCorr + AutoCorr(FrameWidth+2:FrameWidth2+1);
      % SumAutoCorr = SumAutoCorr + AutoCorr(1:FrameWidth); % this is how the above line was for Matlab 5.3.1
   end
   ACOR(:,counter) = fliplr(SumAutoCorr)';
   % ACOR(:,counter) = SumAutoCorr'; % this is how the above line was for Matlab 5.3.1
   counter = counter+1;
end
fprintf(1,'Done.\n');

% Plot if needed
if (inPlotFlag)
   HFig = figure;
   
   subplot(211);
   IPEMPlotMultiChannel(FANI,inSampleFreq,'Filtered Auditory Nerve Image (FANI)','Time (in s)',...
        'Auditory channels',14,1:40,-1);
   xlabel([]);
    
   subplot(212);
   [ACORRows,ACORColumns] = size(ACOR);
   T = (0:ACORColumns-1)/outSampleFreq;
   imagesc(T,outPeriods,ACOR(1:FrameWidth,:)); axis xy;
   colormap(1-gray);
   axis tight;
   xlabel('Time (in s)');
   ylabel('Periods (in s)');
   title('Periodicity pitch');
   IPEMSetFigureLayout(HFig);
end

% Output the results
outSignal = ACOR;
outFANI = FANI;

% Elementary feedback
fprintf(1,'...end of IPEMPeriodicityPitch.\n');

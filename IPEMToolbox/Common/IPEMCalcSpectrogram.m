function [outSpectrogram,outTimes,outFrequencies] = IPEMCalcSpectrogram (varargin)
% Usage:
%   [outSpectrogram,outTimes,outFrequencies] = ...
%     IPEMCalcSpectrogram(inSignal,inSampleFreq,inFrameSize,inFrameInterval,
%                         inWindowType,inFFTSize,inPlotFlag,inPlotTreshold)
%
% Description:
%   Utility function for calculating/plotting the spectrogram of a signal.
%
% Input arguments:
%   inSignal = signal to analyze
%   inSampleFreq = sample frequency of the incoming signal (in Hz)
%   inFrameSize = size of one analysis frame (in s)
%                 if empty or not specified, 0.040 is used by default
%   inFrameInterval = interval between successive frames (in s)
%                     if empty or not specified, 0.010 is used by default
%   inWindowType = if this is a string: type of window to be used
%                  supported types are: 'bartlett','blackman','boxcar','hamming',
%                                       'hann','hanning','triang'
%                  if this is a 1-column matrix: any user defined window of size
%                  [Round(inFrameSize*inSampleFreq) 1]
%                  if empty or not specified, 'hanning' is used by default
%   inFFTSize = size of FFT to be used
%               if -1 is specified, a value corresponding to inFrameSize is used
%               if empty or not specified, the power of two >= inFrameSize
%               in samples is used
%   inPlotFlag = if non-zero, a plot is generated (showing dB levels)
%                if empty or not specified, 1 is used by default
%   inPlotTreshold = values below this level are ignored in the plot (in dB)
%                    if empty or not specified, -Inf is used by default
%
% Output:
%   outSpectrogram = spectrogram data (amplitude values, so not in dB)
%   outTimes = instants at which an analysis was calculated (in s)
%   outFrequencies = frequencies used in decomposition (in Hz)
%
% Example:
%   [S,T,F] = IPEMCalcSpectrogram(s,fs,0.040,0.010);
%
% Authors:
%   Koen Tanghe - 20001130
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
[inSignal,inSampleFreq,inFrameSize,inFrameInterval,inWindowType,inFFTSize,inPlotFlag,inPlotTreshold] = ...
    IPEMHandleInputArguments(varargin,3,{[],[],0.040,0.010,'hanning',[],1,-Inf});

% Additional input handling/parameter setup
WindowSize = round(inFrameSize*inSampleFreq);
if ischar(inWindowType)
    Window = feval(inWindowType,WindowSize);
elseif isequal(size(inWindowType),[WindowSize 1])
    Window = inWindowType;
end
if isempty(inFFTSize)
    inFFTSize = 2^(ceil(log(WindowSize)/log(2)));
elseif (inFFTSize == -1)
    inFFTSize = WindowSize;
end
NumOverlap = WindowSize-round(inFrameInterval*inSampleFreq);

% Calculate spectrogram
[outSpectrogram,outFrequencies,outTimes] = specgram(inSignal,inFFTSize,inSampleFreq,Window,NumOverlap);

% Normalize (no correction for window type though...)
outSpectrogram = outSpectrogram/(WindowSize/2);

% Plot if needed
if (inPlotFlag)
    figure;
    imagesc(outTimes,outFrequencies,IPEMClip(20*log10(abs(outSpectrogram)),inPlotTreshold,[],inPlotTreshold));
    set(gca,'TickDir','out');
    colormap(1-gray);
    axis xy;
    title('Spectrogram (dB scale)');
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
end

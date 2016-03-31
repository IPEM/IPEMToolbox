function outSignal = IPEMGenerateBandPassedNoise(varargin)
% Usage:
%   outSignal = ...
%     IPEMGenerateBandPassedNoise(inPassBands,inDuration,inSampleFreq,...
%                                 indBLevel,inFFTWidth)
%
% Description:
%   Generates a band passed noise signal using inverse FFT.
%
% Input arguments:
%   inPassBands = 2 column vector containing specification of the pass bands:
%                 each row specifies a low and high frequency (in Hz)
%   inDuration = duration of the sound (in s)
%   inSampleFreq = wanted sample frequency (in Hz)
%                  if empty or not specified, 22050 is used by default
%   indBLevel = dB level for the signal (in dB)
%               if empty or not specified, -6 is used by default
%   inFFTWidth = FFT width to use for the inverse FFT
%                if -1, the next power of 2 >= number of samples is used
%                if empty or not specified, the number of samples is used
%                by default
%
% Output:
%   outSignal = generated band passed noise signal
%
% Remarks:
%   When using an inFFTWidth that is smaller than the number of requested
%   samples, the resulting sound will consist of the appropriate number of
%   repetitions of the inverse fft of size inFFTWidth, thus introducing an
%   artificial period of the size of 1 inverse fft. For non dense noise, this
%   can become noticable.
%
% Example:
%   s = IPEMGenerateBandPassedNoise([1000 1200],1);
%
% Authors:
%   Koen Tanghe - 20000926
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
[inPassBands,inDuration,inSampleFreq,indBLevel,inFFTWidth] = IPEMHandleInputArguments(varargin,2,{[],1,22050,-6,[]});

% Init some parameters
NumOfSamples = round(inDuration*inSampleFreq);
if isempty(inFFTWidth)
    N = NumOfSamples;
elseif (inFFTWidth == -1)
    N = 2^nextpow2(NumOfSamples);
else
    N = inFFTWidth;
end
Ampl = zeros(1,N);
NumOfUniquePoints = ceil((N+1)/2);
NumOfBands = size(inPassBands,1);
NumOfPasses = ceil(NumOfSamples/N);
Freqs = (0:N-1)/N;

% Set up the bands and the inverse fft matrix
for i = 1:NumOfBands
    Min = round(min(inPassBands(i,:))/inSampleFreq*N)+1;
    Max = round(max(inPassBands(i,:))/inSampleFreq*N)+1;
    Ampl(Min:Max) = N/2;
end
Ampl(1) = Ampl(1)*2; % DC comp. (once)
Ampl(end-(NumOfUniquePoints-2):end) = fliplr(Ampl(2:NumOfUniquePoints)); % Other freqs (twice)
if ~mod(N,2)
    Ampl(NumOfUniquePoints) = Ampl(NumOfUniquePoints)*2; % Nyquist freq. for even FFT width (once) 
end
Phase = rand(1,N)*2*pi-pi;

% Generate the sound by applying inverse fft and put it at the desired level
FFT = Ampl.*exp(j*Phase);
IFFT = ifft(FFT,N);
Sound = real(IFFT);
outSignal = repmat(Sound,1,NumOfPasses);
outSignal = outSignal(1,1:NumOfSamples);
outSignal = IPEMAdaptLevel(outSignal,indBLevel);

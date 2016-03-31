function [outAmpl,outPhase,outFreqs] = IPEMCalcFFT (varargin)
% Usage:
%   [outAmpl,outPhase,outFreqs] = IPEMCalcFFT (inSignal, inSampleFreq, ...
%                                              inFFTSize, inPlotFlag, ...
%                                              inUseLogScale, inShowPhase)
%
% Description:
%   This function calculates (and shows) the amplitude and phase of a real
%   signal.
% 
% Input arguments:
%   inSignal = the signal to be analyzed
%   inSampleFreq = the frequency at which the signal was sampled (in Hz)
%   inFFTSize = size of the FFT 
%               if empty or not specified, the power of two nearest to the full
%               length of the signal is used by default
%   inPlotFlag = if non-zero, shows FFT plot
%                if empty or not specified, 1 is used by default
%   inUseLogScale = if non-zero, a logarithmic scale is used for the frequency
%                   if empty or not specified, 1 is used by default
%   inShowPhase = if non-zero, the phase is shown as well
%                 if empty or not specified, 0 is used by default
%
% Output:
%   outAmpl = amplitude of fft components
%   outPhase = phase of fft components
%   outFreqs = frequencies used for fft calculation
%   
%   The indices in these output matrices (of length L) correspond to the
%   following frequencies:
%     index 1  corresponds to  the DC component
%     index i  corresponds to  frequency (i-1)*inSampleFreq/inFFTSize
%     index L  corresponds to  the Nyquist frequency (if inFFTSize was even)
%
% Remarks:
%   If inFFTSize is smaller than the length of inSignal, inSignal is truncated
%   (a warning is issued when this happens).
%   If inFFTSize is bigger than the length of inSignal, inSignal is padded with
%   zeroes.
%
% Example:
%   [Ampl,Phase,Freqs] = IPEMCalcFFT (Signal,SampleFreq,1024,1,1,0);
%
% Authors:
%   Koen Tanghe - 20010627
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
[inSignal,inSampleFreq,inFFTSize,inPlotFlag,inUseLogScale,inShowPhase] = ...
    IPEMHandleInputArguments(varargin,3,{[],[],[],1,1,0});

% Additional checking
L = length(inSignal);
if isempty(inFFTSize) % Use nearest power of 2
   inFFTSize = 2^nextpow2(L);
end;

% Get normalizer
if (inFFTSize < L)
    Norm = inFFTSize;
    fprintf(1,'FFT size smaller than signal size: truncating signal...\n');
else
    Norm = L;
end

% Get the frequencies
NumPoints = ceil((inFFTSize+1)/2);
outFreqs = (0:NumPoints-1)/inFFTSize*inSampleFreq;

% Calculate Fourier transform
F = fft(inSignal,inFFTSize);

% Get the amplitude and phase
outAmpl = 2*abs(F(1:NumPoints))/Norm;
outAmpl(1) = outAmpl(1)/2; % DC is unique
if (rem(inFFTSize,2) == 0) % Nyquist freq. is unique
   outAmpl(NumPoints) = outAmpl(NumPoints)/2;
end;
outPhase = angle(F(1:NumPoints));

% Plot if needed
if (inPlotFlag ~= 0)
   
   % Show the results
   fig = figure;
   % 1) amplitude part
   if (inShowPhase ~= 0)
      subplot(2,1,1);
   end;
   if (inUseLogScale == 0)
      plot(outFreqs, outAmpl);
   else
      semilogx(outFreqs, outAmpl);
   end
   axis([min(outFreqs) max(outFreqs) min(outAmpl) max(outAmpl)]);
   xlabel('Frequency (Hz)');
   ylabel('Amplitude');
   
   if (inShowPhase ~= 0)
      % 2) Phase part
      subplot(2,1,2);
      if inUseLogScale == 0
         plot(outFreqs, outPhase);
      else
         semilogx(outFreqs, outPhase);
      end
      axis([min(outFreqs) max(outFreqs) -pi +pi]);
      xlabel('Frequency (Hz)');
      ylabel('Phase (radians)');
   end;
end;

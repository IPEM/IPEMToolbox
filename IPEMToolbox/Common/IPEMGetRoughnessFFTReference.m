function outReferenceValue = IPEMGetRoughnessFFTReference(varargin)
% Usage:
%   outReferenceValue = IPEMGetRoughnessFFTReference(indBLevel,inLength)
%
% Description:
%   Returns the reference value for IPEMRoughnessFFT at the specified
%   dB level.
%
% Input arguments:
%   indBLevel = dB level for which the reference value is requested
%   inLength = length (in s) used for calculating roughness with FFT method
%              if empty or not specified, 1 is used by default
%
% Output:
%   outReferenceValue = the requested reference value
%
% Remarks:
%   The reference is taken to be an AM sine tone at the specified dB level
%   with the following properties:
%     - carrier frequency = 1000 Hz
%     - modulation frequency = 70 Hz
%     - modulation index = 1
%     - duration = 1 s
%   The reference value is calculated over the reference sound as a whole
%   (not as the mean of the calculated frames over the sound)
%
% Example:
%   Ref = IPEMGetRoughnessFFTReference(-20,0.5)
%
% Authors:
%   Koen Tanghe - 20010816
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
[indBLevel,inLength] = IPEMHandleInputArguments(varargin,2,{[],1});

% The reference tone
fs = 22050; % Hz
Duration = 1.25*inLength; % s
Frequency1 = 70; % Hz
Frequency2 = 1000; % Hz
ModulationIndex = 1;
t = (0:Duration*fs-1)/fs;
s = (1+ModulationIndex*sin(2*pi*Frequency1*t)) .* sin(2*pi*Frequency2*t);

% Calculation of roughness
s = IPEMAdaptLevel(s,indBLevel);
[ANI,ANIFreq,ANIFilterFreqs] = IPEMCalcANI(s,fs);
L = round(inLength*ANIFreq);
[R,RFreq] = IPEMRoughnessFFT(ANI(:,1:L),ANIFreq,ANIFilterFreqs,inLength,inLength,0);
outReferenceValue = R;

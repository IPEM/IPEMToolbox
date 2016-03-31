function [outSignal,outSubSignals] = IPEMSineComplex(varargin)
% Usage:
%   [outSignal,outSubSignals] = ...
%     IPEMSineComplex(inSampleFreq,inDuration,...
%                     inFrequencies,inAmplitudes,inPhases,indBLevel)
%
% Description:
%   Generates a signal consisting of pure sinusoids with constant amplitude
%   and phase.
%
% Input arguments:
%   inSampleFreq = wanted sample frequency (in Hz)
%   inDuration = wanted duration (in s)
%   inFrequencies = frequency components (in Hz)
%   inAmplitudes = amplitudes for the frequency components
%                  if empty or not specified, 1 is used for all components
%   inPhases = phases for the frequency components (in radians)
%              if you specify 'random', random phase between 0 and 2*pi is used
%              if empty or not specified, 0 is used for all components
%   indBLevel = normalization level (in dB) for the generated sound
%               (the signals in outSubSignals are not normalized)
%               if empty or not specified, no normalization is performed
%
% Output:
%   outSignal = the generated signal
%   outSubSignals = multi-channel signal where each row contains the generated
%                   sine wave for the corresponding frequency
%
% Example:
%   s = IPEMSineComplex(22050,1,[110 220 550 660],[1 0.5 0.8 0.4],'random',-6);
%
% Authors:
%   Koen Tanghe - 20020506
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
[inSampleFreq,inDuration,inFrequencies,inAmplitudes,inPhases,indBLevel] = ...
    IPEMHandleInputArguments(varargin,5,{[],[],[],[],[],[]});

% Get number of components
N = length(inFrequencies);

% Additional checking
if isempty(inAmplitudes)
    inAmplitudes = ones(1,N);
end
if isempty(inPhases)
    inPhases = zeros(1,N);
elseif (ischar(inPhases) & isequal(inPhases,'random'))
    inPhases = rand(1,N)*2*pi;
end

% Generate the sound
t = 0:1/inSampleFreq:inDuration-1/inSampleFreq;
NT = length(t);
outSubSignals = repmat(inAmplitudes',1,NT) .* sin(2*pi*kron(inFrequencies',t) + repmat(inPhases',1,NT));
outSignal = sum(outSubSignals,1);
if ~isempty(indBLevel)
    outSignal = IPEMAdaptLevel(outSignal,indBLevel);
end

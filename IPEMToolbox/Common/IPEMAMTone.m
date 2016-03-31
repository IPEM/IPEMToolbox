function [outSignal] = IPEMAMTone(varargin)
% Usage:
%   [outSignal] = IPEMAMTone(inCarrierFreq,inModulationFreq,inModulationDepth,...
%                            inDuration,indBLevel,inSampleFreq,inFadeInOut)
%
% Description:
%   Generates an amplitude modulated tone according to:
%     s(t) = (1 + inModulationDepth*sin(2*pi*inModulationFreq*t))
%            *sin(2*pi*inCarrierFreq*t)
%
% Input arguments:
%   inCarrierFreq = carrier frequency (in Hz)
%   inModulationFreq = modulation frequency (in Hz)
%   inModulationDepth = modulation depth
%   inDuration = wanted duration (in s)
%   indBLevel = wanted dB level (in dB)
%               if empty or not specified, -20 dB is used by default
%   inSampleFreq = wanted sample frequency (in Hz)
%                  if empty or not specified, 22050 is used by default
%   inFadeInOut = duration of linear fade in and out of the sound signal (in s)
%                 given as [FadeIn FadeOut] or as a scalar (FadeIn == FadeOut)
%                 if empty or not specified, 0.010 is used by default
%
% Output:
%   outSignal = generated sound signal
%
% Example:
%   s = IPEMAMTone(1000,70,0.65,0.200,-20,44100,0.010);
%
% Authors:
%   Koen Tanghe - 20040323
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
[inCarrierFreq,inModulationFreq,inModulationDepth,inDuration,indBLevel,inSampleFreq,inFadeInOut] = ...
    IPEMHandleInputArguments(varargin,6,{[],[],[],[],-20,22050,0.010});

% Setup signal
t = 0:1/inSampleFreq:inDuration-1/inSampleFreq;
outSignal = (1 + inModulationDepth*sin(2*pi*inModulationFreq*t)).*sin(2*pi*inCarrierFreq*t);

% Adapt level and fade in and out
outSignal = IPEMAdaptLevel(outSignal,indBLevel);
outSignal = IPEMFadeLinear(outSignal,inSampleFreq,inFadeInOut);

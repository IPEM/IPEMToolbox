function outCrestFactor = IPEMGetCrestFactor(varargin)
% Usage:
%   outCrestFactor = IPEMGetCrestFactor(inSignal)
%
% Description:
%   Gets the crest factor of the signal, which is defined as:
%        CF = max(abs(signal))/rms(signal))
%
% Input arguments:
%   inSignal = input signal
%
% Output:
%   outCrestFactor = the crest factor over the entire signal
%
% Example:
%   [s,fs] = IPEMReadSoundFile;
%   CF = IPEMGetCrestFactor(s);
%
% Authors:
%   Koen Tanghe - 20030415
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
[inSignal] = IPEMHandleInputArguments(varargin,0,{[]});

RMSLevel = IPEMGetLevel(inSignal,0);
I = find(RMSLevel == 0);
outCrestFactor = max(abs(inSignal),[],2)./RMSLevel;
outCrestFactor(I) = 1;
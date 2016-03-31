function outSignal = IPEMFadeLinear (inSignal,inSampleFreq,inFadeTime)
% Usage:
%   outSignal = IPEMFadeLinear (inSignal,inSampleFreq,inFadeTime)
%
% Description:
%   Does a linear fade in and out of the signal over inFadeTime seconds.
%   Can be used for smoothing beginnings and endings of a synthesized signal.
%
% Input arguments:
%   inSignal = the input signal
%   inSampleFreq = sample frequency of the signal (in Hz)
%   inFadeTime = the time to fade in and out (in s)
%                if this is a scalar, both fade in and out time are the same
%                if this is a two element row vector, inFadeTime(1) is the fade
%                in time and inFadeTime(2) is the fade out time
%                (fade times should be smaller than the signal duration)
%
% Output:
%   outSignal = the faded signal
%
% Remarks:
%   If the sum of fade in and fade out time is >= the sound length,
%   then the fades will accumulate at the overlapping section, thus introducing
%   a quadratic fade at that section.
%
% Example:
%   Signal = IPEMFadeLinear(Signal,SampleFreq,0.01);
%
% Authors:
%   Koen Tanghe - 20000913
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

% Initialization
outSignal = [];
[R,C] = size(inFadeTime);

% Fade
if isequal([R,C],[1,1])
    NIn = floor(inFadeTime*inSampleFreq);
    NOut = floor(inFadeTime*inSampleFreq);
else
    NIn = floor(inFadeTime(1)*inSampleFreq);
    NOut = floor(inFadeTime(2)*inSampleFreq);
end

% Fade
FadeIn = (0:NIn-1)/NIn;
FadeOut = (NOut-1:-1:0)/NOut;
outSignal = [inSignal(1:NIn).*FadeIn inSignal(NIn+1:end)];
outSignal = [outSignal(1:end-NOut) outSignal(end-NOut+1:end).*FadeOut];

function outSignal = IPEMHarmonicToneComplex (varargin)
% Usage:
%   outSignal = IPEMHarmonicToneComplex(inToneVector,inDuration,inSampleFreq,...
%                                       inPhaseFlag,indBLevel,inNumOfHarmonics)
%
% Description:
%   This function generates a tone complex built up of harmonic tones.
%
% Input arguments:
%   inToneVector = a 12 elements vector representing the amplitude for each tone
%                  C, C#, D, ... in the tone complex (0 = no tone, 1 = full
%                  amplitude)
%   inDuration = the duration (in s)
%                if empty or not specified, 1 is used by default
%   inSampleFreq = the desired sample frequency for the output signal (in Hz)
%                  if empty or not specified, 22050 is used by default
%   inPhaseFlag = for choosing whether random phase has to be used or not
%                 (1 to use random phase, 0 otherwise)
%                 if empty or not specified, 1 is used by default
%   indBLevel = dB level of generated tone complex (in dB)
%               if empty or not specified, no level adjustment is performed
%   inNumOfHarmonics = number of harmonics for each tone (including the
%                      fundamental frequency)
%                      if empty or not specified, 10 is used by default
% 
% Output:
%   outSignal = the signal for the tone complex
%
% Remarks:
%   This is a rather simple routine because the frequencies are fixed:
%
%       notes = C4,    C#4,   D4,    D#4,   E4,    F4,    F#4,   G4,    G#4,
%       freqs = 261.6, 277.2, 293.7, 311.1, 329.6, 349.2, 370.0, 392.0, 415.3,
%
%       notes = A,     A#4,   B
%       freqs = 440.0, 466.2, 493.9
%
% Example:
%   Signal = IPEMHarmonicToneComplex([1 0 0 0 1 0 0 1 0 0 0 0],1,22050,1,-20,5);
%
% Authors:
%   Marc Leman - 19990528
%   Koen Tanghe - 20010116
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
[inToneVector,inDuration,inSampleFreq,inPhaseFlag,indBLevel,inNumOfHarmonics] = ...
    IPEMHandleInputArguments(varargin,2,{[],1,22050,1,[],10});

% Static data
%       note =   C4    C#4   D4    D#4   E4    F4    F#4   G4    G#4   A     A#4   B
theNoteFreqs = [ 261.6 277.2 293.7 311.1 329.6 349.2 370.0 392.0 415.3 440.0 466.2 493.9];

% Setup the tone complex
outSignal = zeros(1,round(inDuration*inSampleFreq));
for i = 1:12
   if (inToneVector(i) ~= 0)
      outSignal = outSignal + IPEMHarmonicTone(theNoteFreqs(i),inDuration,inSampleFreq,inPhaseFlag,[],inNumOfHarmonics);
   end
end

% Adjust level if needed
if ~isempty(indBLevel)
    outSignal = IPEMAdaptLevel(outSignal,indBLevel);
end

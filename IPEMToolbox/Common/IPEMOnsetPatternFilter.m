function [outOnsetSignal,outOnsetSignalFreq] = IPEMOnsetPatternFilter (inOnsetPattern, inSampleFreq)
% Usage:
%   [outOnsetSignal,outOnsetSignalFreq] = ...
%     IPEMOnsetPatternFilter (inOnsetPattern, inSampleFreq)
%
% Description:
%   This function takes an (multi-channel) OnsetPattern generated by 
%   IPEMOnsetPattern, and outputs a (one-dimensional) signal in which a non-zero
%   value means an onset occurred (the value is a measurement of the likeliness
%   for the onset).
%
%   Currently, the following (simple) strategy is followed:
%   an onset is detected at a certain moment, if:
%   1. a certain fraction of channels have an onset within a specific period of
%      time
%   2. the moment falls at least a minimum period of time behind the last
%      detected onset
%
% Input arguments:
%   inOnsetPattern = a matrix of size [N M],
%                    where N = the number of channels and
%                          M = the number of samples
%   inSampleFreq = sample frequency of the input signal (in Hz)
%
% Output:
%   outOnsetSignal = a 1D signal having a non-zero value at detected onset-times
%                    (the clearer the onset, the higher the value)
%   outOnsetSignalFreq = sample frequency of the result (same as inSampleFreq)
%
% Example:
%   [OnsetSignal,OnsetSignalFreq] = ...
%     IPEMOnsetPatternFilter(OnsetPattern,SampleFreq);
%
% Authors:
%   Koen Tanghe - 20031209
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

% Set to 1 for debugging
myDebug = 0;

% The parameters
theFrameWidth = 0.03;         % frame within which a certain number of onsets must occur (s)
theMinNumOnsetsFactor = 9/40; % minimum fraction of channels that have an onset within the frame
theMinDistance = 0.04;        % minimum distance between onsets

% Conversion to samples
W = round(theFrameWidth*inSampleFreq);
D = round(theMinDistance*inSampleFreq);

% Get number of channels and pattern length and init output
[N M] = size(inOnsetPattern);
outOnsetSignal = zeros(1,M);
outOnsetSignalFreq = inSampleFreq;

% Process pattern
i = 1;
while i < M
   
   % Look for an onset in any channel
   if max(inOnsetPattern(:,i)) ~= 0
      
      % Get the total number of onsets within this frame
      theCount = sum(sum(inOnsetPattern(:,i:min(M,i+W-1))));
      
      % Decide whether we accept this to be an onset or not
      if (theCount/N >= theMinNumOnsetsFactor)
         outOnsetSignal(i) = theCount/N;
         i = i + D;
      else
         i = i + 1;
      end
      
   % Otherwise, just proceed in time   
   else
      i = i + 1;
   end
      
end % ...of while loop

% For debug only
if myDebug ~= 0
   figure;
   plot(outOnsetSignal); axis tight;
end

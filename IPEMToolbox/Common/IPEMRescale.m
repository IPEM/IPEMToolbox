function outSignal = IPEMRescale (varargin)
% Usage:
%   outSignal = IPEMRescale (inSignal,inLowLevel,inHighLevel,inScaleGlobally)
%
% Description:
%   This function rescales each channel of the incoming signal between the given
%   lower and upper bounds. Signal channels are represented by rows.
%
% Input arguments:
%   inSignal = the signal that is to be rescaled (each row represents a channel)
%   inLowLevel = the new value for the lowest value in the incoming signal
%                if empty or not specified, 0 is used by default
%   inHighLevel = the new value for the highest value in the incoming signal
%                 if empty or not specified, 1 is used by default
%   inScaleGlobally = if non-zero, all channels are scaled in exactly the
%                     same way
%                     if zero, each channel is scaled separately
%                     if empty or not specified, 0 is used by default
%
% Output:
%   outSignal = the rescaled signal
%
% Remarks:
%   1. For constant signals, inLowLevel is used as constant output level
%   2. You can specify a value for inLowLevel that is higher than the
%      inHighLevel, in which case the signal will be inverted and scaled between
%      the two given levels.
%
% Example:
%   Signal = IPEMRescale(Signal,-1,1);
%
% Authors:
%   Koen Tanghe - 20000224
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
[inSignal,inLowLevel,inHighLevel,inScaleGlobally] = ...
    IPEMHandleInputArguments(varargin,2,{[],0,1,0});

% Additional checking
if isempty(inSignal)
   outSignal = [];
   return;
end;

% Get the size of the incoming signal
[theRows,theColumns] = size(inSignal);

% Allocate space for output signal
outSignal = zeros(theRows,theColumns);

% Determine scaling method
if (inScaleGlobally == 0)

   % Rescale each channel separately
   for i = 1:theRows
      theMinimum = min(inSignal(i,:));
      theMaximum = max(inSignal(i,:));
      if (theMinimum ~= theMaximum)
         outSignal(i,:) = ((inSignal(i,:)-theMinimum)*(inHighLevel-inLowLevel))/(theMaximum-theMinimum)+inLowLevel;
      else
         outSignal(i,:) = inLowLevel;
      end;
   end;
   
else
   
   % Rescale globally
   theMinimum = min(min(inSignal));
   theMaximum = max(max(inSignal));
   if (theMinimum ~= theMaximum)
      outSignal = ((inSignal-theMinimum)*(inHighLevel-inLowLevel))/(theMaximum-theMinimum)+inLowLevel;
   else
      outSignal = inLowLevel;
   end;
end;

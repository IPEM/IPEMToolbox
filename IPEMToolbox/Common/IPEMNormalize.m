function outSignal = IPEMNormalize (varargin)
% Usage:
%   outSignal = IPEMNormalize (inSignal, inNormalizeSeparately)
%
% Description:
%   This function normalizes the given (multi-channel) signal, so that all
%   values are in the range [-1,1]. Channels are represented by rows.
%
% Input arguments:
%   inSignal = the signal to be normalized (each row represents a channel)
%   inNormalizeSeparately = if non-zero, each channel is normalized separately
%                           if zero, empty or not specified, all channels are
%                           multiplied with the same normalisation factor,
%                           so that channel level ratio's are conserved
%
% Output:
%   outSignal = the normalized signal
%
% Example:
%   Signal = IPEMNormalize(Signal);
%
% Authors:
%   Koen Tanghe - 20000919
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
[inSignal, inNormalizeSeparately] = IPEMHandleInputArguments(varargin,2,{[],0});

% Get the size of the incoming signal
[theRows,theColumns] = size(inSignal);

% Allocate space for output signal
outSignal = zeros(theRows,theColumns);

if (inNormalizeSeparately ~= 0)
   
   % Handle each channel separately
   for i = 1:theRows
      theScaleFactor = max(abs(inSignal(i,:)));
      if (theScaleFactor ~= 0)
         outSignal(i,:) = inSignal(i,:)/theScaleFactor;
      else
         outSignal(i,:) = inSignal(i,:);
      end;
   end;

else      
   
   % Handle all channels together
   theScaleFactor = max(max(abs(inSignal)));
   if theScaleFactor ~= 0
      outSignal = inSignal/theScaleFactor;
   else
      outSignal = inSignal;
   end;
   
end;

function outSignal = IPEMClip (varargin)
% Usage:
%   outSignal = IPEMClip(inSignal,inLowLimit,inHighLimit,
%                        inClipLowTo,inClipHighTo)
%
% Description:
%   This function clips the incoming (multi-channel) signal at the given limits.
%   Specify empty values for either one of the limits if you don't want clipping
%   at that side of the signal range.
%   Signal channels are represented by rows.
%
% Input arguments:
%   inSignal = the (multi-channel) signal to be clipped
%   inLowLimit = specifies the low level clipping value: values lower than this
%                are replaced by either the limit itself or inClipLowTo
%                if empty, no clipping occurs
%   inHighLimit = specifies the high level clipping value: values higher than
%                 this are replaced by either the limit itself or inClipHighTo
%                 if empty or not specified, no clipping occurs
%   inClipLowTo = if non-empty, this is a replacement value for too low values
%                 if empty or not specified, inLowLimit is used
%   inClipHighTo = if non-empty, this is a replacement value for too high values
%                  if empty or not specified, inHighLimit is used
%
% Output:
%   outSignal = the clipped signal
%
% Example:
%   Signal = IPEMClip(Signal,0.05,1,0,[]);
%
% Authors:
%   Koen Tanghe - 20000419
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
[inSignal,inLowLimit,inHighLimit,inClipLowTo,inClipHighTo] = ...
    IPEMHandleInputArguments(varargin,3,{[],[],[],[],[]});

% Allocate space for the output signal
outSignal = inSignal;

% Clipping at the low limit
if ~isempty(inLowLimit)
   theIndices = find(inSignal < inLowLimit);
   if ~isempty(inClipLowTo)
      outSignal(theIndices) = inClipLowTo;
   else
      outSignal(theIndices) = inLowLimit;
   end;
end;

% Clipping at the high limit
if ~isempty(inHighLimit)
   theIndices = find(inSignal > inHighLimit);
   if ~isempty(inClipHighTo)
      outSignal(theIndices) = inClipHighTo;
   else
      outSignal(theIndices) = inHighLimit;
   end;
end;

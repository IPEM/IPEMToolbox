function outZeroCrossings = IPEMCountZeroCrossings (varargin)
% Usage:
%   outZeroCrossings = IPEMCountZeroCrossings(inSignal,inZeroTolerance)
%
% Description:
%   Counts the number of zero crossings for each row of inSignal.
%
% Input arguments:
%   inSignal = signal to be analyzed for zero-crossings
%   inZeroTolerance = defines a region around zero where zero-crossings are not
%                     counted (useful for noisy parts of the signal)
%                     if empty or not specified, 0 is used by default
%
% Output:
%   outZeroCrossings = number of zero crossings for each row
%
% Example:
%   ZeroCrossing = IPEMCountZeroCrossings(MusicExcerpt,0.01);
%
% Authors:
%   Koen Tanghe - 20000509
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
[inSignal,inZeroTolerance] = IPEMHandleInputArguments(varargin,2,{[],0});

% Get size of input
[theRows,theColumns] = size(inSignal);

% Get size of incoming data
[Rows,Columns] = size(inSignal);

% Calculate the zero crossings
outZeroCrossings = zeros(Rows,1);
for i = 1:Rows
   Data = inSignal(i,:);
   Indices = find(abs(Data) < inZeroTolerance); % use zero-tolerance threshold
   Data(Indices) = 0;
   Signs = sign(Data);
   Signs = Signs(find(Signs ~= 0)); % remove zeroes
   N = length(Signs);
   
   % zero-crossings occur when product of two successive signs is -1
   ProductOfSigns = Signs(1:N-1).*Signs(2:N);
   outZeroCrossings(i) = length(find(ProductOfSigns == -1));
end;

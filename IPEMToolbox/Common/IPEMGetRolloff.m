function outRolloffIndex = IPEMGetRolloff(varargin)
% Usage:
%   outRolloffIndex = IPEMGetRolloff(inData,inRolloffFraction)
%
% Description:
%   Gets the index R in inData for which:
%     sum(inData,1,R) = inRolloffFraction*sum(inData,1,length(inData))
%
% Input arguments:
%   inData = Data to be analyzed (each row is analyzed separately).
%   inRolloffFraction = Column vector containing a rolloff fraction for each row
%                       in inData. If a scalar is given, the same value is used
%                       for all rows.
%
% Output:
%   outRolloffIndex = column vector containing the rolloff indices for each row
%                     in inData
%
% Example:
%   v = rand(1,20);
%   ri = IPEMGetRolloff(v,0.85);
%   v(ri)
%
% Authors:
%   Koen Tanghe - 20030523
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
[inData,inRolloffFraction] = IPEMHandleInputArguments(varargin,2,{[],[]});

% Setup the boundaries
[R,C] = size(inData);
if (length(inRolloffFraction) ~= R)
    inRolloffFraction = ones(R,1)*inRolloffFraction;
end
FOS = inRolloffFraction.*sum(inData,2);

% Find the rolloff points
CS = cumsum(inData,2);
for i = 1:R
    I = find(CS(i,:) >= FOS(i));
    outRolloffIndex(i,1) = I(1);
end

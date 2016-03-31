function outY = IPEMBellShape (inX,inCenter,inWidth,inPeak)
% Usage:
%   outY = IPEMBellShape (inX,inCenter,inWidth,inPeak)
%
% Description:
%   This function generates a bell shaped curve.
%
% Input arguments:
%   inX = input data points
%   inCenter = center of the curve
%   inWidth = width of the curve:
%             the value at (inCenter + inWidth) is 10% of inPeak 
%   inPeak = maximum value (at the center of the curve)
%
% Output:
%   outY = curve values for the input
%
% Example:
%   Y = IPEMBellShape(0:1000,500,100,1);
%
% Authors:
%   Koen Tanghe - 20000208
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

theFactor = 1/sqrt(-log(0.1));
outY = inPeak*exp(-((inX-inCenter)/(inWidth*theFactor)).^2);

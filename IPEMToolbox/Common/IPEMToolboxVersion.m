function [outVersionString,outMajor,outMinor,outType,outBuildDate] = IPEMToolboxVersion
% Usage:
%   IPEMToolboxVersion
%
% Description:
%   Returns the version of the IPEM Toolbox
%
% Output:
%   outVersionString = string with full version information
%   outMajor = major version number
%   outMinor = minor version number
%   outType = version type string (either 'beta' or empty)
%   outBuildDate = build date of this version using the format 'YYYYMMDD',
%                  where YYYY = year, MM = month and DD = day
%
% Authors:
%   Koen Tanghe - 20050120
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

% Major and minor version
outMajor = 1;
outMinor = 2; % hundreds: 1 will display as .01, whereas 10 will display as .10
outType = 'beta';
outBuildDate = '20050120';

% Setup version string
outVersionString = sprintf('%.2f',outMajor + outMinor/100);
if ~isempty(outType)
    outVersionString = [outVersionString sprintf(' (%s)',outType)];
end

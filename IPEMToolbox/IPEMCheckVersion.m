function [outCompatibility,outCurrentVersion] = IPEMCheckVersion(inComponent,inReferenceVersion)
% Usage:
%   function [outCompatibility,outCurrentVersion] = ...
%     IPEMCheckVersion(inComponent,inReferenceVersion)
%
% Description:
%   Checks compatibility using version numbers
%
% Input arguments:
%   inComponent = string identifying the component to check
%   inReferenceVersion = version number string to compare with
%
% Output:
%   outCompatibility = compatibility result:
%                      -1 if the current version is lower than the reference
%                       0 if the current version is the same as the reference
%                      +1 if the current version is higher than the reference
%                      empty if the component was not present at all
%   outCurrentVersion = current version number string of requested component
%                       empty if not present
%
% Remarks:
%   For comparison, str2num is used on the version number strings.
%
% Example:
%   [Comp,CurrVer] = IPEMCheckVersion('signal','5.0');
%
% Authors:
%   Koen Tanghe - 20011204
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

v = ver(inComponent);
if isempty(v)
    outCompatibility = [];
    outCurrentVersion = [];
else
    outCurrentVersion = v.Version;
    outCurrentVersionNum = str2num(outCurrentVersion);
    ReferenceVersionNum = str2num(inReferenceVersion);
    if isempty(ReferenceVersionNum)
        error('ERROR: no valid reference version number given');
    end
    if (outCurrentVersionNum < ReferenceVersionNum)
        outCompatibility = -1;
    elseif (outCurrentVersionNum > ReferenceVersionNum)
        outCompatibility = +1;
    else
        outCompatibility = 0;
    end
end

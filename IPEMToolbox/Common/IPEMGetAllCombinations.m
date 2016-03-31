function outCombinations = IPEMGetAllCombinations(varargin)
% Usage:
%   outCombinations = IPEMGetAllCombinations(inValueArrays)
%
% Description:
%   Finds all combinations of values by picking a value from a specified set of
%   values for each of the multiple dimensions.
%
% Input arguments:
%   inValueArrays = Cell array containing for each dimension an array of the 
%                   values from which one should be chosen for a combination.
%
% Output:
%   outCombinations = Array containing all possible combinations in rows.
%
% Example:
%   Comb = IPEMGetAllCombinations({[1 2 3],[10 20],[111 222 333]})
%
% Authors:
%   Koen Tanghe - 20040510
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
[inValueArrays] = IPEMHandleInputArguments(varargin,2,{[]});

N = length(inValueArrays);
A = cell(1,N);
[A{:}] = ndgrid(inValueArrays{:});
E = [];
for i = 1:N
    E = [E A{i}(:)];
end
outCombinations = sortrows(E);

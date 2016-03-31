function outMatrix = IPEMRotateMatrix (inMatrix,inRows,inColumns)
% Usage:
%   outMatrix = IPEMRotateMatrix (inMatrix,inRows,inColumns)
%
% Description:
%   Rotates a matrix along its rows and/or columns.
%
% Input arguments:
%   inMatrix = matrix to process
%   inRows = number of rows by which to rotate
%            positive values mean rotation towards increasing row numbers
%   inColumns = number of columns by which to rotate
%               positive values mean rotation towards increasing column numbers
%
% Output:
%   outMatrix = the rotated matrix
%
% Example:
%   RotMat = IPEMRotateMatrix([1 2 3; 4 5 6; 7 8 9],-1,2);
%
%   --> RotMat == [5 6 4; 8 9 7; 2 3 1]
%
% Authors:
%   Koen Tanghe - 20000209
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

% Get matrix size
[Rows,Columns] = size(inMatrix);

% Remap rotation numbers
inRows = mod(-inRows,Rows);
inColumns = mod(-inColumns,Columns);

% Start with original matrix
outMatrix = inMatrix;

% Rotate along rows
if (inRows ~= 0)
   outMatrix = [outMatrix(inRows+1:Rows,:) ; outMatrix(1:inRows,:)];
end;

% Rotate along columns
if (inColumns ~= 0)
   outMatrix = [outMatrix(:,inColumns+1:Columns) outMatrix(:,1:inColumns)];
end;


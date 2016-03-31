function outParts = IPEMStripFileSpecification (inFileSpecification)
% Usage:
%   outParts = IPEMStripFileSpecification (inFileSpecification)
%
% Description:
%   Strips a complete file specification into its subparts.
%   Can also be used to strip directory paths in their subparts.
%
% Input arguments:
%   inFileSpecification = the complete file specification
%
% Output:
%   outParts = a struct containing the following information:
%   outParts.FileName = string containing the name of the file
%   outParts.Name = name of the file without extension
%   outParts.Extension = extension of the file
%   outParts.Path = complete path towards the file
%   outParts.PathParts = cell array containing the subparts of the path
%                        specification
%
% Remarks:
%   1. Only tested on Windows!
%   2. If the specification doesn't end on an extension, it is assumed to be a
%      directory path.
%
% Example:
%   theParts = IPEMStripFileSpecification('D:\Koen\Data\Sounds\schum1.wav');
%   --->
%   theParts.FileName = 'schum1.wav'
%   theParts.Name = 'schum1'
%   theParts.Extension = 'wav'
%   theParts.Path = 'D:\Koen\Data\Sounds'
%   theParts.PathParts = {'D:' 'Koen' 'Data' 'Sounds'}
%
% Authors:
%   Koen Tanghe - 20000607
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

% Setup some easy vars
L = length(inFileSpecification);
s = inFileSpecification;
theExt = [];
theName = [];

% Try to find file name, extension and end of path
theAccu = [];
theExtFlag = 0;
theFileSepFlag = 0;
theEndOfPathIndex = L;
for i = L:-1:1
   % Check for last . in filespec
   if and(s(i) == '.', theExtFlag ~= 1)
      theExt = theAccu;  % the extension is all we have found upto now
      theExtFlag = 1; % remember we found a .
      theAccu = [];   % reset accumulator
   elseif (s(i) == filesep)
      theFileSepFlag = 1;
      break;
   else
      theAccu = [s(i) theAccu];
   end;
end;
if (theExtFlag == 1)
   theName = theAccu;
   if (theFileSepFlag == 1)
      theEndOfPathIndex = i-1;
      theFullname = s(i+1:L);
   else
      theEndOfPathIndex = 0;
      theFullname = s(1:L);
   end;
else   
   theFullname = [];
end;

% Everything from 1 to theEndOfPathIndex is path specification
thePathParts = {};
if (theEndOfPathIndex < 1)
   theFullpath = [];
else
   theFullpath = s(1:theEndOfPathIndex);
   % Strip full path in subpaths
   theAccu = [];
   for i = theEndOfPathIndex:-1:1
      if (s(i) == filesep)
         thePathParts = [ {theAccu} thePathParts];
         theAccu = [];
      else
         theAccu = [s(i) theAccu];
      end;
   end;
   if ~isempty(theAccu)
      thePathParts = [ {theAccu} thePathParts];
   end;
end;

% Account for computer names in network paths like \\computer\e\mydir\test.txt
if (L >= 2)
    if isequal(s(1:2),[filesep filesep])
        thePathParts = [{[filesep filesep thePathParts{2}]} thePathParts(3:end)];
    end
end

% Setup the output struct
outParts = struct( ...
   'FileName', theFullname, ...
   'Name', theName, ...
   'Extension', theExt, ...
   'Path', theFullpath, ...
   'PathParts', {thePathParts} );

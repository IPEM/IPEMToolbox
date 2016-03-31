function [outFullFiles,outFileNames,outFilePaths] = IPEMGetFileList(varargin)
% Usage:
%   [outFullFiles,outFileNames,outFilePaths] = ...
%     IPEMGetFileList(inDirectory,inFilePattern,inRecurse)
%
% Description:
%   Gets a list of files located in a given directory and whose names adhere
%   to a specific pattern (option for recursion).
%
% Input arguments:
%   inDirectory = Path to the directory to search in.
%   inFilePattern = Pattern to which files should adhere in order to be listed.
%                   If empty or not specified, '*' is used by default.
%   inRecurse = If non-zero, also subdirectories are scanned.
%               If empty or not specified, 0 is used by default.
%
% Output:
%   outFullFiles = Cell array containing the full file specifications.
%   outFileNames = Cell array containing only the file names.
%   outFilePaths = Cell array containing only the paths to the files.
%
% Example:
%   [F,FN,FP] = IPEMGetFileList('D:\Koen\','*.txt',1);
%
% Authors:
%   Koen Tanghe - 20040507
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
[inDirectory,inFilePattern,inRecurse] = ...
    IPEMHandleInputArguments(varargin,2,{[],'*',0});

% Init outputs
outFullFiles = {};
outFileNames = {};
outFilePaths = {};

% Get the directory listing and find files and directories
DL = dir(fullfile(inDirectory,inFilePattern));
FI = find(~[DL.isdir]);
DL2 = dir(fullfile(inDirectory,'*.*'));
DI = find([DL2.isdir] & ~strcmp({DL2.name},'.') & ~strcmp({DL2.name},'..'));
Dirs = {DL2(DI).name};
clear DL2;

% Add all files
if (~isempty(FI))
    for i = 1:length(FI)
        outFullFiles{i} = fullfile(inDirectory,DL(FI(i)).name);
    end
    outFileNames = {DL(FI).name};
    outFilePaths = repmat({inDirectory},1,length(FI));
end

% Recurse if requested
if (inRecurse)
    for i = 1:length(Dirs)
       [F,FN,FP] = IPEMGetFileList(fullfile(inDirectory,Dirs{i}),inFilePattern,inRecurse);
       outFullFiles = cat(2,outFullFiles,F);
       outFileNames = cat(2,outFileNames,FN);
       outFilePaths = cat(2,outFilePaths,FP);
   end
end

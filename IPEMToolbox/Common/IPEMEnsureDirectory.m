function outResult = IPEMEnsureDirectory (varargin)
% Usage:
%   outResult = IPEMEnsureDirectory (inDirectoryPath,inCreate)
%
% Description:
%   Checks whether the given directory exists (and optionally creates it, if not)
%
% Input arguments:
%   inDirectoryPath = full directory path to be checked (created)
%   inCreate = if non-zero, the directory will be created if it doesn't exist
%              if empty or not specified, 1 is used by default
%
% Output:
%   outResult = 1 if the directory already existed before calling this function
%
% Remarks:
%   Use this function with care: it's good policy to only create a directory
%   1. if this is really necessary (let user specify directory if possible)
%   2. within the default output directory (that way, the user's disk doesn't
%      get scattered with new directories)
%
% Example:
%   IPEMEnsureDirectory(fullfile(IPEMRootDir('output'),'Test','Example1'),1);
%
%   The above line makes sure that a directory Test\Example1 exists within the
%   default output directory.
%
% Authors:
%   Koen Tanghe - 20040504
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
[inDirectoryPath,inCreate] = IPEMHandleInputArguments(varargin,2,{[],1});
if isempty(inDirectoryPath)
    error('ERROR: inDirectoryPath not specified');
end

% Check if the directory already exists
outResult = ~isempty(dir(inDirectoryPath));

% Create if needed
if (outResult == 0) & (inCreate ~= 0)
    
    % Create all needed subpaths
    s = IPEMStripFileSpecification(inDirectoryPath);
    N = size(s.PathParts,2);
    if (N == 1)
        % Create directory in current directory
        [status,msg] = mkdir(inDirectoryPath);
        if ~isempty(msg) error(msg); end;
    else
        % Create all subpaths that do not already exist
        Directory = '';
        for i = 1:N
            ParentDirectory = Directory;
            Directory = fullfile(Directory,s.PathParts{i});
            % If not a computer name, check (and create) directory 
            if ((i ~= 1) | ~isequal(Directory(1:2),[filesep filesep]))
                if (isempty(dir(Directory)))
                    NewDir = s.PathParts{i};
                    [status,msg] = mkdir([ParentDirectory  filesep],NewDir);
                    if ~isempty(msg) error(msg); end;
                end
            end
        end
    end
end

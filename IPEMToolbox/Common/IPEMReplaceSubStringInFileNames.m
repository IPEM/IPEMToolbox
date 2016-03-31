function IPEMReplaceSubStringInFileNames(varargin)
% Usage:
%   IPEMReplaceSubStringInFileNames(inDir,inOriginalString,inNewString,...
%                                   inRecursive,inAffectExtensions)
%
% Description:
%   Replaces a substring in the filenames of the files contained in a specific
%   directory (and its subdirectories if needed) by a new substring.
%
% Input arguments:
%   inDir = full directory path to the root directory for which the changes
%           should be applied
%   inOriginalString = substring to be replaced in the filenames
%                      if empty or not specified, '_' is used by default
%   inNewString = substring by which inOriginalString will be replaced
%                 if empty or not specified, '' is used by default
%   inRecursive = if non-zero, subdirectories are also affected
%                 if empty or not specified, 0 is used by default
%   inAffectExtensions = if non-zero, extensions of filenames are also affected
%                        if empty or not specified, 0 is used by default
%
% Example:
%   % Remove all underscores in the filenames (not the extensions) of all files
%   % under the given directory and its subdirectories
%   IPEMReplaceSubStringInFileNames('D:\Koen\Temp\Test','_','',1,0);
%
% Authors:
%   Koen Tanghe - 20010522
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
[inDir,inOriginalString,inNewString,inRecursive,inAffectExtensions] = ...
    IPEMHandleInputArguments(varargin,2,{[],'_','',0,0});

% Start applying changes
DirStruct = dir(inDir);
N = length(DirStruct);
for i=1:N
    Name = DirStruct(i).name;
    if (inRecursive & (DirStruct(i).isdir))
        if (~isequal(Name,'.') & (~isequal(Name,'..')))
            IPEMReplaceSubStringInFileNames(fullfile(inDir,DirStruct(i).name),inOriginalString,inNewString,inRecursive,inAffectExtensions);
        end
    else
        if (~inAffectExtensions)
            [a,NameWithoutExtension,Extension,d] = fileparts(Name);
            NewName = [strrep(NameWithoutExtension,inOriginalString,inNewString) Extension];
        else
            NewName = strrep(Name,inOriginalString,inNewString);
        end
        if (~isequal(NewName,Name))
            Command = ['rename "' fullfile(inDir,Name) '" "' NewName '"'];
            dos(Command);
        end
    end
end

function outRootDirPath = IPEMRootDir (inDirType)
% Usage:
%   outRootDirPath = IPEMRootDir(inDirType)
%
% Description:
%   This function returns a default root directory for the requested type.
%   These directories are used by some of the IPEM functions.
%
% Input arguments:
%   inType = string specifying the type of info for which you want the standard
%            directory (the supported types are defined below)
%
% Output:
%   outRootDirPath = the requested directory path
%
% Remarks:
%
%   *** Description of supported types ***
%   
%   'input'
%   The directory that will be used as the root of the subdirectories
%   containing data to be processed by the IPEM Toolbox code.
%   (e.g. sound files could be stored in a subdirectory called 'Sounds',
%   located in this 'input' directory)
%
%   'output'
%   Same as 'input', but for output of the IPEM Toolbox code.
%   In some special cases, the directory of the processed file is used (but this
%   will always be explicitely mentioned in the comments of such a function)
%
%   'code'
%   This is the directory where the IPEM Matlab code is located and can NOT be
%   set by setpref.
%   (e.g. 'E:\Code\Matlab\IPEMToolbox')
%
%
%   *** Supports preferences ***
%
%   You can specify the default 'input' and 'output' root directories by typing:
%
%      setpref('IPEMToolbox','RootDir_Input','directory1')
%
%   and/or
%
%      setpref('IPEMToolbox','RootDir_Output','directory2') 
%
%   where directory1 and directory2 should be replaced by the complete paths to
%   existing directories on your system.
%   If you don't set these directory preferences, the 'Temp' subdirectory in
%   your 'IPEMToolbox' directory is used by default.
%
% Authors:
%   Koen Tanghe - 20010117
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

% ------------------------------------------
% !!! DON'T CHANGE ANYTHING TO THIS FILE !!!
% ------------------------------------------

% Setup path for code root
CodeRoot = which('IPEMSetup');
CodeRoot = CodeRoot(1:length(CodeRoot)-length([filesep 'IPEMSetup.m']));

% The supported types and their default directory paths.
theRootDirs = {
   'input'  getpref('IPEMToolbox','RootDir_Input'); % preferred input root
   'output' getpref('IPEMToolbox','RootDir_Output'); % preferred output root
   'code'   CodeRoot  % code root
};

% Initialize output path
outRootDirPath = [];

% Look for match
theIndex = find(strcmp(theRootDirs(:,1),inDirType) == 1);
if ~isempty(theIndex)
    outRootDirPath = theRootDirs{theIndex,2};
else
    error('Unknown root dir type...');
end;
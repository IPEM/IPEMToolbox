function IPEMSetupPreferences(varargin)
% Usage:
%   IPEMSetupPreferences(inReset)
%
% Description:
%   This function sets up preferences for the IPEM Toolbox.
%
%   Use getpref('IPEMToolbox','preference') to get the value of a preference.
%   Use setpref('IPEMToolbox','preference',value) to set the value of a
%   preference.
% 
% Input arguments:
%   inReset = if non-zero, resets all preferences to their initial values
%             if zero, initializes non-existing preferences, but keeps existing
%             ones
%             if empty or not specified, 0 is used by default
%
% Remarks:
%   List of currently supported preferences:
%
%   'RootDir_Input'        - standard input directory
%                          - initial value: IPEMToolbox\Temp
%     
%   'RootDir_Output'       - standard output directory
%                          - initial value: IPEMToolbox\Temp
% 
% Example:
%   IPEMSetupPreferences(1);
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

% Handle input arguments
[inReset] = IPEMHandleInputArguments(varargin,1,{0});

% Get code root
CodeRoot = which('IPEMSetup');
CodeRoot = CodeRoot(1:length(CodeRoot)-length([filesep 'IPEMSetup.m']));

% Initial preferences
InitialPreferences = { ...
        'RootDir_Input', fullfile(CodeRoot,'Temp');...
        'RootDir_Output', fullfile(CodeRoot,'Temp');...
    };

% Ensure existence of directory holding preference file
% (needed because of Matlab 6.0 bug; in 5.3 preferences where stored in the registry)
prefdir(1);

% Run through preferences and add if they don't exist
for i = 1:size(InitialPreferences,1)
    try
        Value = getpref('IPEMToolbox',InitialPreferences{i,1});
        if (inReset)
            setpref('IPEMToolbox',InitialPreferences{i,1},InitialPreferences{i,2});
        end
    catch
        addpref('IPEMToolbox',InitialPreferences{i,1},InitialPreferences{i,2});
    end;
end

function IPEMSetup
% Usage:
%   IPEMSetup
%
% Description:
%   This function sets up the Matlab environment for working with the
%   IPEM Toolbox.
%
% Example:
%   IPEMSetup;
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

% ------------------------------------------
% !!! DON'T CHANGE ANYTHING TO THIS FILE !!!
% ------------------------------------------

% Paths to be added
Paths = {'Common',...
%        'Scripts',...
        'Demos',...
%        fullfile('Demos','Contextuality'),...
%        fullfile('Demos','Roughness'),...
%        fullfile('Demos','RoughnessApplications'),...
        fullfile('Demos','MECPatternExtraction'),...
    };

% ------------------------------------------------------------------------------
% Check some requirements
% ------------------------------------------------------------------------------

% Check OS
%if ~ispc
%    disp('ERROR:');
%    disp('The IPEM Toolbox was developed for Windows systems only, sorry!');
%    return;
%end

% Check Matlab version
MatlabVersion = '6.0';
MatlabComp = IPEMCheckVersion('matlab',MatlabVersion);
if (MatlabComp < 0)
    disp('ERROR:');
    disp(['Your Matlab version should be at least ' MatlabVersion]);
    disp('IPEM Toolbox setup failed...');
    return;
elseif (MatlabComp > 0)
    disp('WARNING:');
    disp('Your Matlab version is higher than the one the IPEM Toolbox');
    disp(['was developed with/for (which is ' MatlabVersion ').']);
    disp('It could be expected that your Matlab version is backwards compatible');
    disp('with version 6, but be aware of possible bugs.');
end

% Check Signal Processing Toolbox presence and version
SignalVersion = '5.0';
SignalComp = IPEMCheckVersion('signal',SignalVersion);
if isempty(SignalComp)
    disp('ERROR:');
    disp('The Signal Processing Toolbox is not installed.');
    disp('The IPEM Toolbox cannot work without it...');
    disp('IPEM Toolbox setup failed...');
else
    if (SignalComp < 0)
        disp('ERROR:');
        disp(['Your Signal Processing Toolbox version should be at least ' SignalVersion]);
        disp('IPEM Toolbox setup failed...');
        return;
    elseif (SignalComp > 0)
        disp('WARNING:');
        disp('Your Signal Processing Toolbox version is higher than the one the IPEM Toolbox');
        disp(['was developed with/for (which is ' SignalVersion ').']);
        disp('It could be expected that your Signal Processing Toolbox version is backwards compatible');
        disp('with version 5, but be aware of possible bugs.');
    end
end

% ------------------------------------------------------------------------------

% Some elementary feedback
fprintf(1,'Initializing IPEM Toolbox... ');

% Get the current path in a cell array
CurrentPaths = {};
Remainder = path;
while ~isempty(Remainder)
    [PathEntry,Remainder] = strtok(Remainder,pathsep);
    CurrentPaths = cat(1,CurrentPaths,{PathEntry});
end;

% Get code root
theCodeRoot = which('IPEMSetup');
theCodeRoot = theCodeRoot(1:length(theCodeRoot)-length([filesep 'IPEMSetup.m']));

% Add the paths for the IPEM subdirectories to the Matlab paths
for i = 1:size(Paths,1)
    Path = fullfile(theCodeRoot,Paths{i});
    if ~ismember(Path,CurrentPaths)
        addpath(Path);
    end
end;

isOctave = exist('OCTAVE_VERSION') ~= 0;
if (isOctave)
  disp('WARNING:');
  disp('You are running Octave. The IPEM Toolbox ');
  disp(['was developed with/for (which is ' MatlabVersion ').']);
  disp('Be aware of possible compatibility problems.');
else
  path2rc;
end

% Setup preferences for the IPEM Toolbox
IPEMSetupPreferences;

% Feedback
fprintf(1,'Done.\n');

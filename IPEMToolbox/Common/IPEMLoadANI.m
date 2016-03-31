function varargout = IPEMLoadANI(varargin)
% Usage:
%   [outANI,outANIFreq,outANIFilterFreqs] = IPEMLoadANI(inName,inPath,...
%       inANIName,inANIFreqName,inANIFilterFreqsName)
%
% Description:
%   Loads an auditory nerve image and its corresponding sample frequency and
%   filter frequencies from a .mat file on disk.
%
% Input arguments:
%   inName = the name of the .mat file containing the nerve image
%            if empty or not specified, 'ANI.mat' is used by default
%   inPath = path to the .mat file
%            if empty or not specified, IPEMRootDir('code')\Temp is used
%            by default
%   inANIName = name of the auditory nerve image array
%               if empty or not specified, 'ANI' is used by default
%   inANIFreqName = name of the sample frequency of the auditory nerve image
%                   if empty or not specified, 'ANIFreq' is used by default
%   inANIFilterFreqsName = name of the filter frequencies array
%                          if empty or not specified, 'ANIFilterFreqs' is used
%                          by default
%
% Output:
%   outANI = the auditory nerve image
%   outANIFreq = the sample frequency of the ANI
%   outANIFilterFreqs = center frequencies used for calaculting the ANI
%
% Example:
%   [ANISchum1,ANIFreqSchum1,ANIFilterFreqsSchum1] = ...
%     IPEMLoadANI('ANIs','c:\','Schum1','Schum1Freq','Schum1FilterFreqs');
%
% Authors:
%   Koen Tanghe - 20000221
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
[inName,inPath,inANIName,inANIFreqName,inANIFilterFreqs] = IPEMHandleInputArguments(varargin,1,...
    {'ANI',fullfile(IPEMRootDir('code'),'Temp'),'ANI','ANIFreq','ANIFilterFreqs'});

% Check number of output arguments
if ((nargout < 0) | (nargout > 3))
    error('ERROR: Illegal number of output arguments...');
end

% Setup file name
theFile = fullfile(inPath,inName);
theSpec = IPEMStripFileSpecification(theFile);
if ~strcmpi(theSpec.Extension,'mat')
    theFile = [theFile '.mat'];
end

% Load the nerve image variables
VariableNames = {inANIName,inANIFreqName,inANIFilterFreqs};
ANIData = load(theFile);
for i = 1:nargout
    if isfield(ANIData,VariableNames{i})
        varargout{i} = getfield(ANIData,VariableNames{i});
    else
        error(['Variable ' VariableNames{i} ' could not be found in the file']);
    end;
end;

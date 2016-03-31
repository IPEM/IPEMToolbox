function IPEMSaveANI(varargin);
% Usage:
%   IPEMSaveANI(inANI,inANIFreq,inANIFilterFreqs,inName,inPath,...
%               inANIName,inANIFreqName,inANIFilterFreqsName,inAppend)
%
% Description:
%   Saves an auditory nerve image and its corresponding sample frequency and
%   filter frequencies to a .mat file on disk.
%
% Input arguments:
%   inANI = auditory nerve image array
%   inANIFreq = sample frequency of the auditory nerve image
%   inANIFilterFreqs = filter frequencies array
%   inName = the name of the .mat file for storing the nerve image
%            if empty or not specified, 'ANI.mat' is used by default
%   inPath = path to the .mat file
%            if empty or not specified, IPEMRootDir('code')\Temp is used
%            by default
%   inANIName = name for the auditory nerve image array in the mat file
%               if empty or not specified, 'ANI' is used by default
%   inANIFreqName = name for the sample frequency
%                   if empty or not specified, 'ANIFreq' is used by default
%   inANIFilterFreqsName = name for the filter frequencies array
%                          if empty or not specified, 'ANIFilterFreqs' is used
%                          by default
%   inAppend = if 1, the variables are appended to the mat file (if it already
%              exists) otherwise, a new mat file is created
%              if empty or not specified, 0 is used by default
%
% Example:
%   IPEMSaveANI(ANI,ANIFreq,ANIFilterFreqs,'ANIs','c:\','Schum1','FreqSchum1',...
%               'FilterFreqsSchum1');
%
% Authors:
%   Koen Tanghe - 20000515
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
[inANI,inANIFreq,inANIFilterFreqs,inName,inPath,inANIName,inANIFreqName,inANIFilterFreqsName,inAppend] = ...
    IPEMHandleInputArguments(varargin,4,{[],[],[],'ANI',fullfile(IPEMRootDir('code'),'Temp'),...
        'ANI','ANIFreq','ANIFilterFreqs',0});

% Setup file name
theFile = fullfile(inPath,inName);
theSpec = IPEMStripFileSpecification(theFile);
if ~strcmpi(theSpec.Extension,'mat')
    theFile = [theFile '.mat'];
end

% Delete old file first if we don't want to append
if (inAppend ~= 1)
    if ~isempty(dir(theFile))
        delete(theFile);
    end
end

% Save the variables
IPEMSaveVar(theFile,inANIName,inANI);
IPEMSaveVar(theFile,inANIFreqName,inANIFreq);
IPEMSaveVar(theFile,inANIFilterFreqsName,inANIFilterFreqs);

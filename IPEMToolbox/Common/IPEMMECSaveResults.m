function IPEMMECSaveResults(varargin)
% Usage:
%   IPEMMECSaveResults(inFileName,inFilePath,inSound,inSampleFreq,...
%                      inPeriods,inBestPeriodIndices,inAnalysisFreq,...
%                      inPatterns,inPatternLengths,inPatternFreq,
%                      inOriginalSignalFreq,inNoiseBands,inANIFilterFreqs,...
%                      inAppend,inSuffix)
%
% Description:
%   Utility function that saves the results of IPEMMECExtractPatterns, so that
%   resynthesis can still be done at a later date, after reloading this data.
%
% Input arguments:
%   inFileName = name of the .mat file to save the results to
%   inFilePath = full path to the location where the file must be saved
%                if empty, IPEMRootDir('output') is used by default
%   inSound = original sound
%   inSampleFreq = sample frequency of inSound (in Hz)
%   inPeriods = (see IPEMMECExtractPatterns)
%   inBestPeriodIndices = (idem)
%   inAnalysisFreq = (idem)
%   inPatterns = (see IPEMMECSynthesis)
%   inPatternLengths = (idem)
%   inPatternFreq = (idem)
%   inOriginalSignalFreq = (idem)
%   inNoiseBands = (idem)
%   inANIFilterFreqs = ANI filter frequencies (empty if non-ANI data)
%   inAppend = if non-zero, the data is appended to the data already in the file
%              if zero, empty or not specified, all old data is cleared
%   inSuffix = suffix that should be added to the general names
%              (this facilitates saving multiple result sets)
%              if empty or not specified, no suffix is used by default
%
% Remarks:
%   1. For generality, the given input arguments are saved under the following
%      names:
%      'Sound','SampleFreq',Periods','BestPeriodIndices','AnalysisFreq','P',
%      'PLengths','PFreq','OrginalFreq','NoiseBands' and 'ANIFilterFreqs'.
%      A suffix can be added to these names if inSuffix is given.
%   2. You can later reload the data and perform another resynthesis using
%      IPEMMECSynthesis like shown in the example below
%
% Example:
%   IPEMMECSaveResults('MEC_ligeti.mat','e:\temp',s,fs,Periods,...
%                      BestPeriodIndices,AnalysisFreq,P,PLengths,PFreq,...
%                      RMSFreq,NoiseBands,ANIFilterFreqs);
%   ... 
%   DataStruct = load('e:\temp\MEC_ligeti.mat');
%   IPEMMECReSynthUI('Start',DataStruct);
%
% Authors:
%   Koen Tanghe - 20010228
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
[inFileName,inFilePath,inSound,inSampleFreq,inPeriods,inBestPeriodIndices,inAnalysisFreq,...
        inPatterns,inPatternLengths,inPatternFreq,inOriginalSignalFreq,inNoiseBands,inANIFilterFreqs,...
        inAppend,inSuffix] = ...
    IPEMHandleInputArguments(varargin,14,{[],[],[],[],[],[],[],[],[],[],[],[],[],0,''});

% Setup names and file
Names = {'Sound','SampleFreq','Periods','BestPeriodIndices','AnalysisFreq',...
         'P','PLengths','PFreq','OriginalFreq','NoiseBands','ANIFilterFreqs'};
if ~isempty(inSuffix)
    Names = strcat(Names,inSuffix);
end
File = fullfile(inFilePath,inFileName);

% Feedback
fprintf(1,'Saving MEC results to %s ... ',File);

% Save data to file
for i = 1:length(Names)
    IPEMSaveVar(File,Names{i},varargin{i+2});
end

% Feedback
fprintf(1,'Done.\n');

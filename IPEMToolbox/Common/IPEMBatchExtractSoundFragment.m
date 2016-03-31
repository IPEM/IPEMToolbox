function IPEMBatchExtractSoundFragment(varargin)
% Usage:
%   IPEMBatchExtractSoundFragment(inFragment,inInputDirectory,inFilePattern,...
%                                 inOutputDirectory,inNewNameFormat,...
%                                 inCreateDir,inFadeInOutTime,...
%                                 inPreferNegativeTimes)
%
% Description:
%   Extracts a fragment from all sound files in a specific directory matching 
%   the specified wildcard pattern, and saves each fragment to the specified 
%   output directory appending a suffix.
%
% Input arguments:
%   inFragment = Fragment that should be extracted.
%                Specified as [StartTime EndTime] where both elements are in s.
%                If StartTime < 0, it is referenced from the end of file.
%                If EndTime <= 0, it is referenced from the end of the file.
%   inInputDirectory = Directory where the sound files are located.
%   inFilePattern = Wildcard pattern for the files that should be processed.
%                   If empty or not specified, '*.wav' is used by default.
%   inOutputDirectory = Directory where the extracted sound fragments should be 
%                       written. If empty or not specified, inInputDirectory is 
%                       used by default.
%   inNewNameFormat = Format string that should be used for the file names of
%                     the new sound fragments. This must be a format string 
%                     where the first type specifier is a %s (will be replaced 
%                     by the original base file name), and the second and third 
%                     are a %f (will be replaced by the start resp. end time
%                     in seconds). 
%                     If empty or not specified, '%s_%gs_%gs" is used by default.
%   inCreateDir = If 1, the output directory is created if it doesn't exist yet.
%                 If empty or not specified, 1 is used by default.
%   inFadeInOutTime = Time over which the beginning and end should be faded in
%                     repectively out (in s).
%                     If empty or not specified, 0.010 s is used by default.
%   inPreferNegativeTimes = If 0, negative start or end times will be shown as 
%                           the actually used times in the output file names.
%                           Otherwise, negative times will be kept.
%                           If empty or not specified, 1 is used by default.
%
% Example:
%   IPEMBatchExtractSoundFragment([60 90],'D:\Temp\','*.wav','D:\Temp2\');
%
% Authors:
%   Koen Tanghe - 20040702
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
[inFragment,inInputDirectory,inFilePattern,inOutputDirectory,inNewNameFormat,inCreateDir,inFadeInOutTime,inPreferNegativeTimes] = ...
    IPEMHandleInputArguments(varargin,3,{[],[],'*.wav',[],'%s_%gs_%gs',1,0.010,1});
if isempty(inOutputDirectory)
    inOutputDirectory = inInputDirectory;
end

% Check output directory
if (inCreateDir)
    IPEMEnsureDirectory(inOutputDirectory,1);
else
    if (IPEMEnsureDirectory(inOutputDirectory,0) == 0)
        error('The given output directory does not exist.');
    end
end

% Get the list of files to process
D = dir(fullfile(inInputDirectory,inFilePattern));
I = find(~[D.isdir]);
for i = 1:length(I)
 
    % Get the base name and extension
    FileName = D(I(i)).name;
    [a,BaseName,Extension] = fileparts(FileName);

    % Get the sound file duration
    [a,fs,theSize] = IPEMReadSoundFile(FileName,inInputDirectory,'size');
    Dur = theSize(1)/fs;
    
    % Handle negative start and end times
    theFragment = inFragment;
    if (theFragment(1) < 0)
        theFragment(1) = Dur+theFragment(1);
    end
    if (theFragment(2) <= 0)
        theFragment(2) = Dur+theFragment(2);
    end
    
    % Check the fragment start and end times against the duration
    if or(any(theFragment > [Dur Dur]),any(theFragment < [0 0]))
        if (~isequal(warning,'off'))
            disp(['File ' FileName ' could not be processed because the given start and/or end time are not valid for this file.']);
        end
        continue;
    end
    
    % Now extract the fragment
    try
            
        [s,fs] = IPEMReadSoundFile(FileName,inInputDirectory,theFragment);
        s = IPEMFadeLinear(s,fs,inFadeInOutTime);
        if (inPreferNegativeTimes)
            NewFileName = [sprintf(inNewNameFormat,BaseName,inFragment(1),inFragment(2)) Extension];
        else
            NewFileName = [sprintf(inNewNameFormat,BaseName,theFragment(1),theFragment(2)) Extension];
        end
        IPEMWriteSoundFile(s,fs,NewFileName,inOutputDirectory);
    catch
        if (~isequal(warning,'off'))
            disp(['File ' FileName ' could not be processed (probably because it''s too short for the given start and/or end time).']);
        end
    end
end

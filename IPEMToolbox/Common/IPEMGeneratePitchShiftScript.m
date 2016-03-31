function IPEMGeneratePitchShiftScript(varargin)
% Usage:
%   IPEMGeneratePitchShiftScript(inFileName,inFilePath,inCentsToRaise,...
%                                inCentsPerStep,inScriptFilePath,inOnlyShift)
%
% Description:
%   Generates a CoolEdit2000 script for creating a sound file containing
%   appended pitch-shifted versions of the original sound file.
%   Generated pitch-shifted sounds can be mixed with original sound.
%
%   Way to go:
%     1. run this function on your sound file
%     2. start CoolEdit2000 and open the sound file
%     3. go to 'Options\Scripts & Batch Processing' and open the script file
%     4. deselect 'Pause at Dialogs', select the script 'shift' and press 'Run'
%     5. wait...
%     6. save your sound file (either using suffix '_shifted' or '_mixed')
%
% Input arguments:
%   inFileName = name of the sound file to generate a script for
%   inFilePath = path to the location of the sound file
%                if empty or not specified, IPEMRootDir('input')\Sounds is used
%                by default
%   inCentsToRaise = maximum number of cents for the pitch to raise
%                    if empty or not specified, 1200 is used by default
%   inCentsPerStep = number of cents the pitch will raise per step
%                    if empty or not specified, 100 is used by default
%   inScriptFilePath = path to the location where the script file will be saved
%                      if empty or not specified, the same location as the sound
%                      file is used by default
%   inOnlyShift = if 1, the script will only generate the shifted versions
%                 of the sound signal (from low to high)
%                 otherwise, it will immediately mix these shifted versions with
%                 the appropriate number of copies of the original sound signal
%                 if empty or not specified, 0 is used by default
%                 (mixing enabled)
%
% Output:
%   A CoolEdit2000 script with the same name as the sound file, but with the
%   extension .scp
%
% Remarks:
%   CoolEdit2000 scripts contain selection ranges and sample rates (which are
%   different for different sound files), so you can only use the script for the
%   sound file you created it for (or for sound files with exactly the same
%   number of samples and sampling rate)...
%
%   You can download a trial version of CoolEdit2000 from:
%       http://www.syntrillium.com
%   Make sure you select function groups 1 (Save...) and 3 (Stretching...)
%   in order to be able to run the script.
%
% Example:
%   IPEMGeneratePitchShiftScript('bottle.wav');
%
% Authors:
%   Koen Tanghe - 20000418
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
[inFileName,inFilePath,inCentsToRaise,inCentsPerStep,inScriptFilePath,inOnlyShift] = ...
    IPEMHandleInputArguments(varargin,2,{[],fullfile(IPEMRootDir('input'),'Sounds'),1200,100,[],0});

% Additional checking
theFile = fullfile(inFilePath,inFileName);
theSpec = IPEMStripFileSpecification(theFile);
if isempty(inScriptFilePath)
   inScriptFilePath = theSpec.Path;
end;

% Read the sound file and get its length and sample rate
[s,fs,bits] = wavread(theFile);
L = size(s,1);

% Setup script file
theScriptFileName = [theSpec.Name '.scp'];
theScriptFile = fullfile(inScriptFilePath,theScriptFileName);
FID = fopen(theScriptFile,'wt');
if (FID == -1)
   fprintf(2,['ERROR: Could not open file [' theScriptFile '] for writing...']);
   return;
end;

% Calculate the frequency factors
theCents = 0:inCentsPerStep:inCentsToRaise;
theFactors = 2.^((theCents/100)/12);
N = length(theFactors);

% Write header of script once
fprintf(FID,'Collection: New Collection\n');
fprintf(FID,'Title: shift\n');
if (inOnlyShift)
    MixingOption = 'shift only';
else
    MixingOption = 'shift + mix';
end
fprintf(FID,sprintf('Description: CoolEdit2000 pitch shift script for %s (%d cents in steps of %d, %s) %s\n', ...
                    theSpec.FileName,inCentsToRaise,inCentsPerStep,MixingOption,datestr(now)));
fprintf(FID,'Mode: 2\n');
fprintf(FID,'\n');

% Copy original sound and paste once at 50% once
fprintf(FID,'Selected: none at 0 scaled %d SR %d\n',L,fs);
fprintf(FID,'cmd: Channel Both\n');
fprintf(FID,'\n');
fprintf(FID,'Selected: 0 to %d scaled %d SR %d\n',L-1,L,fs);
fprintf(FID,'cmd: Copy\n');
fprintf(FID,'1: 0\n');
fprintf(FID,'\n');
fprintf(FID,'cmd: Paste Special\n');
fprintf(FID,'1: 0.5\n');
fprintf(FID,'2: 0.5\n');
fprintf(FID,'3: 1\n');
fprintf(FID,'4: 1\n');
fprintf(FID,'5: 0\n');
fprintf(FID,'6: 0\n');
fprintf(FID,'7: \n');
fprintf(FID,'8: 2\n');
fprintf(FID,'9: 0\n');
fprintf(FID,'\n');

% Copy 50% sound
fprintf(FID,'cmd: Cut\n');
fprintf(FID,'1: 0\n');
fprintf(FID,'\n');

Offset = 0;
if (~inOnlyShift)
    % Write copies
    fprintf(FID,'cmd: Paste Special\n');
    fprintf(FID,'1: 1\n');
    fprintf(FID,'2: 1\n');
    fprintf(FID,'3: %d\n',N);
    fprintf(FID,'4: 1\n');
    fprintf(FID,'5: 1\n');
    fprintf(FID,'6: 0\n');
    fprintf(FID,'7: \n');
    fprintf(FID,'8: 2\n');
    fprintf(FID,'9: 0\n');
    Offset = N*L;
end

% Write subsequent pitch shifts
for i = 1:N
   theCERatio = 1/theFactors(i); % Ratio used by CoolEdit
   fprintf(FID,'\n');
   
   % Paste at the right spot
   fprintf(FID,'Selected: none at %d scaled %d SR %d\n',Offset+(N-1)*L,L,fs);
   fprintf(FID,'cmd: Paste\n');
   fprintf(FID,'1: 0\n');
   fprintf(FID,'\n');
   
   % Pitch shift
   fprintf(FID,'cmd: Time/Pitch\\Stretch\n');
   fprintf(FID,'1: %.4f\n',theCERatio);
   fprintf(FID,'2: %.4f\n',theCERatio);
   fprintf(FID,'3: 0\n');
   fprintf(FID,'4: 1\n');
   fprintf(FID,'5: 32\n');
   fprintf(FID,'6: 2\n');
   fprintf(FID,'7: 0.25\n');
   fprintf(FID,'8: 5\n');
   fprintf(FID,'9: 5\n');
   fprintf(FID,'10: 0\n');
   fprintf(FID,'11: 1\n');
end;

if (~inOnlyShift)
    % Cut and Paste Special
    fprintf(FID,'\n');
    fprintf(FID,'Selected: 0 to %d scaled %d SR %d\n',N*L-1,L,fs);
    fprintf(FID,'cmd: Cut\n');
    fprintf(FID,'1: 0\n');
    fprintf(FID,'\n');
    fprintf(FID,'cmd: Paste Special\n');
    fprintf(FID,'1: 1\n');
    fprintf(FID,'2: 1\n');
    fprintf(FID,'3: 1\n');
    fprintf(FID,'4: 1\n');
    fprintf(FID,'5: 0\n');
    fprintf(FID,'6: 0\n');
    fprintf(FID,'7: \n');
    fprintf(FID,'8: 0\n');
    fprintf(FID,'9: 0\n');
    fprintf(FID,'\n');
end

% Deselect all and end
fprintf(FID,'\n');
fprintf(FID,'Selected: none at 0 scaled %d SR %d\n',L,fs);
fprintf(FID,'End:\n');
fclose(FID);

% General feedback
fprintf(1,'Generated CoolEdit2000 script [%s]\n',theScriptFile);
fprintf(1,'for use with sound file [%s]\n',theFile);
fprintf(1,'doing pitch shifting up to %d cents in steps of %d cents (%s).\n',inCentsToRaise,inCentsPerStep,MixingOption);

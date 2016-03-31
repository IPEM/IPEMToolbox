function varargout = IPEMReadSoundFile (varargin)
% Usage:
%   [outSignal,outSampleFreq,outSize,outFile] = ...
%     IPEMReadSoundFile(inFileName,inFilePath,inSection,inPlotFlag)
%
% Description:
%   Reads (part of) a sound file into memory.
%
% Input arguments:
%   inFileName = name of the sound file (with extension)
%                if empty or not specified, the standard "open file" dialog box
%                can be used to select a sound file (if the user then presses
%                'Cancel', all outputs will be empty)
%   inFilePath = path to the sound file (if it does not exist, the current
%                directory is used)
%                use the empty string '' if inFilename already contains a full 
%                path specification (no extra path will be prepended)
%                if empty or not specified, IPEMRootDir('input')\Sounds is used
%                by default (if it exists)
%   inSection = section of the sound file to read, given as [start end] (in s)
%               if 'size', no samples are read: outSignal will be empty, and
%               only outSampleFreq and outSize will have relevant values
%               if empty or not specified, the entire sound file is read
%   inPlotFlag = if non-zero, a plot is generated
%                if empty or not specified, 0 is used by default
%
% Output:
%   outSignal = the sound signal (each row represents a channel)
%   outSampleFreq = the frequency at which the sound was sampled (in Hz)
%   outSize = the size of the entire sound file returned as
%             [NumSamples NumChannels] (optional)
%             where NumSamples = number of samples in each channel
%                   NumChannels = number of channels
%   outFile = entire path specification of the sound file
%
% Remarks:
%   The 'end' in the section specification is exclusive:
%   if you want to read the first second of a sound file sampled at 1000 Hz,
%   you should specify [0 1] for inSection (and not [0 0.999]). This will read
%   samples 1 to 1000, which is a full second (the sample at time 1 s is not
%   read!).
%
% Example:
%   [s,fs] = IPEMReadSoundFile('schum1.wav');
%
% Authors:
%   Koen Tanghe - 20040409
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

% Special handling of second input argument
theNoPathFlag = 0;
if (length(varargin) >= 2)
    % Handle empty string as 'no path prepending'
    if (isempty(varargin{2}) & strcmp(class(varargin{2}),'char'))
        theNoPathFlag = 1;
    end
end

% Check input arguments
[inFileName,inFilePath,inSection,inPlotFlag] = IPEMHandleInputArguments(varargin,1,...
    {[],fullfile(IPEMRootDir('input'),'Sounds'),[],0});

% Check output arguments
if ~isempty(nargchk(2,4,nargout))
   error('Wrong number of output arguments.');
end;

if (theNoPathFlag)
    % Empty the file path
    inFilePath = '';
else
    % Use standard "open file" dialog
    if (isempty(inFileName))
        OldPath = cd;
        if (IPEMEnsureDirectory(inFilePath,0))
            cd(inFilePath);
        end
        [inFileName,inFilePath] = uigetfile('*.wav;*.snd;*.au','Select a sound file to read:');
        cd(OldPath);
        % If user pressed Cancel, set all outputs to [] and return
        if (inFileName == 0)
            varargout{1} = [];
            varargout{2} = [];
            if (nargout >= 3)
                varargout{3} = [];
            end;
            if (nargout >= 4)
                varargout{4} = [];
            end;
            return;
        end
    end
end

% Setup the complete sound file specification
theFile = fullfile(inFilePath,inFileName);
theParts = IPEMStripFileSpecification(theFile);
theExtension = lower(theParts.Extension);

% Get info on the sound file
if (strcmp(theExtension,'wav'))
    [theSize,theSampleFreq] = wavread(theFile,'size');
elseif or(strcmp(theExtension,'snd'),strcmp(theExtension,'au'))
    [theSize,theSampleFreq] = auread(theFile,'size');
else
    error('ERROR: Sound file extension should be .wav, .snd or .au');
end
if (nargout >= 3)
    varargout{3} = theSize;
end;
if (nargout >= 4)
    varargout{4} = theFile;
end;

% Check section
L = theSize(1);
if ischar(inSection) 
    if strcmp(lower(inSection),'size')
        varargout{1} = [];
        varargout{2} = theSampleFreq;
        return;
    end
else
    if isempty(inSection)
        Section = [1 L];
    else
        Section = round([inSection(1) inSection(2)-1/theSampleFreq]*theSampleFreq+1);
        if or(any(Section > [L L]),any(Section < [1 1]))
            error(sprintf('ERROR: Illegal section (sound signal duration is %f s)',L/theSampleFreq));
        end
    end
end

% Read section
if (strcmp(theExtension,'wav'))
    [varargout{1},varargout{2}] = wavread(theFile,Section);
elseif or(strcmp(theExtension,'snd'),strcmp(theExtension,'au'))
    [varargout{1},varargout{2}] = auread(theFile,Section);
end;  
varargout{1} = varargout{1}'; % Transpose: we use channels in rows !

% Plot if needed
if (inPlotFlag)
    HFig = figure;
    NChan = size(varargout{1},1);
    t = (0:size(varargout{1},2)-1)/varargout{2};
   if (NChan == 1)
        plot(t,varargout{1}');
        axis([0 t(end) -1 1]);
        title('Sound signal');
        xlabel('Time (s)');
        ylabel('Amplitude');
    else
        for i = 1:NChan
            subplot(NChan,1,i);
            plot(t,varargout{1}(i,:));
            axis([0 t(end) -1 1]);
            title(['Sound signal channel ' num2str(i)]);
            ylabel('Amplitude');
        end
        xlabel('Time (s)');
    end
    IPEMSetFigureLayout(HFig);
end

function [outSegments,outActualWidth,outActualInterval] = IPEMGenerateFrameBasedSegments(varargin)
% Usage:
%   [outSegments,outActualWidth,outActualInterval] = ...
%     IPEMGenerateFrameBasedSegments(inSignalOrDuration,inSampleFreq,...
%                                    inFrameWidth,inFrameInterval,...
%                                    inIncludeIncompleteFrames)
%
% Description:
%   Generates (overlapping) time segments using equally sized frames.
%
% Input arguments:
%   inSignalOrDuration = if this is a vector, it is the signal for which to
%                        calculate the frame-based time segments
%                        if this is a scalar, it is the duration of a signal
%                        (in s) (allows to generate segments even if you don't
%                        have a signal)
%   inSampleFreq = sample frequency of inSignal (in Hz)
%   inFrameWidth = wanted width of 1 frame (in s)
%   inFrameInterval = wanted interval between frames (in s)
%   inIncludeIncompleteFrames = if non-zero, incomplete frames at the end are
%                               included as well (different lengths!)
%                               if empty or not specified, 0 is used by default
%
% Output:
%   outSegments = 2-column array of segments:
%                 each row contains the start and end moment of a segment (in s)
%   outActualWidth = width used (to get an integer number of samples)
%   outActualInterval = interval used (to get an integer number of samples)
%
% Remarks:
%   Because of the discrete nature of sampled signals, the frame width and
%   interval requested for by the caller might not be representable in the
%   resolution specified by the sample frequency.
%   In that case, the nearest width and interval that are integer multiples of
%   the sample period will be used. This is what the outActualWidth and
%   outActualInterval arguments are for.
%
% Example:
%   [Segments,Width,Interval] = IPEMGenerateFrameBasedSegments(1,100,0.1,0.025)
%
%   Width will be 0.1 s (as requested)
%   Interval will become 0.03 s, since 0.025 s does not exist in a 1/100 s
%   resolution 
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
[inSignalOrDuration,inSampleFreq,inFrameWidth,inFrameInterval,inIncludeIncompleteFrames] = ...
    IPEMHandleInputArguments(varargin,5,{[],[],[],[],0});

% Check input arguments
if ((inFrameWidth < 1/inSampleFreq) | (inFrameInterval < 1/inSampleFreq))
    fprintf(2,'ERROR: frame with and interval must be bigger than sampling period !\n');
    return;
end

% Be sure to get an integer number of samples
WSamples = round(inFrameWidth*inSampleFreq);
outActualWidth = WSamples/inSampleFreq;
ISamples = round(inFrameInterval*inSampleFreq);
outActualInterval = ISamples/inSampleFreq;

% Simple calculation of the segments
[R,C] = size(inSignalOrDuration);
if ((R == 1) & (C == 1))
    Duration = inSignalOrDuration;
else
    Duration = C/inSampleFreq;
end

if (~inIncludeIncompleteFrames)
    Starts = 0:outActualInterval:Duration-outActualWidth;
    outSegments = [Starts ; Starts+outActualWidth-1/inSampleFreq]';
else
    Starts = 0:outActualInterval:Duration-1/inSampleFreq;
    Ends = Starts+outActualWidth-1/inSampleFreq;
    Ends = IPEMClip(Ends,[],Duration-1/inSampleFreq,[],[]);
    outSegments = [Starts ; Ends]';
end

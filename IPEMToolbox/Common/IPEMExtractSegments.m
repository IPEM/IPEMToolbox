function outSignalSegments = IPEMExtractSegments(inSignal,inSampleFreq,inTimeSegments)
% Usage:
%   outSignalSegments = IPEMExtractSegments(inSignal,inSampleFreq,inTimeSegments)
%
% Description:
%   Extracts segments from the signal according to the given time segments.
%
% Input arguments:
%   inSignal = input signal (1 row vector)
%   inSampleFreq = sample frequency of inSignal (in Hz)
%   inTimeSegments = time segments for cutting up the input signal (in s)
%                    (each row contains the start and end of a time segment)
%                    if this is a positive scalar, the signal is divided into
%                    inTimeSegments parts of equal size + an additional segment
%                    containing the remaining part of the signal (which will
%                    contain less than inTimeSegments samples)
%                    if this is a negative scalar, the signal is divided into
%                    -inTimeSegments parts where some segments will contain
%                    1 sample more than other segments
%
% Output:
%   outSignalSegments = 1 column cell (!) vector of signal segments
%                       (each row contains a segment)
%
% Example:
%   Parts = IPEMExtractSegments(s,fs,OnsetSegments);
%   FirstSegment = Parts{1}; % etc...
%
% Authors:
%   Koen Tanghe - 20000510
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

% Get number of segments
N = size(inTimeSegments,1);
L = size(inSignal,2);

% Check for scalar inTimeSegments
if ((N == 1) & (size(inTimeSegments,2) == 1))
    if (inTimeSegments > 0)
        NDiv = inTimeSegments;
        Width = floor(L/NDiv)/inSampleFreq;
        inTimeSegments = IPEMGenerateFrameBasedSegments(L/inSampleFreq,inSampleFreq,Width,Width,1);
    else
        NDiv = -inTimeSegments;
        Starts = (round(1:(L/NDiv):L)-1)/inSampleFreq;
        Ends = [Starts(2:end)-1/inSampleFreq (L-1)/inSampleFreq];
        inTimeSegments = [Starts ; Ends]';
    end
    N = size(inTimeSegments,1);
end

% Find bounds in samples
TimeSegments = IPEMClip(round(inTimeSegments*inSampleFreq)+1,1,L);

% Extract segments from signal
outSignalSegments = cell(N,1);
for i = 1:N
    outSignalSegments{i} = inSignal(TimeSegments(i,1):TimeSegments(i,2));
end

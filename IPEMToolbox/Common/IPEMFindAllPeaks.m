function outPeakIndices = IPEMFindAllPeaks (varargin)
% Usage:
%   thePeakIndices = IPEMFindAllPeaks (inSignal,inFlatPreference,inPlotFlag)
%
% Description:
%   This function finds the indices of all peaks in the given signal vector.
%   A peak is taken to occur whenever a rising part in the signal is followed
%   by a falling part.
%
% Input arguments:
%   inSignal = the signal that is scanned for peaks (a row vector)
%   inFlatPreference = preference for choosing exact position in case of
%                      flat peaks:
%                      if 'left', the leftmost point of a flat peak is chosen
%                      if 'center', the center of a flat peak is chosen
%                      if 'right', the rightmost point of a flat peak is chosen
%                      if empty or not specified, 'center' is used by default
%   inPlotFlag = if non-zero, plots are generated
%                if empty or not specified, 0 is used by default
%
% Output:
%   outPeakIndices = a vector with the indices of the peaks (could be empty!) 
%
% Example:
%   PeakIndices = IPEMFindAllPeaks(Signal,'center');
%
% Authors:
%   Koen Tanghe - 20000509
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
[inSignal,inFlatPreference,inPlotFlag] = IPEMHandleInputArguments(varargin,2,{[],'center',0});

% Differentiate the signal and get the signs
N = length(inSignal);
Diff = diff(inSignal);

% Find the positive-to-negative zero crossings in the differentiated signal:
% this yields all peaks in the signal
Peaks = zeros(1,N);
Start = 0;
i = 1;
% Same loop, but split up to increase performance
switch (inFlatPreference)
case 'left'
    while i < N
        if (Diff(i) > 0)
            Start = i;
        elseif and(Diff(i) < 0, Start ~= 0)
            Peaks(Start+1) = 1;
            Start = 0;
        end
        i = i + 1;
    end
    
case 'center'
    while i < N
        if (Diff(i) > 0)
            Start = i;
        elseif and(Diff(i) < 0, Start ~= 0)
            Peaks(floor((i+Start+1)/2)) = 1;
            Start = 0;
        end
        i = i + 1;
    end
    
case 'right'
    while i < N
        if (Diff(i) > 0)
            Start = i;
        elseif and(Diff(i) < 0, Start ~= 0)
            Peaks(i) = 1;
            Start = 0;
        end
        i = i + 1;
    end
    
end


% Return the indices
outPeakIndices = find(Peaks > 0);

% Plot if needed
if (inPlotFlag == 1)
    figure;
    plot(inSignal); axis tight;
    hold on;
    h = line([outPeakIndices ; outPeakIndices],repmat([min(inSignal) max(inSignal)]',1,length(outPeakIndices)));
    set(h,'color',[0.5 0.5 0.5]);
    hold off;
end;

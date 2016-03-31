function [outOnsetSignal, outOnsetFreq] = IPEMCalcOnsets (varargin)
% Usage:
%   [outOnsetSignal,outOnsetFreq] = 
%     IPEMCalcOnsets(inSignal,inSampleFreq,inPlotFlag)
%
% Description:
%   This function calculates the onsets for the given signal using the auditory
%   model and an integrate-and-fire neural net layer.
%
% Input arguments:
%   inSignal = signal to be processed
%   inSampleFreq = sample frequency of input signal (in Hz)
%   inPlotFlag = if non-zero, a plot is generated at the end
%                if empty or not specified, 0 is used by default
%
% Output:
%   outOnsetSignal = signal having a non-zero value for an onset, and zero
%                    otherwise (the higher the non-zero value, the more our
%                    system is convinced that the onset is really an onset)
%   outOnsetFreq = sample frequency of outOnsetSignal (in Hz)
% 
% Example:
%   [OnsetSignal,OnsetFreq] = IPEMCalcOnsets(s,fs);
%
% Authors:
%   Koen Tanghe - 20030327
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
[inSignal,inSampleFreq,inPlotFlag] = IPEMHandleInputArguments(varargin,3,{[],[],0});

% Calculate ANI
% -------------
if 1 % TBCByKoen - just to make sure this is set to 1 upon release !
    fprintf(1,'Calculating Auditory Nerve Image...\n');
    [ANI,ANIFreq,ANIFilterFreqs] = IPEMCalcANI(inSignal,inSampleFreq,[],0);
    IPEMSaveANI(ANI,ANIFreq,ANIFilterFreqs);
else   
    fprintf(1,'Loading last calculated Auditory Nerve Image...\n');
    [ANI,ANIFreq,ANIFilterFreqs] = IPEMLoadANI;
end;

% Calculate onsets
% ----------------
[outOnsetSignal,outOnsetFreq] = IPEMCalcOnsetsFromANI(ANI,ANIFreq,0);

% Plot results if needed
% ----------------------
if (inPlotFlag ~= 0)
    
    figure;
    
    subplot(211);
    TSignal = (0:length(inSignal)-1)/inSampleFreq;
    plot(TSignal,inSignal);
    axis([0 max(TSignal) -1 1]);
    ylabel('Signal amplitude');
    title('Original sound signal');
    
    subplot(212);
    TOnsets = (0:length(outOnsetSignal)-1)/outOnsetFreq;
    plot(TOnsets,outOnsetSignal);
    axis([0 max(TOnsets) 0 1.25]);
    ylabel('Onset relevance');
    title('Detected onsets');
    xlabel('Time (s)');
    
    figure;
    plot(TSignal,inSignal);
    xlabel('Time (s)');
    ylabel('Signal amplitude');
    title('Segmentation');
    axis([0 max(TOnsets) -1 1]);
    Indices = find(outOnsetSignal ~= 0);
    T = (Indices-1)/outOnsetFreq;
    for i = 1:length(T)
        h = line([T(i) T(i)],[-1 1]);
        set(h,'color','red');
    end
end

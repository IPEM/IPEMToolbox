function outLeakyIntegration = IPEMLeakyIntegration (varargin)
% Usage:
%   outLeakyIntegration = ...
%     IPEMLeakyIntegration(inSignal,inSampleFreq,inHalfDecayTime,...
%                          inEnlargement,inPlotFlag)
%
% Description:
%   Calculates leaky integration with specified half decay time.
%
% Input arguments:
%   inSignal = (multi-dimensional) input signal, each row representing a channel
%              leaky integration is performed for each channel
%   inSampleFreq = sample frequency of inSignal (in Hz)
%   inHalfDecayTime = time (in s) at which an impulse would be reduced to half
%                     its value
%                     if empty or not specified, 0.1 is used by default
%   inEnlargement = time (in s) to enlarge the input signal
%                   if -1, 2*inHalfDecayTime is used
%                   if empty or not specified, 0 is used by default
%   inPlotFlag = if non-zero, plots are generated
%                if empty or not specified, 0 is used by default
%
% Output:
%   outLeakyIntegration = the leaky integration of the input signal
%
% Remarks:
%   Sample frequency of outLeakyIntegration is the same as inSampleFreq.
%
% Example: 
%   LeakyIntegration = ...
%     IPEMLeakyIntegration(PeriodicyPitchMatrix,PeriodicityPitchFreq,0.1,0.1);
%
% Authors:
%   Marc Leman - 19991224
%   Koen Tanghe - 20010129
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
[inSignal,inSampleFreq,inHalfDecayTime,inEnlargement,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,3,{[],[],0.1,0.0,0});

% Additional checking
if (isempty(inSignal))
    fprintf(2,'ERROR: You must specify the input signal as first argument.\n');
    return;
end;
if (isempty(inSampleFreq))
    fprintf(2,'ERROR: You must specify the sample frequency as second argument.\n');
    return;
end;
if (inEnlargement == -1)
    inEnlargement = 2*inHalfDecayTime;
end;

% Setup integrator
if (inHalfDecayTime ~= 0)
    integrator = 2^(-1/(inSampleFreq*inHalfDecayTime));
else
    integrator = 0;
end

% Initialize (enlarged) matrices
Matrix = [inSignal zeros(size(inSignal,1),round(inSampleFreq*inEnlargement))];
outLeakyIntegration = [zeros(size(Matrix))];

% Perform leaky integration
outLeakyIntegration(:,1) = Matrix(:,1);
for j = 2:size(Matrix,2)
    outLeakyIntegration(:,j) = (outLeakyIntegration(:,j-1)*integrator) + Matrix(:,j);
end;

% Plot if needed
if (inPlotFlag)
    HFig = figure;
    N = size(Matrix,1);
    T1 = (0:size(Matrix,2)-1)/inSampleFreq;
    T2 = (0:size(outLeakyIntegration,2)-1)/inSampleFreq;
    subplot(211);
    if (N == 1)
        plot(T1,Matrix);
        axis tight;
    else
        imagesc(T1,1:N,Matrix);
        colormap(1-gray);
    end
    Title = 'Original signal';
    if (inEnlargement ~= 0)
        Title = [Title ' (zero-enlarged)'];
    end
    title(Title);
    subplot(212);
    if (N == 1)
        plot(T2,outLeakyIntegration);
        axis tight;
        xlabel('Time (s)');
    else
        imagesc(T2,1:N,outLeakyIntegration);
        colormap(1-gray);
        xlabel('Time (s)');
    end
    title('Integrated signal');
    IPEMSetFigureLayout(HFig);
end

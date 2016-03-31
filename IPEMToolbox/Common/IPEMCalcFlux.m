function outFlux = IPEMCalcFlux (varargin)
% Usage:
%   outFlux = IPEMCalcFlux (inSignal,inSampleFreq,inPlotFlag)
%
% Description:
%   Calculates the flux of the signal, where the flux is defined as
%   the norm of the difference (vector) between the current and the previous
%   values of the (multichannel) signal.
%
% Input arguments:
%   inSignal = input signal (spectral data, for example)
%   inSampleFreq = sample frequency of inSignal (in Hz)
%   inPlotFlag = if non-zero, plots are generated
%                if not specified, 1 is used by default
%
% Output:
%   outFlux = calculated flux
%
% Example:
%   Flux = IPEMCalcFlux (Signal,SampleFreq);
%
% Authors:
%   Koen Tanghe - 20010906
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
[inSignal,inSampleFreq,inPlotFlag] = IPEMHandleInputArguments(varargin,3,{[],[],1});

% Calculate flux
[M N] = size(inSignal);
theDifferences = (inSignal(:,2:N) - inSignal(:,1:N-1));
outFlux = [0 sqrt(sum(theDifferences.^2,1))];

% Show plot if needed
if (inPlotFlag ~= 0)
   theInputTime = (0:(N-1))/inSampleFreq;
   figure;
   subplot(211);
   imagesc(theInputTime,1:M,inSignal);
   colormap(1-gray);
   axis xy;
   subplot(212);
   plot(theInputTime,outFlux);
   axis([0 max(theInputTime) min(outFlux) max(outFlux)+1e-128]);
   xlabel('time (s)');
   title('flux')
end;

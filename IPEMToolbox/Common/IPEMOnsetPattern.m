function [outOnsetPattern,outOnsetPatternFreq] = IPEMOnsetPattern (inSignal,inSampleFreq)
% Usage:
%   [outOnsetPattern,outOnsetPatternFreq] = ...
%     IPEMOnsetPattern(inSignal,inSampleFreq)
%
% Description:
%   Integrate-and-fire neural net for onset-detection.
%   Based on an article by Leslie S. Smith (1996)
%   Neuron dynamics are given by:
%       dA/dt = I(t) - diss*A       with:  A = neurons' accumulated value
%                                          I = input
%                                          diss = dissipation 
% Input arguments:
%   inSignal = a matrix of size [N M], where N = the number of channels
%              and M = the number of samples
%   inSampleFreq = a scalar representing the frequency at which the signal was
%                  sampled (in Hz)
%
% Output:
%   outOnsetPattern = a matrix of size [N M] where an element is 1 if an onset
%                     was detected
%   outOnsetPatternFreq = sample frequency of result (same as inSampleFreq)
%
% Example:
%   [OnsetPattern,OnsetPatternFreq] = IPEMOnsetPattern(Signal,SampleFreq);
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

% Set myDebug to a non-zero value to show figures at the end
myDebug = 1;

% Parameters
Dissipation = 0.4;           % dissipation for the neuron dynamics
Nadj = 6;                    % number of extra adjecent channels that get same input
Nfb = 20;%10 %20             % number of channels receiving feedback
ExtWeight = 2;               % weights for connections between inputs and neurons
IntWeight = 0.5;             % weights for connections between neurons
Threshold = 7; %8 %7         % threshold that must be exceeded by the neuron in order to fire
RefractoryPeriod = 0.04;     % period after firing during which a neuron is insensitive to input (in s)

% Other variables
dT = 1/inSampleFreq;      % step period (in s)
[N,M] = size(inSignal);	  % number of channels and number of samples
A = zeros(1,N);           % accumulator for the neurons
Cext = zeros(N,N);        % connections between inputs and neurons
Cint = zeros(N,N);        % connections between neurons (feedback, 1 time step delay)
RefractTime = zeros(1,N); % represents the time still left to spend in refractory period

% Setting up the external connections
for i = 1:N
  for k = max(1,i-Nadj/2):min(N,i+Nadj/2)
    Cext(k,i) = ExtWeight;
  end
end

% Setting up the internal connections
for i = 1:N
  for k = max(1,i-Nfb/2):min(N,i+Nfb/2)
    if (i ~= k) Cint(k,i) = IntWeight; end;
  end
end

% Initializing the output
outOnsetPattern = zeros(N,M);
outOnsetPatternFreq = inSampleFreq;
theOutput = zeros(N,1);

% Processing the signal
for k = 1:M

  % Determine sensitivity of neurons to input
  Sensing = ones(1,N);                                    % normally, all neurons accept input...
  theIndices = find(RefractTime > 0);                     % but neurons that are in their refractory period...
  Sensing(theIndices) = 0;                                % don't accept input,
  RefractTime(theIndices) = RefractTime(theIndices) - dT; % they only keep waiting for the end of the refractory period

  % Neuron dynamics
  A = (1-Dissipation)*A + (inSignal(:,k)'*Cext + theOutput'*Cint).*Sensing;
  
  % Detect firing
  theOutput = zeros(N,1);                     % normally, the neurons don't fire...
  theIndices = find(A > Threshold);           % but neurons that exceed the threshold value...
  theOutput(theIndices) = 1;                  % do fire,
  A(theIndices) = 0;                          % their value is reset to zero,
  RefractTime(theIndices) = RefractoryPeriod; % and they enter a refractory period

  % Store result
  outOnsetPattern(:,k) = theOutput;

end % of for loop

% For debugging purposes
% Only plot for debug
if myDebug ~= 0
   figure;
   subplot(211);
   IPEMPlotMultiChannel(inSignal,inSampleFreq,'Results of IPEMOnsetPattern','Time (s)','Channel',[],[],[],[],[],0);
   subplot(212);
   IPEMPlotMultiChannel(outOnsetPattern,outOnsetPatternFreq,'','Time (s)','Channel',[],[],[],[],[],0);
end

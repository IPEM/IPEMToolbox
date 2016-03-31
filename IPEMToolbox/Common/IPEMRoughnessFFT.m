function [outRoughness,outSampleFreq,outFFTMatrix1,outFFTMatrix2] = IPEMRoughnessFFT(varargin)
% Usage:
%   [outRoughness,outSampleFreq,outFFTMatrix1,outFFTMatrix2] =
%      IPEMRoughnessFFT(inANI,inANIFreq,inANIFilterFreqs,...
%                       inFrameWidth,inFrameStepSize,inPlotFlag)
%
% Description:
%   Based on Leman (2000) (paper on calculation and visualization of
%   Synchronization & Roughness)
%   This function calculates three outputs:
%   1. The total energy
%   2. The energy in all channels
%   3. The energy spectrum of the neuronal synchronization 
%
% Input arguments:
%   inANI = auditory nerve image to process, where each row represents a channel
%   inANIFreq = sample frequency of the input signal (in samples per second)
%   inANIFilterFreqs = filterbank frequencies used by the auditory model
%   inFrameWidth = the width of the window for analysing the signal (in s)
%                  if empty or not specified, 0.2 s is used by default
%   inFrameStepSize = the stepsize or time interval between two
%                     inFrameWidthInSampless (in s)
%                     if empty or not specified, 0.02 s is used by default
%   inPlotFlag = if non-zero plots are generated
%                if empty or not specified, 0 is used by default
%
% Output:
%   outRoughness = roughness over signal
%   outSampleFreq = sampling rate of outRoughness (in Hz)
%   outFFTMatrix1 = visualisation of energy over channels
%   outFFTMatrix2 = visualisation of energy spectrum for synchronization
%                   (synchronisation index SI)
%
% Remarks:
%   For now, the roughness values are dependend on the used frame width.
%   So, to make usefull comparisons, only results obtained using the same frame
%   width should be compared (this should be fixed in the future...)
%
% Example:
%   [Roughness,RoughnessFreq] = ...
%      IPEMRoughnessFFT(ANI,ANIFreq,ANIFilterFreqs,0.20,0.02,1);
%
% Authors:
%   Marc Leman - 20000910 (made)
%   Koen Tanghe - 20010816 (bug fix + documentation corrections + code cleanup)
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

% Elementary feedback
fprintf(1,'Start of IPEMRoughnessFFT...\n');

% Handle input arguments
[inANI,inANIFreq,inANIFilterFreqs,inFrameWidth,inFrameStepSize,inPlotFlag] = ...
    IPEMHandleInputArguments(varargin,4,{[],[],[],0.2,0.02,0});

% Low and high frequency (now fixed)
inLowFrequency = 5; % Hz
inHighFrequency = 300; % Hz

% Additional checking
if isempty(inANI)
    error('You must specify the name of the input signal as the first argument\n');
end

% Size of the ANI
[ANIRows,ANICols] = size(inANI);

% Produce some feedback
fprintf(1,'inANIFreq       = %d Hz\n', inANIFreq);
fprintf(1,'inLowFrequency  = %d Hz\n', inLowFrequency);
fprintf(1,'inHighFrequency = %d Hz\n', inHighFrequency);
fprintf(1,'inFrameWidth    = %1.3f s\n', inFrameWidth);
fprintf(1,'inFrameStepSize = %1.3f s\n', inFrameStepSize);
fprintf(1,'inPlotFlag      = %d\n', inPlotFlag);

% Setup some parameters
FrameWidthInSamples = round(inFrameWidth * inANIFreq);
FrameStepSize = round(inFrameStepSize * inANIFreq);
outSampleFreq = inANIFreq/FrameStepSize;

% Recall that index in FFT i --> frequency of f = (i-1)/NFFT*fs Hz
%   DC is FFT(1) 
%   NFFT is the length of the FFT frame
NFFT = 2^nextpow2(FrameWidthInSamples); % always even
Window = kron(ones(ANIRows,1),hamming(FrameWidthInSamples)'); 

% Half of NFFT is kept in FFT
NumberOfUniquePoints = ceil((NFFT+1)/2);

% Setup frequency range that corresponds with NumberOfUniquePoints
f = (0:NumberOfUniquePoints-1)/NFFT*inANIFreq;

% Determine beginning and ending of the regions to be computed
Begin = find(f <= inLowFrequency); Begin = max(Begin);
End = find(f <= inHighFrequency); End = max(End);
NumberOfBins = End-Begin+1;
if (NumberOfBins < 64)
    warning(sprintf('Too few fft bins (%d)! Increase frame width (now %f)...\n',NumberOfBins,inFrameWidth));
end

% Some more feedback...
fprintf(1,'outSampleFreq   = %f Hz\n', outSampleFreq);
fprintf(1,'FFT width in Samples: %d\n',NFFT);
fprintf(1,'The frequency width of one FFT-bin is: %.3f Hz\n',(inANIFreq/NFFT));
fprintf(1,'Zone to sum energy on FFT-bins: %f Hz (= bin %d) ---> %f Hz (= bin %d) (so %d bins in total)\n',...
    inLowFrequency,Begin,inHighFrequency,End,NumberOfBins);

% Calculation of the filters
AttenuateWindow = FilterWeights(ANIRows,NumberOfBins,inANIFilterFreqs,Begin,End,f);

% Calculation of the channel weights
W = ChannelWeighting(ANIRows,inANIFilterFreqs,AttenuateWindow);
WKron = kron(W,ones(1,NumberOfBins));

if 0
    figure;
    plot(f(Begin:End),AttenuateWindow');
    figure;
    plot(f(Begin:End),(WKron .* AttenuateWindow)');
    figure;
    hsurf = surf(WKron .* AttenuateWindow);
    set(hsurf,'MeshStyle','row','FaceColor','none');
end

% Calculation of synchronization
fprintf(1,'Calculate Synchronization...\n');
NumOfIterations = length(1:FrameStepSize:ANICols-FrameWidthInSamples+1);
outRoughness = zeros(1,NumOfIterations);
outFFTMatrix1 = zeros(ANIRows,NumOfIterations);
outFFTMatrix2 = zeros(NumberOfBins,NumOfIterations);
fprintf(1,'Progress (in %%): ');
Counter = 1;
Progress = 0;
PrevProgress = -inf;
for i = 1:FrameStepSize:ANICols-FrameWidthInSamples+1
    P = round(Counter/NumOfIterations*100);
    Progress = P-rem(P,5);
    if (Progress ~= PrevProgress)
        fprintf(1,'%d, ',Progress);
        PrevProgress = Progress;
    end
    
    % Extract signal, apply window and calculate fft
    WindowedSignal = Window .* inANI(:,i:i+FrameWidthInSamples - 1);
    FFT = fft(WindowedSignal,NFFT,2);
    A = abs(FFT);
    
    Alfa = 1.6; % ---> Magnitude 2 is Energy;
    DC = kron(A(:,1),ones(1,NumberOfBins));
   
    Weightings = WKron .* AttenuateWindow ./DC;
   
    EnergyOverChannels =  sqrt(sum(Weightings .* (A(:,Begin:End) .^ Alfa),2)/NFFT/FrameWidthInSamples);
    EnergyOverFrequencies = sqrt(sum(Weightings .* (A(:,Begin:End) .^ Alfa),1)/NFFT/FrameWidthInSamples);

    outFFTMatrix1(:,Counter) = EnergyOverChannels;
    outFFTMatrix2(:,Counter) = EnergyOverFrequencies';
    outRoughness(Counter) = sum(EnergyOverChannels)/ANIRows;
    Counter = Counter + 1;
end

% Plot if needed
if (inPlotFlag)
    
    figure;
    subplot(311);
    IPEMPlotMultiChannel(outFFTMatrix1,outSampleFreq,'','','',[],inANIFilterFreqs,5,[],[],1);
    ylabel('Center freq. (Hz)');
    
    subplot(312);
    IPEMPlotMultiChannel(outFFTMatrix2(2:size(outFFTMatrix2,1),:),outSampleFreq,'','','',[],f(Begin:End),20,[],[],1);
    ylabel('Synchr. index (Hz)');
    colormap(1 - gray);
    
    subplot(313);
    plot((1:size(outRoughness,2))/outSampleFreq,outRoughness);
    axis tight;
    ylabel('Roughness');
    
    xlabel('Time (s)')
end

% Some feedback
fprintf(1,'...end of IPEMRoughnessFFT...\n');


% --------------------------------------------------------------------------------

%Here starts the dirty work
function AttenuateWindow = FilterWeights(ANIRows,NumberOfBins,inANIFilterFreqs,Begin,End,f)
fprintf(1,'Setup synchronization filters for all auditory channels\n');

AttenuateWindow = kron(zeros(ANIRows,1),ones(1,NumberOfBins));
for win = 1:ANIRows
    
    Sigmoid = ((win/40).^2 ./ (.04 + ((win/40).^2.8))-win*.007) ;
    
    MaximumHz =  20 + (52*  Sigmoid);
    MaximumInSamples = round(End*(MaximumHz/300));
    %Sigmoid = Sigmoid/max(Sigmoid);
    Sigmoid = ((win/40).^2 ./ (.04 + ((win/40).^2.45))-win*.007) ;
    BandwidthHz = 10 + (300 * Sigmoid );
    %10 + (MaximumBandWidth *(1 - exp(-6*(win-1)/40)));
    BandwidthInSamples = round(End*(BandwidthHz/310));
    BW = (1:BandwidthInSamples);
    
    FilterInSamples = exp(- 8*BW/BandwidthInSamples) .*(1-cos(2*pi*BW/(10*BandwidthInSamples)));
    
    %FilterInSamples = ( (1- cos(2*pi*(1:BandwidthInSamples)/BandwidthInSamples)).^.3 .* logspace(2.0,0,BandwidthInSamples));
    F = zeros(size(FilterInSamples));
    index = find(FilterInSamples >0);
    F(index) = FilterInSamples(index);
    FilterInSamples = F/max(F);
    
    MaxFilterInSamples = find(FilterInSamples == max(FilterInSamples));
    
    NAddZeros = End - (MaximumInSamples - MaxFilterInSamples + size(FilterInSamples,2));
    Roughness = [zeros(1,MaximumInSamples - MaxFilterInSamples) FilterInSamples zeros(1,NAddZeros)];   
    Attenuate = Roughness(Begin:End);
    AttenuateWindow(win,:) = (Attenuate * 1/(max(Attenuate) - min(Attenuate))) - min(Attenuate);
end


% --------------------------------------------------------------------------------

function ChannelWeights = ChannelWeighting(ANIRows,inANIFilterFreqs,AttenuateWindow)    
fprintf(1,'Setup weights for the channels:\n');
% These model the contribution of the different channels to roughness

ChannelWeights = linspace(1,0.45,40)';


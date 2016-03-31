function [outError,outBestRatioDiffs] = IPEMToneScaleComparison
% Usage:
%   [outError,outBestRatioDiffs] = IPEMToneScaleComparison;
%
% Description:
%   Compares tonescales with different subdivisions to the 'ideal case'
%
% Output:
%   outError = error compared to ideal case
%   outBestRatioDiffs = difference of the best ratio's with the ideal ones
%
% Remarks:
%   Works for the 3 ideal ratio's 6/5, 5/4, 3/2
%
% Authors:
%   Koen Tanghe - 19990816
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

% Setup
theIdealRatios = [1.2 1.25 1.5];
theOctaveRatio = 2;
theMaxDivisions = 120;

% Calculation
N = length(theIdealRatios);
outBestRatioDiffs = zeros(theMaxDivisions,N);
outError = zeros(1,theMaxDivisions);
for theSubdivisions = N:theMaxDivisions
   
   % Calculate frequency ratio's
   theRatios = theOctaveRatio.^((0:theSubdivisions)/theSubdivisions);
   
   % Find the best matching ratio's
   theIndices = FindBestMatch(theRatios,theIdealRatios);
   
   % Store the differences for the best ratios
   outBestRatioDiffs(theSubdivisions,:) = theRatios(theIndices)-theIdealRatios;
   
   % Calculate the error value for this scale
   outError(theSubdivisions) = sum(abs(theRatios(theIndices)-theIdealRatios));
   
end;

% Write to file (will only work for 3 ideal ratios, should be generalized)
theFile = fullfile(IPEMRootDir('output'),'ToneScales.txt');
theOutFile = fopen(theFile,'wt');
theRange = N:theMaxDivisions;
fprintf(theOutFile,'%-4s %-10s %-10s\n','Ndiv','Error','Differences with the ideal case');
fprintf(theOutFile,'%-4d %-10.6f %-+10.6f %-+10.6f %-+10.6f\n',[theRange; outError(theRange); outBestRatioDiffs(theRange,:)']);
fclose(theOutFile);
fprintf(1,'Saved results to file [%s]\n',theFile);

% Show
figure;
theSubdivisions = N:theMaxDivisions;
plot(theSubdivisions,outError(theSubdivisions));
axis tight;
xlabel('number of subdivisions');
ylabel('error compared to ideal case (6/5, 5/4 and 3/2)');
   
function outIndices = FindBestMatch(inRatios, inIdealRatios)
N = length(inIdealRatios);
outIndices = zeros(1,N);
for i = 1:N
   [theMin,theMinIndex] = min(abs(inRatios-inIdealRatios(i)));
   outIndices(i) = theMinIndex;
end;

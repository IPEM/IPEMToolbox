function outSignal = IPEMReshape(varargin)
% Usage:
%   outSignal = IPEMReshape(inData,inShaper,inMethod,inSymmetry,inPlotFlag)
%
% Description:
%   Reshapes the incoming data by substituting each original value by a 
%   new value using the given shaper matrix.
%
% Input arguments:
%   inData = 1D data vector to be reshaped
%   inShaper = shaper matrix: two column matrix of which the first column
%              represents the original value and the second column represents
%              its substituted value
%   inMethod = string with the method to be used for interpolating substituded
%              values (see description of methods in Matlab's interp1 function)
%              if empty or not specified, 'linear' is used by default
%   inSymmetry = if 1, inShaper is assumed to be one half of a curve symmetric
%                around the point zero: Y(-X) = -Y(X)
%                if 2, inShaper is assumed to be one half of a curve symmetric
%                around the Y-axis: Y(-X) = Y(X)
%                if empty or not specified, no symmetry is assumed by default
%   inPlotFlag = if non-zero, a plot is generated
%                if empty or not specified, 0 is used by default
%
% Output:
%   outSignal = reshaped data
%
% Remarks:
%   Only values between the min(inShaper(:,1)) and max(inShaper(:,1)) can be
%   substituted, so always make sure to include these bounds and their
%   subsitutes in inShaper. 
%   In case you make use of inSymmetry, only max(inShaper(:,1)) will play a role
%   in defining the region where values can be substituted.
%
% Example:
%   X = 0:0.1:1;
%   Y = X.^3;
%   s2 = IPEMReshape(s,[X' Y'],'linear',1,1);
%
% Authors:
%   Koen Tanghe - 20010110
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
[inData,inShaper,inMethod,inSymmetry,inPlotFlag] = IPEMHandleInputArguments(varargin,3,{[],[],'linear',0,0});

% Sort and handle symmetry if assumed
if (inSymmetry == 1)
    NonZeroIndices = find(inShaper(:,1) ~= 0);
    inShaper = inShaper(NonZeroIndices,:);
    inShaper = [inShaper ; -inShaper];
elseif (inSymmetry == 2)
    inShaper = [inShaper ; [-inShaper(:,1) inShaper(:,2)]];
end

% Eliminate duplicate x-values
[a,Indices] = unique(inShaper(:,1));
inShaper = inShaper(Indices,:);

% Reshape
outSignal = interp1(inShaper(:,1),inShaper(:,2),inData,inMethod);

% Plot if needed
if (inPlotFlag)
    figure;
    
    subplot(122);
    Min = min(inShaper(:,1));
    Max = max(inShaper(:,1));
    Org = Min:(Max-Min)/1000:Max;
    New = interp1(inShaper(:,1),inShaper(:,2),Org,inMethod);
    plot(Org,New);
    hold on;
    plot(inShaper(:,1),inShaper(:,2),'ro');
    hold off;
    axis tight;
    title('Reshaping function')
    xlabel('Original value');
    ylabel('Substituted value');
    
    subplot(221);
    plot(inData);
    axis tight;
    title('Original data');
    subplot(223);
    plot(outSignal);
    axis tight;
    title('Reshaped data');
    IPEMSetFigureLayout;
end

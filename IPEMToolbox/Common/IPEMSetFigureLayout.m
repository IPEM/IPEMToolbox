function IPEMSetFigureLayout(varargin)
% Usage:
%   IPEMSetFigureLayout(inFigureHandle)
%
% Description:
%   Sets the layout of the figure to the IPEM defaults.
%
% Input arguments:
%   inFigureHandle = handle of the figure to be adjusted
%                    if 'all' is specified, all open figures will be adjusted
%                    if empty or not specified, the current figure will be
%                    adjusted
%
% Example:
%   FigH = figure;
%   % ... some plots ...
%   IPEMSetFigureLayout(FigH);
%
% Authors:
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
[inFigureHandle] = IPEMHandleInputArguments(varargin,1,{[]});

% Additional checking
if isempty(inFigureHandle)
    CurFig = get(0,'CurrentFigure');
    if isempty(CurFig)
        return;
    else 
        Figures = CurFig;
    end
elseif (inFigureHandle == 'all')
    Figures = findobj(0,'Type','Figure');
else
    Figures = inFigureHandle;
end

% Run through all figures
for i = 1:length(Figures)
    
    % Run through all axes
    Axes = findobj(Figures(i),'Type','Axes');
    for j = 1:length(Axes)
        SetLayoutForOneAxis(Axes(j));        
    end
    
end


% ------------------------------------------------------------------------------

function SetLayoutForOneAxis(inAxisHandle)
% Local subfunction for handling one axis

% The subparts
XLabel = get(inAxisHandle,'XLabel');
YLabel = get(inAxisHandle,'YLabel');
ZLabel = get(inAxisHandle,'ZLabel');
Title = get(inAxisHandle,'Title');

% The settings
set(XLabel,'FontWeight','Bold');
set(XLabel,'FontSize',10);
set(YLabel,'FontWeight','Bold');
set(YLabel,'FontSize',10);
set(ZLabel,'FontWeight','Bold');
set(ZLabel,'FontSize',10);
set(Title,'FontWeight','Bold');
set(Title,'FontSize',12);
set(Title,'Interpreter','none');
set(inAxisHandle,'FontSize',8);
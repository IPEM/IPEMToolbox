function IPEMExportFigures(varargin)
% Usage:
%   IPEMExportFigures(inInputPath,inOutputPath,inFormat,inUseIPEMLayout)
%
% Description:
%   Exports figures to specified graphics format.
%
% Input arguments:
%   inInputPath = path to scan for .fig files
%                 if empty or not specified, the currently opened figures are
%                 exported, with the names being just 'Figure_No_1', etc...
%                 (in this case, inOutputPath must be given)
%   inOutputPath = path to be used for saving the exported figures
%                  if empty or not specified, inInputPath is used by default
%   inFormat = graphics format to be used
%              this can be one of the following:
%                'lowpng' = low resolution png ('-dpng -r75')
%                'highpng' = high resolution png ('-dpng -r300')
%                'screenpng' = screen resolution png ('-dpng -r0')
%                'eps' = black & white eps ('-deps -r600')
%                'epsc' = colored eps ('-depsc -r600')
%              or an entire specification conforming to Matlab's 'print' options
%              (to be specified as a cell array of strings, see 'help print')
%              if empty or not specified, 'lowpng' is used by default
%   inUseIPEMLayout = if non-zero, the default IPEM layout settings are used
%                     if empty or not specified, each figure is used "as is"
%
% Output:
%   Files having the same name as the figures, but with an extension depending
%   on inFormat.
%
% Remarks:
%   This thing is NOT COMPILABLE because in Matlab R11.1 the print command does
%   not work when called from a compiled M-file (does work in R12 however).
%
% Example:
%   IPEMExportFigures('E:\Koen\Docs\Research\TeacupPaper\Originals');
%
% Authors:
%   Koen Tanghe - 20010528
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
[inInputPath,inOutputPath,inFormat,inUseIPEMLayout] = ...
    IPEMHandleInputArguments(varargin,1,{[],[],'lowpng',1});

% Additional checking
if isempty(inOutputPath)
    if ~isempty(inInputPath)
        inOutputPath = inInputPath;
    else
        error('ERROR: you should specify a valid output path');
    end
end

% Setup print command
if isequal(inFormat,'lowpng')
    PrintOptions = {'-dpng','-r75'};
elseif isequal(inFormat,'highpng')
    PrintOptions = {'-dpng','-r300'};
elseif isequal(inFormat,'screenpng')
    PrintOptions = {'-dpng','-r0'};
elseif isequal(inFormat,'eps')
    PrintOptions = {'-deps','-r600'};
elseif isequal(inFormat,'epsc')
    PrintOptions = {'-depsc','-r600'};
else
    PrintOptions = inFormat;
end

% Start exporting figures
if isempty(inInputPath)
    
    % Export all currently opened figures
    Figures = findobj(0,'Type','Figure');
    for i = 1:length(Figures)
        Name = sprintf('Figure_No_%d',Figures(i));
        DestinationFile = fullfile(inOutputPath,Name);
        fprintf(1,'Printing %s',Name);
        print(Figures(i),PrintOptions{:},DestinationFile);
        fprintf(1,', done.\n');
    end
    
else
    
    % Export .fig files at inInputPath
    DirStruct = dir(fullfile(inInputPath,'*.fig'));
    for i = 1:size(DirStruct,1)
        FileName = DirStruct(i).name;
        SourceFile = fullfile(inInputPath,FileName);
        [a,Name,c,d] = fileparts(FileName);
        DestinationFile = fullfile(inOutputPath,Name);
        fprintf(1,'Opening %s',FileName);
        open(SourceFile);
        if (inUseIPEMLayout)
            IPEMSetFigureLayout(gcf);
        end;
        fprintf(1,', printing');
        print(gcf,PrintOptions{:},DestinationFile);
        close(gcf);
        fprintf(1,', done.\n');
    end;
    
end

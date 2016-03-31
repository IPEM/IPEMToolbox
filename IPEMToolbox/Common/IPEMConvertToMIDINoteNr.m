function outMIDINoteNr = IPEMConvertToMIDINoteNr (inNoteString)
% Usage:
%   outMIDINoteNr = IPEMConvertToMIDINoteNr(inNoteString)
%
% Description:
%   Converts a cell array of note specification strings to an array of
%   MIDI note numbers.
%
% Input arguments:
%   inNoteString = cell array of note specification string
%
% Output:
%   outMIDINoteNr = MIDI note number array
%
% Remarks:
%   Both sharps ('#') or flats ('b') can be used.
%   You can specify a sign in front of the octave part, if you want to...
%   Things like 'Cb' and 'E#' will be interpreted as, respectively, 'B' and 'F'.
%
%   If you want to compare note strings, you'll have to make sure that you
%   always stick to the same notation method (sharps OR flats).
%   If you don't, you'll have to use the note NUMBERS to test for equality,
%   and not the note STRINGS !
%
% Example:
%   IPEMConvertToMIDINoteNr('A4')
%
% Authors:
%   Koen Tanghe - 20000315
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

% Setup conversion table
ConversionTable = {
    'C',  1 ;
    'D',  3 ; 
    'E',  5 ;
    'F',  6 ;
    'G',  8 ;
    'A', 10 ;
    'B', 12    
};

% Check if a single string (not a cell array) is given
if ~iscellstr(inNoteString)
    inNoteString = {inNoteString};
end

% Init output
[R,C] = size(inNoteString);
outMIDINoteNr = repmat(NaN,R,C);

for Row = 1:R
    
    for Col = 1:C
        
        NoteString = inNoteString{Row,Col};
        
        % Get octave part
        L = length(NoteString);
        Index = 0;
        for i = L:-1:1
            if ~isempty(str2num(NoteString(i)))
                Index = i;
            elseif ((NoteString(i) == '-') | (NoteString(i) == '+'))
                Index = i;
            else
                break;
            end
        end
        if (Index ~= 0)
            
            Octave = str2num(NoteString(Index:L));
            
            % Get flat or sharp part
            Offset = 0;
            if ((NoteString(Index-1) == 'b') & (Index-1 ~= 1))
                Offset = -1; Index = Index -1;
            elseif (NoteString(Index-1) == '#')
                Offset = +1; Index = Index - 1;
            end
            
            % Get note part
            Note = NoteString(1:Index-1);
            Result = find(strcmpi(ConversionTable,Note));
            if ~isempty(Result)
                Note = ConversionTable{Result,2};
                outMIDINoteNr(Row,Col) = (Note-10) + Offset + 12*(Octave-4) + 69;
            end
            
        end;
        
    end % of Col loop
    
end; % of Row loop

function outNoteString = IPEMConvertToNoteString (varargin)
% Usage:
%   outNoteString = IPEMConvertToNoteString (inMIDINoteNr,inUseFlats)
%
% Description:
%   Converts an array of MIDI note numbers to a cell array of note strings.
%
% Input arguments:
%   inMIDINoteNr = array containing MIDI note numbers
%   inUseFlats = if non-zero, flats will be used instead of sharps
%                if empty or not specified, 0 is used by default (sharps)
%
% Output:
%   outNoteString = cell array with note specification strings
%
% Remarks:
%   Where inMIDINoteNr contains an illegal MIDI note number (NaN), the note
%   string corresponding with that value will be left empty...
%
% Example:
%   IPEMConvertToNoteString([69 70 ; 58 57])
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

% Handle input arguments
[inMIDINoteNr,inUseFlats] = IPEMHandleInputArguments(varargin,2,{[],0});

% Note name array (either sharps or flats)
if (inUseFlats == 0)
    NoteNameArray = { 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B' , '' };
else
    NoteNameArray = { 'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B' , '' };
end

% Get size and reshape (because of limitations with char arrays)
[R,C] = size(inMIDINoteNr);
inMIDINoteNr = reshape(inMIDINoteNr,R*C,1);

% Find places of illegal MIDI note numbers
IllegalPlaces = isnan(inMIDINoteNr);

% Get the octaves and notes
Octave = num2str(floor((inMIDINoteNr-69+10-1)/12+4),'%-8d');
NoteIndices = mod(inMIDINoteNr-69+10-1,12)+1;
NoteIndices(IllegalPlaces) = 13;
Note = NoteNameArray(NoteIndices)';

% Concatenate, replace illegal places with empty string and reshape
outNoteString = strcat(Note,cellstr(Octave));
outNoteString(IllegalPlaces) = {''};
outNoteString = reshape(outNoteString,R,C);

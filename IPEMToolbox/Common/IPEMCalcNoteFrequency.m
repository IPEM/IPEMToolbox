function outFrequency = IPEMCalcNoteFrequency (varargin)
% Usage:
%   outFrequency = 
%     IPEMCalcNoteFrequency(inNoteNr,inOctaveNr,
%                           inRefNoteNr,inRefOctaveNr,
%                           inRefFreq,inNotesPerOctave,
%                           inOctaveRatio)
%
% Description:
%   Calculates the frequency of a note.
%   Supports non-standard tone scales that can be calculated like this:
%
%       Frequency = RefFreq * OctaveRatio^Exponent
%
%       where:
%
%       Exponent = (OctaveNr-RefOctaveNr) + (NoteNr-RefNoteNr)/NotesPerOctave 
%
% Input arguments:
%   inNoteNr = the rank number of the note (for example: 1 for C, 2 for C#, ...)
%              For the standard octave division (12 notes, ref. A4), this can
%              also be a note string like 'A#' (in which case inOctaveNr must
%              still be specified), or 'A#4' (in which case inOctaveNr can be
%              omitted or left empty). Both sharps (#) and flats (b) can be used.
%   inOctaveNr = the octave number of the note
%                if empty or not specified, inNoteNr is assumed to contain the
%                octave specification 
%   inRefNoteNr = the rank number of the reference note
%                 if empty or not specified, 10 is used by default
%   inRefOctaveNr = the octave number of the reference note
%                   if empty or not specified, 4 is used by default
%   inRefFreq = the frequency of the reference note (in Hz)
%               if empty or not specified, 440 Hz is used
%   inNotesPerOctave = the number of notes in one octave
%                      if empty or not specified, 12 is used by default
%   inOctaveRatio = the frequency ratio between two octaves
%                   if empty or not specified, 2 is used
%
% Output:
%   outFrequency = the frequency for the note (in Hz)
%
% Example:
%   Frequency = IPEMCalcNoteFrequency('A#5');
%
% Authors:
%   Koen Tanghe - 20000509
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
[inNoteNr,inOctaveNr,inRefNoteNr,inRefOctaveNr,inRefFreq,inNotesPerOctave,inOctaveRatio] = ...
    IPEMHandleInputArguments(varargin,2,{[],[],10,4,440,12,2});

% Init output
outFrequency = [];

% Convert note names to numbers if needed
if (ischar(inNoteNr) & isempty(str2num(inNoteNr)))
    NoteNr = IPEMConvertToMIDINoteNr({[inNoteNr num2str(inOctaveNr)]});
    if isempty(NoteNr)
        error;
    else
        if ((inRefNoteNr ~= 10) | (inRefOctaveNr ~= 4) | (inNotesPerOctave ~= 12))
            error(['ERROR: note names only work for following octave setup:\n'...
                   '       reference note A4 and 12 notes/octave)']);
        else
            inNoteNr = mod(NoteNr,12)+1;
            inOctaveNr = (NoteNr-inNoteNr+1)/12 - 1;
        end
    end;
else
    if isempty(inOctaveNr)
        error('ERROR: no octave specified...');
    end
end;

% Calculate the frequency
theExponent = (inOctaveNr-inRefOctaveNr) + (inNoteNr-inRefNoteNr)/inNotesPerOctave;
outFrequency = inRefFreq*(inOctaveRatio.^theExponent);


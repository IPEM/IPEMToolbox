function [outNoteNr,outOctaveNr,outExactFrequency,outNoteString] = IPEMFindNoteFromFrequency (varargin)
% Usage:
%   [outNoteNr,outOctaveNr,outExactFrequency,outNoteString] =
%      IPEMFindNoteFromFrequency(inFrequency,inRefNoteNr,inRefOctaveNr,
%                                inRefFreq,inNotesPerOctave,inOctaveRatio)
%
% Description:
%   Finds nearest note corresponding to the given frequency.
%   Supports non-standard tone scales that can be calculated like this:
%
%       Frequency = RefFreq * OctaveRatio^Exponent
%
%       where:
%
%       Exponent = (OctaveNr-RefOctaveNr) + (NoteNr-RefNoteNr)/NotesPerOctave 
%
% Input arguments:
%   inFrequency = frequency for which a corresponding note must be found
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
%   outNoteNr = rank number of the note (1 to inNotesPerOctave)
%   outOctaveNr = octave number of the note (integer)
%   outExactFrequency = exact frequency of the found note (in Hz)
%   outNoteString = string representing the found note
%                   (only for standard tone scale, otherwise empty)
%
% Remarks:
%   Getting the note name for standard tone scale:
%     MIDINoteNr = (outNoteNr-1) + 12*(outOctaveNr+1);
%     NoteString = IPEMConvertToNoteString(MIDINoteNr);
%
% Example:
%   [NoteNr,OctaveNr,Freq,Name] = ...
%     IPEMFindNoteFromFrequency([441.01 153 ; 222 94]);
%
% Authors:
%   Koen Tanghe - 20000629
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
[inFrequency,inRefNoteNr,inRefOctaveNr,inRefFreq,inNotesPerOctave,inOctaveRatio] = ...
    IPEMHandleInputArguments(varargin,2,{[],10,4,440,12,2});

% Initialize output
[R,C] = size(inFrequency);
outNoteNr = repmat(NaN,R,C);
outOctaveNr = repmat(NaN,R,C);
outExactFrequency = repmat(NaN,R,C);

% Handle non-zero frequencies
INonZero = find(inFrequency ~= 0);
if ~isempty(INonZero)
    
    % Find corresponding note
    Value = inNotesPerOctave*(log(inFrequency(INonZero)/inRefFreq)/log(inOctaveRatio)+inRefOctaveNr)+inRefNoteNr-1;
    outOctaveNr(INonZero) = floor(Value/inNotesPerOctave);
    outNoteNr(INonZero) = round(Value - outOctaveNr(INonZero)*inNotesPerOctave)+1;
    
    % Find wrap points
    IWrap = find(outNoteNr == (inNotesPerOctave + 1));
    if ~isempty(IWrap)
        outOctaveNr(IWrap) = outOctaveNr(IWrap) + 1;
        outNoteNr(IWrap) = 1;
    end
    
    % Find exact frequency
    theExponent = (outOctaveNr(INonZero)-inRefOctaveNr) + (outNoteNr(INonZero)-inRefNoteNr)/inNotesPerOctave;
    outExactFrequency(INonZero) = inRefFreq*(inOctaveRatio.^theExponent);
    
end

% In case note strings were requested and we have a standard tone scale
if (nargout >= 4)
    if ([inRefNoteNr,inRefOctaveNr,inRefFreq,inNotesPerOctave,inOctaveRatio] == [10,4,440,12,2])
        MIDINoteNr = (outNoteNr-1) + 12*(outOctaveNr+1);
        outNoteString = IPEMConvertToNoteString(MIDINoteNr);
    else
        outNoteString = cell(size(outNoteNr));
    end
end

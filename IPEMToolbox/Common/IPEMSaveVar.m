function IPEMSaveVar (inFile,inName,inValue)
% Usage:
%   IPEMSaveVar (inFile,inName,inValue)
%
% Description:
%   Saves a variable with name inValue and value inValue to a mat file.
%   If the file did not already exist, a new file is created first.
%
% Input arguments:
%   inFile = full name (with path) of the mat file (the .mat extension will be
%            added automatically if it's not there already)
%   inName = name for the variable
%   inValue = value for the variable
%
% Remarks:
%   This thing is NOT COMPILABLE because of call stack/workspace differences
%   between M-file evaluation and mex-evaluation !
%
% Example:
%   IPEMSaveVar('E:\Koen\Data\music.mat','NerveImage',ANI);
%
% Authors:
%   Koen Tanghe - 20000209
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

% Append extension .mat if not given
Spec = IPEMStripFileSpecification(inFile);
if (strcmpi(Spec.Extension,'mat') ~= 1)
    inFile = [inFile '.mat'];
end

if ~(strcmp(inName,'inFile') | strcmp(inName,'inName') | strcmp(inName,'inValue'))
    % It's safe to use AssignVariable without name clashes
    AssignVariable(inName,'inValue');
    if ~isempty(dir(inFile))
        EvalSave('inFile',inName,1);
    else
        EvalSave('inFile',inName,0);
    end
else
    % The string in inName happens to be the name of one of our already existing variables:
    % make copies to other variables before using AssignVariable !
    theFile = inFile;
    theName = inName;
    theValue = inValue;
    AssignVariable(inName,'theValue');
    if ~isempty(dir(theFile))
        EvalSave('theFile',inName,1);
    else
        EvalSave('theFile',inName,0);
    end
end;

% ------------------------------------------------------------------------------

function AssignVariable(inNameOfVariable,inNameOfValue)
% Description:
%   Assigns value of variable with name stored in inNameOfValue
%   to variable in caller's workspace with name stored in inNameOfVariable.
%
% Remark:
%   Check inNameOfVariable with your variables before calling this function!!!

String = [inNameOfVariable ' = ' inNameOfValue ';'];
evalin('caller',String);

% ------------------------------------------------------------------------------

function EvalSave(inFileVarName,inName,inAppend)
% Description:
%   Evals 'save' in caller's workspace.

if (inAppend)
    String = sprintf('save(%s,%c%s%c,%c-append%c);',inFileVarName,39,inName,39,39,39);
else
    String = sprintf('save(%s,%c%s%c);',inFileVarName,39,inName,39);
end;    
evalin('caller',String);

function varargout = IPEMHandleInputArguments(inPassedArgs,inNumFirstOptionalArg,inDefaults)
% Usage:
%   [...] = IPEMHandleInputArguments(inPassedArgs,inNumFirstOptionalArg,
%                                    inDefaults)
%
% Description:
%   This function is a simple but general input handling routine.
%   Just pass what you got from your caller, say what variables you expect and
%   which of them are optional, and specify the defaults (which will be used to
%   replace arguments that were left empty).
%   After calling this function, you'll have the valid arguments you need to
%   proceed with.
%
% Input arguments:
%   inPassedArguments = cell array with the arguments as passed to the caller
%   inNumFirstOptionalArg = number of the first optional argument
%                           if empty, length(inDefaults)+1 is used by default
%                           (this means: no optional arguments)
%   inDefaults = cell array with default values for the arguments that were
%                left empty
%
% Output:
%   The specified variables are set in the caller's name space or an appropriate
%   error message is returned if something was wrong with the arguments.
%
% Example:
%
%   This is a function using IPEMHandleInputArguments:
%
%       function Test (varargin)
%       % Usage: 
%       %   Test(inArg1,inArg2,inArg3,inArg4)
%       % ----------------------------------------------------------------------
%
%       % Handle input arguments
%       [inArg1,inArg2,inArg3,inArg4] = ...
%           IPEMHandleInputArguments (varargin, 3, {'def1' 'def2' 0.1 0.2});
%
%       % Rest of code for Test
%       .....
%
%   If you now call Test the following way:
%
%       Test('abc',[],5);
%
%   the internal variables of Test after the call to IPEMHandleInputArguments
%   will be:
%
%       inArg1 = 'abc'
%       inArg2 = 'def2'
%       inArg3 = 5
%       inArg4 = 0.2
%
% Authors:
%   Koen Tanghe - 19991109
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

% Check whether optional arguments are allowed or not
if isempty(inNumFirstOptionalArg)
   inNumFirstOptionalArg = length(inDefaults)+1;
end;

% Check if number of output arguments corresponds with number of default arguments
NumArgs = length(inDefaults);
if (nargout ~= NumArgs)
    error(sprintf('ERROR: Number of output arguments is not the same as number of default arguments'));
end;

% Check number of passed arguments
NumPassedArgs = length(inPassedArgs);
Msg = nargchk(inNumFirstOptionalArg-1,NumArgs,NumPassedArgs);
if ~isempty(Msg)
   error(sprintf('ERROR: Wrong number of input parameters in calling function:\n%s\n',Msg));
end;

% Set specified arguments to what was passed, or set to default if empty
for i = 1:NumPassedArgs
   theValue = inPassedArgs{i};
   if isempty(theValue)
      theValue = inDefaults{i}; % set to default
   end;
   varargout{i} = theValue;
end;

% Set missing optional arguments to defaults
for i = NumPassedArgs+1:NumArgs
	varargout{i} = inDefaults{i};
end;

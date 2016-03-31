Version:    1.02 (beta)
Build Date: 20050120

===================================================
   ReadMe.txt - ReadMe file for the IPEM Toolbox
===================================================

CONTENTS
--------
1. Preparing Matlab for using the IPEM Toolbox
2. Important changes
3. About the _CommentTemplate.m file
4. About the IPEMToolbox directory structure
5. About frame-based calculations
6. Compatibility
7. License, contact, support



1. Preparing Matlab for using the IPEM Toolbox
   -------------------------------------------

In order to use the IPEM Toolbox, perform the following 4 steps:
  1. Unzip all files in the IPEMToolbox.zip file to a directory called IPEMToolbox.
  2. Start Matlab, go to 'Set Path...' in the 'File' menu and add the IPEMToolbox
     directory to the Matlab search path.
  3. Type the following line at the Matlab command prompt:
         IPEMSetup;
     You should now see: "Initializing IPEM toolbox..." and then: "Done."
  4. Set your preferred 'input' and 'output' root directories by typing:
	   setpref('IPEMToolbox','RootDir_Input','your input directory');
	   setpref('IPEMToolbox','RootDir_Output','your output directory');
     where 'your input directory' is the complete path to your preferred
     input directory between single quotes (same for output directory).
     If you don't, IPEMToolbox\Temp will be used as both input and output
     directory.

Remark: each user on your Windows machine needs to perform steps 3. and 4.
once, to initialize the IPEM Toolbox and set his/her preferred input and
output directory.


2. Important changes
   -----------------

Important changes between versions are logged in the file 'Changes.txt'.
Take a moment to read this file whenever you receive a new version of the
toolbox !


3. About the _CommentTemplate.m file
   ---------------------------------

This file shows the standard comment layout that is used in any of the
IPEM...m files. It provides the user of the function with all necessary
information about how (and what) to use the function (for).
If you create a new function that is likely to be integrated in the IPEM Toolbox,
copy the template in your new file and edit the different sections.

The following is a brief explanation of the different sections found in
this comment template. Notice that some sections should always be there,
and others are rather optional.

Usage:
  This shows the syntax for using the function:
  what and how many input arguments and outputs are there, and what is
  their order ?
  [obligatory]

Description:
  This shows the semantics of the function:
  what is it intended for and/or how does it work ?
  [obligatory]

Input arguments:
  A description of the input arguments together with a specification of
  whether they are optional or not, and what their defaults are.
  [obligatory if any]

Output:
  A description of the outputs of the function.
  [obligatory if any]

Remarks:
  Any additional remarks that are not in the other sections.
  [optional]

Example:
  A simple example of how to use the function.
  [optional]

Authors:
  A list of the people who wrote (parts of) the code of the function, or
  have made some changes to it. Accompanied by the date of their most
  recent changes.
  [obligatory]


4. About the IPEMToolbox directory structure
   -----------------------------------------

For maintenance reasons, it is best not to change/add anything to the IPEMToolbox
directory. This will keep it easy for you to just unzip/copy a new version
of the IPEM toolbox to the old location without having to worry about
overwriting or deleting files or subdirectories you might have added to the 
IPEMToolbox directory. It will also prevent you from mixing up the latest IPEM
files with your own files.

EXAMPLE
The following directory structure is a good example of how to manage your
code:

E:\Koen\Code\Matlab\IPEMToolbox
                   \IPEMToolbox\Common
                   \IPEMToolbox\...
E:\Koen\Code\Matlab\KoenNewOrChanged
                   \KoenNewOrChanged\Changing
                   \KoenNewOrChanged\ChangedFinished
E:\Koen\Code\Matlab\Tests
E:\Koen\Code\Matlab\FromInternet

If there is a new version of the IPEM toolbox, you can just completely
remove the contents of the IPEMToolbox directory and copy the new contents in
there, without affecting any code stored in the other directories.


5. About frame-based calculations
   ------------------------------

Many of the functions in the toolbox perform frame-based calculations given 
a frame width W and a frame step size S. These calculations are only
meaningful/consistent if they are performed on a complete frame.
Therefore, these functions all produce an output signal with as first value
the value calculated for the first complete frame. This means that the
first value in the output signal corresponds to the interval [0,W] in the
input signal.
The same holds for the end of the output signal: the last value corresponds 
to the last complete frame in the input signal.


6. Compatibility
   -------------

The decision was taken to develop this toolbox for Windows platforms only, so
it won't work on other platforms (although some of the functions might work perfectly).
Developed and tested with Matlab version 6.0 (R12).

Note:
The Matlab 5.3.1 (R11.1) version is no longer maintained.
We shipped the code with the Matlab 6.0 version of IPEMPeriodicityPitch.m . If you want to use the package with Matlab 5.3.1, you'll need to edit that file on 
lines 170 and 173, and use the appropriate auditory model dll for 5.3.1. There is a 
separate package containing all the necessary files to build that dll.


7. License, contact, support
   -------------------------

This package is released under the GNU GPL license.
See the file gpl.txt in this directory for full details.

The IPEM Toolbox project has ended. If you have any questions you may try sending 
them to the following email address:

	toolbox[at]ipem[dot]ugent[dot]be

or you can write to:

	IPEM, Ghent University
	Blandijnberg 2
	9000 Ghent
	Belgium

We do not officially provide any support at all, however we might do an effort to 
answer your questions if you ask politely and we find some time ;-)

The IPEM Toolbox website is:
	
	http://www.ipem.ugent.be/Toolbox


Koen Tanghe
IPEM - Ghent University

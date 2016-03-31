This readme document is created by Jane Lee on March/14, 2016.

This is a record of how I compiled Auditory Model in IPEM Toolbox for MATLAB 2015b (matlab8) for 64bit Windows.

Reference information for IPEM Toolbox
@inproceedings{135924,
  author       = {Leman, Marc and Lesaffre, Micheline and Tanghe, Koen},
  booktitle    = {Conference Program and Abstracts of SMPC 2001 Kingston, August 9-11, 2001},
  language     = {eng},
  pages        = {25},
  title        = {An introduction to the IPEM Toolbox for Perception-Based Music Analysis.},
  year         = {2001},
}

==================================================
Install compiler
==================================================

------------------------------
METHOD (1) Use "Add-Ons" menu built in Matlab
------------------------------
See http://www.mathworks.com/help/matlab/matlab_external/install-mingw-support-package.html
Note: I have Matlab 2015b and I could not install the compiler using "Add-Ons"

OR

------------------------------
METHOD (2) Self installation
------------------------------
STEP 1:
Download MinGW version 4.9.2 from and install it.
https://sourceforge.net/projects/tdm-gcc/files/TDM-GCC%20Installer/Previous/1.1309.0/tdm64-gcc-4.9.2-3.exe/download
Downloaded file name: tdm64-gcc-4.9.2-3.exe
Important Note: Untick the box saying "Check for updated files on the TDM-GCC server"

STEP 2:
Download Matlab add-on installer and install.
http://www.mathworks.com/matlabcentral/fileexchange/52848-matlab-support-for-the-mingw-w64-c-c++-compiler-from-tdm-gcc
Downloaded file name: mingw.mlpkginstall

==================================================
Compile IPEM Auditory model
==================================================
STEP 1:
Create a folder and

STEP 2:
Copy all *.c files and *.h files from AuditoryModel\src\ into the new folder created in STEP 1

STEP 3:
IPEMProcessAuditoryModelSafe.c from AuditoryModel\Matlab8_UNIX\ into the new folder created in STEP 1

STEP 4:
Modify line 33 and line 36 of command.h by commenting out the #if and #endif
i.e.
//#if !defined (_WIN32)
#define max(a,b)    (((a) > (b)) ? (a) : (b))
#define min(a,b)    (((a) < (b)) ? (a) : (b))
//#endif

STEP 5:
Cmpile using mex
i.e.
mex -I. Audimod.c AudiProg.c command.c cpu.c cpupitch.c decimation.c ecebank.c filenames.c filterbank.c Hcmbank.c IPEMAuditoryModel.c IPEMProcessAuditoryModelSafe.c pario.c sigio.c

STEP 6:
Rename the *.mexw64 file obtained in STEP 5 as IPEMProcessAuditoryModelSafe.mexw64 and
copy it to ...\IPEMToolbox\Common\ and
also copy AuditoryModel\Matlab8_UNIX\IPEMProcessAuditoryModel.m to ...\IPEMToolbox\Common\
==================================================

THE END of the readme document


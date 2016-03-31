Copy both IPEMProcessAuditoryModel.dll and IPEMProcessAuditoryModel.m to 
IPEMToolbox/Common folder






OLD Readme--------------------------------------------------------------------------------------


If you change anything to IPEMProcessAuditoryModel.m, you'll have to rebuild
the IPEMProcessAuditoryModel project in the IPEM VC++ workspace.

To do this, first rebuild the .c and .h files with the following command in Matlab:

	mcc -t -L C -W mex IPEMProcessAuditoryModel.m

Make sure IPEMProcessAuditoryModel.m is on your Matlab path for this.

Next, copy the generated files into the source directory of the project,
and finally perform a 'rebuild all' on the project.

That should do the trick...


Remark:
1. The project settings contain pre-link steps for generating libraries:
	lib /def:"d:\matlabr11\extern\include\matlab.def" /machine:ix86 /out:"Release\mymatlab.lib"
	lib /def:"d:\matlabr11\extern\include\libmatlbmx.def" /machine:ix86 /out:"Release\mylibmatlbmx.lib"

2. For Matlab R12:
mexLibrary is used instead of mexFunction as entry point in a mex file.
So this entry point must be changed in the .def file.
This should be done for the IPEMProce
ssAuditoryModel.dll file as well !!!

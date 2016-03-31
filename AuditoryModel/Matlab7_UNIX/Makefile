# Makefile by Stefan Tomic, Center for Mind and Brain, UC Davis
# sttomic@ucdavis.edu
# Updated 2/12/2009
# Updated 06/01/2014 by Joren Six, IPEM, University Ghent
#	-changed paths to conform with github release
#
# This was compiled on Red Hat Enterprise Linux (32 and 64 -bit versions), and OS X (32 and 64 -bit versions)
#
# You may be able to get this to work for Matlab 7 on other platforms
# by changing some of the following variables

#Change the following line to point to your matlab installation directory
#On a mac, this will be somewhere in your /Applications directory (e.g. /Applications/MATLAB74)
#On linux, this is probably in /usr/local (e.g. /usr/local/matlab-R14SP3)
MATLAB_DIR=/usr/local/matlab-R14SP3

#change the following mex extension for 32-bit Matlab on linux (mexglx), 64-bit Matlab on linux (mexa64), Macintosh PPC (mexmac), Macintosh Intel 32-bit (mexmaci), or Macintosh Intel 64-bit (mexmaci64)
MEX_EXT=mexa64

#if compiling on Mac Intel 64-bit, comment out the following line and uncomment the line with the -arch x86_64 flag
GCCFLAGS = -DMATLAB_MEX_FILE -fPIC -fno-omit-frame-pointer -D_GNU_SOURCE -pthread -fexceptions
#GCCFLAGS = -DMATLAB_MEX_FILE -fPIC -fno-omit-frame-pointer -D_GNU_SOURCE -pthread -fexceptions -arch x86_64

#the subdirectory where your mex script is located 
#this may not need to be changed - it is usually the "bin" subdirectory of your matlab installation.
MEX_SCRIPT_DIR=bin

#The following path should hopefully not need to be changed for different platforms
INCLUDE_DIR=extern/include

OUTDIR=./Release
OBJDIR=./Release
GCC=gcc
INCLUDE= -I$(MATLAB_DIR)/$(INCLUDE_DIR) -I../src -I../src/library -I../src/audiprog
OBJS = $(OBJDIR)/Audimod.o $(OBJDIR)/AudiProg.o $(OBJDIR)/command.o $(OBJDIR)/cpu.o $(OBJDIR)/cpupitch.o $(OBJDIR)/decimation.o $(OBJDIR)/ecebank.o $(OBJDIR)/filenames.o $(OBJDIR)/filterbank.o $(OBJDIR)/Hcmbank.o $(OBJDIR)/IPEMAuditoryModel.o $(OBJDIR)/pario.o $(OBJDIR)/sigio.o

$(OUTDIR)/IPEMProcessAuditoryModelSafe.$(MEX_EXT) : $(OBJS)
	$(MATLAB_DIR)/$(MEX_SCRIPT_DIR)/mex -outdir $(OUTDIR) ../../Sources/AuditoryModelForMatlab_7/IPEMProcessAuditoryModelSafe.c $(OBJS)

$(OBJDIR)/Audimod.o : ../src/audiprog/Audimod.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ../src/audiprog/Audimod.c -o $(OBJDIR)/Audimod.o

$(OBJDIR)/AudiProg.o : ../src/audiprog/AudiProg.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ../src/audiprog/AudiProg.c -o $(OBJDIR)/AudiProg.o

$(OBJDIR)/command.o : ../src/library/command.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS)  ../src/library/command.c -o $(OBJDIR)/command.o

$(OBJDIR)/cpu.o : ../src/audiprog/cpu.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ../src/audiprog/cpu.c -o $(OBJDIR)/cpu.o

$(OBJDIR)/cpupitch.o : ../src/audiprog/cpupitch.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ../src/audiprog/cpupitch.c -o $(OBJDIR)/cpupitch.o

$(OBJDIR)/decimation.o : ../src/audiprog/decimation.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS)  ../src/audiprog/decimation.c -o $(OBJDIR)/decimation.o

$(OBJDIR)/ecebank.o : ../src/audiprog/ecebank.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ../src/audiprog/ecebank.c -o $(OBJDIR)/ecebank.o

$(OBJDIR)/filenames.o : ../src/library/filenames.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ../src/library/filenames.c -o $(OBJDIR)/filenames.o

$(OBJDIR)/filterbank.o : ../src/audiprog/filterbank.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ../src/audiprog/filterbank.c -o $(OBJDIR)/filterbank.o

$(OBJDIR)/Hcmbank.o : ../src/audiprog/Hcmbank.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ../src/audiprog/Hcmbank.c -o $(OBJDIR)/Hcmbank.o

$(OBJDIR)/IPEMAuditoryModel.o : ../src/IPEMAuditoryModel.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ../src/IPEMAuditoryModel.c -o $(OBJDIR)/IPEMAuditoryModel.o

$(OBJDIR)/pario.o : ../src/library/pario.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ../src/library/pario.c -o $(OBJDIR)/pario.o

$(OBJDIR)/sigio.o : ../src/library/sigio.c
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ../src/library/sigio.c -o $(OBJDIR)/sigio.o

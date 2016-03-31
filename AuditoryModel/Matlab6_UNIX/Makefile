# Makefile by Stefan Tomic, Center for Mind and Brain, UC Davis
# sttomic@ucdavis.edu
# Updated 06/01/2014 by Joren Six, IPEM, University Ghent 
# 		-changed paths to conform with github release



# This was compiled on a Red Hat Enterprise 3.0 Linux Workstation
# Kernel version 2.4.21-15
# gcc version 3.2.3
# glibc version 2.3.2
# mcc version 3.0

#This also was successfully compiled on a G5 Macintosh, and Matlab 6.5

#Change the following line to point to your matlab installation directory
#On a mac, this will be somewhere in your /Applications directory (e.g. /Applications/MATLAB6p5p2)
#On linux, this is probably in /usr/local/
MATLAB_DIR = /usr/local/matlab

#change the following mex extension for 32-bit Matlab on linux (mexglx), or  Macintosh PPC (mexmac). 
MEX_EXT=mexglx


#Change the extension of the following for your Platform (mexglx for linux, mexmac for OS X)
OUTPUT_MEX_FILE = $(OUTDIR)/IPEMProcessAuditoryModel.$(MEX_EXT)

OUTDIR=./Release
OBJDIR=./Release

GCC=gcc
MCC=$(MATLAB_DIR)/bin/mcc
INCLUDE= -I$(MATLAB_DIR)/extern/include -I../src -I../src/library -I../src/audiprog

OBJS =  $(OBJDIR)/IPEMProcessAuditoryModel.o $(OBJDIR)/IPEMProcessAuditoryModel_mex.o $(OBJDIR)/Audimod.o $(OBJDIR)/AudiProg.o $(OBJDIR)/command.o $(OBJDIR)/cpu.o $(OBJDIR)/cpupitch.o $(OBJDIR)/decimation.o $(OBJDIR)/ecebank.o $(OBJDIR)/filenames.o $(OBJDIR)/filterbank.o $(OBJDIR)/Hcmbank.o $(OBJDIR)/IPEMAuditoryModel.o $(OBJDIR)/IPEMProcessAuditoryModel_external.o $(OBJDIR)/pario.o $(OBJDIR)/sigio.o

all:
	$(GCC) -c $(INCLUDE) ../src/audiprog/Audimod.c -o $(OBJDIR)/Audimod.o
	$(GCC) -c $(INCLUDE) ../src/audiprog/AudiProg.c -o $(OBJDIR)/AudiProg.o
	$(GCC) -c $(INCLUDE) ../src/library/command.c -o $(OBJDIR)/command.o
	$(GCC) -c $(INCLUDE) ../src/audiprog/cpu.c -o $(OBJDIR)/cpu.o
	$(GCC) -c $(INCLUDE) ../src/audiprog/cpupitch.c -o $(OBJDIR)/cpupitch.o
	$(GCC) -c $(INCLUDE) ../src/audiprog/decimation.c -o $(OBJDIR)/decimation.o
	$(GCC) -c $(INCLUDE) ../src/audiprog/ecebank.c -o $(OBJDIR)/ecebank.o
	$(GCC) -c $(INCLUDE) ../src/library/filenames.c -o $(OBJDIR)/filenames.o
	$(GCC) -c $(INCLUDE) ../src/audiprog/filterbank.c -o $(OBJDIR)/filterbank.o
	$(GCC) -c $(INCLUDE) ../src/audiprog/Hcmbank.c -o $(OBJDIR)/Hcmbank.o
	$(GCC) -c $(INCLUDE) ../src/IPEMAuditoryModel.c -o $(OBJDIR)/IPEMAuditoryModel.o
	$(GCC) -c $(INCLUDE) ../src/library/pario.c -o $(OBJDIR)/pario.o
	$(GCC) -c $(INCLUDE) ../src/library/sigio.c -o $(OBJDIR)/sigio.o
	$(GCC) -c $(INCLUDE) IPEMProcessAuditoryModel.c -o $(OBJDIR)/IPEMProcessAuditoryModel.o
	$(GCC) -c $(INCLUDE) IPEMProcessAuditoryModel_external.c -o $(OBJDIR)/IPEMProcessAuditoryModel_external.o
	$(GCC) -c $(INCLUDE) IPEMProcessAuditoryModel_mex.c -o $(OBJDIR)/IPEMProcessAuditoryModel_mex.o
	$(MCC) -v -T link:mexLibrary -o $(OUTPUT_MEX_FILE) $(OBJS)

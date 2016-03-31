
# Makefile by Joren Six, IPEM, University Ghent
# joren.six@ugent.be
# Updated 2014.01.06

#Tested on 64bit Debian Wheezy with octave 3.6

#if compiling on Mac Intel 64-bit, comment out the following line and uncomment the 
#line with the -arch x86_64 flag
GCCFLAGS = -fPIC -pthread -fpermissive
OBJDIR=./Release
GCC=g++
INCLUDE= -I. -I./library -I./audiprog

#compile the objects file and creates a mex file
all:
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./audiprog/Audimod.c    -o $(OBJDIR)/Audimod.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./audiprog/AudiProg.c   -o $(OBJDIR)/AudiProg.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./library/command.c     -o $(OBJDIR)/command.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./audiprog/cpu.c        -o $(OBJDIR)/cpu.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./audiprog/cpupitch.c   -o $(OBJDIR)/cpupitch.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./audiprog/decimation.c -o $(OBJDIR)/decimation.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./audiprog/ecebank.c    -o $(OBJDIR)/ecebank.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./library/filenames.c   -o $(OBJDIR)/filenames.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./audiprog/filterbank.c -o $(OBJDIR)/filterbank.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./audiprog/Hcmbank.c    -o $(OBJDIR)/Hcmbank.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./IPEMAuditoryModel.c   -o $(OBJDIR)/IPEMAuditoryModel.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./library/pario.c       -o $(OBJDIR)/pario.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./library/sigio.c       -o $(OBJDIR)/sigio.o
	$(GCC) -c $(INCLUDE) $(GCCFLAGS) ./IPEMAuditoryModelConsole.cpp  -o IPEMAuditoryModelConsole.o
	#g++ $(OBJDIR)/*.o    $(GCCFLAGS) -o IPEMAuditoryModelConsole

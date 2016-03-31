/* pario.c */

/*------------------------------------------------------------------------------
    IPEM Toolbox - Toolbox for perception-based music analysis 
    Copyright (C) 2005 Ghent University 
    
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
------------------------------------------------------------------------------*/

/*********************************************************************
		   I/O OF (SPEECH) PARAMETER FILES

A speech parameter file consists of two parts :
   part 1 : individual frames
   part 2 : frames representing overall statistics
Each frame is represented by X[+1] text lines :
   line 1..X : spectral parameters
   line X+1  : frame code + special parameters (!!!!! Optional !!!!!)
The meaning of the spectral parameters depends on the parameter type
   partype = 1 : autocorrelation coefficients	(-1 .. +1)
             2 : reflection coefficients	(-1 .. +1)
	     3 : unused				(-1 .. +1)
	     4 : DFT coefficients		(0 to 1.000)
	     5 : unused				(0 to 1.000)
	     6 : loudnesses from ear model FB 	(0 to 1.000)
	     7 : firing rates from ear model 	(0 to 1.000)
	     8 : envelopes from ear model 	(0 to 1.000)
	     9 : envelope parameters            (0 to 1.000)
   If the format is DSPS, the parameters are represented by
   2 character hex-codes (see READ_FRAME and WRITE_FRAME)
The frame code determines the kind of frame we are dealing with
   code =  0  : unvoiced speech frame (or unknown type of frame)
	   1  : voiced speech frame
	   2  : end-of-file indicator (not used anymore)
	   3  : averages of speech parameters
	   4  : variances of speech parameters
	   5  : undefined
	   6  : rows of a matrix (covariance matrix for instance)
The meaning of the special parameters is type dependent :
   partype = 1,2,3  : f0 (Hz), rms_after_preemph, ZCR (nr. per ms),
		      rms_before_preemph
	     4,5    : all kinds of parameters between 0 and 9.999
	     6 .. 9 : all kinds of parameters between 0 and 9.999
   If the format is DSPS, the special parameters are represented
   by 5-digit positive numbers (see READ_FRAME and WRITE_FRAME)

-------------- INTERFACE WITH THE CALLING PROCESS ------------------
Exported routines
   function read_frame(par) : integer
	read a frame and put the frame code in the function result
   procedure write_frame(code,n_per_line,par)
	write a frame to a file
   procedure init_pario
	specify nr of parameters, parameter type, ...
        the special code is not counted as a parameter !!!!!!!!!!!

Exported variables
   nr_of_par : number of parameters (spectral+special)
   nspect    : number of spectral parameters
   partype   : parameter type
   parformat : format of parameter files

Exported types
   parameters : array of 80 reals
 *********************************************************************/

#include <command.h>
#include <pario.h>

int  nr_of_par=22;      /* nr of parameters/frame    */
int  nspect=20;         /* nr of spectral parameters */
int  parformat=0;       /* inputfile format (0=DSPS) */
int  partype=8;         /* parameter type            */
 

double spectral_parameter(int p)
{int i1,i2;
 double val;

 if (parformat!=0) val=atof(item);
 else
 {i1=item[0]-'0'; if (i1>9) i1=i1-7;
  i2=item[1]-'0'; if (i2>9) i2=i2-7; i1=16*i1+i2;
  switch (partype)
  {case 1: case 2: case 3: if (i1>=128) i1=i1-256; val=(double)i1/128.0; 
                           break;
   default               : val=(double)i1/256.0; break;
  }
 }
 return val;
}

double special_parameter(int p)
{double val;

 val=atof(item);
 if (parformat==0) switch (partype)
 {case 1: case 2: if (p==nspect+1) return val;
                          else if (p==nspect+3) return val/1000.0; 
                               else return val/4000.0;
                          break;
  default               : return val/1000.0; break;
 }
 return val;
}

int read_frame(parameters par)
{int p=1;
 int res=0;

 while (p<=nspect) 
 {fgets(answer,maxstrlen,readfile);
  if (feof(readfile)) return -1;
  while (first_item() && (p<=nspect)) {par[p]=spectral_parameter(p); p++;} 
 }
 if (nr_of_par==nspect) return 0;
 else 
 {fgets(answer,maxstrlen,readfile); 
  first_item(); res=atoi(item); 
  for (p=nspect+1;p<=nr_of_par;p++) 
   if (first_item()) par[p]=special_parameter(p); else par[p]=0;
 }
 return res;
}

void write_spectral_parameter(double par)
{int i,j;

 if (parformat!=0) fprintf(writefile," %10g",par);
 else
 {switch (partype) 
  {case 1: case 2: case 3: i=round_int(128*par); if (i<0) i=i+256; break;
   default               : i=round_int(256*par); break;
  }
  if (i>255) i=255; else if (i<0) i=0;
  j=i/16; if (j>9) j=j+7; fprintf(writefile," %c",j+'0');
  j=i%16; if (j>9) j=j+7; fprintf(writefile,"%c",j+'0');
 }
}

void write_special_parameter(int p,double par)
{int i;

 if (parformat!=0) fprintf(writefile,"%10g",par); 
 else
 {switch (partype) 
  {case 1: case 2: if (p==nspect+1) i=round_int(par);
                   else if (p==nspect+3) i=round_int(1000.0*par); 
                        else i=round_int(4000.0*par);
                   break;
   default       : i=round_int(1000.0*par); break;
  }
  if (i>9999) i=9999; else if (i<-999) i=-999; 
  fprintf(writefile,"%5d",i);
 }
}

void write_frame(int code,int n_per_line,parameters par)
{int p,p2;

 if (nspect>n_per_line) p2=n_per_line; else p2=nspect;
 for (p=1;p<=nspect;p++) 
 {write_spectral_parameter(par[p]);
  if (p==p2) 
  {fprintf(writefile,"\n"); 
   p2=p2+n_per_line; 
   if (p2>nspect) p2=nspect;
  }
 }
 if (nr_of_par>nspect) 
 {fprintf(writefile,"%1d",code); 
  for (p=nspect+1;p<=nr_of_par;p++) write_special_parameter(p,par[p]);
  fprintf(writefile,"\n");
 }
}
 
void init_pario()
{text_line s;

 printf("----- Initialization of module PARIO -----\n");
 strcpy(s,"nr of parameters/frame   ");
 get_one_integer(inpt,s,&nr_of_par);
 strcpy(s,"nr of spectral parameters");
 get_one_integer(usual,s,&nspect);
 strcpy(s,"parameter type (1..9)    ");
 get_one_integer(usual,s,&partype);
 strcpy(s,"parfile format : DSPS(=0) or real(#0)");
 get_one_integer(usual,s,&parformat);
}
 

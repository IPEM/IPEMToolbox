/* audimod.c */

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

/***************************************************************************
    A U D I T O R Y  M O D E L  B A S E D  S P E E C H  A N A L Y S I S
 ***************************************************************************/

#include "audiprog.h"
#include "audimod.h"
#include "decimation.h"
#include "filterbank.h"
#include "hcmbank.h"

/* KT 19990525
#include "ecebank.h"
#include "cpu.h"
*/

#define width      16

static double      delay;             /* delay introduced by model    */
static parameters  par[width-1+1];            
static long        par_ptr;           /* pointer to most recent frame */
static int         one_byte;
static double      tend,tout;
static double      t,Tsmp;
static long        pitch_delay;       /* get pitch from frame[n+pitch_delay] */
static int         auto_factor;


void setup_modules()
/***********************************************************************
  Add extra 10 ms to pitch delay, due to pitch window length which
  is larger than erl-analysis window length
 ***********************************************************************/
{
 startup_sigio(); 
 setup_omef(); 
 setup_filterbank();
 setup_decimation(); /* KT: JPM "setup_decimation NA setup_filterbank" */
 setup_hcmbank(); 

/* KT 19990525
 setup_ecebank(); 
 setup_cpu();

 pitch_delay=shift;
 if (pitch_delay>7) printf("%s\n","Error: Tframe must be > 3 ms (for pitch)");
*/
}

void init_modules(const char* inOutputFileName)
{
 init_omef();
 init_decimation(); 
 init_filterbank(); 
 init_hcmbank(inOutputFileName); 

/* KT 19990525
 init_ecebank(); 
 init_cpu();
*/
}

/* Finalize modules */
/* KT 19990525      */
void finish_modules()
{
	finish_hcmbank();
}

long specify_parameters(long inNumOfChannels, double inFirstFreq, double inFreqDist, double inSampleFrequency)
{
	/* KT adapted */
	if (inNumOfChannels > max_nchan)
	{
		printf("ERROR:\nToo many channels! Max. = 40");
		return -1;
	}
	nchan = inNumOfChannels;	// given, checked with max_nchan
	uc1 = inFirstFreq;			// given
	duc = inFreqDist;			// given
	fssig = inSampleFrequency/1000;	// (kHz) should better be extracted from sound file...
	// Tframe stays fixed to 10 (time between frames)
	// Nerl stays fixed to 5 (number of erl samples/frame)

	// KT 19991006
//	if (fssig>=16) { ndecim=3; Tse=8.0/fssig; } else { ndecim=2; Tse=4.0/fssig; }
	ndecim = 1; Tse = 2.0/fssig; 

	Terl=Tframe/Nerl;
	return 0;
}

void scale_frame(int *vuv,parameters frame)
/*********************************************************************
   Replace the pitch (in Tsmp) by the fundamental (in kHz)
   Replace the pitch and V/UV evidence over 30 ms to the left in
   the output stream (=frame)
 *********************************************************************/
{int i;
 long m; 

 if (par[par_ptr][nchan+1]!=0) 
    par[par_ptr][nchan+1]=fsmp/(par[par_ptr][nchan+1]);
 m=par_ptr-pitch_delay; if (m<0)  m=m+width;
 for (i=1;i<=npar_max;i++) frame[i]=par[m][i];
 frame[nchan+1]=par[par_ptr][nchan+1]; 
 frame[nchan+2]=par[par_ptr][nchan+2];
 if (frame[nchan+1]!=0) *vuv=1; else *vuv=0;
}

long startup_audiprog(int bytes,int *nspect,int *npar,
					  long inNumOfChannels,double inFirstFreq,double inFreqDist,double inSampleFrequency)
{
 long theResult = 0;
 one_byte=bytes; 
 theResult = specify_parameters(inNumOfChannels,inFirstFreq,inFreqDist,inSampleFrequency);
 if (theResult == 0)
 {
	 setup_modules(); 
	 delay=Tdecim+Tmodel; 
	 printf("%s%7.3f%7.3f%7.3f%4d\n","Td,Tm,delay,Ne =",Tdecim,Tmodel,delay,Ne);
	 *nspect=nchan; 
	 *npar=nchan+Nerl+3;
 }
 return theResult;
}

void init_factor(text_line filename)
{
 double smax,sn;
 int last;

 if (open_readfile(filename))
 {
   smax=0; sn=0; last=0;
   do
   {
     sn=new_sample(one_byte,&last);
     smax=max(smax,fabs(sn));
   }
   while (!last);
   factor=max(1.0,0.75/smax);
   close_readfile(); /* !!!!! */
 }
 else factor=1.0;
 printf("factor = %f\n",factor);
}

int init_analysis(text_line filename,const char* inOutputFileName)
/**********************************************************************
    The signal is supposed to be surrounded by two silent intervals
    of at least 20 ms long.
    The spectrum generated at frame n is supposed to correspond to
    time n.Tframe (n=1..nframe)
 **********************************************************************/
{int m,p;

 if (auto_factor) init_factor(filename);
 init_modules(inOutputFileName); n=0; nmod=0; t=0; tout=delay+Tframe; tend=0; 
 Tsmp=1/fsmp; par_ptr=0; 
 for (m=0;m<=width-1;m++) for (p=1;p<=nchan+Nerl+3;p++) par[m][p]=0;
 return open_readfile(filename);
}

/* Finalize analysis of one file */
/* KT 19990525 */
void finish_analysis()
{
	finish_modules();
}

int one_frame(int *last,parameters frame)
{long   cnt;
 int    vuv;
 double sn;

 if (tend!=0) *last=1; else *last=0; 
 if (n==0) cnt=shift+1; else cnt=1;
 do
 {if (*last) sn=0;
  else 
  {sn=factor*new_sample(one_byte,last);
   if (*last) {tend=n*Tsmp+delay+2*Tframe; close_readfile();}
  }
  sn=omef(sn); 
  decimate(sn); 
  filterbank(); 
  hcmbank(); 

/* KT 19990525
  ecebank(); 
  cpu();
*/
  if (fsmp!=fssig) 
  {sn=0; n++; t=t+Tsmp; 
   nmod++; if (nmod==max_step) nmod=0;
   decimate(sn); 
   filterbank(); 
   hcmbank(); 

/* KT 19990525
   ecebank(); 
   cpu();
*/
  }
  n++; t=t+Tsmp; nmod++; if (nmod==max_step) nmod=0;
  if (((n & Nemask)==0) && (t>=tout))  
  {if (par_ptr==width-1) par_ptr=0; else par_ptr++;

/* KT 19990525
   results(t-tout,par[par_ptr]); 
*/
   scale_frame(&vuv,frame); 

   tout=tout+Tframe;
   cnt--;
  } 
 }
 while (cnt>0);
 if ((tend!=0) && (tout>=tend)) *last=1; else *last=0;
 return vuv;
}


/* cpupitch.c */

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
    Part of the CPU that is responsible for the pitch extraction
 ***************************************************************************/

#include "audiprog.h"
#include "assert.h"
#include "cpupitch.h"

#define  nextr      12   /* nr. of evp-extrema that can be stored */
#define  min_dt      2   /* min. dt between extrema (in ms)       */
#define  max_pitch  16   /* max. pitch in ms                      */
#define  Twindow    30   /* window length in ms                   */

typedef struct{
               long     search_max;      /* look for a maximum? */
               double   extr;            /* current extremum */
               double   y1,y2;           /* previous and next y */
               long     indx;            /* where to put extr */
               long     tmax[nextr-1+1]; /* locations of extrema (in 0.2 ms) */
               double   sum[nextr-1+1];  /* area under extrema */
              } extrdata; /* extrema in evp(8n) pattern */

typedef struct{
               long     nex;         /* nr. of peaks */
               long     tmax[30+1];  /* locations */
               double   ampl[30+1];  /* amplitudes */
              } peakdata; /* peaks in autocorrelation function */

static double    Tse2;               /* Tse/2 = time unit for pitch analysis  */
static extrdata  extrd[max_nchan+1]; /* data about extrema in evp(n.Tse)      */
static double    R[200+1];           /* autocorrelation function (time x Tse2)*/
static peakdata  peaks[31+1];
static long      ptr;                /* pointer to current peakdata (in Tse2) */
static long      prev_T0;            /* previous value of T0 (in Tse2)        */
static long      max_T0;             /* maximum value of T0 (in Tse2)         */
static long      Nwindow;            /* window length (in Tse2)               */
static long      min_dn;             /* minimum time between extrema (in Tse2)*/
static long      scope;              /* nr. of frames to consider for T0,evid */



void setup_pitch()
{
 Tse2=0.5*Tse; min_dn=round_int(min_dt/Tse2); max_T0=round_int(max_pitch/Tse2);
 printf("%s%7.3f%4d%4d\n","Tse2,min_dn,max_T0 =",Tse2,min_dn,max_T0);
 assert(max_T0<=200); /* R[m], m=0..max_T0 */
 Nwindow=round_int((double)Twindow/Tse2);
 shift=round_int(20.0/Tframe); scope=2*(shift)+1;
 printf("%s%4d%4d\n","CPUPITCH: Scope and shift = ",scope,shift);
}

void init_pitch()
{int m,p;

 for (p=1;p<=nchan;p++)
 {extrd[p].search_max=0; extrd[p].indx=0;
  for (m=0;m<=nextr-1;m++) {extrd[p].sum[m]=0; extrd[p].tmax[m]=-900;}
 }
 ptr=0; prev_T0=0; for (m=0;m<=7;m++) peaks[m].nex=0;
}


void analyse_ev(int p)
/*********************************************************************
   Look for an extremum in the ev(8n) pattern of channel P.
 *********************************************************************/
{
#define  delta  0.0125   /* minimum value accepted as maximum */

 double y;
 long   i,dt,t;

 if (ev[p]>0) y=ev[p]; else y=0.0; t=(2*n) / Ne;
 if (extrd[p].search_max)
 {extrd[p].sum[extrd[p].indx]+=y;
  if (y>extrd[p].extr)
  {extrd[p].tmax[extrd[p].indx]=t;
   extrd[p].y1=extrd[p].extr;
   extrd[p].extr=y;
  }
  else
  {if (((2*n) / Ne)==(extrd[p].tmax[extrd[p].indx]+2)) extrd[p].y2=y;
   if (y==0)
   {dt=round_int((extrd[p].y2-extrd[p].y1)
             /(2.04*extrd[p].extr-extrd[p].y1-extrd[p].y2));
    extrd[p].tmax[extrd[p].indx]+=dt;
    extrd[p].extr=0;
    extrd[p].search_max=0;
    if (extrd[p].indx==0) i=nextr-1; else i=extrd[p].indx-1;
    if (extrd[p].tmax[extrd[p].indx]>(extrd[p].tmax[i]+min_dn))
       {extrd[p].indx++; if (extrd[p].indx==nextr) extrd[p].indx=0;}
    else
    {if (extrd[p].sum[extrd[p].indx]>extrd[p].sum[i])
        extrd[p].tmax[i]=extrd[p].tmax[extrd[p].indx];
     if (extrd[p].sum[i]<extrd[p].sum[extrd[p].indx])
                extrd[p].sum[i]=extrd[p].sum[extrd[p].indx];
     extrd[p].tmax[extrd[p].indx]=-900;
    }
   }
  }
 }
 else if (y>=delta)
 {extrd[p].search_max=1; extrd[p].y1=0; extrd[p].extr=y;
  extrd[p].sum[extrd[p].indx]=y; extrd[p].tmax[extrd[p].indx]=t;
 }
}

static void autocorrelation_analysis()
/*********************************************************************
   Compute the short time autocorrelation function of the pulse trains
   represented by the evp-extrema in the different channels.
   The extremum at index INDX is only reliable if search_max is false
   and if tmax[indx] is larger than 0.
 *********************************************************************/
{long p,m,k,last,first,t,dt;

 for (m=0;m<=max_T0;m++) R[m]=0; t=2*n / Ne;
 for (p=1;p<=nchan;p++)
 {if (extrd[p].indx==0) last=nextr-1; else last=extrd[p].indx-1;
  if (extrd[p].tmax[last]>=(t-Nwindow))
  {if (extrd[p].search_max) {first=extrd[p].indx+1; if (first==nextr) first=0;}
   else first=extrd[p].indx;
   while (extrd[p].tmax[first]<(t-Nwindow)) 
      {first++; if (first==nextr) first=0;}
   m=first; last++; if (last==nextr) last=0;
   do
   {k=m;
    do
    {dt=extrd[p].tmax[k]-extrd[p].tmax[m];
     if (dt<max_T0) if (extrd[p].sum[m]<extrd[p].sum[k]) R[dt]+=extrd[p].sum[m];
                    else R[dt]+=extrd[p].sum[k];
     k++; if (k==nextr) k=0;
    }
    while (k!=last);
    m++; if (m==nextr) m=0;
   }
   while (m!=last);
  }
 }
}


void determine_peaks_in_R()
/*********************************************************************
   Collect all peaks in R which are larger than a threshold delta,
   and put them in PEAKS[ptr] (update ptr first).
 *********************************************************************/
{
#define   peak_delta   0.012   /* min. peak accepted in R */

 double y,extr,epsilon;
 long   search_max;
 long   m,indx; 

 ptr++; if (ptr==scope) ptr=0; indx=1;
 search_max=0; epsilon=nchan*peak_delta; extr=0;   
 for (m=min_dn;m<=max_T0-1;m++)
 {y=0.25*R[m-1]+0.5*R[m]+0.25*R[m+1];
  if (search_max)
  {if (y>extr) {peaks[ptr].tmax[indx]=m; extr=y;}
   else if (y<0.8*(extr-epsilon))
     {peaks[ptr].ampl[indx]=extr; indx++; search_max=0;}
  }
  else if (y<extr) extr=y;
       else if (y>1.25*(extr+epsilon))
         {search_max=1; extr=y; assert(indx<=30); peaks[ptr].tmax[indx]=m;}
 }
 peaks[ptr].nex=indx-1;
}

void extract_pitch(long *T0, double *evid)
/*********************************************************************
   Determine the pitch T0 (in multiples of Tsmp) and its evidence.
   The pitch extraction introduces a delay of SHIFT frames.
 *********************************************************************/
{
#define   min_ev   0.07  /* minimum evidence for voiced */

 long   m,k,i,t,nr,dT0;
 double ev,vuv_thr;

 autocorrelation_analysis();
 determine_peaks_in_R();
 nr=ptr-shift; if (nr<0) nr=nr+scope; *T0=0; *evid=0; 
 for (m=1;m<=peaks[nr].nex;m++) 
 {ev=0; t=peaks[nr].tmax[m];
  for (i=0;i<=scope-1;i++) for (k=1;k<=peaks[i].nex;k++) 
      if ( 10*labs(t-peaks[i].tmax[k]) < (t+peaks[i].tmax[k]) )
    ev=ev+peaks[i].ampl[k];
  if (ev>*evid) {*T0=(Ne*t) / 2; *evid=ev;}
 }
 vuv_thr=nchan*min_ev; *evid=(*evid)/scope; dT0=(*T0) / 5;
 if (*evid<(0.5*vuv_thr)) *T0=0;
 else if (*evid<vuv_thr) 
       if ((prev_T0==0) || (labs(prev_T0-*T0)>dT0)) *T0=0; 
 prev_T0=*T0;               
}

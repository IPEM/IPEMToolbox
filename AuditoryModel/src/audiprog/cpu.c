/* cpu.c */

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

/*************************************************************************
    Central Processing Unit of the Auditory Model
 *************************************************************************/
 
#include "audiprog.h"
#include "cpupitch.h"
#include "cpu.h"

#define max_nbuf 32

static double  Terlbuf;       /* time between computations of erl_sum */
static long    Nerlbuf;       /* ratio between Terlbuf and Tse */
static double  erl_buf[max_nbuf-1+1];
                              /* contains last (Tframe/Tse) samples erl_sum */
static long    pbuf;          /* Tframe/Tse */
static long    nbuf;          /* pointer to most recent sample in buffer */


void setup_cpu()
{
 Nerlbuf=round_int(Terl*fsmp);
 Terlbuf=(double)Nerlbuf/fsmp;
 printf("%s%4d\n","Nerlbuf =",Nerlbuf);
 nbuf=1+round_int(Tframe/Terlbuf); 
 setup_pitch();
 if (nbuf>max_nbuf) printf("ERROR: Nerl too large for CPU\n");
 else printf("%s%4d%4d\n","nbuf,Nerl =",nbuf,Nerl);
}

void init_cpu()
/**********************************************************************
   Initialize the state variables of the CPU module
 **********************************************************************/
{int p;

 pbuf=0; for (p=0;p<=max_nbuf-1;p++) erl_buf[p]=nchan*fspont;
 init_pitch();
}

void cpu()
/**********************************************************************
   If n is a multiple of Ne samples: look for extrema in ev(n,p)
 **********************************************************************/
{int p;

 if ((n & Nemask)==0) for (p=1;p<=nchan;p++) analyse_ev(p);
 if ((n % Nerlbuf)==0)
 {pbuf++; if (pbuf==max_nbuf) pbuf=0; erl_buf[pbuf]=0;
  for (p=1;p<=nchan;p++)
  {if (erl[p]>fspont) erl_buf[pbuf]=erl_buf[pbuf]+erl[p];
   else erl_buf[pbuf]=erl_buf[pbuf]+fspont;
  }
 }
}

void results(double dt,parameters par)
/**********************************************************************
   Compute pitch and voicing evidence and put the results in parameter
   vector PAR.
    - par[1..nchan]  : erl values for different channels at time tm,
                       obtained by interpolating between values at the
                       current time t0=tm+dt, and those at t1=t0-Terl.
    - pitch+evidence : pitch and voicing evidence of current frame,
                       but based on postprocessing of frames m-shift
                       to m+shift (===> delay of shift frames)
    - total_erl      : 5 times average total erl (sum over channels)
                       in frame of length Tframe
    - erl_buf        : samples of the total sum of erl-contributions
                       measured at tj=tm-(Nerl-j).Terl (j=1,..,Nerl).
                       (again: linear interpolation is used).
   The total number of parameters (NPAR) is nchan+Nerl+3
 **********************************************************************/
{long   p,m,m1,k;
 double rx,ry,rz,sum,t,tT;

 rx=dt/Tse; ry=1-rx; sum=0;
 for (p=1;p<=nchan;p++)
 {sum=ry*erl[p]+rx*prev_erl[p]-fspont;
  if (sum>0) par[p]=4*sum; else par[p]=0.0;
 }
 sum=0;
 for (p=1;p<=Nerl;p++)
 {t=dt+(Nerl-p)*Terl; tT=t/Terlbuf; k=(long)(tT);
  m=pbuf-k; if (m<0) m=m+max_nbuf;
  if (m==0) m1=max_nbuf-1; else m1=m-1; 
  rx=tT-k; /* rx=(t-k*Terlbuf)/Terlbuf; */
  rz=rx*erl_buf[m1]+(1-rx)*erl_buf[m]-nchan*fspont;
  if (rz>0.0) par[nchan+3+p]=rz; else par[nchan+3+p]=0.0; sum=sum+rz;
 }
 extract_pitch(&m,&par[nchan+2]); par[nchan+1]=m; par[nchan+3]=4*sum/Nerl;
}


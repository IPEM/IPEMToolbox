/* ecebank.c */

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

#include "audiprog.h"

#define  tauS1   11.0           /* smallest time constant in ECE      */
#define  tauS2   33.0           /* largest time constant in ECE       */

static double  ch1,sh1,cl1,sl1;        /* coefficients of hpf1,lpf1          */
static double  ch2,sh2,cl2,sl2;        /* coefficients of hpf2,lpf2          */


void setup_ecebank()
/**********************************************************************
  Compute the lpf1,hpf1,lpf2,hpf2 filter coefficients
     lpf1,hpf1 operate at a sampling rate fse=1/Tse
     lpf2,hpf2 operate at a sampling rate fse=1/Tse
  The gain factor 5 is intended to get ev-samples which scale to
  amplitudes of 1
 **********************************************************************/
{
 cl1=exp(-Tse/tauS1);          sl1=0.5*(1-cl1);
 ch1=exp(-Tse/(0.35*tauS1));   sh1=0.5*(1+ch1);
 cl2=exp(-Tse/tauS2);          sl2=0.5*(1-cl2);
 ch2=exp(-Tse/(0.35*tauS2));   sh2=0.5*(1+ch2);
 Tmodel+=0.35*tauS1;
}

void init_ecebank()
{int p;

 for (p=1;p<=nchan;p++) {ev[p]=0; erl[p]=yhcm[p];}
}

void ecebank()
/**********************************************************************
   Compute a sample of the envelope components EV and ERL
 **********************************************************************/
{int p;

 if ((n & Nemask)==0) for (p=1;p<=nchan;p++)
 {ev[p] =ch1*ev[p]+sh1*(yhcm[p]-yhcm1[p]);
  prev_erl[p]=erl[p];
  erl[p]=cl1*erl[p]+sl1*(yhcm[p]+yhcm1[p]);
 }
}


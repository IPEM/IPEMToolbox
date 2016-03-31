/* audiprog.h */

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
   Declaration of constants, types and variables and functions
   which are visible at the general outline level.
 ***************************************************************************/

#include <command.h>
#include <pario.h>
#include <sigio.h>

#if !defined( AUDIPROG_H )
#define AUDIPROG_H

#define pi           3.14159
#define max_nchan    40        /* maximum number of channels */
#define fspont       0.05      /* spontaneous firing rate */

typedef double rvector[max_nchan+1];
typedef long   ivector[max_nchan+1];

extern double  Tdecim;     /* delay introduced by decimation unit (ms)  */
extern double  Tmodel;     /* delay introduced by rest of model (ms)    */
extern double  fsmp;       /* internal sampling frequency = 1/Tsmp      */
extern double  fssig;      /* signal sampling frequency                 */
extern double  Tframe;     /* time between successive frames (ms)       */
extern int     ndecim;     /* number of decimation filters to use       */
extern double  Tse;        /* time between successive envelope samples  */
extern int     Ne;         /* Tsmp for envelope / Tsmp of model         */
extern int     Nemask;     /* Ne-1 = mask for MOD replacement           */
extern int     Nerl;       /* number of erl samples per frame           */
extern double  Terl;       /* time between erl samples in frame         */
extern int     shift;      /* pitch comes from SHIFT frames behind      */
extern int     nchan;      /* number of filterbank channels             */
extern double  uc1;        /* ucp of first channel                      */
extern double  duc;        /* spacing between succesive ucp's           */
extern int     n;          /* time index                                */

extern rvector fc;         /* BPF central frequencies                   */
extern rvector uc;         /* corresponding critical band units         */
extern ivector x2;         /* is there a need to upsample after BPF?    */
extern ivector step;       /* time steps used in analysis channels      */
extern ivector stepmask;   /* stepmask=step-1 = mask for MOD replacement*/
/* JPM: 20/10/98: new implementation of channel selection ***************/
extern int     max_step;   /* maximum step encountered in channels      */
extern int     nmod;       /* time modulo max_step                      */
extern int     low_ch[16]; /* lowest channel to process for different   */
                           /* values of nmod                            */
/************************************************************************/
extern double  decim[5+1]; /* decimation products                       */
extern ivector indx;       /* index in decimation product array         */
extern rvector ybpf;       /* BPF outputs at multiples of step.Tsmp     */

extern rvector yhcm;       /* HCM outputs at multiples of Tse           */
extern rvector yhcm1;      /* previous HCM outputs at multiples of Tse  */
extern rvector ev,erl;     /* virtual tone, roughness+loudness comps.   */
extern rvector prev_erl;   /* previous roughness+loudness components    */
extern rvector yres;       /* xxx outputs at multiples of step.Tsmp     */
extern double  factor;     /* multiplication factor for input samples   */

#endif /* AUDIPROG_H */


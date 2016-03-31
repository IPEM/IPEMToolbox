/* hcmbank.c */

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
#include "hcmbank.h"

#define  tau1      8.0       /* smallest time constant (ms) of LPF     */
#define  tau2     40.0       /* largest time constant (ms) of LPF      */
#define  ratio     0.860     /* mixing ratio in LPF                    */
#define  fsat      0.150     /* saturation firing rate (/ms)           */
#define  yref      0.001     /* value added to the input sample        */
#define  fe        1.250     /* cutoff frequency of EEF                */	/* KT 19990525 */


typedef struct{
               double a1q,a2q;   /* coefficients of the AGC          */
               double g1q,c1,c2; /* lowpass filter section           */
               double zn;        /* state variable of cell 1 of LPF  */
               double w1n,fn;    /* state variables of cell 1 of LPF */
               double w2n,qn;    /* state variables of cell 2 of LPF */
               double qfac;      /* precomputed fsat/(bias+sqrt(qn)) */
              } hcmdata;

typedef struct{
               double b;       /* - envelope extraction LPF --------  */
               double b1,b2;   /* coefficients                        */
               double g1,g2;   /* gain factors                        */
               double y1n;     /* output of first order cell          */
               double wn1,wn2; /* state vector of 2nd order cell      */
              } eefdata;

static double   bias;               /* bias in gain control branch         */
static double   factor2;            /* fsat/sqr(bias)                      */
static hcmdata  hcmd[max_nchan+1];  /* coefficients + state vars of hcm's  */
static eefdata  eefd[max_nchan+1];  /* coefficients + state vars of eef's  */

static FILE*    sEnvelopeFile = NULL;	/* The file in which the envelopes of
							               the firing probabilities are stored */
							            /* KT 19990525 */

/* ----- Down from here: KT 19990525 ----- */

/* Open the firing probability envelope file.
   Returns 1 on success, 0 on failure */
int HCMBank_OpenEnvelopeFile (const char* inFileNameWithPath)
{
	sEnvelopeFile = fopen(inFileNameWithPath,"wb");
	return (sEnvelopeFile == NULL) ? 0 : 1;
}

/* Close the firing probability envelope file. */
void HCMBank_CloseEnvelopeFile ()
{
	fclose(sEnvelopeFile);
	sEnvelopeFile = NULL;
}

/* Finalize HCM bank */
void finish_hcmbank ()
{
	HCMBank_CloseEnvelopeFile();
}

/* end of KT changes */

double h_eef(int p,double f,double fs)
{double rz,iz,rz2,iz2,x,y;

 rz =cos(2*pi*f/fs); iz =sin(2*pi*f/fs);
 rz2=cos(4*pi*f/fs); iz2=sin(4*pi*f/fs);
 x=pow(rz+1,2.0)+pow(iz,2.0); y=x/(pow(rz-eefd[p].b,2.0)+pow(iz,2.0));
 return eefd[p].g1*eefd[p].g2*x*sqrt(y/(pow(rz2+eefd[p].b1*rz+eefd[p].b2,2.0)
        +pow(iz2+eefd[p].b1*iz,2.0)));
}

void write_eef()
{int i,p;
 long prev_s;
 double f,fs,y,ydb;

 if (open_writefile("eef.dat")) 
 {for (i=1;i<=100;i++)
  {f=i*fsmp/1600; fprintf(writefile,"%7.3f",f); prev_s=0;
   for (p=1;p<=nchan;p++) if (step[p]!=prev_s)
   {fs=fsmp/step[p]; prev_s=step[p];
    y=h_eef(p,f,fs); ydb=8.68*log(y+1.0E-04);
    fprintf(writefile,"%7.2f",ydb);
   }
   fprintf(writefile,"\n");
  }
  close_writefile();
 }
}

double h_lpf(int p,double f,double fs)
{double rz,iz,x,y;

 rz=cos(2*pi*f/fs); iz=sin(2*pi*f/fs);
 y=1/(pow(rz-hcmd[p].c1,2.0)+pow(iz,2.0));
 x=pow(hcmd[p].a1q*rz-hcmd[p].a2q,2.0)+pow(hcmd[p].a1q*iz,2.0); 
 y=y*x/(pow(rz-hcmd[p].c2,2.0)+pow(iz,2.0));
 return hcmd[p].g1q*sqrt(y);
}

void write_lpf()
{int i,p;
 long prev_s;
 double f,fs,y,ydb;

 if (open_writefile("lpf.dat")) 
 {for (i=1;i<=100;i++)
  {f=i/200.0; fprintf(writefile,"%7.3f",f); prev_s=0;
   for (p=1;p<=nchan;p++) if (step[p]!=prev_s) 
   {fs=fsmp/step[p]; prev_s=step[p];
    y=h_lpf(p,f,fs); ydb=8.68*log(y+1.0E-04);
    fprintf(writefile,"%7.2f",ydb);
   }
   fprintf(writefile,"\n");
  }
  close_writefile();
 }
}


void setup_hcmbank()
/**********************************************************************
  Each haircell model consists of a halfwave rectification, an envelope
  extraction filter, and an automatic gain controller. The outputs of
  the EEF filter are computed at a rate fse=1/Tse, the state vector of
  this filter however is computed at the rate fsp=1/Tsp.
  The LPF and the EEF are derived from analog filters by means of the
  bilinear transform:
  LPF: h(t) = alpha.[r.exp(-t/tau1) + (1-r).exp(-t/tau2)]
       H(s) = alpha.[s+tau/tau1/tau2]/(1+s.tau1)(1+s.tau2)
                                   with tau = r.tau1+(1-r).tau2
       s ==> z = (c+s)/(c-s) with c = 2fsp
       H(z) = g1q.(1-c1)(1+z^-1)/(1-c1.z^-1).(a1q-a2q.z^-1)/(1-c2.z^-1)
       with   c1    = (2fsp.tau1-1)/(2fsp.tau1+1)
              c2    = (2fsp.tau2-1)/(2fsp.tau2+1)
              g1q   = 0.5*(1-c1)
              a2q/a1q = (2fsp.tau1.tau2-tau)/(2fsp.tau1.tau2+tau)
              a1q   = (1-c2)*(fsp.tau1.tau2/tau+0.5)
 **********************************************************************/
{int    p;
 double fsp,kb,tau;
 double tmp1;

 Tmodel+=0.9/(2*pi*fe); /*first cell = 0.35, second cell = 0.55*/
 for (p=1;p<=nchan;p++)
 {fsp=fsmp/step[p]; 
  hcmd[p].c1=(2*fsp*tau1-1)/(2*fsp*tau1+1); 
  hcmd[p].g1q=0.5*(1-hcmd[p].c1);
  hcmd[p].c2=(2*fsp*tau2-1)/(2*fsp*tau2+1); tau=ratio*tau1+(1-ratio)*tau2;
  hcmd[p].a1q=(1-hcmd[p].c2)*(0.5+fsp*tau1*tau2/tau);
  hcmd[p].a2q=(2*fsp*tau1*tau2-tau)*hcmd[p].a1q/(2*fsp*tau1*tau2+tau);
/** JPM **
  printf("p,c1,c2,a1,a2 =%3d%7.4g%7.4g%7.4g%7.4g\n",p,hcmd[p].c1,hcmd[p].c2,
         hcmd[p].a1q,hcmd[p].a2q);
 *********/
  kb=pi*fe/fsp; kb=cos(kb)/sin(kb);
  eefd[p].b=(kb-1)/(kb+1); eefd[p].g1=0.5*(1-eefd[p].b);
          /* 0.50 because g1 will be multiplied with fn+fn1 */
  tmp1=pow(kb,2.0);
  eefd[p].b2=(1+tmp1-kb)/(1+tmp1+kb);
  eefd[p].b1= 2*(1-tmp1)/(1+tmp1+kb);
  eefd[p].g2=0.25*(1+eefd[p].b1+eefd[p].b2);
          /* 0.25 because f(0) = 4w(0) = 4g2.f(0)/(1+b1+b2) */
 }
 bias=sqrt(yref*fsat/fspont)-sqrt(yref); factor2=fsat/pow(bias,2.0);
 write_lpf(); write_eef();
}


/* Initialize HCM bank */
void init_hcmbank(const char* inOutputFileName)
{
/**********************************************************************
   Initialization of state variables of the AGC devices. The demands
   are that q(0) = yref and f(0) = yh(0) = fspont
   LPF
    - w1(0) = g1q.2yref + c1.w(0)   ====> w1(0) = g1q.2yref/(1-c1) = yref
    - w2(0) = w1(0) + c1.w2(0)      ====> w2(0) = w1(0)/(1-c1)
    - q(0)  = a1q.w2(0) - a2q.w2(0) ====> q(0)  = w2(0).(a1q-a2q)
                                                = w2(0).(1-c2) = yref
   EEF
    - y1(0) = g1.2f(0) + b.y1(0)    ====> y1(0) = 2.g1.f(0)/(1-b)
                                                = fspont
    - w(0)  = g2.y1(0) - b1.w(0) -b2.w(0)
                                    ====> w(0)  = g2.y1(0)/(1+b1+b2)
    - yh(0) = w(0)+2w(0)+w(0)       ====> yh(0) = 4.w(0) = fspont
                                    ====> w(0)  = fspont/4
 **********************************************************************/
 int p;

 for (p=1;p<=nchan;p++)
 {hcmd[p].zn=yref; hcmd[p].qn=yref; hcmd[p].qfac=0; 
  hcmd[p].w1n=yref; hcmd[p].w2n=yref/(hcmd[p].a1q-hcmd[p].a2q);
  hcmd[p].fn=fspont; 
  eefd[p].y1n=fspont; eefd[p].wn1=0.25*fspont; eefd[p].wn2=eefd[p].wn1;
  yhcm[p]=fspont; yhcm1[p]=yhcm[p];
 }

 /* Initialization for the envelope output file */	/* KT 19990525 */
 if (!HCMBank_OpenEnvelopeFile(inOutputFileName))
 {
	printf("\nERROR: the output file \"%s\" could not be opened for writing...\n", inOutputFileName);
 }
}

void hcmbank()
/**********************************************************************
   Compute the firing rate in channel p every Tse.
    LPF: H1: w1(n) = gq1.z(n)  + c1.w1(n-1)
         H2: w2(n) = w1(n) + c2.w2(n-1)
             q(n)  = a1q.w2(n) - a2q.w2(n-1) for n = multiple of Tse
    AGC:     f(n)  = G[q(n)].z(n)
    EEF: E1: y1(n) = g1.f(n)  + b.y1(n-1)
         E2: w(n)  = g2.y1(n) - b1.w(n-1) - b2.w(n-2)
             e(n)  = w(n) + 2.w(n-1) + w(n-2)
 **********************************************************************/
{int    p,compute_en;
 double zn1,fn1,new_w2,new_w;

 compute_en=((n & Nemask)==0);
 for (p=low_ch[nmod];p<=nchan;p++)
/*
 for (p=1;p<=nchan;p++) if ((n & stepmask[p])==0)
*/
 {zn1=hcmd[p].zn; fn1=hcmd[p].fn; 
  if (ybpf[p]+yref>0.0) hcmd[p].zn=ybpf[p]+yref; else hcmd[p].zn=0.0;
  hcmd[p].w1n=hcmd[p].g1q*(hcmd[p].zn+zn1)+hcmd[p].c1*hcmd[p].w1n; 
  new_w2=hcmd[p].w1n+hcmd[p].c2*hcmd[p].w2n;
  if (compute_en) 
  {hcmd[p].qn=hcmd[p].a1q*new_w2-hcmd[p].a2q*hcmd[p].w2n; 
   hcmd[p].qfac=0;
  }
  hcmd[p].w2n=new_w2;
  if (hcmd[p].zn<=0) hcmd[p].fn=0; 
  else if (hcmd[p].qn<=0) hcmd[p].fn=factor2*hcmd[p].zn; 
       else
       {if (hcmd[p].qfac==0) hcmd[p].qfac=fsat/pow(bias+sqrt(hcmd[p].qn),2.0); 
        hcmd[p].fn=hcmd[p].qfac*hcmd[p].zn;
       }
 
  eefd[p].y1n=eefd[p].g1*(hcmd[p].fn+fn1)+eefd[p].b*eefd[p].y1n; 
  new_w=eefd[p].g2*eefd[p].y1n-eefd[p].b1*eefd[p].wn1-eefd[p].b2*eefd[p].wn2;
  if (compute_en)
  {
	yhcm1[p]=yhcm[p]; yhcm[p]=new_w+2*eefd[p].wn1+eefd[p].wn2;
	fprintf(sEnvelopeFile,"%.10lf ",(yhcm[p] < 0) ? 0 : yhcm[p]);	/* KT 19990525 */
  }
  eefd[p].wn2=eefd[p].wn1; eefd[p].wn1=new_w;
 }
 if (compute_en) fprintf(sEnvelopeFile,"\n");	/* KT 19990525 */
}




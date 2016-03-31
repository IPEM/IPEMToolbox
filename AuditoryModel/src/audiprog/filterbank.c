/* filterbank.c */

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
#include "filterbank.h"

#define  ncel     2          /* number of 2nd-order cells per BPF      */
#define  f0       1.5        /* min. f (kHz) for which u(f)~ln(f)      */
#define  ratio    0.20       /* rel. width of critical band for f>f0   */
#define  min_bw   0.07       /* min. value of the critical bandwidth   */

typedef struct{
               double a1,a2;  /* coefficients of numerator   */
               double b1,b2;  /* coefficients of denominator */
               double w1,w2;  /* cell's state variables      */
              } celldata;
typedef struct{
               double    gain;
               celldata  cell[ncel+1];
              } bpfdata;

static double   ca,cb,cc;
static double   cd,u0;
static bpfdata  bpfd[max_nchan+1];       /* BPF filter coeffs and states     */

double u(double f)
{if (f<=f0) return ca*atan(cb*f); else return cc*log(f)+cd;
}

double umin1(double ut)
{
 if (ut<=u0) return sin(ut/ca)/cos(ut/ca)/cb; else return exp((ut-cd)/cc);
}

void define_bplp(double fs,double f1,double f2,double *kbp,double *cos_fie)
/*********************************************************************
  Analog bandpass to digital lowpass transform
       s = kbp.(z^2-2.z.cos_fie+1)/(z^2-1)
       wa = kbp.(cos_fie-cos(wd))/sin(wd)
 *********************************************************************/
{double w1,w2,wc,hdw,rx;

 rx=2*pi/fs;
 w1=rx*f1;
 w2=rx*f2;
 wc=(w2+w1)/2;
 hdw=(w2-w1)/2;
 *kbp=cos(hdw)/sin(hdw);
 *cos_fie=cos(wc)/cos(hdw);
}
 
 
void lpbp2(double kbp,double cos_fie,double re,double im,
           double *alfa1,double *beta1,double *alfa2,double *beta2)
/*********************************************************************
  Digital lowpass to analog bandpass transform
    z1=(k.cos_fie-s)/(k-s)    alfa1 = -2.re(z1)   beta = |z1|^2
    z2=(k.cos_fie+s)/(k-s)    alfa2 = -2.re(z2)   beta = |z2|^2
  with s = re + j.im (and im nonzero)
 *********************************************************************/
{double rx,ry,re_sy,im_sy;
 double a,b,c,d,e/*,f*/; /* LVT 22/3/94: f is unreferenced */

 rx=kbp*cos_fie; ry=pow(re-kbp,2.0)+pow(im,2.0);
 e=re-kbp;
 a=(rx-kbp)*(rx+kbp)+(re-im)*(re+im);
 b=2*re*im;
 c=pow(pow(a,2.0)+pow(b,2.0),0.25);
 d=atan(b/a); if (a<0) d=d+pi;
 d=d/2;
 re_sy=c*cos(d); im_sy=c*sin(d);
 c=re_sy-rx; d=re_sy+rx;
 *alfa1=-2*(e*c-im*im_sy)/ry;
 *beta1=(pow(c,2.0)+pow(im_sy,2.0))/ry;
 *alfa2=2*(e*d-im*im_sy)/ry;
 *beta2=(pow(d,2.0)+pow(im_sy,2.0))/ry;
}

double h2(double f,double fs,bpfdata *bpfd)
/*******************************************************************
   Compute the square of the bandpass frequency response in f (the
   sampling frequency is fs) in case the gain is 1.
 *******************************************************************/
{double resp,r,c1,c2,s1,s2;
 int m;

 r=2*pi*f/fs; 
 c1=cos(r); c2=cos(2*r); 
 s1=sin(r); s2=2*s1*c1;
 resp=1; 
 for (m=1;m<=ncel;m++) 
 {resp=resp*((pow(1+bpfd->cell[m].a1*c1+bpfd->cell[m].a2*c2,2.0)
              +pow(bpfd->cell[m].a1*s1+bpfd->cell[m].a2*s2,2.0))
       /(pow(1+bpfd->cell[m].b1*c1+bpfd->cell[m].b2*c2,2.0)
         +pow(bpfd->cell[m].b1*s1+bpfd->cell[m].b2*s2,2.0)));
 }
 return resp;
}
 
void butterworth(double fc,double uc,double fs,bpfdata *bpfd)
/*******************************************************************
   Butterworth bandpass filter design:
     center frequency   : fc=umin1(uc)
     sampling frequency : fs
   Transfer function (order 2.ncel)
     H(z) = gain . product of (1+a1/z+a2/z**2)/(1+b1/z+b2/z**2)
   Procedure
     1. Transform frequencies f1=umin1(uc-duc2) and f2=umin1(uc+duc2) 
        to -1 and +1 by a bp-lp transform. 
     2. Design normalized LPF of order ncel by Butterworth technique
     3. Transform normalized lowpass filter to a BPF of order 2.ncel
     3. Substitute two zeroes at z=-1 by a complex zero pair at freq.
         fh = freq in (0.26fs,0.5fs) closest to umin1(uc+5)
        This requires a gain correction:
          (1-cos(rc))/sqrt[(1-cos(rh-rc))(1-cos(rh+rc))]
        with rc=2.pi.fc/fs and rh=2.pi.fh/fs
   Remark: if there were no zero-manipulation, duc2 would be 0.5
 ********************************************************************/
{
#define duc2  0.64

 double  kbp,cos_fie,f1,f2,fh,r; 
 int     m,k;

 f1=umin1(uc-duc2); f2=umin1(uc+duc2); fh=umin1(uc+6); 
 define_bplp(fs,f1,f2,&kbp,&cos_fie); 
 k=1;
 for (m=1;m<=ncel/2;m++) 
 {r=pi*(2*m-1)/ncel/2; 
  lpbp2(kbp,cos_fie,-sin(r),cos(r),&(bpfd->cell[k].b1),&(bpfd->cell[k].b2),
        &(bpfd->cell[k+1].b1),&(bpfd->cell[k+1].b2));
  k=k+2;
 }
 for (k=1;k<=ncel;k++) {bpfd->cell[k].a1=0; bpfd->cell[k].a2=-1;}
 if (fh>0.5*fs)
 {r=exp(-1.5*(fh-0.5*fs)/fs);
  bpfd->cell[1].a1=2*r;
  bpfd->cell[1].a2=pow(r,2.0);
 }
 else
 {if (fh<0.25*fs) fh=0.25*fs;
  r=2*pi*fh/fs;
  bpfd->cell[1].a1=-2*cos(r); bpfd->cell[1].a2=1;
 }
 if (fs==fsmp/step[1]) r=1; else r=2;
 r=1-exp(-0.25*uc*r); bpfd->cell[ncel].a1=-2*r; bpfd->cell[ncel].a2=r*r;

 bpfd->gain=1/sqrt(h2(fc,fs,bpfd));
}

void write_filterbank()
{int i,p;
 double ut,f,fs,y,umax;

 if (open_writefile("filters.dat")) 
 {umax=uc[nchan]+4;
  for (i=1;i<=200;i++)
  {ut=i*umax/200; f=umin1(ut); fprintf(writefile,"%7.3f%7.3f",f,ut);
   for (p=1;p<=nchan;p++) 
   {fs=fsmp/step[p];
    if (f>=0.5*fs) y=-80; 
    else {y=pow(bpfd[p].gain,2.0)*h2(f,fs,&bpfd[p]); y=4.34*log(y+1.0E-08);}
    fprintf(writefile,"%7.2f",y);
   }
   fprintf(writefile,"\n");
  }
  close_writefile();
 }
}
 
void setup_filterbank()
/**********************************************************************
 Selection of the maximal sampling frequency (fsmp)
   If largest_fc <= alpha*fssig then fsmp = fssig else fsmp = 2*fssig.
   Ideally, alpha should be equal to 0.125, but it could be chosen a
   little larger to take into account that the highest channels may
   mostly carry unvoiced signals and that there is no need to require
   that the harmonics of the main components introduced by the hair
   cell models do not give rise to aliasing products which have to be
   ruled out.
 Selection of channel sampling frequency fsk
   If fc <= 0.125*fsmp then search for an fsk = fsmp/2^k that is not
   smaller than fse = 1/Tse and that is not smaller than the minimum
   of 8*fc and fsmp/16
**********************************************************************/
{
#define alpha 0.125

 int    p,k;
 double fsk,r;
 FILE* theFilterFrequenciesFile = NULL;

 cc=1/ratio;
 cb=sqrt(ratio*f0/min_bw-1)/f0;
 ca=1/min_bw/cb; u0=ca*atan(cb*f0); cd=u0-cc*log(f0);
/** AV **
 printf("ca,cb,cc,cd,u0: %10.5g %10.5g %10.5g %10.5g %10.5g\n",ca,cb,cc,cd,u0);
 ********/
 r=uc1+(nchan-1)*duc; r=umin1(r);
 if (r<=alpha*fssig) fsmp=fssig; else fsmp=2*fssig;
 Ne=round_int(Tse*fsmp); if (Ne>16) Ne=16; Nemask=Ne-1;
 printf("\nFilterbank data: fssig = %.3f kHz en fsmp = %.3f kHz\n",fssig,fsmp);
 
 /* open a file for the filter frequencies */ 
 theFilterFrequenciesFile = fopen("FilterFrequencies.txt","w");
 if (theFilterFrequenciesFile == NULL)
	 printf("Error: Could not open output file FilterFrequencies.txt, but continuing program execution.");

 for (p=1;p<=nchan;p++)
 {
   uc[p]=uc1+(p-1)*duc; fc[p]=umin1(uc[p]);
   fsk=fsmp; r=fc[p]/fsk; step[p]=1; indx[p]=1;
   while ((r<=0.125) && (step[p]<Ne))
   { indx[p]++; step[p]=2*step[p]; r=2*r; fsk=0.5*fsk; }
   stepmask[p]=step[p]-1;
   butterworth(fc[p],uc[p],fsk,&bpfd[p]);
   printf("%3ld: fc(kHz),fsk(kHz),uc(cbu),step = %7.3f%7.3f%7.3f%3ld%3ld\n",p,
     fc[p],fsk,uc[p],indx[p],step[p]);
   if (fc[p]>0.5*fsmp) printf("error: fc too high\n");
   
   /* write the filter frequencies */
   if (theFilterFrequenciesFile != NULL)
	   fprintf(theFilterFrequenciesFile,"%.3f\n",fc[p]);
 }

 /* close the file */
 fclose(theFilterFrequenciesFile);

 Tmodel=0.5;
 write_filterbank();
 max_step=step[1];
/*** JPM: 20/10/98: new implementation of channel selection ***********/
 printf("low_ch: ");
 for (k=0;k<=max_step-1;k++)
 {
   low_ch[k]=nchan+1;
   for (p=1;p<=nchan;p++) if (k%step[p]==0) low_ch[k]=min(low_ch[k],p);
   printf("%i ",low_ch[k]);
 }
 printf("\n");
/**********************************************************************/
}

void init_filterbank()
/*******************************************************************
    Initialization of the state variables of the bandpass filters
 *******************************************************************/
{int p,k;

 for (p=1;p<=nchan;p++)
 {yres[p]=0; ybpf[p]=0;
  for (k=1;k<=ncel;k++) {bpfd[p].cell[k].w1=0; bpfd[p].cell[k].w2=0;}
 }
}

void filterbank()
/*******************************************************************
    Compute a sample of the BPF in channel p. The output ynp[p] is
    only computed if n is a multiple of step[p].
 *******************************************************************/
{int    m,p;
 double x,y;

 for (p=low_ch[nmod];p<=nchan;p++)
/*
 for (p=1;p<=nchan;p++) if ((n & stepmask[p])==0)
*/
 {y=bpfd[p].gain*decim[indx[p]];
  for (m=1;m<=ncel;m++)
  {x=y-bpfd[p].cell[m].b1*bpfd[p].cell[m].w1
     -bpfd[p].cell[m].b2*bpfd[p].cell[m].w2;
   y=x+bpfd[p].cell[m].a1*bpfd[p].cell[m].w1
     +bpfd[p].cell[m].a2*bpfd[p].cell[m].w2;
   bpfd[p].cell[m].w2=bpfd[p].cell[m].w1; bpfd[p].cell[m].w1=x;
  }
  ybpf[p]=y;
 }
}

/* decimation.c */

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

/* Last changed: JPM 19991103 - delay corrections */

#include "audiprog.h"
#include "decimation.h"

#define  order    3        /* order of decimation filter at 2fssig    */
#define  nh       8        /* 2.nh+1 = length of decimation filter h  */
#define  nh2   2*nh
#define  ndel 14*nh        /* maximum length required for delay lines */
#define  fres     4.00     /* resonance frequency of OMEF (in kHz)    */
#define  Ares     2.25     /* amplitude at resonance frequency        */
#define  fhp      0.25     /* cut-off frequency of high-pass section  */


typedef double state_array[ndel-1+1];

typedef struct{
               double a1,a2; /* coefficients of numerator              */
               double b1,b2; /* coefficients of denominator            */
               double w1,w2; /* cell's state variables                 */
              } celldata;

typedef struct{
               double   gain;
               celldata cell[order+1];
              } lpfdata;

static double  zhp;             /* pole of HPF in OMEF                     */
static double  gain;            /* gain-factor in OMEF                     */
static double  b1,b2;           /* denominator coefficients of OMEF        */
static double  xhp,yhp;         /* state variables of HPF in OMEF          */
static double  yn1,yn2;         /* state variables of OMEF                 */

static double  h[nh2+1];        /* h of decimation filters: h[0]..h[2.nh]  */
static state_array d0,d1,d2,d3; /* state vectors of the decimation filters */
static long         ptrin[4+1]; /* ptrin[j] points to where to add input   */
static long         Td[4+1];    /* Td[j] : delay with respect to input     */

static lpfdata  DF0;            /* special decimation filter DF0           */


double h2_omef(double f)
{double rz,iz,rz2,iz2,y;

 rz =cos(2*pi*f/fssig); iz =sin(2*pi*f/fssig);
 rz2=cos(4*pi*f/fssig); iz2=sin(4*pi*f/fssig);
 y=(pow(rz-1,2.0)+pow(iz,2.0))/(pow(rz-zhp,2.0)+pow(iz,2.0));
 return y/(pow(rz2+b1*rz+b2,2.0)+pow(iz2+b1*iz,2.0));
}

void write_omef()
{int i;
 double f,y,ydb;

 if (open_writefile("omef.dat")) 
 {for (i=1;i<=100;i++)
  {f=i*fssig/200; y=gain*sqrt(h2_omef(f)+1.0E-06); ydb=8.68*log(y);
   fprintf(writefile,"%7.3f%8.4f%7.2f\n",f,y,ydb);
  }
  close_writefile();
 }
}

double h_decim(double f,double fs)
{long    m;
 double y;

 y=h[nh]; for (m=1;m<=nh;m++) y=y+2*h[nh-m]*cos(2*pi*m*f/fs);
 return y;
}

void write_decim()
{int i;
 double f,y,ydb;

 if (open_writefile("decim.dat"))
 {for (i=1;i<=100;i++)
  {f=i*fssig/200; y=h_decim(f,fssig); ydb=8.68*log(y);
   fprintf(writefile,"%7.3f%8.4f%7.2f\n",f,y,ydb);
  }
  close_writefile();
 }
}

void setup_omef()
/**********************************************************************
   H(z) = H1(z).H2(z) = (z-1)/(z-zhp) . gain/(z^2+b1.z+b2)
   with zhp   = 1-2.pi.fhp/fssig
        gain  = 1+b1+b2
        b1,b2 = determined iteratively as to obtain that
                |H2(fres)/H2(0)| becomes equal to Ares
 **********************************************************************/
{double alpha,theta,rx;

 rx=1-1/Ares; theta=2*pi*fres/fssig;
 b2=pow(rx,2.0); b1=-2*rx*cos(theta); zhp=1;
 do
 {alpha=sqrt(h2_omef(fres))*(1+b1+b2)/Ares;
  rx=1-sqrt(alpha)*(1-rx); b2=pow(rx,2.0); b1=-2*rx*cos(theta);
 }
 while (fabs(alpha-1.0)>=0.05);
 zhp=1-2*pi*fhp/fssig; gain=1+b1+b2;
 write_omef();
}

void init_omef()
{
 xhp=0; yhp=0; yn1=0; yn2=0;
}

double omef(double xn)
{double yn;

 yhp=zhp*yhp+xn-xhp; xhp=xn;
 yn=gain*yhp-b1*yn1-b2*yn2; yn2=yn1; yn1=yn;
 return yn;
}

void design_DF0()
/**********************************************************************
  The decimation filter to be introduced after doubling the signal
  sampling frequency is a IIR filter (phase distrortion is low for
  low frequencies, and not important at higher frequencies). It is
  designed using the IIRF program on /speech/prog/filterdesign and
  it has the following characteristics (fs = 1):
    design: f1 = 0.225, f2 = 0.275, ripple = 0.50 dB, att = 50 dB
            method: Cauer filter, order to be determined
    result: f1 = 0.225, f2 = 0.275, ripple = 0.77 dB, att = 50 dB
  Assumption: no important signal frequency components between 0.45
              and 0.5 times the signal sampling frequency (that is
              where the 0.225 and 0.275 come from)
 **********************************************************************/
{
 DF0.gain=0.04435;
 DF0.cell[1].a1=0.35876;  DF0.cell[1].a2=1; 
 DF0.cell[1].b1=-0.20127; DF0.cell[1].b2=0.86735;
 DF0.cell[2].a1=0.79104;  DF0.cell[2].a2=1; 
 DF0.cell[2].b1=-0.36732; DF0.cell[2].b2=0.54560;
 DF0.cell[3].a1=1.74419;  DF0.cell[3].a2=1; 
 DF0.cell[3].b1=-0.61855; DF0.cell[3].b2=0.18040;
}

void setup_decimation()
/**********************************************************************
  Setup the coefficients of a linear phase FIR filter to be used in 
  the branches of the decimation unit generating decimation products
  ats sampling frequencies smaller than fssig.
  Depending on fssig, 2 or 3 decimation filters will be required to
  perform the entire decimation.
  If fssmp<>ffssig it means that there is an up-sampling involved, and
  therefore also an IIRF-filtering of the upsampled signal as well as
  an extra delay-line (d0).

  Decimation filter: designed with /speech/prog/filterdesign/fir
  Filter 2
    settings: fs=1., fpb = 0.140, fsb = 0.270, dpb = 0.03, dsb = 0.003
    results : nh= 8, dpb = 0.028, dsb = 0.0028
  Filter 3
    settings: fs=1., fpb = 0.185, fsb = 0.270, dpb = 0.10, dsb = 0.003
    results : nh=10, dpb = 0.083, dsb = 0.0025
  Filter 4
    settings: fs=1., fpb = 0.200, fsb = 0.265, dpb = 0.08, dsb = 0.003
    results : nh=13, dpb = 0.083, dsb = 0.0031
(**********************************************************************/
{int m;

/* filter 1 
 h[7]=+0.3655; h[6]=+0.2833; h[5]=0.1078; h[4]=-0.0260;
 h[3]=-0.0558; h[2]=-0.0237; h[1]=0.0036; h[0]=+0.0064;
*/
/* filter 2 
 h[8]= 0.37413874; h[7]= 0.28733066; h[6]= 0.10383687;
 h[5]=-0.03176577; h[4]=-0.05527618; h[3]=-0.01559476;
 h[2]= 0.01410902; h[1]= 0.01402861; h[0]= 0.00366723;
*/
/* filter 2 */
 h[0]= 0.30106236E-02;
 h[1]= 0.16853167E-01;
 h[2]= 0.21166865E-01;
 h[3]=-0.95273824E-02;
 h[4]=-0.57905637E-01;
 h[5]=-0.42390779E-01;
 h[6]= 0.96695431E-01;
 h[7]= 0.29275990E+00;
 h[8]= 0.38665709E+00;
/* filter 3 
   h[ 0]= -.006105189;
   h[ 1]= -.024116686;
   h[ 2]= -.029925069;
   h[ 3]= -.000828495;
   h[ 4]=  .039323039;
   h[ 5]=  .023138845;
   h[ 6]= -.054238349;
   h[ 7]= -.077740349;
   h[ 8]=  .065788567;
   h[ 9]=  .308105767;
   h[10]=  .429930151;
*/
/* filter 4 
  h[ 0]= -.35221174E-02;
  h[ 1]=  .33571692E-02;
  h[ 2]=  .22004064E-01;
  h[ 3]=  .29918425E-01;
  h[ 4]=  .43065301E-02;
  h[ 5]= -.28338615E-01;
  h[ 6]= -.13832754E-01;
  h[ 7]=  .37666567E-01;
  h[ 8]=  .37750941E-01;
  h[ 9]= -.45584224E-01;
  h[10]= -.89071497E-01;
  h[11]=  .51024362E-01;
  h[12]=  .31236950E+00;
  h[13]=  .44703954E+00;
*/

 for (m=1;m<=nh;m++) h[nh+m]=h[nh-m];

/*********************************************************************
  The delay lines are used as ring buffers, and ptrin points at the
  place where one has to put the new input. The delayed input of the
  filter is found at a position which is Td samples away from ptrin.
  The delay of the IIRF-filter is estimated to be 8 samples at the
  sampling rate fsmp, and the delay of the decimation products with
  respect to the original input is given by Td[1]/fssig (even if only
  2 decimation filters are required, 
 *********************************************************************/

 if (ndecim<3) {Td[0]=6*nh-8;  Td[1]=3*nh; Td[2]=nh;   Td[3]=0;}
          else {Td[0]=14*nh-8; Td[1]=7*nh; Td[2]=3*nh; Td[3]=nh;}
       /* estimated delay of DF0 is 8 samples */
 Tdecim=Td[1]/fssig;
 write_decim();
 if (fsmp!=fssig) {design_DF0();}

}

void init_decimation()
/**********************************************************************
  Initialize the time index N, and the state variables of the 3
  decimation filters
 **********************************************************************/
{int m;

 for (m=1;m<=order;m++) {DF0.cell[m].w1=0; DF0.cell[m].w2=0;}
 ptrin[0]=0; for (m=0;m<=ndel-1;m++) d0[m]=0;

 ptrin[1]=0; for (m=0;m<=ndel-1;m++) d1[m]=0;
 ptrin[2]=0; for (m=0;m<=ndel-1;m++) d2[m]=0;
 ptrin[3]=0; for (m=0;m<=ndel-1;m++) d3[m]=0;
 n=0;
}

void decimation(long j,double *xn,state_array d)
{long nd,m; 

 nd=ptrin[j]-1; if (nd<0) nd=nd+ndel; ptrin[j]=nd;
 d[nd]=*xn;
 *xn=h[0]*(*xn);
 for (m=1;m<=nh2;m++) {nd++; if (nd==ndel) nd=0; *xn=*xn+h[m]*(d[nd]);}
}

void decimate(double xn)
/**********************************************************************
  Decimation processor:
    - product at fsmp=2fssig is obtained by doubling the samples, 
      inserting zeroes at the odd positions, applying an IIRF and 
      adding a delay Td[0]
    - products at fssig, fssig/2, fssig/4 [and fssig/8] are obtained
      by a cascade of 2 or 3 FIR decimation filters whose outputs are
      downsampled (factor 2) and fed to the next filter, and whose 
      delayed inputs represent the decimation products
  Alle the decimation products must correspond to a sampling frequency
  that is not smaller than 2 kHz.
  A group delay compensation is implemented to equalize the delays of
  the decimation products as much as possible.
 **********************************************************************/
{long t,m;
 double x,yn;

 if (fsmp==fssig) t=n+n; 
 else 
 {t=n; yn=DF0.gain*xn;
  for (m=1;m<=order;m++) 
  {x=yn-DF0.cell[m].b1*DF0.cell[m].w1-DF0.cell[m].b2*DF0.cell[m].w2; 
   yn=x+DF0.cell[m].a1*DF0.cell[m].w1+DF0.cell[m].a2*DF0.cell[m].w2; 
   DF0.cell[m].w2=DF0.cell[m].w1; DF0.cell[m].w1=x;
  }
  m=ptrin[0]-1; if (m<0) m=m+ndel; ptrin[0]=m; d0[m]=2*yn;
  m=m+Td[0]; if (m>=ndel) m=m-ndel; decim[1]=d0[m];
 }
 if (t % 2==0) 
 {decimation(1,&xn,d1);
  m=ptrin[1]+Td[1]; if (m>=ndel) m=m-ndel;
  decim[2]=d1[m];
  if (t % 4==0)
  {decimation(2,&xn,d2);
   m=ptrin[2]+Td[2]; if (m>=ndel) m=m-ndel;
   decim[3]=d2[m];
   if (t % 8==0)
     if (ndecim<3) decim[4]=xn;
     else
     {decimation(3,&xn,d3);
      m=ptrin[3]+Td[3]; if (m>=ndel) m=m-ndel;
      decim[4]=d3[m]; if (t % 16==0) decim[5]=xn;
     }
  }
 }
}


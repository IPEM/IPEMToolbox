/* sigio.c */

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

    READ AND WRITE SIGNAL FILES IN DSPS FORMAT

    format description
        char 1    : * number of  datawords (I2 format)
        char 2    : *
	char 2i+1 : lsp of (2 or 6 bit)
	char 2i+2 : msp of (6 bit)
    storage of samples
        either compressed (8 bit) or not (12 bit)

 ************** list of routines and their function ******************

    compression(x,xmax) : positive integer function
      if x >  0 : compression := 256-ctab[2047*x/xmax]
         x <= 0 : compression := ctab[-2047*x/xmax]
      with ctab[i] = 127*ln(1+mu*i/2047)/ln(1+mu)      (i=0,...,2047)
    expansion(indx) : real function
      if indx = 0..127   : expansion := -etab[indx]
               = 128..255 : expansion :=  etab[256-indx]
      with etab[i] = (exp(i*(1+mu)/127 -1) / mu      (i=0,..,128)
    new_sample(bytes,last) : real
      Read a sample sn (byte or 12-bit word) from readfile, and
      assume it is in the range (-1,+1). The boolean LAST is set as
      soon as the last sample of the file is read
    write_sample(bytes,last_sample,x)
      Write a sample x (in -1,+1) to writefile. Use the byte or 12-bit
      representation. The samples are accumulated until there are
      32 of them, before they are written. If last_sample is true, the
      routine will immediately write the samples accumulated so far.

 *********************************************************************/

#include <command.h>
#include <sigio.h>

#define  mu  100

#define  BYTE unsigned char
 
double etab[128+1]; 
int    ctab[2048+1];
BYTE   rbuf[66+1];
BYTE   tbuf[66+1];
BYTE   wbuf[66+1];
int    eo_rbuf=0; 
int    unsig;
int    size;
int    wavefiles=0;
int    binary;
int    msb_first;

void set_sigioread_format(int format)
/*********************************************************************
   Input file format: 0 = our sample format (.adc)
                      1 = our bytes  format (.sam)
                      2 = wave file  format
                      3 = plain 16 bit format (.b16) (MSB first)
                      4 = plain  8 bit format (.b08) (MSB first)
                      5 = plain 16 bit format (.pcm) (MSB last) (=le)
   Wave file format: (between brackets: number of bytes)
        (4) 1. Magic word: "RIFF"
        (4) 2. length of the file, after the magic word
        (4) 3. Magic word 2: "wave"
        (4) 4. Magic word 3: "fmt "  (=format)
        (4) 5. length of the subsequent format header
        (2) 6. filetype, 10 is PCM
        (2) 7. nr of channels, 10 is mono
        (4) 8. sampling rate in Hz, e.g. 0h 0h 56h 22h is 22050 Hz
                AV: c4[0]=34 c4[1]=86 c4[2]=0 c4[3]=0 (22.56kHz: 2*16+2=34
                en 5*16+6=86)
        (4) 9. average number of bytes per second
        (2) 10. block align (?)
        (2) 11. sample width: 8 = byte, unsigned, 16 = word, 2-complement,
                             32 = long, 2-complement
        (4) 12. Magic word: "data"
        (4) 13. length of the subsequent datablok
**********************************************************************/
{
 wavefiles=0;
 switch (format)
 {case 2: wavefiles=1; break;
  case 3: binary=1; unsig=0; size=2; msb_first=1; break;
  case 5: binary=1; unsig=0; size=2; msb_first=0; break;
  case 4: binary=1; unsig=0; size=1; break;
  default: binary=0;
 }
}

void startup_sigio()
{double rx;
 int     i;

 rx=127/log(1+mu);
 for (i=0;i<=127;i++) etab[i]=(exp(i/rx)-1)/mu;
 for (i=0;i<=2047;i++) ctab[i]=round_int(rx*log(1+mu*i/2047.0));
 etab[128]=etab[127]; ctab[2048]=ctab[2047];
}
 
double expansion(int indx)
{
 if (indx>127) {indx=256-indx; return etab[indx];} 
 else {return -etab[indx];}
} 

int compression(double x)
{int i;

 i=round_int(2047*x); 
 if (i>2047) i=2047; else if (i<-2047) i=-2047;
 if (i<=0) return ctab[-i];
 else
 {i=256-ctab[i];
  if (i==256) return 0; else return i;
 }
}
 
void read_header()
{BYTE c4[4];
 BYTE c2[2];

 fread(&c4,1,4,readfile); /* 1 */
 fread(&c4,1,4,readfile); /* 2 */
 fread(&c4,1,4,readfile); /* 3 */
 fread(&c4,1,4,readfile); /* 4 */
 fread(&c4,1,4,readfile); /* 5 */
 fread(&c2,1,2,readfile); /* 6 */
 fread(&c2,1,2,readfile); /* 7 */
 fread(&c4,1,4,readfile); /* 8 */

printf("sampling frequency (hexa): %d %d %d %d\n",c4[0],c4[1],c4[2],c4[3]);

 fread(&c4,1,4,readfile); /* 9 */
 fread(&c2,1,2,readfile); /* 10 */
 fread(&c2,1,2,readfile); /* 11 */

printf("sample width: %d\n",c2[0]);

 switch (c2[0])
 {case 8: unsig=1; size=1; break;
  case 16: unsig=0; size=2; break;
  case 32: unsig=0; size=4; break;
 }
 fread(&c4,1,4,readfile); /* 12 */
 fread(&c4,1,4,readfile); /* 13 */
/*
 eo_rbuf=c4[0]+256*(c4[1]+256*(c4[2]+256*(c4[3]))) / size;
*/
 eo_rbuf=c4[0]+256*(c4[1]+256*(c4[2]+256*(c4[3])));
}

void read_new_record()
{int nwrd;

 if (feof(readfile)) eo_rbuf=0;
 else
 {fscanf(readfile,"%s\n",rbuf);
  read_ptr=2;
  nwrd=10*(rbuf[0]-'0')+(rbuf[1]-'0');
  eo_rbuf=2*nwrd+2-1;
 }
}
 
double one_wave_sample(int *last)
/**************************************************
 De variabele unsig wordt blijkbaar niet gebruikt,
 in tegenstelling tot de Pascal-versie.
***************************************************/
{BYTE c2[2];
 BYTE c1;
 BYTE c4[4];
 short signed int i;
 signed int i2;
 double x;

 if (!read_ptr) read_header();
 if (read_ptr>=eo_rbuf) {*last=1; return 0;}
 switch (size)
 {case 1: fread(&c1,1,size,readfile); read_ptr++;
          i=c1; x=(double)i/256.00;
          *last=0; return x;
          break;
  case 2: fread(&c2,1,size,readfile); read_ptr+=2;
          i2=c2[1]*256+c2[0]; 
          if (i2>=32768) i2=i2-65536;
          x=(double)i2/32768.0;
          *last=0; return x;
          break;
  case 4: fread(&c4,1,size,readfile); read_ptr+=4;
          i2=c4[1]*256+c4[0]; x=(double)i2/65536.0;
          i2=c4[2]+256*c4[3]; x+=i2; x=x/32768.0; if (x>=1) x=x-2; 
          *last=0; return x;
          break;
 }
 printf("-- Error in SIGIO (one_wave_sample), please check\n"); return 0;
}

double one_binary_sample(int *last)
{static BYTE c2[2];
 static BYTE c1;
 BYTE c2vol[2];
 BYTE c1vol;
 short signed int i;
 double x;

 if (!read_ptr) {if (size==2) fread(&c2,1,size,readfile); 
                 else fread(&c1,1,size,readfile); /* size=1 */
                 read_ptr++;}
 if (feof(readfile)) {*last=1; return 0;}
 else
 {switch (size)
  {case 1: fread(&c1vol,1,size,readfile);
           i=c1; x=(double)i/128.0;
           if (feof(readfile)) {*last=1; eo_rbuf=read_ptr; return x;} 
           else {*last=0; c1=c1vol; return x;}
           break;
   case 2: fread(&c2vol,1,size,readfile);
           if (msb_first) i=c2[0]*256+c2[1]; else i=c2[1]*256+c2[0];
           x=(double)i/32768.0;
           if (feof(readfile)) {*last=1; eo_rbuf=read_ptr; return x;}
           else {*last=0; c2[0]=c2vol[0]; c2[1]=c2vol[1]; return x;}
           break;
  }
 }
 printf("-- Error in SIGIO (one_binary_sample), please check\n"); return 0;
}

double new_sample(int bytes,int *last)
{int ixn;

 if (binary) return one_binary_sample(last);
 if (wavefiles) return one_wave_sample(last);

 if (read_ptr==0) read_new_record(); 
 *last=0;
 if (read_ptr>=eo_rbuf) {*last=1; return 0;}
 else
 {ixn=rbuf[read_ptr]-'0'+64*(rbuf[read_ptr+1]-'0');
  read_ptr=read_ptr+2; 
  if (read_ptr>eo_rbuf) read_ptr=0;
  if (bytes) {return expansion(ixn / 16);}
  else {if (ixn>=2048) ixn=ixn-4096; return (double)ixn/2048.0;} 
 }
}

void BYTE_substr(BYTE *resstring,const BYTE *origstring,int start,int length)
/****************************************************************************
  This function is the same as the function substr specified in command.c, 
  with the expection that we are dealing  here with strings of BYTEs.
****************************************************************************/
{int n;

 for (n=start;n<(start+length);n++) resstring[n-start]=origstring[n];
 resstring[length]='\0';
}
 
void write_new_record()
{int nbyt,nwrd;
 BYTE dum[66+1];

 nbyt=write_ptr; nwrd=(nbyt / 2)-1;
 tbuf[1]=(nwrd / 10)+'0'; tbuf[2]=(nwrd % 10)+'0';
 BYTE_substr(dum,tbuf,1,nbyt);
 fprintf(writefile,"%s\n",dum); write_ptr=0;
}

void write_sample(int bytes,int last,double x)
{int ixn;

 if (bytes) ixn=16*compression(x);
 else 
 {ixn=round_int(2047*x);
  if (ixn>2047) ixn=2047; else if (ixn<-2048) ixn=-2048;
  if (ixn<0) ixn+=4096;
 }
 if (write_ptr==0) write_ptr=2;
 tbuf[write_ptr+1]=(ixn % 64)+'0';
 tbuf[write_ptr+2]=(ixn / 64)+'0'; write_ptr+=2;
 if ((last) || (write_ptr>=66)) write_new_record();
}


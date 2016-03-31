/* command.c */

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

#include <command.h>

cmnd_modes cmnd_mode=normal;
int        submit_mode=0;
srcds      cmnd_src=inpt;
int        nr_of_seq;
int        seq_cntr;
int        read_ptr;
int        write_ptr;
text_line  answer;
text_line  item;
FILE       *seq_buffer;
FILE       *ascii_file;
FILE       *out_file;
FILE       *readfile;
FILE       *writefile;
text_line  tmp_filename;

/***************************************************************************

Export to the outside world:
types
  cmnd_modes  : normal,read_seq or exec_seq
  srcds       : none, usual, inpt, ascii, buffer, outpt
  text_line   : character array
variables
  answer,item : text_line
  seq_buffer  : internal text file to receive command file data
  ascii-file  : external text file for read or write operations of the
                form : open, read/write the entire file, close.
  readfile    : external text file for reading of data piece by piece
                (frames of a signal for instance)
  writefile   : external text file for writing of data piece by piece
  out_file    : external text file (to receive all output data that
                are normally listed on the OUTPUT device. OUTPUT itself
                is only used as ERROR and COMMAND device)
  read_ptr    : pointer to be used in connection with readfile
  write_ptr   : pointer to be used in connection with writefile
  cmnd_mode   : one of modes
  cmnd_src    : one of none, usual, inpt, ascii, buffer or outpt
  nr_of_seq   : number of sequences to be executed in succession
  seq_cntr    : number of already executed sequences (since request)
  submit_mode : if true, the prompt of a question (get_string) will
                be suppressed (must be set when the program is started
                by a submit order)

***************************************************************************/

#if !defined(_WIN32)
int remove_uncompressed_file=0;
#endif /* !defined(_WIN32) */

int round_int(double a)
{int i;

 if (a<0) a=a-0.5;
 else a=a+0.5;
 i=(int) a;
 return i;
}

int strindex(const char *s,const char *t)
/******************************************************************************
  The strindex function returns the starting index of the first instance 
  of the second parameter within the first parameter. If the second parameter
  does not exist in the first parameter, strindex returns a -1. This function 
  is more or less the same as the Pascal function INDEX, with that difference 
  that INDEX returns a zero if the second parameter does not exist in the
  first one, whereas strindex returns a -1.
******************************************************************************/
{int i,j,k;

 for (i=0;s[i]!='\0';i++)
 {for (j=i,k=0;((t[k]!='\0') && (s[j]==t[k]));j++,k++) ;
  if ((k>0) && (t[k]=='\0')) return i;
 }
 return -1;
}

void substr(char *resstring,const char *origstring,int start,int length)
/************************************************************************
  More or less the same as the Pascal function SUBSTR. Keep in mind 
  that the first character of the source string is at position 0. Thus, 
  the Pascal statement string:=SUBSTR(string,1,2) is translated as
  substr(string,string,0,2).
************************************************************************/
{int n;

 for (n=start;n<(start+length);n++) resstring[n-start]=origstring[n];
 resstring[length]='\0';
}

/**************************************************************************

     PART 1 : routines, intended to allow the user to construct
              a command handler, capable of handling command
              sequences

get_cmnd(question)
  Get a string from the cmnd source of the moment, and put it in answer.
  The cmnd source can either be INPUT, a command file, or seq_buffer.
  If it is INPUT then the routine first issues a question to OUTPUT.
first_item
  If there exists a nonempty first item in answer, it is stripped off
  from answer and stored in item, and first_item is made true. In the
  other case, item is cleared and first_item is made false. If the first
  nonblanc or nontab character of answer is a comma, it is assumed that
  the first item of answer is empty.
get_sequence(fname)
  Prepare for the input of a sequence of commands and other data from
  a source the name of which is to be found in FNAME. If FNAME is empty,
  it is assumed that the source will be INPUT. The command source will
  be set for the next get_command.
put_sequence(fname)
  Output of the contents of seq_buffer to a destination the name of
  which is to be found in FNAME. If FNAME is empty, it is assumed that
  this destination is OUTPUT.
execute_sequence(nseq)
  Prepare for the execution of a command sequence stored in seq_buffer.
  The number of sequences to be executed in succession is nseq.
item_ok(size,keywords)
  Limit item to size characters, convert it to upper case, insert
  a leading blanc, and check if the resulting item is a substring of
  keywords. If it does, replace item by that substring and make
  item_ok true, if it doesn't, make item_ok false. Keywords is a string.

***********************************************************************

   PART 2 : routines intended to read data (strings, integers, reals)
            from an io-source which is either the command source, the
            terminal, or an ascii_file. The string representation of
            the data is read in ANSWER. If the io-source is NONE, it
            is assumed that this representation is already in ANSWER.

get_string(io-source,question)
  Read a string from the io-source in answer. The 'none' value for
  the io-source has little significance here.
  If the source is ascii or buffer, an EOF detection results in an
  empty answer.
get_one_name(io-source,question,name)
  Read a string from the io-source in answer. If answer is empty,
  the original value of name is left unaltered and the function
  result is made false. If answer is not empty, name is replaced
  by the first item of answer (which is " " if the first character
  of answer is a comma).
get_integers(io-source,question,i1,i2,i3,i4)
  Read the string representation of the data (if <>'none') an put it
  in answer. (If answer is empty, the function result is false else it
  is true). Then, convert the first four items of answer to integers.
  If an item is empty (see first_item) or not starting with '-', '+'
  or '0'..'9', the corresponding integer is left unaltered.
get_reals(io-source,question,r1,r2,r3,r4)
  Same as get_integers, except that the data are reals now. A real
  number can also start with '.'.
get_one_integer(io-source,question,int)
  Same as get_integer, except that only one integer is read, and that
  its original value is prompted with the question
get_one_real(io_source,question,r)
  Same as get_one_integer, except that the variable is a real
uppercase(string)
  Convert a string to upper case
lowercase(string)
  Convert a string to lower case

***********************************************************************

    PART 3 : routines intended to open and to prepare READFILE and
             WRITEFILE to be used for reading and writing data.

open_readfile(filename)
  If readfile is open it is closed. It is then opened with the
  provided name. If the name exists on disc, open_readfile is made
  true, in the other case it is made false.
  A variable read_ptr is set to 0.
open_writefile(filename)
  If writefile is open, it is closed. It is then opened with the
  provided name (rewrite included). If there is an error in the
  filename, the function result is made false else it is true.
  A variable write_ptr is set to 0.
close_readfile
  Close readfile and set read_ptr to 0
close_writefile
  Close writefile and set write_ptr to 0

***************************************************************************/

void get_string(srcds source,const char *question)
{
 if (source!=none) 
 {if (source==usual) source=cmnd_src;
  switch (source) 
  {case inpt:   if (!submit_mode) printf("%s",question); 
                gets(answer); break;
   case ascii:  fgets(answer,maxstrlen,ascii_file); 
                if (feof(ascii_file)) strcpy(answer,""); break;
   case buffer: fgets(answer,maxstrlen,seq_buffer); 
                if (feof(seq_buffer)) {strcpy(answer,""); fclose(seq_buffer);}
                break;
   default:     strcpy(answer,""); break;
  }   
  if (cmnd_mode==read_seq) fprintf(seq_buffer,"%s\n",answer);
 }
}
 
void get_cmnd(const char *question)
{
 if (cmnd_mode==read_seq) /* sequence definition */
 {if (!((cmnd_src==ascii) && feof(ascii_file))) 
  {strcpy(answer,"seq : "); strcat(answer,question);
   get_string(usual,answer);
  } 
  if (cmnd_src!=ascii) {if (strlen(answer)==0) cmnd_mode=normal;} 
  else if (feof(ascii_file)) {fclose(ascii_file); cmnd_mode=normal;}
 }
 if (cmnd_mode==exec_seq) /* sequence execution */
 {if (!feof(seq_buffer)) get_string(usual," ");
  else if (seq_cntr==nr_of_seq) cmnd_mode=normal;
       else 
       {seq_cntr++; 
        fclose(seq_buffer); seq_buffer=fopen("seq_buffer","rb"); 
        get_string(usual," ");
       }
 }
 if (cmnd_mode==normal) /* interactive mode */
 {cmnd_src=inpt; get_string(usual,question);} 
}
 
int first_item()
{int  nchar,ptr,ptr2;
 char htab='\t';
 char nlin='\n';
 char carr='\r'; /* added by HV, Nov 4 1997 */
 int  comma,blanc;

 nchar=strlen(answer); strcpy(item,""); 
 if (nchar!=0)  
 {ptr= -1; 
  do
  {ptr++;
   comma=(answer[ptr]==',');
   blanc=((answer[ptr]==' ') || (answer[ptr]==htab) || (answer[ptr]==nlin) 
          || (answer[ptr]==carr));
  }
  while ((ptr!=nchar) && blanc);

  if (comma || blanc) ptr2=ptr;
  else
  {ptr2=ptr-1;
   do
   {ptr2++;
    comma=(answer[ptr2]==',');
    blanc=((answer[ptr2]==' ') || (answer[ptr2]==htab) || (answer[ptr2]==nlin) 
           || (answer[ptr2]==carr));
   }
   while ((ptr2!=nchar) && !comma && !blanc);
   if (comma || blanc) substr(item,answer,ptr,ptr2-ptr);
   else substr(item,answer,ptr,ptr2-ptr+1);
  }

  if (ptr2==nchar) strcpy(answer,""); 
  substr(answer,answer,ptr2+1,nchar-ptr2);
 }
 if (strlen(item)!=0) return 1; else return 0;
}
 
void uppercase(char *string)
{int n;

 n=0;
 while ((string[n]=toupper(string[n]))!='\0') ++n;
}

void lowercase(char *string)
{int n;

 n=0;
 while ((string[n]=tolower(string[n]))!='\0') ++n;
}

int item_ok(int size,const char *keywords)
{char *ptri;
 int srange,pos;
 text_line dummy;

 srange=strlen(keywords);
 if (strlen(item)>(size_t)size) substr(item,item,0,size);
 uppercase(item); strcpy(dummy," "); strcat(dummy,item); strcpy(item,dummy);
 ptri=strstr(keywords,item);
 if (ptri==NULL) return 0;
 else
 {pos=ptri-keywords; if ((pos+size)>srange) size=srange-pos;
  substr(item,keywords,pos,size); return 1;
 }
}
 
void get_sequence(char *fname)
{
 if (cmnd_mode!=normal)
 {printf("Invalid sequence definition request\n");
  cmnd_mode=normal;
  if (cmnd_src==ascii) fclose(ascii_file); cmnd_src=inpt;
 }
 else 
 {cmnd_mode=read_seq; fclose(seq_buffer); 
  seq_buffer=fopen("seq_buffer","wb"); 
  if (strlen(fname)==0) cmnd_src=inpt;
  else {cmnd_src=ascii; ascii_file=fopen(fname,"rb");} 
 }   
}
 
void put_sequence(char *fname)
{
 if (cmnd_mode!=normal)
 {printf("Invalid sequence output request\n"); cmnd_mode=normal;}
 else 
 {fclose(seq_buffer); seq_buffer=fopen("seq_buffer","rb"); 
  strcpy(answer,fname);
  if (feof(seq_buffer)) printf("No sequence defined\n"); 
  else if (first_item()) ascii_file=fopen(item,"wb"); 
  fgets(answer,maxstrlen,seq_buffer);
  while (!feof(seq_buffer))
  {if (strlen(item)!=0) fprintf(ascii_file,"%s\n",answer);
   else fprintf(out_file,"%s\n",answer);
   fgets(answer,maxstrlen,seq_buffer);
  }
 } 
 if (strlen(item)!=0) fclose(ascii_file); else fprintf(out_file,"\n"); 
}
 
void execute_sequence(int nseq)
{
 if (cmnd_mode!=normal)
 {printf("Invalid sequence execution request\n"); 
  cmnd_mode=normal;
 } 
 else 
 {nr_of_seq=nseq; seq_cntr=1; fclose(seq_buffer);
  seq_buffer=fopen("seq_buffer","rb");
  if (feof(seq_buffer)) printf("No sequence defined\n");
  else {cmnd_mode=exec_seq; cmnd_src=buffer;}
 }
}
 
int get_integers(srcds io,const char *question,
                    int *i1,int *i2,int *i3,int *i4)
{text_line question1;

 strcpy(question1,question);
 sprintf(item,"%6d%6d%6d%6d",*i1,*i2,*i3,*i4);
 strcat(question1," ("); strcat(question1,item); strcat(question1," ) = ");
 get_string(io,question1); 
 if (cmnd_mode!=read_seq) 
 {if (strlen(answer)==0) return 0;
  else 
  {if (first_item()) 
    if ((item[0]=='-') || (item[0]=='+') || (item[0]>='0' && item[0]<='9'))
     *i1=atoi(item);
   if (first_item()) 
    if ((item[0]=='-') || (item[0]=='+') || (item[0]>='0' && item[0]<='9'))
     *i2=atoi(item);
   if (first_item()) 
    if ((item[0]=='-') || (item[0]=='+') || (item[0]>='0' && item[0]<='9'))
     *i3=atoi(item);
   if (first_item()) 
    if ((item[0]=='-') || (item[0]=='+') || (item[0]>='0' && item[0]<='9'))
     *i4=atoi(item);
   return 1;
  }
 }
 return 1;
}
 
int get_reals(srcds io,const char *question,
                 double *r1,double *r2,double *r3,double *r4)
{text_line question1;

 strcpy(question1,question);
 sprintf(item,"%6.3g%6.3g%6.3g%6.3g",*r1,*r2,*r3,*r4);
 strcat(question1," ("); strcat(question1,item); strcat(question1," ) = ");
 get_string(io,question1);
 if (cmnd_mode!=read_seq) 
 {if (strlen(answer)==0) return 0;
  else
  {if (first_item()) 
    if ((item[0]=='-') || (item[0]=='+') || (item[0]=='.') ||
     (item[0]>='0' && item[0]<='9')) *r1=atof(item);
   if (first_item())
    if ((item[0]=='-') || (item[0]=='+') || (item[0]=='.') ||
     (item[0]>='0' && item[0]<='9')) *r2=atof(item);
   if (first_item())
    if ((item[0]=='-') || (item[0]=='+') || (item[0]=='.') ||
     (item[0]>='0' && item[0]<='9')) *r3=atof(item);
   if (first_item())
    if ((item[0]=='-') || (item[0]=='+') || (item[0]=='.') ||
     (item[0]>='0' && item[0]<='9')) *r4=atof(item);
   return 1;
  }
 }
 return 1;
}
 
int get_one_name(srcds io,const char *question, char *fname)
{text_line tmp,question1;

 strcpy(question1,question); strcpy(tmp,"");
 if (strlen(fname)>=0) if (strlen(fname)<=maxstrlen) strcpy(tmp,fname);
 strcat(question1," ("); strcat(question1,tmp); strcat(question1,") = ");
 get_string(io,question1);
 if (cmnd_mode!=read_seq)
 {if (strlen(answer)==0) {strcpy(fname,tmp); return 0;}
  else if (first_item()) strcpy(fname,item);
  return 1;
 }
 return 1;
}

int get_one_integer(srcds io,const char *question,int *i)
{text_line question1;

 strcpy(question1,question);
 if (io!=none)
 {sprintf(item,"%d",*i);
  strcat(question1," ("); strcat(question1,item); strcat(question1," ) = ");
  get_string(io,question1);
 }
 if (cmnd_mode!=read_seq)
 {if (strlen(answer)==0) return 0;
  else if (first_item())
   if ((item[0]=='-') || (item[0]=='+') || (item[0]>='0' && item[0]<='9'))
    *i=atoi(item);
 }
 return 1;
}

int get_one_real(srcds io,const char *question,double *r)
{text_line question1;

 strcpy(question1,question);
 if (io!=none)
 {sprintf(item,"%g",*r);
  strcat(question1," ("); strcat(question1,item); strcat(question1," ) = ");
  get_string(io,question1);
 }
 if (cmnd_mode!=read_seq)
 {if (strlen(answer)==0) return 0;
  else if (first_item())
   if ((item[0]=='-') || (item[0]=='+') || (item[0]=='.') ||
    (item[0]>='0' && item[0]<='9')) *r=atof(item); 
 }
 return 1;
}

int open_readfile(const char *filename)
{
#if !defined(_WIN32)
 text_line tmp;
#endif /* !defined(_WIN32) */

 readfile=fopen(filename,"rb");
#if defined(_WIN32)
 if (readfile==NULL)
 {printf("error opening %s\n",filename); return 0;}
#else
 remove_uncompressed_file=0;
 if (readfile==NULL)
 {strcpy(tmp,filename); strcat(tmp,".Z");
  if (readfile=fopen(tmp,"rb")) 
  {fclose(readfile); 
   strcpy(tmp,"cp "); strcat(tmp,filename); strcat(tmp,".Z rfxxx.xxx.Z");
   system(tmp);
   strcpy(tmp,"uncompress rfxxx.xxx.Z");
   system(tmp);
   strcpy(tmp,"rfxxx.xxx");
   readfile=fopen(tmp,"rb");
   remove_uncompressed_file=1;
  }
  else {printf("error opening %s\n",filename); return 0;}
 }
#endif /* defined(_WIN32) */
 read_ptr=0; return (!feof(readfile));
}

int open_writefile(const char *filename)
{
 writefile=fopen(filename,"wb");
 write_ptr=0; 
 if (writefile!=NULL) return 1; else return 0;
}

void close_readfile()
{
#if !defined(_WIN32)
 text_line tmp;
#endif /* !defined(_WIN32) */

 fclose(readfile);
 read_ptr=0;
#if !defined(_WIN32)
 if (remove_uncompressed_file) {strcpy(tmp,"rm rfxxx.xxx"); system(tmp);}
#endif /* !defined(_WIN32) */
}

void close_writefile()
{
 fclose(writefile);
 write_ptr=0;
}


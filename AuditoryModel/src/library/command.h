/* command.h */

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

#if !defined( COMMAND_H )
#define COMMAND_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

#define maxstrlen 1024

#if !defined (_WIN32)
#define max(a,b)    (((a) > (b)) ? (a) : (b))
#define min(a,b)    (((a) < (b)) ? (a) : (b))
#endif

enum cmnd_modes_t {normal,read_seq,exec_seq};
enum srcds_t {none,usual,inpt,ascii,buffer,outpt};
typedef enum cmnd_modes_t cmnd_modes; 
typedef enum srcds_t srcds;
typedef char text_line[maxstrlen+1];

extern cmnd_modes cmnd_mode;
extern int        submit_mode;
extern srcds      cmnd_src;
extern int        nr_of_seq;
extern int        seq_cntr;
extern int        read_ptr;
extern int        write_ptr;
extern text_line  answer;
extern text_line  item;
extern FILE       *seq_buffer;
extern FILE       *ascii_file;
extern FILE       *out_file;
extern FILE       *readfile;
extern FILE       *writefile;
extern text_line  tmp_filename;

extern int round_int(double a);
extern int strindex(const char *s,const char *t);
extern void substr(char *resstring,const char *origstring,int start,int length);

extern void get_string(srcds source,const char *question); 
extern void get_cmnd(const char *question); 
extern int first_item(); 
extern void uppercase(char *string); 
extern void lowercase(char *string); 
extern int item_ok(int size,const char *keywords); 
extern void get_sequence(char *fname);
extern void put_sequence(char *fname);
extern void execute_sequence(int nseq);
extern int get_integers(srcds io,const char *question,
                    int *i1,int *i2,int *i3,int *i4); 
extern int get_reals(srcds io,const char *question,
                    double *r1,double *r2,double *r3,double *r4);
extern int get_one_name(srcds io,const char *question,char *fname);
extern int get_one_integer(srcds io,const char *question,int *i);
extern int get_one_real(srcds io,const char *question,double *r);

extern int open_readfile(const char *filename); 
extern int open_writefile(const char *filename); 
extern void close_readfile(); 
extern void close_writefile(); 

#endif /* !defined( COMMAND_H ) */


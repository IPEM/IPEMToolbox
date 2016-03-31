/* filenames.c */

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
 
	Filename treatment procedures
 	-----------------------------
        - define_filenameformat
	    type 0 : directory + anything + extension
            type 1 : directory + prefix + 4 digit number + extension
            type 2 : directory + w%%s%%v%% + extension
            type 3 : directory + subdir_prefix + 4 digits + '/'
                               + filename_prefix + 4 digits + extension
	    remark : the '.' belongs to the extension
        - type1_name, type2_name, type3_name
            construct the variable part of type 1 to type 3 names
 	- get_filename
	    read the variable part of a filename from an io-source
	    return FALSE if io-source is empty
	- extension
	    get extension from a filename
	- change_extension
	    replace extension by another one
        - inputfilename
            add input directory and extension to a name
        - outputfilename
            add output directory and extension to a name
 
 ********************************************************************/

#include <command.h>
#include <filenames.h>


int        filename_type=1;
text_line  subdir_prefix="s";  
text_line  filename_prefix="z";
text_line  input_extension="";
text_line  output_extension="";
text_line  input_directory="";
text_line  output_directory=""; 


void define_filenameformat(srcds io)
{
 get_one_integer(io,"filename type (0..3)",&filename_type);
 if (filename_type==3)
 {
   get_one_name(io,"filename prefix",filename_prefix);
   get_one_name(io,"subdir prefix",subdir_prefix);
   get_one_name(io,"directory name",input_directory);
   strcpy(output_directory,input_directory);
 }
 else
 {
   if (filename_type==1) get_one_name(io,"prefix",filename_prefix);
   get_one_name(io,"directory of inputfiles",input_directory);
   get_one_name(io,"extension of inputfiles",input_extension);
   get_one_name(io,"directory of outputfiles",output_directory);
   get_one_name(io,"extension of outputfiles",output_extension);
 }
}
 
void type1_name(char *res,int nr)
{
 sprintf(res,"%s%4.4ld",filename_prefix,nr);
}
 
void type2_name(char *res,int w,int s,int v)
{
 sprintf(res,"w%2.2lds%2.2ldv%2.2ld",w,s,v);
}

void type3_name(char *res,int nr1,int nr2)
{text_line name;

 type1_name(name,nr2);
#if defined(_WIN32)
 sprintf(res,"%s%4.4ld%s%s",subdir_prefix,nr1,"\\",name);
#else
 sprintf(res,"%s%4.4ld%s%s",subdir_prefix,nr1,"/",name);
#endif /* defined(_WIN32) */
}
 
void extension(char *res,char *name)
{int n,m;

 m=strlen(name); n=m; do n--; while (name[n]!='.');
 substr(res,name,n,m-n);
}
 
void change_extension(char *name,const char *ext)
{int n,m;

 m=strlen(name); n=m; do n--; while (name[n]!='.');
 substr(name,name,0,n);
 strcat(name,ext);
}
 
int get_filename(srcds io,char *name)
{int nr,w,v,s;
 int res=0;
 text_line t;

 switch (filename_type)
 {case 0: strcpy(t,"nonfixed part of filename");
          res=get_one_name(io,t,name);
          break;
  case 1: nr=1; strcpy(t,"number"); res=get_one_integer(io,t,&nr);
          type1_name(name,nr);
          break;
  case 2: w=1; s=1; v=1; nr=0; strcpy(t,"word,speaker,version (1,1,1) = ");
          res=get_integers(io,t,&w,&s,&v,&nr);
          type2_name(name,w,s,v);
          break;
  case 3: w=1; s=1; v=0; strcpy(t,"nr1,nr2 (1,1) = ");
          res=get_integers(io,t,&s,&w,&v,&v);
          type3_name(name,s,w);
          break;
  default: break;
 }
 return res;
}

void inputfilename(char *res,char *name)
{
 strcpy(res,input_directory);
 strcat(res,name);
 strcat(res,input_extension);
}

void outputfilename(char *res,char *name)
{
 strcpy(res,output_directory);
 strcat(res,name);
 strcat(res,output_extension);
}


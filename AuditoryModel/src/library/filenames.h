/* filenames.h */

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

#if !defined( FILENAMES_H )
#define FILENAMES_H

#include "command.h"

extern int        filename_type;  
extern text_line  subdir_prefix;
extern text_line  filename_prefix;
extern text_line  input_extension;
extern text_line  output_extension;
extern text_line  input_directory;
extern text_line  output_directory; 

extern void define_filenameformat(srcds io);
extern void type1_name(char *res,int nr);
extern void type2_name(char *res,int w,int s,int v);
extern void type3_name(char *res,int nr1,int nr2);
extern void extension(char *res,char *name);
extern void change_extension(char *name,const char *ext);
extern int get_filename(srcds io,char *name);
extern void inputfilename(char *res,char *name);
extern void outputfilename(char *res,char *name);

#endif /* !defined( FILENAMES_H ) */


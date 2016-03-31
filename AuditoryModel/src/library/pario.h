/* pario.h */

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

#if !defined( PARIO_H )
#define PARIO_H

#define  npar_max   80	/* maximum number of parameters/frame */
 
typedef double parameters[npar_max+1];
 
extern int  nr_of_par;      /* nr of parameters/frame	 */
extern int  nspect;         /* nr of spectral parameters */
extern int  parformat;      /* inputfile format (0=DSPS) */
extern int  partype;        /* parameter type		 */
 
extern int read_frame(parameters par);
extern void write_frame(int code,int n_per_line,parameters par); 
extern void init_pario(); 

#endif /* !defined( PARIO_H ) */


#!/bin/bash


#Compile the IPEMToolboxManual tex files and create a PDF. 

pdflatex -shell-escape -interaction=nonstopmode --src-specials IPEMToolboxManual.tex --enable-write18
#run bibtex on the aux file
bibtex IPEMToolboxManual.aux
#second iteration: include bibliography
pdflatex -shell-escape -interaction=nonstopmode --src-specials IPEMToolboxManual.tex --enable-write18
#third iteration: fix references
pdflatex -shell-escape -interaction=nonstopmode --src-specials IPEMToolboxManual.tex --enable-write18 

#remove generated files
rm *.aux
rm *.log
rm *.toc
rm *.out
rm *.blg
rm *.bbl

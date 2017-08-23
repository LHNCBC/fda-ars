#!/bin/sh

PATH=$PATH:./bin
WORKAREA=.
SAXON_JAR=lib/saxon9he.jar
REPLACE_UTF8=lib/replace_utf8.jar
JYTHONJAR=lib/jython-standalone-2.7.0.jar
PYTHONSCRIPTS=scripts
XSLSCRIPTS=scripts
# PYTHON=python
PYTHON="java -jar $JYTHONJAR"
PYTHONPATH=scripts
export PYTHONPATH
ext=xml
if [ $# -gt 0 ]; then
    fnlist=$*
else
    fnlist=input/*.$ext
fi
for fn in $fnlist; do
    fnbase=`basename $fn .$ext`
#    for section in adverse_reactions boxed_warnings precautions use_in_specific_populations warnings_and_precautions warnings
    for section in adverse_reactions boxed_warnings precautions warnings_and_precautions warnings; do
	echo "Processing $fn --> ${fnbase}_${section}.txt.utf8"
	java -Xmx2g -jar $SAXON_JAR -xsl:${XSLSCRIPTS}/fda2brattext_${section}.xsl -s:$fn  > temp/${fnbase}_${section}.txt.utf8
	# if file is greater than zero continue processing
	if [ -s temp/${fnbase}_${section}.txt.utf8 ]; then
	    echo "Processing ${fnbase}_${section}.txt.utf8 --> ${fnbase}_${section}.txt.ascii"
	    java -cp $REPLACE_UTF8 replace_UTF8 temp/${fnbase}_${section}.txt.utf8 > temp/${fnbase}_${section}.txt.ascii
	    # convert tabs to spaces
	    echo "Processing ${fnbase}_${section}.txt.ascii --> ${fnbase}_${section}.unprocessed"
	    sed 's/\t/ /g' temp/${fnbase}_${section}.txt.ascii > temp/${fnbase}_${section}.txt.unprocessed
	    echo "Processing ${fnbase}_${section}.txt.unprocessed --> ${fnbase}_${section}.txt0"
	    $PYTHON ${PYTHONSCRIPTS}/table_formatter.py temp/${fnbase}_${section}.txt.unprocessed > temp/${fnbase}_${section}.txt0
	    
	    echo "Processing ${fnbase}_${section}.txt0 --> ${fnbase}_${section}.txt"
	    # delete all trailing blank lines at end of file
	    sed ':a;/^[ \n]*$/{$d;N;ba}' temp/${fnbase}_${section}.txt0 > output/${fnbase}_${section}.txt

	    if [ ! -s output/${fnbase}_${section}.ann ]; then
		touch output/${fnbase}_${section}.ann
	    fi
	fi
    done
done

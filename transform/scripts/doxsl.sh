#!/bin/sh

PATH=$PATH:./bin
SAXON_JAR=./lib/saxon9he.jar
REPLACE_UTF8=./lib/replace_utf8.jar
ext=xml
fnlist=*.$ext
for fn in $fnlist; do
    fnbase=`basename $fn .$ext`
    # Note: Translations of periods and tabs are now done in XSL.
    echo "Processing $fn -> $fnbase.sldi.utf8"
    java -Xmx2g -jar $SAXON_JAR -xsl:../fda2sldi.xsl -s:$fn  > $fnbase.sldi.utf8

    echo "Processing $fnbase.sldi.utf8 --> $fnbase.sldi.0"
    java -jar $REPLACE_UTF8 $fnbase.sldi.utf8 > $fnbase.sldi.0

    echo "Removing trailing spaces. $fnbase.sldi.0 --> $fnbase.sldi.1"
    sed 's/ *$//' $fnbase.sldi.0 > $fnbase.sldi.1

    echo "Removing lines with empty text fields. $fnbase.sldi.1 --> $fnbase.sldi"
    gawk -f ../massage.awk $fnbase.sldi.1 > $fnbase.sldi

    echo "diffing $fnbase.sldi.0 $fnbase.sldi --> $fnbase.diff"
    diff $fnbase.sldi.0 $fnbase.sldi > $fnbase.diff
    grep "<title" $fn > $fnbase.titles
    grep "<tables" $fn > $fnbase.tables

    echo "Processing $fn -> $fnbase.html"
    java -Xmx4G -jar $SAXON_JAR -xsl:../fda2html.xsl -s:$fn  > $fnbase.html

    # echo "Processing $fn -> $fnbase.txt.utf8"
    # java -Xmx4G -jar $SAXON_JAR -xsl:../fda2brattext.xsl -s:$fn  > $fnbase.txt.utf8
    # echo "Processing $fnbase.txt.utf8 --> $fnbase.txt"
    # java -cp $REPLACE_UTF8 replace_UTF8 $fnbase.txt.utf8 > $fnbase.txt
done

echo "Looking for empty text fields, should return nothing..."
grep -Hi -e "\\\\|$" *.sldi
grep -Hi -e "\\\\|$" *.sldi > empty.textfields

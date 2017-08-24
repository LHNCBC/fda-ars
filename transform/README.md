# README

## Overview

Code for converting FDA Structured Product Labels (SPL) into formats
suitable for use by the BRAT Annotation Tool and the MetaMap
named-entity recognition tool.

## Pre-Requisites for all platforms

+ Java JRE 1.6 or later (www.java.org)
* Python 2.6 or later or Jython 2.7 or later (www.python.org) [Jython requires Java]
* Saxon 9 XSLT Processor - Home Edition (saxon9he.jar) (http://saxon.sourceforge.net/) [requires Java]

The Java 1.6 Runtime Environment (JRE) is required to run the Saxon
XSLT program which is used to transform the SPL  XML to the various formats
described by the XSL stylesheets.

## Linux/Macos/BSD Pre-Requisites

The scripts require the following programs to be present on Linux
systems (or BSD or MacOS)

+ GNU Bash
+ GNU Sed (BSD Sed may work)

## Windows Pre-Requisites

+ GNU Bash
+ GNU Sed
* GNU coreutils (basename, touch)
* GNU diffutils (diff)
* GNU AWK (gawk)
* GNU grep

All of the above can be obtained for Windows by installing the Minimalist GNU for
Windows (www.mingw.org) or Cygwin (www.cygwin.com).

The Windows 10 Subsystem for Linux may also provide the necessary programs.

## First steps

Using a command prompt window (windows) or a terminal window (Linux),
migrate to the directory created when you extracted the archive
containing the software distribution ( _fda\_ar\_sw_ ).

## Installing third-party libraries

Copy the saxon9he.jar from Saxon 9 website (and the
jython-standalone-2.7.0.jar from the Jython website if you're using
Jython) to the _lib_ directory.

If you're using Python then edit the file _scripts/doxsltext.sh_ and
replace "java -jar $JYTHONJAR" in the line:

    PYTHON="java -jar $JYTHONJAR"

with the path to your Python interpreter.

If you are using a version of Jython other than 2.7.0 then modify the line:

    JYTHONJAR=lib/jython-standalone-2.7.0.jar

to reference the jython jar file you are using.

## Before running the scripts

Before running the supplied scripts make sure the following programs
are in your program path:

* basename
* bash
* diff 
* grep
* sed
* touch

## Generating brat format free-text files from Drug Label XML files.

The program scripts/doxsltext.sh generates a set of files for each
drug label, one for each "Box Warnings", "Adverse Reactions", and
"Warnings and Precautions" section of the label.

To use place the drug label XML files in the _input_ directory of 
_fda\_ar\_sw_ directory.  invoke the following command:

    bash ./scripts/doxsltext.sh

The output files will appear in the _output_ directory of
_fda\_ar\_sw_.

For the file Adcedtris.xml placed in the _input_ directory, the
following files will be created in the _output_ directory:
   
    Adcetris_adverse_reactions.ann
    Adcetris_adverse_reactions.txt
    Adcetris_boxed_warnings.ann
    Adcetris_boxed_warnings.txt
    Adcetris_warnings_and_precautions.ann
    Adcetris_warnings_and_precautions.txt

## Generating Single Line Delimited Input with ID for MetaMap

input files using Single Line Delimited Input with ID format for
MetaMap can be generated in the same manner:

    bash ./scripts/doxsl.sh

For the file _input_/Adcedtris.xml the _output_ directory will
contain:

    Adcetris.sldi
    Adcetris.diff
    Adcetris.titles
    Adcetris.tables
    Adcetris.html
    empty.textfields

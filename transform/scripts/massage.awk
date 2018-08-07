#!/bin/gawk -f 
BEGIN {
    FS = "|"
}
{
    if ( length($2) > 2 ) {
	printf("%s|%s\n",$1,$2);
    }
}

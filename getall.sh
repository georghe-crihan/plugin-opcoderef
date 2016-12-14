#!/bin/sh
PARSER=hackman
OUTPUT=opcoderef0 

./get_doc.pl hlprtf $PARSER $PARSER.conf $OUTPUT.h > $OUTPUT.rtf
./get_doc.pl html $PARSER $PARSER.conf > $OUTPUT.htm
./get_doc.pl tex $PARSER $PARSER.conf > $OUTPUT.tex
latex $OUTPUT.tex
dvips -o $OUTPUT.ps $OUTPUT.dvi

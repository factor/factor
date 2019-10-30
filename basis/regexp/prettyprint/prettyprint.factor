! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors escape-strings kernel make prettyprint.backend
prettyprint.custom regexp regexp.parser sequences splitting ;
IN: regexp.prettyprint

M: regexp pprint*
    [
        [
            dup options>> options>string [
                raw>> "/" "\\/" replace "re" % escape-simplest %
            ] [
                [ raw>> "/" "\\/" replace "re:: " % escape-simplest % ]
                [ " " % escape-simplest % ] bi*
            ] if-empty
        ] "" make
    ] keep present-text ;

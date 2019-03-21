! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel make prettyprint.backend
prettyprint.custom regexp regexp.parser splitting ;
IN: regexp.prettyprint

M: regexp pprint*
    [
        [
            [ raw>> "/" "\\/" replace "R/ " % % "/" % ]
            [ options>> options>string % ] bi
        ] "" make
    ] keep present-text ;

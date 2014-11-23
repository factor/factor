! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes continuations kernel make math
math.parser sequences sets ;
IN: summary

GENERIC: summary ( object -- string )

: object-summary ( object -- string ) class-of name>> ; inline

M: object summary object-summary ;

M: sequence summary
    [
        dup class-of name>> %
        " with " %
        length #
        " elements" %
    ] "" make ;

M: assoc summary
    [
        dup class-of name>> %
        " with " %
        assoc-size #
        " entries" %
    ] "" make ;

M: set summary
    [
        dup class-of name>> %
        " with " %
        cardinality #
        " members" %
    ] "" make ;

! Override sequence => integer instance
M: f summary object-summary ;

M: integer summary object-summary ;

: safe-summary ( object -- string )
    [ summary ]
    [ drop object-summary "~summary error: " "~" surround ]
    recover ;

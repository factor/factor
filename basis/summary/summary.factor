! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes sequences kernel namespaces
make words math math.parser assocs ;
IN: summary

GENERIC: summary ( object -- string )

: object-summary ( object -- string )
    class name>> ;

M: object summary object-summary ;

M: sequence summary
    [
        dup class name>> %
        " with " %
        length #
        " elements" %
    ] "" make ;

M: assoc summary
    [
        dup class name>> %
        " with " %
        assoc-size #
        " entries" %
    ] "" make ;

! Override sequence => integer instance
M: f summary object-summary ;

M: integer summary object-summary ;

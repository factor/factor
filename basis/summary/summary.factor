! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes sequences kernel namespaces
make words math math.parser assocs classes.struct
alien.c-types ;
IN: summary

GENERIC: summary ( object -- string )

: object-summary ( object -- string )
    class name>> " instance" append ;

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

M: struct summary
    [
        dup class name>> %
        " struct of " %
        byte-length #
        " bytes " %
    ] "" make ;

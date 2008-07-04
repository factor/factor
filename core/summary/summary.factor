! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes sequences splitting kernel namespaces
words math math.parser io.styles prettyprint assocs ;
IN: summary

GENERIC: summary ( object -- string )

: object-summary ( object -- string )
    class name>> " instance" append ;

M: object summary object-summary ;

M: input summary
    [
        "Input: " %
        input-string "\n" split1 swap %
        "..." "" ? %
    ] "" make ;

M: word summary synopsis ;

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

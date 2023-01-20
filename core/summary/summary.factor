! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes continuations kernel make math
math.parser sequences sets strings ;
IN: summary

GENERIC: summary ( object -- string )

: object-summary ( object -- string ) class-of name>> ; inline

: container-summary ( obj size word -- str )
    [ object-summary ] 2dip [
        [ % " with " % ] [ # ] [ " " % % ] tri*
    ] "" make ;

GENERIC: tuple-summary ( object -- string )

M: assoc tuple-summary
    dup assoc-size "entries" container-summary ;

M: object tuple-summary
    object-summary ;

M: set tuple-summary
    dup cardinality "members" container-summary ;

M: tuple summary
    tuple-summary ;

M: object summary object-summary ;

M: sequence summary
    dup length "elements" container-summary ;

M: string summary
    dup length "code points" container-summary ;

! Override sequence => integer instance
M: f summary object-summary ;

M: integer summary object-summary ;

: safe-summary ( object -- string )
    [ summary ]
    [ drop object-summary "~summary error: " "~" surround ]
    recover ;

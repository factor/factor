! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes continuations formatting kernel math
sequences sets strings ;
IN: summary

GENERIC: summary ( object -- string )

: object-summary ( object -- string ) class-of name>> ; inline

: container-summary ( obj size word -- str )
    [ object-summary ] 2dip "%s with %d %s" sprintf ;

M: object summary object-summary ;

M: sequence summary
    dup length "elements" container-summary ;

M: assoc summary
    dup assoc-size "entries" container-summary ;

M: unordered-set summary
    dup cardinality "members" container-summary ;

! Override sequence => integer instance
M: f summary object-summary ;

M: integer summary object-summary ;

: safe-summary ( object -- string )
    [ summary ]
    [ drop object-summary "~summary error: " "~" surround ]
    recover ;

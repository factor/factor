! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors interpreter kernel lists namespaces prettyprint
stdio ;

DEFER: recursive-state

: inference-condition ( msg symbol -- )
    [
        , , recursive-state get , meta-d get , meta-r get ,
    ] make-list ;

: inference-error ( msg -- )
    \ inference-error inference-condition throw ;

: inference-warning ( msg -- )
    \ inference-warning inference-condition error. ;

: inference-condition. ( cond msg -- )
    write
    cdr unswons error.
    "Recursive state:" print
    car [.] ;
!    "Meta data stack:" print
!    unswons {.}
!    "Meta return stack:" print
!    car {.} ;

PREDICATE: cons inference-error car \ inference-error = ;
M: inference-error error. ( error -- )
    "Inference error: " inference-condition. ;

PREDICATE: cons inference-warning car \ inference-warning = ;
M: inference-warning error. ( error -- )
    "Inference warning: " inference-condition. ;

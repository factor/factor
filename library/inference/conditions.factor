! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors interpreter kernel lists namespaces prettyprint
sequences stdio ;

DEFER: recursive-state

: inference-condition ( msg symbol -- )
    [
        , , recursive-state get , meta-d get , meta-r get ,
    ] make-list ;

: inference-condition. ( cond msg -- )
    "! " write write
    cdr unswons error.
    "! Recursive state:" print
    car [ "! " write . ] each ;

: inference-error ( msg -- )
    #! Signalled if your code is malformed in some
    #! statically-provable way.
    \ inference-error inference-condition throw ;

PREDICATE: cons inference-error car \ inference-error = ;
M: inference-error error. ( error -- )
    "Inference error: " inference-condition. ;

: inference-warning ( msg -- )
    "inference-warnings" get [
        \ inference-warning inference-condition error.
    ] [
        drop
    ] ifte ;

PREDICATE: cons inference-warning car \ inference-warning = ;
M: inference-warning error. ( error -- )
    "Inference warning: " inference-condition. ;

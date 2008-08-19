! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel sets namespaces accessors assocs
arrays combinators continuations columns math
compiler.tree
compiler.tree.def-use
compiler.tree.combinators ;
IN: compiler.tree.checker

! Check some invariants.
ERROR: check-use-error value message ;

: check-use ( value uses -- )
    [ empty? [ "No use" check-use-error ] [ drop ] if ]
    [ all-unique? [ drop ] [ "Uses not all unique" check-use-error ] if ] 2bi ;

: check-def-use ( -- )
    def-use get [ uses>> check-use ] assoc-each ;

GENERIC: check-node* ( node -- )

M: #shuffle check-node*
    [ [ mapping>> values ] [ in-d>> ] bi subset? [ "Bad mapping inputs" throw ] unless ]
    [ [ mapping>> keys ] [ out-d>> ] bi set= [ "Bad mapping outputs" throw ] unless ]
    bi ;

: check-lengths ( seq -- )
    [ length ] map all-equal? [ "Bad lengths" throw ] unless ;

M: #copy check-node* inputs/outputs 2array check-lengths ;

M: #>r check-node* inputs/outputs 2array check-lengths ;

M: #r> check-node* inputs/outputs 2array check-lengths ;

M: #return-recursive check-node* inputs/outputs 2array check-lengths ;

M: #phi check-node*
    [ [ phi-in-d>> <flipped> ] [ out-d>> ] bi 2array check-lengths ]
    [ phi-in-d>> check-lengths ]
    bi ;

M: #enter-recursive check-node*
    [ [ in-d>> ] [ out-d>> ] bi 2array check-lengths ]
    [ recursive-phi-in check-lengths ]
    bi ;

M: #push check-node*
    out-d>> length 1 = [ "Bad #push" throw ] unless ;

M: node check-node* drop ;

: check-values ( seq -- )
    [ integer? ] all? [ "Bad values" throw ] unless ;

ERROR: check-node-error node error ;

: check-node ( node -- )
    [
        [ node-uses-values check-values ]
        [ node-defs-values check-values ]
        [ check-node* ]
        tri
    ] [ check-node-error ] recover ;

: check-nodes ( nodes -- )
    compute-def-use
    check-def-use
    [ check-node ] each-node ;

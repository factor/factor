USING: classes.parser classes.predicate combinators.short-circuit continuations
kernel lexer math.intervals parser sequences words ;
IN: math.intervals.predicates

ERROR: invalid-interval-definition stack ;

<PRIVATE
PREDICATE: empty-interval-class < word empty-interval eq? ;
UNION: valid-interval interval full-interval empty-interval-class ;

: evaluate-interval ( quot -- interval )
    { } swap with-datastack
    dup { [ length 1 = ] [ first valid-interval? ] } 1&&
    [ first ]
    [ invalid-interval-definition ] if ;

: interval>predicate ( interval -- quot )
    [ interval-contains? ] curry ;
PRIVATE>

: define-interval-predicate-class ( class superclass interval -- )
    [ interval>predicate define-predicate-class ]
    [ nip "declared-interval" set-word-prop ] 3bi ;

SYNTAX: INTERVAL-PREDICATE:
    scan-new-class "<" expect scan-class parse-definition
    evaluate-interval define-interval-predicate-class ;

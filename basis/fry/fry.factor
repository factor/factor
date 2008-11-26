! Copyright (C) 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences combinators parser splitting math
quotations arrays make words locals.backend summary sets ;
IN: fry

: _ ( -- * ) "Only valid inside a fry" throw ;
: @ ( -- * ) "Only valid inside a fry" throw ;

ERROR: >r/r>-in-fry-error ;

<PRIVATE

: [ncurry] ( n -- quot )
    {
        { 0 [ [ ] ] }
        { 1 [ [ curry ] ] }
        { 2 [ [ 2curry ] ] }
        { 3 [ [ 3curry ] ] }
        [ \ curry <repetition> ]
    } case ;

M: >r/r>-in-fry-error summary
    drop
    "Explicit retain stack manipulation is not permitted in fried quotations" ;

: check-fry ( quot -- quot )
    dup { >r r> load-locals get-local drop-locals } intersect
    empty? [ >r/r>-in-fry-error ] unless ;

: shallow-fry ( quot -- quot' )
    check-fry
    [ dup \ @ = [ drop [ _ call ] ] [ 1array ] if ] map concat
    { _ } split [ length 1- [ncurry] ] [ spread>quot ] bi prefix ;

PREDICATE: fry-specifier < word { _ @ } memq? ;

GENERIC: count-inputs ( quot -- n )

M: callable count-inputs [ count-inputs ] sigma ;
M: fry-specifier count-inputs drop 1 ;
M: object count-inputs drop 0 ;

PRIVATE>

: fry ( quot -- quot' )
    [
        [
            dup callable? [
                [ count-inputs \ _ <repetition> % ] [ fry % ] bi
            ] [ , ] if
        ] each
    ] [ ] make shallow-fry ;

: '[ \ ] parse-until fry over push-all ; parsing

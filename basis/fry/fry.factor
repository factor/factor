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
    dup { load-local load-locals get-local drop-locals } intersect
    [ >r/r>-in-fry-error ] unless-empty ;

PREDICATE: fry-specifier < word { _ @ } member-eq? ;

GENERIC: count-inputs ( quot -- n )

M: callable count-inputs [ count-inputs ] sigma ;
M: fry-specifier count-inputs drop 1 ;
M: object count-inputs drop 0 ;

GENERIC: deep-fry ( obj -- )

: shallow-fry ( quot -- quot' curry# )
    check-fry
    [ [ deep-fry ] each ] [ ] make
    [ dup \ @ = [ drop [ _ call ] ] [ 1array ] if ] map concat
    { _ } split [ spread>quot ] [ length 1 - ] bi ;

PRIVATE>

: fry ( quot -- quot' ) shallow-fry [ncurry] swap prefix ;

M: callable deep-fry
    [ count-inputs \ _ <repetition> % ] [ fry % ] bi ;

M: object deep-fry , ;

SYNTAX: '[ parse-quotation fry append! ;

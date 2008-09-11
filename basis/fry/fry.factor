! Copyright (C) 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences combinators parser splitting math
quotations arrays make qualified words ;
IN: fry

: _ ( -- * ) "Only valid inside a fry" throw ;
: @ ( -- * ) "Only valid inside a fry" throw ;

<PRIVATE

DEFER: (shallow-fry)
DEFER: shallow-fry

: ((shallow-fry)) ( accum quot adder -- result )
    >r shallow-fry r>
    append swap [
        [ prepose ] curry append
    ] unless-empty ; inline

: (shallow-fry) ( accum quot -- result )
    [ 1quotation ] [
        unclip {
            { \ _ [ [ curry ] ((shallow-fry)) ] }
            { \ @ [ [ compose ] ((shallow-fry)) ] }
            [ swap >r suffix r> (shallow-fry) ]
        } case
    ] if-empty ;

: shallow-fry ( quot -- quot' ) [ ] swap (shallow-fry) ;

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

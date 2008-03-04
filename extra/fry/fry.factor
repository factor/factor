! Copyright (C) 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences combinators parser splitting
quotations arrays namespaces ;
IN: fry

: , "Only valid inside a fry" throw ;
: @ "Only valid inside a fry" throw ;
: _ "Only valid inside a fry" throw ;

DEFER: (fry)

: ((fry)) ( accum quot adder -- result )
    >r [ ] swap (fry) r>
    append swap dup empty? [ drop ] [
        [ swap compose ] curry append
    ] if ; inline

: (fry) ( accum quot -- result )
    dup empty? [
        drop 1quotation
    ] [
        unclip {
            { , [ [ curry ] ((fry)) ] }
            { @ [ [ compose ] ((fry)) ] }
            [ swap >r add r> (fry) ]
        } case
    ] if ;

: trivial-fry ( quot -- quot' ) [ ] swap (fry) ;

: fry ( quot -- quot' )
    { _ } last-split1 [
        [
            trivial-fry %
            [ >r ] %
            fry %
            [ [ dip ] curry r> compose ] %
        ] [ ] make
    ] [
        trivial-fry
    ] if* ;

: '[ \ ] parse-until fry over push-all ; parsing

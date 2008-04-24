! Copyright (C) 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences combinators parser splitting
quotations arrays namespaces qualified ;
QUALIFIED: namespaces
IN: fry

: , "Only valid inside a fry" throw ;
: @ "Only valid inside a fry" throw ;
: _ "Only valid inside a fry" throw ;

DEFER: (shallow-fry)

: ((shallow-fry)) ( accum quot adder -- result )
    >r [ ] swap (shallow-fry) r>
    append swap dup empty? [ drop ] [
        [ swap compose ] curry append
    ] if ; inline

: (shallow-fry) ( accum quot -- result )
    dup empty? [
        drop 1quotation
    ] [
        unclip {
            { \ , [ [ curry ] ((shallow-fry)) ] }
            { \ @ [ [ compose ] ((shallow-fry)) ] }

            ! to avoid confusion, remove if fry goes core
            { \ namespaces:, [ [ curry ] ((shallow-fry)) ] }

            [ swap >r suffix r> (shallow-fry) ]
        } case
    ] if ;

: shallow-fry ( quot -- quot' ) [ ] swap (shallow-fry) ;

: deep-fry ( quot -- quot' )
    { _ } last-split1 [
        [
            shallow-fry %
            [ >r ] %
            deep-fry %
            [ [ dip ] curry r> compose ] %
        ] [ ] make
    ] [
        shallow-fry
    ] if* ;

: fry ( quot -- quot' )
    [
        [
            dup callable? [
                [
                    [ { , namespaces:, @ } member? ] subset length
                    \ , <repetition> %
                ]
                [ deep-fry % ] bi
            ] [ namespaces:, ] if
        ] each
    ] [ ] make deep-fry ;

: '[ \ ] parse-until fry over push-all ; parsing

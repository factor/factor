! Copyright (C) 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences combinators parser splitting math
quotations arrays namespaces qualified sequences.deep sequences.lib ;
QUALIFIED: namespaces
IN: fry

: , ( -- * ) "Only valid inside a fry" throw ;
: @ ( -- * ) "Only valid inside a fry" throw ;
: _ ( -- * ) "Only valid inside a fry" throw ;

DEFER: (shallow-fry)
DEFER: shallow-fry

: ((shallow-fry)) ( accum quot adder -- result )
    >r shallow-fry r>
    append swap dup empty? [ drop ] [
        [ prepose ] curry append
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

: deep-fry ( quot -- quot )
    { _ } last-split1 dup [
      shallow-fry [ >r ] rot
      deep-fry    [ [ dip ] curry r> compose ] 4array concat
    ] [
        drop shallow-fry
    ] if ;

: fry-specifier? ( obj -- ? ) { , namespaces:, @ } member? ;

: count-inputs ( quot -- n )
    [
        {
            { [ dup callable?      ] [ count-inputs ] }
            { [ dup fry-specifier? ] [ drop 1       ] }
                                     [ drop 0       ]
        } cond
    ] map sum ;

: fry ( quot -- quot' )
    [
        [
            dup callable? [
                [ count-inputs \ , <repetition> % ] [ fry % ] bi
            ] [ namespaces:, ] if
        ] each
    ] [ ] make deep-fry ;

: '[ \ ] parse-until fry over push-all ; parsing

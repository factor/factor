! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel accessors quotations slots words
sequences namespaces combinators combinators.short-circuit
summary smalltalk.classes ;
IN: smalltalk.compiler.lexenv

! local-readers: assoc string => word
! local-writers: assoc string => word
! self: word or f for top-level forms
! class: class word or f for top-level forms
! method: generic word or f for top-level forms
TUPLE: lexenv local-readers local-writers self return class method ;

: <lexenv> ( -- lexenv ) lexenv new ; inline

CONSTANT: empty-lexenv T{ lexenv }

: lexenv-union ( lexenv1 lexenv2 -- lexenv )
    [ <lexenv> ] 2dip {
        [ [ local-readers>> ] bi@ assoc-union >>local-readers ]
        [ [ local-writers>> ] bi@ assoc-union >>local-writers ]
        [ [ self>> ] either? >>self ]
        [ [ return>> ] either? >>return ]
        [ [ class>> ] either? >>class ]
        [ [ method>> ] either? >>method ]
    } 2cleave ;

: local-reader ( name lexenv -- local )
    local-readers>> at dup [ 1quotation ] when ;

: ivar-reader ( name lexenv -- quot/f )
    dup class>> [
        [ class>> "slots" word-prop slot-named ] [ self>> ] bi
        swap dup [ name>> reader-word [ ] 2sequence ] [ 2drop f ] if
    ] [ 2drop f ] if ;

: class-name ( name -- quot/f )
    classes get at dup [ [ ] curry ] when ;

ERROR: bad-identifier name ;

M: bad-identifier summary drop "Unknown identifier" ;

: lookup-reader ( name lexenv -- reader-quot )
    {
        [ local-reader ]
        [ ivar-reader ]
        [ drop class-name ]
        [ drop bad-identifier ]
    } 2|| ;

: local-writer ( name lexenv -- local )
    local-writers>> at dup [ 1quotation ] when ;

: ivar-writer ( name lexenv -- quot/f )
    dup class>> [
        [ class>> "slots" word-prop slot-named ] [ self>> ] bi
        swap dup [ name>> writer-word [ ] 2sequence ] [ 2drop f ] if
    ] [ 2drop f ] if ;

: lookup-writer ( name lexenv -- writer-quot )
    {
        [ local-writer ]
        [ ivar-writer ]
        [ drop bad-identifier ]
    } 2|| ;
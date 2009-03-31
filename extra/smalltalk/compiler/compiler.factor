! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
continuations fry kernel namespaces quotations sequences sets
generalizations slots locals.types generalizations splitting math
locals.rewrite.closures generic words smalltalk.ast
smalltalk.compiler.lexenv smalltalk.selectors
smalltalk.classes ;
IN: smalltalk.compiler

SYMBOL: return-continuation

GENERIC: need-return-continuation? ( ast -- ? )

M: ast-return need-return-continuation? drop t ;

M: ast-block need-return-continuation? body>> need-return-continuation? ;

M: ast-message-send need-return-continuation?
    {
        [ receiver>> need-return-continuation? ]
        [ arguments>> need-return-continuation? ]
    } 1&& ;

M: ast-assignment need-return-continuation?
    value>> need-return-continuation? ;

M: array need-return-continuation? [ need-return-continuation? ] any? ;

M: object need-return-continuation? drop f ;

GENERIC: assigned-locals ( ast -- seq )

M: ast-return assigned-locals value>> assigned-locals ;

M: ast-block assigned-locals
    [ body>> assigned-locals ] [ arguments>> ] bi diff ;

M: ast-message-send assigned-locals
    [ arguments>> assigned-locals ]
    [ receiver>> assigned-locals ]
    bi append ;

M: ast-assignment assigned-locals
    [ name>> dup ast-name? [ name>> 1array ] [ drop { } ] if ]
    [ value>> assigned-locals ] bi append ;

M: array assigned-locals
    [ assigned-locals ] map concat ;

M: object assigned-locals drop f ;

GENERIC: compile-ast ( lexenv ast -- quot )

M: object compile-ast nip 1quotation ;

M: self compile-ast drop self>> 1quotation ;

ERROR: unbound-local name ;

M: ast-name compile-ast name>> swap lookup-reader ;

M: ast-message-send compile-ast
    [ arguments>> [ compile-ast ] with map [ ] join ]
    [ receiver>> compile-ast ]
    [ nip selector>> selector>generic ]
    2tri [ append ] dip suffix ;

M: ast-return compile-ast
    value>> compile-ast
    [ return-continuation get continue-with ] append ;

GENERIC: contains-blocks? ( obj -- ? )

M: ast-block contains-blocks? drop t ;

M: object contains-blocks? drop f ;

M: array contains-blocks? [ contains-blocks? ] any? ;

M: array compile-ast
    dup contains-blocks? [
        [ [ compile-ast ] with map [ ] join ] [ length ] bi
        '[ @ _ narray ]
    ] [ call-next-method ] if ;

GENERIC: compile-assignment ( lexenv name -- quot )

M: ast-name compile-assignment name>> swap lookup-writer ;

M: ast-assignment compile-ast
    [ value>> compile-ast [ dup ] ] [ name>> compile-assignment ] 2bi 3append ;

: block-lexenv ( block -- lexenv )
    [ arguments>> ] [ body>> [ assigned-locals ] map concat unique ] bi
    '[
        dup dup _ key?
        [ <local-reader> ]
        [ <local> ]
        if
    ] { } map>assoc
    dup
    [ nip local-reader? ] assoc-filter
    [ <local-writer> ] assoc-map
    <lexenv> swap >>local-writers swap >>local-readers ;

: compile-block ( lexenv block -- vars body )
    [
        block-lexenv
        [ nip local-readers>> values ]
        [ lexenv-union ] 2bi
    ] [ body>> ] bi
    [ drop [ nil ] ] [ [ compile-ast ] with map [ drop ] join ] if-empty ;

M: ast-block compile-ast
    compile-block <lambda> '[ _ ] ;

: make-return ( quot n block -- quot )
    need-return-continuation? [
        '[
            [
                _ _ ncurry
                [ return-continuation set ] prepose callcc1
            ] with-scope
        ]
    ] [ drop ] if
    rewrite-closures first ;

GENERIC: compile-smalltalk ( ast -- quot )

M: object compile-smalltalk ( statement -- quot )
    [ [ empty-lexenv ] dip compile-ast 0 ] keep make-return ;

: (compile-method-body) ( lexenv block -- lambda )
    [ drop self>> ] [ compile-block ] 2bi [ swap suffix ] dip <lambda> ;

: compile-method-body ( lexenv block -- quot )
    [ [ (compile-method-body) ] [ arguments>> length 1+ ] bi ] keep
    make-return ;

: compile-method ( lexenv ast-method -- )
    [ [ class>> ] [ name>> selector>generic ] bi* create-method ]
    [ body>> compile-method-body ]
    2bi define ;

: <class-lexenv> ( class -- lexenv )
    <lexenv> swap >>class "self" <local-reader> >>self ;

M: ast-class compile-smalltalk ( ast-class -- quot )
    [
        [ name>> ] [ superclass>> ] [ ivars>> ] tri
        define-class <class-lexenv> 
    ]
    [ methods>> ] bi
    [ compile-method ] with each
    [ nil ] ;

ERROR: no-word name ;

M: ast-foreign compile-smalltalk
    [ class>> dup ":" split1 lookup [ ] [ no-word ] ?if ]
    [ name>> ] bi define-foreign
    [ nil ] ;
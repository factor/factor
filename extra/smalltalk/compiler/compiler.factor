! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
continuations fry kernel namespaces quotations sequences sets
generalizations slots locals.types splitting math
locals.rewrite.closures generic words combinators locals smalltalk.ast
smalltalk.compiler.lexenv smalltalk.compiler.assignment
smalltalk.compiler.return smalltalk.selectors smalltalk.classes ;
IN: smalltalk.compiler

GENERIC: compile-ast ( lexenv ast -- quot )

M: object compile-ast nip 1quotation ;

M: self compile-ast drop self>> 1quotation ;

ERROR: unbound-local name ;

M: ast-name compile-ast name>> swap lookup-reader ;

: compile-arguments ( lexenv ast -- quot )
    arguments>> [ compile-ast ] with map [ ] join ;

: compile-new ( lexenv ast -- quot )
    [ receiver>> compile-ast ]
    [ compile-arguments ] 2bi
    [ new ] 3append ;

: compile-ifTrue:ifFalse: ( lexenv ast -- quot )
    [ receiver>> compile-ast ]
    [ compile-arguments ] 2bi
    [ if ] 3append ;

M: ast-message-send compile-ast
    dup selector>> {
        { "ifTrue:ifFalse:" [ compile-ifTrue:ifFalse: ] }
        { "new" [ compile-new ] }
        [
            drop
            [ compile-arguments ]
            [ receiver>> compile-ast ]
            [ nip selector>> selector>generic ]
            2tri [ append ] dip suffix
        ]
    } case ;

M: ast-cascade compile-ast
    [ receiver>> compile-ast ]
    [
        messages>> [
            [ compile-arguments \ dip ]
            [ selector>> selector>generic ] bi
            [ ] 3sequence
        ] with map
        unclip-last [ [ [ drop ] append ] map ] dip suffix
        cleave>quot
    ] 2bi append ;

M: ast-return compile-ast
    [ value>> compile-ast ] [ drop return>> 1quotation ] 2bi
    [ continue-with ] 3append ;

: (compile-sequence) ( lexenv asts -- quot )
    [ drop [ nil ] ] [
        [ compile-ast ] with map [ drop ] join
    ] if-empty ;

: block-lexenv ( block -- lexenv )
    [ [ arguments>> ] [ temporaries>> ] bi append ]
    [ body>> [ assigned-locals ] map concat unique ] bi
    '[
        dup dup _ key?
        [ <local-reader> ]
        [ <local> ]
        if
    ] H{ } map>assoc
    dup
    [ nip local-reader? ] assoc-filter
    [ <local-writer> ] assoc-map
    <lexenv> swap >>local-writers swap >>local-readers ;

: lookup-block-vars ( vars lexenv -- seq )
    local-readers>> '[ _ at ] map ;

: make-temporaries ( block lexenv -- quot )
    [ temporaries>> ] dip lookup-block-vars
    [ <def> [ f ] swap suffix ] map [ ] join ;

:: compile-sequence ( lexenv block -- vars quot )
    lexenv block block-lexenv lexenv-union :> lexenv
    block arguments>> lexenv lookup-block-vars
    lexenv block body>> (compile-sequence) block lexenv make-temporaries prepend ;

M: ast-sequence compile-ast
    compile-sequence nip ;

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

M: ast-block compile-ast
    compile-sequence <lambda> '[ _ ] ;

:: (compile-method-body) ( lexenv block -- lambda )
    lexenv block compile-sequence
    [ lexenv self>> suffix ] dip <lambda> ;

: compile-method-body ( lexenv block -- quot )
    [ [ (compile-method-body) ] [ arguments>> length 1+ ] bi ] 2keep
    make-return ;

: compile-method ( lexenv ast-method -- )
    [ [ class>> ] [ name>> selector>generic ] bi* create-method ]
    [ body>> compile-method-body ]
    2bi define ;

: <class-lexenv> ( class -- lexenv )
    <lexenv> swap >>class "self" <local> >>self "^" <local> >>return ;

M: ast-class compile-ast
    nip
    [
        [ name>> ] [ superclass>> ] [ ivars>> ] tri
        define-class <class-lexenv> 
    ]
    [ methods>> ] bi
    [ compile-method ] with each
    [ nil ] ;

ERROR: no-word name ;

M: ast-foreign compile-ast
    nip
    [ class>> dup ":" split1 lookup [ ] [ no-word ] ?if ]
    [ name>> ] bi define-foreign
    [ nil ] ;

: compile-smalltalk ( statement -- quot )
    [ empty-lexenv ] dip [ compile-sequence nip 0 ]
    2keep make-return ;
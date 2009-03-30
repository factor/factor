! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
continuations fry kernel namespaces quotations sequences sets
slots locals.types generalizations smalltalk.ast
smalltalk.compiler.lexenv smalltalk.selectors ;
IN: smalltalk.compiler

SYMBOL: return-continuation

GENERIC: need-return-continuation? ( ast -- ? )

M: ast-return need-return-continuation? drop t ;

M: ast-block need-return-continuation? body>> [ need-return-continuation? ] any? ;

M: ast-message-send need-return-continuation?
    {
        [ receiver>> need-return-continuation? ]
        [ arguments>> [ need-return-continuation? ] any? ]
    } 1&& ;

M: ast-assignment need-return-continuation?
    value>> need-return-continuation? ;

M: object need-return-continuation? drop f ;

GENERIC: assigned-locals ( ast -- seq )

M: ast-return assigned-locals value>> assigned-locals ;

M: ast-block assigned-locals
    [ body>> [ assigned-locals ] map concat ] [ arguments>> ] bi diff ;

M: ast-message-send assigned-locals
    [ receiver>> assigned-locals ]
    [ arguments>> [ assigned-locals ] map ] bi append ;

M: ast-assignment assigned-locals
    [ name>> dup ast-name? [ name>> 1array ] [ drop { } ] if ]
    [ value>> assigned-locals ] bi append ;

M: object assigned-locals drop f ;

GENERIC: compile-ast ( lexenv ast -- quot )

M: object compile-ast nip 1quotation ;

ERROR: unbound-local name ;

M: ast-name compile-ast
    name>> swap local-readers>> at 1quotation ;

M: ast-message-send compile-ast
    [ receiver>> compile-ast ]
    [ arguments>> [ compile-ast ] with map concat ]
    [ nip selector>> selector>generic ]
    2tri [ append ] dip suffix ;

M: ast-return compile-ast
    value>> compile-ast
    [ return-continuation get continue-with ] append ;

GENERIC: compile-assignment ( lexenv name -- quot )

M: ast-name compile-assignment
    name>> swap local-writers>> at 1quotation ;

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
    <lexenv> ;

M: ast-block compile-ast
    [
        block-lexenv
        [ nip local-readers>> values ]
        [ lexenv-union ] 2bi
    ] [ body>> ] bi
    [ drop [ nil ] ] [
        unclip-last
        [ [ compile-ast [ drop ] append ] with map [ ] join ]
        [ compile-ast ]
        bi-curry* bi
        append
    ] if-empty
    <lambda> '[ @ ] ;

: compile-method ( block -- quot )
    [ [ empty-lexenv ] dip compile-ast ] [ arguments>> length ] [ need-return-continuation? ] tri
    [ '[ [ _ _ ncurry [ return-continuation set ] prepose callcc1 ] with-scope ] ] [ drop ] if ;
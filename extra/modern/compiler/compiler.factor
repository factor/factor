! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators combinators.short-circuit fry
kernel lexer modern namespaces sequences sets strings ;
IN: modern.compiler

<<
SYMBOL: left-decorators
left-decorators [ HS{ } clone ] initialize
>>
<<
: make-left-decorator ( string -- )
    left-decorators get adjoin ;

>>
<<
SYNTAX: \LEFT-DECORATOR: scan-token make-left-decorator ;
>>

LEFT-DECORATOR: delimiter
LEFT-DECORATOR: deprecated
LEFT-DECORATOR: final
LEFT-DECORATOR: flushable
LEFT-DECORATOR: foldable
LEFT-DECORATOR: inline
LEFT-DECORATOR: recursive

: left-decorator? ( obj -- ? )
    left-decorators get in? ;

<<
SYMBOL: arities
arities [ H{ } clone ] initialize
>>
<<
: make-arity ( n string -- )
    arities get set-at ;
>>
<<
SYNTAX: \ARITY: scan-token scan-token swap make-arity ;
>>

ARITY: \ALIAS: 2
ARITY: \ARITY: 2
ARITY: \BUILTIN: 1
ARITY: \CONSTANT: 2
ARITY: \DEFER: 1
ARITY: \GENERIC#: 3
ARITY: \GENERIC: 2
ARITY: \HOOK: 3
ARITY: \IN: 1
ARITY: \INSTANCE: 2
ARITY: \MAIN: 1
ARITY: \MATH: 1
ARITY: \MIXIN: 1
ARITY: \PRIMITIVE: 2
ARITY: \QUALIFIED-WITH: 2
ARITY: \QUALIFIED: 1
ARITY: \RENAME: 3
ARITY: \SINGLETON: 1
ARITY: \SLOT: 1
ARITY: \SYMBOL: 1
ARITY: \UNUSE: 1
ARITY: \USE: 1

: get-arity ( string -- n/f )
    arities get at ;

<<
SYMBOL: variable-arities
variable-arities [ H{ } clone ] initialize
>>
<<
: make-variable-arity ( n string -- )
    variable-arities get set-at ;
>>
<<
SYNTAX: \VARIABLE-ARITY: scan-token scan-token swap make-arity ;
>>

VARIABLE-ARITY: \EXCLUDE: 2
VARIABLE-ARITY: \FROM: 2
VARIABLE-ARITY: \INTERSECTION: 1
VARIABLE-ARITY: \PREDICATE: 3
VARIABLE-ARITY: \SYNTAX: 1
VARIABLE-ARITY: \TUPLE: 1
VARIABLE-ARITY: \UNION: 1
VARIABLE-ARITY: \WORD: 2

VARIABLE-ARITY: \<CLASS: 3
VARIABLE-ARITY: \<FUNCTOR: 2

: matched-literal? ( obj -- ? )
    dup array? [
        {
            [ ?first "[" tail? ]
            [ ?first "{" tail? ]
            [ ?first "(" tail? ]
            [ { [ ?first ":" tail? ] [ ?last ";" tail? ] } 1&& ]
        } 1||
    ] [
        drop f
    ] if ;

: (map-literals) ( obj quot: ( obj -- obj' ) -- seq )
    over matched-literal? [
        [ call drop ] [
            '[
                first3 [ [ _ (map-literals) ] map ] dip 3array
            ] call
        ] 2bi
    ] [
        call
    ] if ; inline recursive

: map-literals ( obj quot: ( obj -- obj' ) -- seq )
    '[ _ (map-literals) ] map ; inline





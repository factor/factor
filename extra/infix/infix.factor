! Copyright (C) 2009 Philipp Brüschweiler
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
effects fry infix.parser infix.ast kernel locals.parser
locals.types math multiline namespaces parser quotations
sequences summary words ;
IN: infix

<PRIVATE
: prepare-operand ( term -- quot )
    dup callable? [ 1quotation ] unless ;

ERROR: local-not-defined name ;
M: local-not-defined summary
    drop "local is not defined" ;

: >local-word ( string -- word )
    locals get ?at [ local-not-defined ] unless ;

: select-op ( string -- word )
    {
        { "+" [ [ + ] ] }
        { "-" [ [ - ] ] }
        { "*" [ [ * ] ] }
        { "/" [ [ / ] ] }
        [ drop [ mod ] ]
    } case ;

GENERIC: infix-codegen ( ast -- quot/number )

M: ast-number infix-codegen value>> ;

M: ast-local infix-codegen
    name>> >local-word ;

M: ast-array infix-codegen
    [ index>> infix-codegen prepare-operand ]
    [ name>> >local-word ] bi '[ @ _ nth ] ;

M: ast-op infix-codegen
    [ left>> infix-codegen ] [ right>> infix-codegen ]
    [ op>> select-op ] tri
    2over [ number? ] both? [ call( a b -- c ) ] [
        [ [ prepare-operand ] bi@ ] dip '[ @ @ @ ]
    ] if ;

M: ast-negation infix-codegen
    term>> infix-codegen
    {
        { [ dup number? ] [ neg ] }
        { [ dup callable? ] [ '[ @ neg ] ] }
        [ '[ _ neg ] ] ! local word
    } cond ;

ERROR: bad-stack-effect word ;
M: bad-stack-effect summary
    drop "Words used in infix must declare a stack effect and return exactly one value" ;

: check-word ( argcount word -- ? )
    dup stack-effect [ ] [ bad-stack-effect ] ?if
    [ in>> length ] [ out>> length ] bi
    [ = ] dip 1 = and ;

: find-and-check ( args argcount string -- quot )
    dup search [ ] [ no-word ] ?if
    [ nip ] [ check-word ] 2bi
    [ 1quotation compose ] [ bad-stack-effect ] if ;

: arguments-codegen ( seq -- quot )
    dup empty? [ drop [ ] ] [
        [ infix-codegen prepare-operand ]
        [ compose ] map-reduce
    ] if ;

M: ast-function infix-codegen
    [ arguments>> [ arguments-codegen ] [ length ] bi ]
    [ name>> ] bi find-and-check ;

: [infix-parse ( end -- result/quot )
    parse-multiline-string build-infix-ast
    infix-codegen prepare-operand ;
PRIVATE>

SYNTAX: [infix
    "infix]" [infix-parse parsed \ call parsed ;

<PRIVATE
: parse-infix-locals ( assoc end -- quot )
    [
        in-lambda? on
        [ dup [ locals set ] [ push-locals ] bi ] dip
        [infix-parse prepare-operand swap pop-locals
    ] with-scope ;
PRIVATE>

SYNTAX: [infix|
    "|" parse-bindings "infix]" parse-infix-locals <let>
    ?rewrite-closures over push-all ;

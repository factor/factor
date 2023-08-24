! Copyright (C) 2009 Philipp Brüschweiler
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit effects
effects.parser infix.ast infix.parser kernel locals.parser
locals.types math math.functions math.order multiline parser
quotations ranges sequences summary vocabs.parser words
words.constant ;
IN: infix

<PRIVATE
: prepare-operand ( term -- quot )
    dup callable? [ 1quotation ] unless ;

ERROR: local-not-defined name ;
M: local-not-defined summary
    drop "local is not defined" ;

: >local-word ( string -- word )
    dup search dup {
        [ local? ]
        [ constant? ]
        [ stack-effect ( -- x ) effect= ]
    } 1|| [ nip ] [ drop local-not-defined ] if ;

ERROR: invalid-op string ;

: select-op ( string -- word )
    {
        { "+" [ [ + ] ] }
        { "-" [ [ - ] ] }
        { "*" [ [ * ] ] }
        { "/" [ [ / ] ] }
        { "%" [ [ mod ] ] }
        { "**" [ [ ^ ] ] }
        [ invalid-op ]
    } case ;

GENERIC: infix-codegen ( ast -- quot/number )

M: ast-value infix-codegen value>> ;

M: ast-local infix-codegen
    name>> >local-word ;

:: infix-nth ( n seq -- elt )
    n dup 0 < [ seq length + ] when seq nth ;

M: ast-array infix-codegen
    [ index>> infix-codegen prepare-operand ]
    [ name>> >local-word ] bi '[ @ _ infix-nth ] ;

: infix-subseq-step ( subseq step -- subseq' )
    {
        { 0 [ "slice step cannot be zero" throw ] }
        { 1 [ ] }
        { -1 [ reverse! ] }
        [
            [ dup length 1 [-] 0 ] dip
            [ 0 > [ swap ] when ] keep
            <range> swap nths
        ]
    } case ;

:: infix-subseq-range ( from to step len -- from to )
    step [ 0 < ] [ f ] if* [
        to [ dup 0 < [ len + ] when 1 + ] [ 0 ] if*
        from [ dup 0 < [ len + ] when 1 + ] [ len ] if*
    ] [
        from 0 or dup 0 < [ len + ] when
        to [ dup 0 < [ len + ] when ] [ len ] if*
    ] if [ 0 len clamp ] bi@ dupd max ;

:: infix-subseq ( from to step seq -- subseq )
    from to step seq length infix-subseq-range
    seq subseq step [ infix-subseq-step ] when* ;

M: ast-slice infix-codegen
    {
        [ from>> [ infix-codegen prepare-operand ] [ [ f ] ] if* ]
        [ to>>   [ infix-codegen prepare-operand ] [ [ f ] ] if* ]
        [ step>> [ infix-codegen prepare-operand ] [ [ f ] ] if* ]
        [ name>> >local-word ]
    } cleave '[ @ @ @ _ infix-subseq ] ;

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
    [ stack-effect ] [ bad-stack-effect ] ?unless
    [ in>> length ] [ out>> length ] bi
    [ = ] dip 1 = and ;

: find-and-check ( args argcount string -- quot )
    parse-word [ nip ] [ check-word ] 2bi
    [ 1quotation compose ] [ bad-stack-effect ] if ;

: arguments-codegen ( seq -- quot )
    [ [ ] ] [
        [ infix-codegen prepare-operand ]
        [ compose ] map-reduce
    ] if-empty ;

M: ast-function infix-codegen
    [ arguments>> [ arguments-codegen ] [ length ] bi ]
    [ name>> ] bi find-and-check ;

: parse-infix-quotation ( end -- result/quot )
    parse-multiline-string build-infix-ast
    infix-codegen prepare-operand ;

PRIVATE>

SYNTAX: [infix
    "infix]" parse-infix-quotation suffix! \ call suffix! ;

<PRIVATE

: (INFIX::) ( -- word def effect )
    [
        scan-new-word
        [ ";" parse-infix-quotation ] parse-locals-definition
    ] with-definition ;

PRIVATE>

SYNTAX: INFIX:: (INFIX::) define-declared ;

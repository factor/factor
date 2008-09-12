! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic sequences prettyprint io words arrays
summary effects debugger assocs accessors namespaces
compiler.errors ;
IN: stack-checker.errors

SYMBOL: recursive-state

TUPLE: inference-error error type rstate ;

M: inference-error compiler-error-type type>> ;

M: inference-error error-help error>> error-help ;

: (inference-error) ( ... class type -- * )
    >r boa r>
    recursive-state get
    \ inference-error boa throw ; inline

: inference-error ( ... class -- * )
    +error+ (inference-error) ; inline

: inference-warning ( ... class -- * )
    +warning+ (inference-error) ; inline

M: inference-error error.
    [
        rstate>>
        [ "Nesting:" print stack. ] unless-empty
    ] [ error>> error. ] bi ;

TUPLE: literal-expected ;

M: literal-expected summary
    drop "Literal value expected" ;

TUPLE: unbalanced-branches-error branches quots ;

: unbalanced-branches-error ( branches quots -- * )
    \ unbalanced-branches-error inference-error ;

M: unbalanced-branches-error error.
    "Unbalanced branches:" print
    [ quots>> ] [ branches>> [ length <effect> ] { } assoc>map ] bi zip
    [ [ first pprint-short bl ] [ second effect>string print ] bi ] each ;

TUPLE: too-many->r ;

M: too-many->r summary
    drop
    "Quotation pushes elements on retain stack without popping them" ;

TUPLE: too-many-r> ;

M: too-many-r> summary
    drop
    "Quotation pops retain stack elements which it did not push" ;

TUPLE: missing-effect word ;

M: missing-effect error.
    "The word " write
    word>> pprint
    " must declare a stack effect" print ;

TUPLE: effect-error word inferred declared ;

: effect-error ( word inferred declared -- * )
    \ effect-error inference-error ;

M: effect-error error.
    "Stack effects of the word " write
    [ word>> pprint " do not match." print ]
    [ "Inferred: " write inferred>> effect>string . ]
    [ "Declared: " write declared>> effect>string . ] tri ;

TUPLE: recursive-quotation-error quot ;

M: recursive-quotation-error error.
    "The quotation " write
    quot>> pprint
    " calls itself." print
    "Stack effect inference is undecidable when quotation-level recursion is permitted." print ;

TUPLE: undeclared-recursion-error word ;

M: undeclared-recursion-error error.
    "The inline recursive word " write
    word>> pprint
    " must be declared recursive" print ;

TUPLE: diverging-recursion-error word ;

M: diverging-recursion-error error.
    "The recursive word " write
    word>> pprint
    " digs arbitrarily deep into the stack" print ;

TUPLE: unbalanced-recursion-error word height ;

M: unbalanced-recursion-error error.
    "The recursive word " write
    word>> pprint
    " leaves with the stack having the wrong height" print ;

TUPLE: inconsistent-recursive-call-error word ;

M: inconsistent-recursive-call-error error.
    "The recursive word " write
    word>> pprint
    " calls itself with a different set of quotation parameters than were input" print ;

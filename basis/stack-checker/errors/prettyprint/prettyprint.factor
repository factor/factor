! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel prettyprint io debugger
sequences assocs stack-checker.errors summary effects ;
IN: stack-checker.errors.prettyprint

M: inference-error error-help error>> error-help ;

M: inference-error error.
    [ word>> [ "In word: " write . ] when* ] [ error>> error. ] bi ;

M: literal-expected error.
    "Got a computed value where a " write what>> write " was expected" print ;

M: unbalanced-branches-error error.
    "Unbalanced branches:" print
    [ quots>> ] [ branches>> [ length <effect> ] { } assoc>map ] bi zip
    [ [ first pprint-short bl ] [ second effect>string print ] bi ] each ;

M: too-many->r summary
    drop
    "Quotation pushes elements on retain stack without popping them" ;

M: too-many-r> summary
    drop
    "Quotation pops retain stack elements which it did not push" ;

M: missing-effect error.
    "The word " write
    word>> pprint
    " must declare a stack effect" print ;

M: effect-error error.
    "Stack effects of the word " write
    [ word>> pprint " do not match." print ]
    [ "Inferred: " write inferred>> . ]
    [ "Declared: " write declared>> . ] tri ;

M: recursive-quotation-error error.
    "The quotation " write
    quot>> pprint
    " calls itself." print
    "Stack effect inference is undecidable when quotation-level recursion is permitted." print ;

M: undeclared-recursion-error error.
    "The inline recursive word " write
    word>> pprint
    " must be declared recursive" print ;

M: diverging-recursion-error error.
    "The recursive word " write
    word>> pprint
    " digs arbitrarily deep into the stack" print ;

M: unbalanced-recursion-error error.
    "The recursive word " write
    word>> pprint
    " leaves with the stack having the wrong height" print ;

M: inconsistent-recursive-call-error error.
    "The recursive word " write
    word>> pprint
    " calls itself with a different set of quotation parameters than were input" print ;

M: unknown-primitive-error error.
    drop
    "Cannot determine stack effect statically" print ;

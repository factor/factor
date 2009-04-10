! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel prettyprint io debugger
sequences assocs stack-checker.errors summary effects make ;
IN: stack-checker.errors.prettyprint

M: inference-error summary error>> summary ;

M: inference-error error-help error>> error-help ;

M: inference-error error.
    [ word>> [ "In word: " write . ] when* ] [ error>> error. ] bi ;

M: literal-expected summary
    [ "Got a computed value where a " % what>> % " was expected" % ] "" make ;

M: literal-expected error. summary print ;

M: unbalanced-branches-error summary
    drop "Unbalanced branches" ;

M: unbalanced-branches-error error.
    dup summary print
    [ quots>> ] [ branches>> [ length <effect> ] { } assoc>map ] bi zip
    [ [ first pprint-short bl ] [ second effect>string print ] bi ] each ;

M: too-many->r summary
    drop
    "Quotation pushes elements on retain stack without popping them" ;

M: too-many-r> summary
    drop
    "Quotation pops retain stack elements which it did not push" ;

M: missing-effect summary
    [
        "The word " %
        word>> name>> %
        " must declare a stack effect" %
    ] "" make ;

M: effect-error summary
    [
        "Stack effect declaration of the word " %
        word>> name>> % " is wrong" %
    ] "" make ;

M: recursive-quotation-error error.
    "The quotation " write
    quot>> pprint
    " calls itself." print
    "Stack effect inference is undecidable when quotation-level recursion is permitted." print ;

M: undeclared-recursion-error summary
    drop
    "Inline recursive words must be declared recursive" ;

M: diverging-recursion-error summary
    [
        "The recursive word " %
        word>> name>> %
        " digs arbitrarily deep into the stack" %
    ] "" make ;

M: unbalanced-recursion-error summary
    [
        "The recursive word " %
        word>> name>> %
        " leaves with the stack having the wrong height" %
    ] "" make ;

M: inconsistent-recursive-call-error summary
    [
        "The recursive word " %
        word>> name>> %
        " calls itself with a different set of quotation parameters than were input" %
    ] "" make ;

M: unknown-primitive-error summary
    drop
    "Cannot determine stack effect statically" ;

M: transform-expansion-error summary
    drop
    "Compiler transform threw an error" ;

M: transform-expansion-error error.
    [ summary print ]
    [ "Word: " write word>> . nl ]
    [ error>> error. ] tri ;
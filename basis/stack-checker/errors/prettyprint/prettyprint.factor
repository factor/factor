! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays debugger io kernel prettyprint sequences
stack-checker.errors summary ;

M: unknown-macro-input summary
    macro>> name>> "Cannot apply '" "' to an input parameter of a non-inline word" surround ;

M: bad-macro-input summary
    macro>> name>> "Cannot apply '" "' to a run-time computed value" surround ;

M: too-many->r summary
    drop "Quotation pushes elements on retain stack without popping them" ;

M: too-many-r> summary
    drop "Quotation pops retain stack elements which it did not push" ;

M: missing-effect summary
    drop "Missing stack effect declaration" ;

M: effect-error summary
    drop "Stack effect declaration is wrong" ;

M: recursive-quotation-error summary
    drop "Recursive quotation" ;

M: undeclared-recursion-error summary
    word>> name>>
    "The inline recursive word '" "' must be declared recursive" surround ;

M: diverging-recursion-error summary
    word>> name>>
    "The recursive word '" "' digs arbitrarily deep into the stack" surround ;

M: unbalanced-recursion-error summary
    word>> name>>
    "The recursive word '" "' leaves with the stack having the wrong height" surround ;

M: inconsistent-recursive-call-error summary
    word>> name>>
    "The recursive word '"
    "' calls itself with a different set of quotation parameters than were input" surround ;

M: transform-expansion-error summary
    word>> name>> "Macro expansion of '" "' threw an error" surround ;

M: transform-expansion-error error.
    [ summary print ]
    [ nl "The error was:" print error>> error. nl ]
    [ continuation>> traceback-link. ]
    tri ;

M: do-not-compile summary
    word>> name>> "Cannot compile call to '" "'" surround ;

M: unbalanced-branches-error summary
    [ word>> name>> ] [ quots>> length 1 = ] bi
    [ "The input quotation to '" "' doesn't match its expected effect" ]
    [ "The input quotations to '" "' do not all leave the stack at the same height" ] if
    surround ;

M: unbalanced-branches-error error.
    dup summary print nl
    "For more information, evaluate:" print
    "    \"inference-branches\" help" print nl
    [ quots>> ] [ declareds>> ] [ actuals>> ] tri 3array flip
    { "Input" "Expected" "Got" } prefix simple-table. ;

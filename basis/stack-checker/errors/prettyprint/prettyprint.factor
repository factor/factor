! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel prettyprint io debugger
sequences assocs stack-checker.errors summary effects ;
IN: stack-checker.errors.prettyprint

M: literal-expected summary
    what>> "Got a computed value where a " " was expected" surround ;

M: literal-expected error. summary print ;

M: unbalanced-branches-error summary
    drop "Unbalanced branches" ;

M: unbalanced-branches-error error.
    dup summary print
    [ quots>> ] [ branches>> [ length <effect> ] { } assoc>map ] bi zip
    [ [ first pprint-short bl ] [ second effect>string print ] bi ] each ;

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
    "The inline recursive word " " must be declared recursive" surround ;

M: diverging-recursion-error summary
    word>> name>>
    "The recursive word " " digs arbitrarily deep into the stack" surround ;

M: unbalanced-recursion-error summary
    word>> name>>
    "The recursive word " " leaves with the stack having the wrong height" surround ;

M: inconsistent-recursive-call-error summary
    word>> name>>
    "The recursive word "
    " calls itself with a different set of quotation parameters than were input" surround ;

M: unknown-primitive-error summary
    word>> name>> "The " " word cannot be called from optimized words" surround ;

M: transform-expansion-error summary
    word>> name>> "Macro expansion of " " threw an error" surround ;

M: transform-expansion-error error.
    [ summary print ] [ error>> error. ] bi ;

M: do-not-compile summary
    word>> name>> "Cannot compile call to " prepend ;
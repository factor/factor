! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays compiler.units kernel stack-checker
sequences vocabs words tools.test tools.test.private ;
IN: compiler.test

: decompile ( word -- )
    dup def>> 2array 1array modify-code-heap ;

: recompile-all ( -- )
    all-words compile ;

: compile-call ( quot -- )
    [ dup infer define-temp ] with-compilation-unit execute ;

<< \ compile-call t "no-compile" set-word-prop >>

: compiler-test ( name -- )
    "resource:basis/compiler/tests/" ".factor" surround run-test-file ;

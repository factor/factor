! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays compiler.cfg compiler.units kernel sequences
stack-checker tools.test vocabs words ;
IN: compiler.test

: decompile ( word -- )
    dup def>> 2array 1array t t modify-code-heap ;

: recompile-all ( -- )
    all-words compile ;

: compile-call ( quot -- )
    [ dup infer define-temp ] with-compilation-unit execute ;

<< \ compile-call t "no-compile" set-word-prop >>

: compiler-test ( name -- )
    "resource:basis/compiler/tests/" ".factor" surround run-test-file ;

USING: compiler.cfg.registers compiler.cfg.stacks compiler.cfg.stacks.local
fry namespaces ;

: init-cfg-test ( -- )
    reset-vreg-counter begin-stack-analysis
    <basic-block> dup basic-block set begin-local-analysis
    H{ } clone replaces set ;

: cfg-unit-test ( result quot -- )
    '[ init-cfg-test @ ] unit-test ; inline

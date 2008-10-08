! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words sequences quotations namespaces io
accessors prettyprint prettyprint.config
compiler.tree.builder compiler.tree.optimizer
compiler.cfg.builder compiler.cfg.linearization
compiler.cfg.stack-frame ;
IN: compiler.cfg.debugger

GENERIC: test-cfg ( quot -- cfgs )

M: callable test-cfg
    build-tree optimize-tree gensym build-cfg ;

M: word test-cfg
    [ build-tree-from-word nip optimize-tree ] keep build-cfg ;

: test-mr ( quot -- mrs )
    test-cfg [ build-mr build-stack-frame ] map ;

: mr. ( mrs -- )
    [
        boa-tuples? on
        "=== word: " write
        dup word>> pprint
        ", label: " write
        dup label>> pprint nl nl
        instructions>> .
        nl
    ] each ;

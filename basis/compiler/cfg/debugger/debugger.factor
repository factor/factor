! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words sequences quotations namespaces io
classes.tuple accessors prettyprint prettyprint.config
compiler.tree.builder compiler.tree.optimizer
compiler.cfg.builder compiler.cfg.linearization
compiler.cfg.stack-frame compiler.cfg.linear-scan ;
IN: compiler.cfg.debugger

GENERIC: test-cfg ( quot -- cfgs )

M: callable test-cfg
    build-tree optimize-tree gensym build-cfg ;

M: word test-cfg
    [ build-tree-from-word nip optimize-tree ] keep build-cfg ;

SYMBOL: allocate-registers?

: test-mr ( quot -- mrs )
    test-cfg [
        build-mr
        allocate-registers? get
        [ linear-scan build-stack-frame ] when
    ] map ;

: insn. ( insn -- )
    tuple>array allocate-registers? get [ but-last ] unless
    [ pprint bl ] each nl ;

: mr. ( mrs -- )
    [
        "=== word: " write
        dup word>> pprint
        ", label: " write
        dup label>> pprint nl nl
        instructions>> [ insn. ] each
        nl
    ] each ;

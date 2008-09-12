! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces sequences assocs io
prettyprint inference generator optimizer
compiler.vops
compiler.tree.builder
compiler.tree.optimizer
compiler.cfg.builder
compiler.cfg.simplifier
compiler.machine.builder
compiler.machine.simplifier ;
IN: compiler.machine.debugger

: tree>linear ( tree word -- linear )
    [
        init-counter
        build-cfg
        [ simplify-cfg build-mr simplify-mr ] assoc-map
    ] with-scope ;

: linear. ( linear -- )
    [
        "==== " write swap .
        [ . ] each
    ] assoc-each ;

: linearized-quot. ( quot -- )
    build-tree optimize-tree
    "Anonymous quotation" tree>linear
    linear. ;

: linearized-word. ( word -- )
    dup build-tree-from-word nip optimize-tree
    dup word-dataflow nip optimize swap tree>linear linear. ;

: >basic-block ( quot -- basic-block )
    build-tree optimize-tree
    [
        init-counter
        "Anonymous quotation" build-cfg
        >alist first second simplify-cfg
    ] with-scope ;

: basic-block. ( basic-block -- )
    instructions>> [ . ] each ;

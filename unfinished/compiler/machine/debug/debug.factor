! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces sequences assocs io
prettyprint inference generator optimizer compiler.vops
compiler.cfg.builder compiler.cfg.simplifier
compiler.machine.builder compiler.machine.simplifier ;
IN: compiler.machine.debug

: dataflow>linear ( dataflow word -- linear )
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
    dataflow optimize
    "Anonymous quotation" dataflow>linear
    linear. ;

: linearized-word. ( word -- )
    dup word-dataflow nip optimize swap dataflow>linear linear. ;

: >basic-block ( quot -- basic-block )
    dataflow optimize
    [
        init-counter
        "Anonymous quotation" build-cfg
        >alist first second simplify-cfg
    ] with-scope ;

: basic-block. ( basic-block -- )
    instructions>> [ . ] each ;

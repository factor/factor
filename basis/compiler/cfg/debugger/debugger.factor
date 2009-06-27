! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words sequences quotations namespaces io vectors
classes.tuple accessors prettyprint prettyprint.config
prettyprint.backend prettyprint.custom prettyprint.sections
parser compiler.tree.builder compiler.tree.optimizer
compiler.cfg.builder compiler.cfg.linearization
compiler.cfg.registers compiler.cfg.stack-frame
compiler.cfg.linear-scan compiler.cfg.two-operand
compiler.cfg.liveness compiler.cfg.optimizer
compiler.cfg.mr compiler.cfg ;
IN: compiler.cfg.debugger

GENERIC: test-cfg ( quot -- cfgs )

M: callable test-cfg
    build-tree optimize-tree gensym build-cfg ;

M: word test-cfg
    [ build-tree optimize-tree ] keep build-cfg ;

: test-mr ( quot -- mrs )
    test-cfg [
        optimize-cfg
        build-mr
    ] map ;

: insn. ( insn -- )
    tuple>array [ pprint bl ] each nl ;

: mr. ( mrs -- )
    [
        "=== word: " write
        dup word>> pprint
        ", label: " write
        dup label>> pprint nl nl
        instructions>> [ insn. ] each
        nl
    ] each ;

! Prettyprinting
M: vreg pprint*
    <block
    \ V pprint-word [ reg-class>> pprint* ] [ n>> pprint* ] bi
    block> ;

: pprint-loc ( loc word -- ) <block pprint-word n>> pprint* block> ;

M: ds-loc pprint* \ D pprint-loc ;

M: rs-loc pprint* \ R pprint-loc ;

: test-bb ( insns n -- )
    [ <basic-block> swap >>number swap >>instructions ] keep set ;

: test-diamond ( -- )
    1 get 1vector 0 get (>>successors)
    2 get 3 get V{ } 2sequence 1 get (>>successors)
    4 get 1vector 2 get (>>successors)
    4 get 1vector 3 get (>>successors) ;
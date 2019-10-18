USING: accessors assocs compiler.cfg.dataflow-analysis
compiler.cfg.dataflow-analysis.private compiler.cfg.rpo compiler.cfg.utilities
kernel tools.test ;
IN: compiler.cfg.dataflow-analysis.tests

! run-dataflow-analysis
TUPLE: im-a-dfa test ;

M: im-a-dfa block-order ( cfg dfa -- bbs )
    drop post-order ;

M: im-a-dfa ignore-block? ( cfg bb -- ? )
    2drop f ;

M: im-a-dfa predecessors ( bb dfa -- seq )
    drop predecessors>> ;

M: im-a-dfa successors ( bb dfa -- seq )
    drop successors>> ;

M: im-a-dfa join-sets ( sets bb dfa -- set )
    2drop ;

M: im-a-dfa transfer-set ( in-set bb dfa -- out-set )
    2drop ;

{ { V{ } } { V{ } } } [
    { } 0 insns>block block>cfg 10 im-a-dfa boa run-dataflow-analysis
    [ values ] bi@
] unit-test

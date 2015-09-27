USING: accessors compiler.cfg.utilities kernel sequences tools.test ;
IN: compiler.cfg.utilities.tests


{ "eh" "eh" 1 2 } [
    V{ } clone 1 insns>block V{ } clone 2 insns>block
    2dup connect-bbs 2dup V{ "eh" } insert-basic-block
    [
        [ successors>> ] [ predecessors>> ] bi*
        [ first instructions>> first ] bi@
    ] keep
    predecessors>> first [ predecessors>> ] [ successors>> ] bi
    [ first number>> ] bi@
] unit-test

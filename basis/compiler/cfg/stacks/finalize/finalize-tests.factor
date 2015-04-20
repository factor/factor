USING: accessors compiler.cfg.instructions compiler.cfg.stacks.finalize
compiler.cfg.utilities kernel sequences tools.test ;
IN: compiler.cfg.stacks.finalize.tests

{
    T{ ##branch f f }
    T{ ##branch f f }
} [
    V{ } clone 1 insns>block V{ } clone 2 insns>block
    2dup connect-bbs 2dup visit-edge
    [ successors>> first instructions>> first ]
    [ predecessors>> first instructions>> first ] bi*
] unit-test

USING: accessors compiler.cfg compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks
compiler.cfg.stacks.finalize compiler.cfg.stacks.local
compiler.cfg.utilities kernel sequences tools.test ;
IN: compiler.cfg.stacks.finalize.tests

{
    "there" "hi"
} [
    V{ "hi" } clone 1 insns>block V{ "there" } clone 2 insns>block
    2dup connect-bbs 2dup visit-edge
    [ successors>> first instructions>> first ]
    [ predecessors>> first instructions>> first ] bi*
] unit-test

{
    T{ ds-loc f 4 }
    T{ rs-loc f 5 }
} [
    begin-stack-analysis
    3 4 T{ basic-block }
    [ record-stack-heights ]
    [ D: 1 swap local-loc>global ]
    [ R: 1 swap local-loc>global ] tri
] unit-test

USING: accessors compiler.cfg compiler.cfg.builder.blocks
compiler.cfg.instructions compiler.cfg.stacks.local
compiler.cfg.utilities compiler.test kernel make namespaces sequences
tools.test ;
IN: compiler.cfg.builder.blocks.tests

! (begin-basic-block)
{ 20 } [
    { } 20 insns>block (begin-basic-block)
    predecessors>> first number>>
] cfg-unit-test

! begin-branch
{ f } [
    height-state get <basic-block> begin-branch drop height-state get eq?
] cfg-unit-test

{ f } [
    <basic-block> dup begin-branch eq?
] cfg-unit-test

! emit-call-block
{
    V{ T{ ##call { word 2drop } } }
    T{ height-state f 0 0 -2 0 }
} [
    \ 2drop -2 <basic-block> [ emit-call-block ] V{ } make
    height-state get
] cfg-unit-test

! emit-trivial-block
{
    V{ T{ ##no-tco } T{ ##branch } }
} [
    <basic-block> dup set-basic-block
    [ drop ##no-tco, ] emit-trivial-block
    predecessors>> first instructions>>
] cfg-unit-test

! end-basic-block
{ } [
    <basic-block> dup set-basic-block ##branch, end-basic-block
] unit-test

{
    { "succ" "succ" "succ" }
} [
    3 [ <basic-block> ] replicate <basic-block> "succ" >>number
    dupd connect-Nto1-bbs [ successors>> first number>> ] map
] unit-test

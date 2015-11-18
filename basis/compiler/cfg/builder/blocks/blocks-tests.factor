USING: accessors compiler.cfg compiler.cfg.builder.blocks
compiler.cfg.stacks.local compiler.cfg.utilities compiler.test kernel
namespaces sequences tools.test ;
IN: compiler.cfg.builder.blocks.tests

! (begin-basic-block)
{ 20 } [
    { } 20 insns>block (begin-basic-block)
    basic-block get predecessors>> first number>>
] cfg-unit-test

! begin-branch
{ f } [
    height-state get <basic-block> begin-branch height-state get eq?
] cfg-unit-test

! make-kill-block
{ t } [
    <basic-block> [ make-kill-block ] keep kill-block?>>
] unit-test

{
    { "succ" "succ" "succ" }
} [
    3 [ <basic-block> ] replicate <basic-block> "succ" >>number
    dupd connect-Nto1-bbs [ successors>> first number>> ] map
] unit-test

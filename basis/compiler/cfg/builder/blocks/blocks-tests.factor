USING: accessors compiler.cfg compiler.cfg.builder.blocks compiler.cfg.stacks
kernel namespaces sequences tools.test ;
IN: compiler.cfg.builder.blocks.tests

{
    { "succ" "succ" "succ" }
} [
    <basic-block> "succ" >>number 3 [ <basic-block> ] replicate
    [ set-successors ] keep
    [ successors>> first number>> ] map
] unit-test

{ 33 } [
    begin-stack-analysis <basic-block> 33 >>number basic-block set
    (begin-basic-block)
    basic-block get predecessors>> first number>>
] unit-test

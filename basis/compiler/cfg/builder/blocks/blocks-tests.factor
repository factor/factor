USING: accessors compiler.cfg compiler.cfg.builder.blocks kernel sequences
tools.test ;
IN: compiler.cfg.builder.blocks.tests

{
    { "succ" "succ" "succ" }
} [
    <basic-block> "succ" >>number 3 [ <basic-block> ] replicate
    [ set-successors ] keep
    [ successors>> first number>> ] map
] unit-test

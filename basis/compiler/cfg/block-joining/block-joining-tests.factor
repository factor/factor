USING: accessors compiler.cfg.block-joining compiler.cfg.utilities
kernel tools.test ;
IN: compiler.cfg.block-joining.tests

{
    V{ "hello" "there" "B" }
} [
    { "there" "B" } 0 insns>block
    { "hello" "B" } 1 insns>block
    [ join-instructions ] keep instructions>>
] unit-test

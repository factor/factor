USING: accessors arrays assocs combinators compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local kernel literals namespaces
tools.test ;
IN: compiler.cfg.stacks.tests

: test-init ( -- )
    0 vreg-counter set-global
    initial-height-state height-state set
    H{ } clone replace-mapping set
    H{ } clone locs>vregs set
    H{ } clone local-peek-set set ;

{
    H{ { D 1 4 } { D 2 3 } { D 0 5 } }
    { { 0 0 } { 0 0 } }
} [
    test-init
    { 3 4 5 } ds-loc store-vregs
    replace-mapping get
    height-state get
] unit-test

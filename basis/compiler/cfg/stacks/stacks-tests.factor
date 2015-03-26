USING: accessors arrays assocs combinators compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local compiler.test kernel literals
namespaces tools.test ;
IN: compiler.cfg.stacks.tests

{
    H{ { D 1 4 } { D 2 3 } { D 0 5 } }
    { { 0 0 } { 0 0 } }
} [
    { 3 4 5 } ds-loc store-vregs
    replace-mapping get
    height-state get
] cfg-unit-test

! load-vregs
{
    { 1 2 3 4 5 6 7 8 }
} [
    8 ds-loc load-vregs
] cfg-unit-test

! 2inputs
{
    1
    2
    { { -2 -2 } { 0 0 } }
} [
    2inputs height-state get
] cfg-unit-test

USING: accessors arrays assocs combinators compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local compiler.test kernel literals
namespaces tools.test ;
IN: compiler.cfg.stacks.tests

! store-vregs
{
    H{ { D: 1 4 } { D: 2 3 } { D: 0 5 } }
    T{ height-state f 0 0 0 0 }
} [
    { 3 4 5 } ds-loc store-vregs
    replaces get
    height-state get
] cfg-unit-test

! stack-locs
{ { D: 4 D: 3 D: 2 D: 1 D: 0 } } [
    ds-loc 5 stack-locs >array
] unit-test

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
    T{ height-state f 0 0 -2 0 }
} [
    2inputs height-state get
] cfg-unit-test

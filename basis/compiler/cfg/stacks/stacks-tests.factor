USING: accessors arrays assocs combinators compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local compiler.test kernel literals
namespaces tools.test ;
IN: compiler.cfg.stacks.tests

! store-vregs
{
    H{ { d: 1 4 } { d: 2 3 } { d: 0 5 } }
    T{ height-state f 0 0 0 0 }
} [
    { 3 4 5 } ds-loc store-vregs
    replaces get
    height-state get
] cfg-unit-test

! stack-locs
{ { d: 4 d: 3 d: 2 d: 1 d: 0 } } [
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

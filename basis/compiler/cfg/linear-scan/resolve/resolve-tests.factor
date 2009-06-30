USING: accessors arrays classes compiler.cfg
compiler.cfg.debugger compiler.cfg.instructions
compiler.cfg.linear-scan.debugger
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.resolve compiler.cfg.predecessors
compiler.cfg.registers compiler.cfg.rpo cpu.architecture kernel
namespaces tools.test vectors ;
IN: compiler.cfg.linear-scan.resolve.tests

[ { 1 2 3 4 5 6 } ] [
    { 3 4 } V{ 1 2 } clone [ { 5 6 } 3append-here ] keep >array
] unit-test

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##replace f V int-regs 0 D 1 }
    T{ ##return }
} 1 test-bb

1 get 1vector 0 get (>>successors)

cfg new 0 get >>entry
compute-predecessors
dup reverse-post-order number-instructions
drop

CONSTANT: test-live-interval-1
T{ live-interval
   { start 0 }
   { end 6 }
   { uses V{ 0 6 } }
   { ranges V{ T{ live-range f 0 2 } T{ live-range f 4 6 } } }
   { spill-to 0 }
   { vreg V int-regs 0 }
}

[ f ] [
    0 get test-live-interval-1 spill-to
] unit-test

[ 0 ] [
    1 get test-live-interval-1 spill-to
] unit-test

CONSTANT: test-live-interval-2
T{ live-interval
   { start 0 }
   { end 6 }
   { uses V{ 0 6 } }
   { ranges V{ T{ live-range f 0 2 } T{ live-range f 4 6 } } }
   { reload-from 0 }
   { vreg V int-regs 0 }
}

[ 0 ] [
    0 get test-live-interval-2 reload-from
] unit-test

[ f ] [
    1 get test-live-interval-2 reload-from
] unit-test

[
    {
        T{ _copy { dst 5 } { src 4 } { class int-regs } }
        T{ _spill { src 0 } { class int-regs } { n spill-temp } }
        T{ _copy { dst 0 } { src 1 } { class int-regs } }
        T{ _reload { dst 1 } { class int-regs } { n spill-temp } }
        T{ _spill { src 0 } { class float-regs } { n spill-temp } }
        T{ _copy { dst 0 } { src 1 } { class float-regs } }
        T{ _reload { dst 1 } { class float-regs } { n spill-temp } }
    }
] [
    {
        T{ register->register { from 0 } { to 1 } { reg-class int-regs } }
        T{ register->register { from 1 } { to 0 } { reg-class int-regs } }
        T{ register->register { from 0 } { to 1 } { reg-class float-regs } }
        T{ register->register { from 1 } { to 0 } { reg-class float-regs } }
        T{ register->register { from 4 } { to 5 } { reg-class int-regs } }
    } mapping-instructions
] unit-test

[
    {
        T{ _spill { src 0 } { class int-regs } { n spill-temp } }
        T{ _copy { dst 0 } { src 2 } { class int-regs } }
        T{ _copy { dst 2 } { src 1 } { class int-regs } }
        T{ _reload { dst 1 } { class int-regs } { n spill-temp } }
    }
] [
    {
        T{ register->register { from 0 } { to 1 } { reg-class int-regs } }
        T{ register->register { from 1 } { to 2 } { reg-class int-regs } }
        T{ register->register { from 2 } { to 0 } { reg-class int-regs } }
    } mapping-instructions
] unit-test

[
    {
        T{ _spill { src 0 } { class int-regs } { n spill-temp } }
        T{ _copy { dst 0 } { src 2 } { class int-regs } }
        T{ _copy { dst 2 } { src 1 } { class int-regs } }
        T{ _reload { dst 1 } { class int-regs } { n spill-temp } }
    }
] [
    {
        T{ register->register { from 1 } { to 2 } { reg-class int-regs } }
        T{ register->register { from 2 } { to 0 } { reg-class int-regs } }
        T{ register->register { from 0 } { to 1 } { reg-class int-regs } }
    } mapping-instructions
] unit-test

[
    {
        T{ _copy { dst 1 } { src 0 } { class int-regs } }
        T{ _copy { dst 2 } { src 0 } { class int-regs } }
    }
] [
    {
        T{ register->register { from 0 } { to 1 } { reg-class int-regs } }
        T{ register->register { from 0 } { to 2 } { reg-class int-regs } }
    } mapping-instructions
] unit-test

[
    { }
] [
    {
       T{ register->register { from 4 } { to 4 } { reg-class int-regs } }
    } mapping-instructions
] unit-test

[
    { T{ _spill { src 4 } { class int-regs } { n spill-temp } } }
] [
    {
       T{ register->memory { from 4 } { to 4 } { reg-class int-regs } }
    } mapping-instructions
] unit-test


[
    {
        T{ _copy { dst 1 } { src 0 } { class int-regs } }
        T{ _copy { dst 2 } { src 0 } { class int-regs } }
        T{ _copy { dst 0 } { src 3 } { class int-regs } }
    }
] [
    {
        T{ register->register { from 0 } { to 1 } { reg-class int-regs } }
        T{ register->register { from 3 } { to 0 } { reg-class int-regs } }
        T{ register->register { from 0 } { to 2 } { reg-class int-regs } }
    } mapping-instructions
] unit-test

[
    {
        T{ _copy { dst 1 } { src 0 } { class int-regs } }
        T{ _copy { dst 2 } { src 0 } { class int-regs } }
        T{ _spill { src 3 } { class int-regs } { n spill-temp } }
        T{ _copy { dst 4 } { src 0 } { class int-regs } }
        T{ _copy { dst 3 } { src 4 } { class int-regs } }
        T{ _reload { dst 0 } { class int-regs } { n spill-temp } }
    }
] [
    {
        T{ register->register { from 0 } { to 1 } { reg-class int-regs } }
        T{ register->register { from 0 } { to 2 } { reg-class int-regs } }
        T{ register->register { from 3 } { to 0 } { reg-class int-regs } }
        T{ register->register { from 4 } { to 3 } { reg-class int-regs } }
        T{ register->register { from 0 } { to 4 } { reg-class int-regs } }
    } mapping-instructions
] unit-test

[
    {
        T{ _copy { dst 2 } { src 0 } { class int-regs } }
        T{ _copy { dst 9 } { src 1 } { class int-regs } }
        T{ _copy { dst 1 } { src 0 } { class int-regs } }
        T{ _spill { src 3 } { class int-regs } { n spill-temp } }
        T{ _copy { dst 4 } { src 0 } { class int-regs } }
        T{ _copy { dst 3 } { src 4 } { class int-regs } }
        T{ _reload { dst 0 } { class int-regs } { n spill-temp } }
    }
] [
    {
        T{ register->register { from 0 } { to 1 } { reg-class int-regs } }
        T{ register->register { from 0 } { to 2 } { reg-class int-regs } }
        T{ register->register { from 1 } { to 9 } { reg-class int-regs } }
        T{ register->register { from 3 } { to 0 } { reg-class int-regs } }
        T{ register->register { from 4 } { to 3 } { reg-class int-regs } }
        T{ register->register { from 0 } { to 4 } { reg-class int-regs } }
    } mapping-instructions
] unit-test

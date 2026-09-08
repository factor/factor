USING: accessors assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.metrics compiler.cfg.optimizer compiler.cfg.utilities
kernel kernel.private math sequences tools.test words ;
IN: compiler.cfg.metrics.tests

{ t } [ \ optimize-cfg pass-list empty? not ] unit-test
[ \ + pass-list ] [ unrecognized-pass-pipeline? ] must-fail-with

! Instruction counts are independent of the allocator's own accounting.
{ 1 2 1 } [
    V{ T{ ##spill } T{ ##reload } T{ ##reload } T{ ##copy }
       T{ ##branch } } insns>cfg cfg-metrics
    [ "spills" of ] [ "reloads" of ] [ "copies" of ] tri
] unit-test

! Exercise the actual compiler pipeline through code generation.
{ t t t } [
    [ + ] measure-compilation
    [ "frontend-nanoseconds" of 0 >= ]
    [ "procedures" of first
      [ "code-bytes" of 0 > ]
      [ "passes" of last "pass" of "build-stack-frame" = ] bi ] bi
] unit-test

! Independent runs must not reuse the previous CFG's allocator state.
{ t } [
    [ { fixnum fixnum } declare + ] measure-compilation
    [ { fixnum fixnum } declare + ] measure-compilation
    [ "procedures" of [ "code-bytes" of ] map ] bi@ =
] unit-test

USING: accessors assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.metrics compiler.cfg.optimizer compiler.cfg.utilities
compiler.cfg.register-allocation kernel kernel.private math
namespaces sequences tools.test words ;
IN: compiler.cfg.metrics.tests

{ t } [ \ optimize-cfg pass-list empty? not ] unit-test
[ \ + pass-list ] [ unrecognized-pass-pipeline? ] must-fail-with

! Instruction counts are independent of the allocator's own accounting.
{ 1 2 1 } [
    V{ T{ ##spill } T{ ##reload } T{ ##reload } T{ ##copy }
       T{ ##branch } } insns>cfg cfg-metrics
    [ "spills" of ] [ "reloads" of ] [ "copies" of ] tri
] unit-test

SINGLETON: delegated-allocator
SYMBOL: measured-cfgs

M: delegated-allocator allocate-cfg
    drop dup measured-cfgs get push linear-scan-allocator allocate-cfg ;

M: delegated-allocator allocator-statistics
    drop H{ { "test-diagnostic" t } } clone ;

! A third-party allocator runs in the actual finalization pipeline. Each
! comparison gets a fresh CFG and leaves the caller's selection unchanged.
{ t t t t } [
    V{ } clone measured-cfgs [
        f register-allocator [
            [ { fixnum fixnum } declare + ]
            { delegated-allocator delegated-allocator } compare-allocators
            [ [
                [ "allocator" of "delegated-allocator" = ]
                [ "procedures" of first "allocation" of
                  "test-diagnostic" of ] bi and
              ] all? ]
            [ [ "procedures" of first "code-bytes" of ] map
              first2 = ] bi
            measured-cfgs get first2 eq? not
            current-register-allocator linear-scan-allocator eq?
        ] with-variable
    ] with-variable
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

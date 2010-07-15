USING: compiler.cfg.scheduling compiler.cfg.instructions
vocabs.loader namespaces tools.test arrays kernel ;
IN: compiler.cfg.scheduling.tests

! Recompile compiler.cfg.scheduling with extra tests,
! and see if any errors come up. Back when there were
! errors of this kind, they always surfaced this way.

t check-scheduling? [
    [ ] [ "compiler.cfg.scheduling" reload ] unit-test
    [ ] [ "compiler.cfg.dependence" reload ] unit-test
] with-variable

[
    { }
    { }
    { T{ ##test-branch } }
] [
    V{ T{ ##test-branch } }
    split-3-ways
    [ >array ] tri@
] unit-test

[
    { T{ ##inc-d } T{ ##inc-r } T{ ##callback-inputs } }
    { T{ ##add } T{ ##sub } T{ ##mul } }
    { T{ ##test-branch } }
] [
    V{
        T{ ##inc-d }
        T{ ##inc-r }
        T{ ##callback-inputs }
        T{ ##add }
        T{ ##sub }
        T{ ##mul }
        T{ ##test-branch }
    }
    split-3-ways
    [ >array ] tri@
] unit-test

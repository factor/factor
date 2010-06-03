USING: compiler.cfg.scheduling vocabs.loader namespaces tools.test ;
IN: compiler.cfg.scheduling.tests

! Recompile compiler.cfg.scheduling with extra tests,
! and see if any errors come up. Back when there were
! errors of this kind, they always surfaced this way.

t check-scheduling? [
    [ ] [ "compiler.cfg.scheduling" reload ] unit-test
    [ ] [ "compiler.cfg.dependence" reload ] unit-test
] with-variable

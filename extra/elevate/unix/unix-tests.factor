USING: elevate elevate.unix generic kernel system tools.test ;
IN: elevate.unix.tests

! FreeBSD uses the shared Unix implementation without a dedicated backend.
{ t } [
    freebsd \ elevated method-for-class M\ unix elevated eq?
] unit-test

{ t } [
    freebsd \ lowered method-for-class M\ unix lowered eq?
] unit-test

{ t } [
    freebsd \ already-root? method-for-class M\ unix already-root? eq?
] unit-test

USING: bootstrap.compat.arm64 kernel kernel.private tools.test ;
IN: bootstrap.compat.arm64.tests

! Requiring the compatibility vocabulary leaves current seeds untouched,
! and upgrades an old ARM64 seed before these checks run.
{ f } [ needs-arm64-callback-upgrade? ] unit-test
{ t } [
    CALLBACK-STUB special-object
    upgrade-arm64-callbacks
    CALLBACK-STUB special-object eq?
] unit-test

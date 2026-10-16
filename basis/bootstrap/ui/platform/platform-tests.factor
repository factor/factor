USING: arrays bootstrap.ui.platform kernel namespaces parser sequences
system tools.test ;
IN: bootstrap.ui.platform.tests

! Cold bootstrapping cannot repair a missing import with parser restarts.
{ } [
    f auto-use? [
        "resource:basis/bootstrap/ui/ui.factor" parse-file drop
    ] with-variable
] unit-test

{ { "ui.backend.gtk4" "ui.backend.gtk4" "ui.backend.gtk4" "ui.backend.gtk4" } } [
    { x86.64 arm.32 ppc.64le riscv.64 }
    [ linux swap default-ui-backend ] map
] unit-test

! GTK4 rejects these CPUs before any native GTK library is loaded.
{ { "ui.backend.gtk3" "ui.backend.gtk3" "ui.backend.gtk3"
    "ui.backend.gtk3" "ui.backend.gtk3" "ui.backend.gtk3" } } [
    { x86.32 riscv.32 mips.64 m68k.32 sparc.32 sparc.64 }
    [ linux swap default-ui-backend ] map
] unit-test

{ "ui.backend.gtk3" "ui.backend.gtk2" "ui.backend.cocoa" "ui.backend.windows" } [
    freebsd ppc.64 default-ui-backend
    netbsd m68k.32 default-ui-backend
    macos arm.64 default-ui-backend
    windows x86.64 default-ui-backend
] unit-test

{ { "ui.backend.gtk3" "ui.backend.gtk3" } } [
    { x86.64 arm.64 } [ haiku swap default-ui-backend ] map
] unit-test

{ { "ui.backend.android" "ui.backend.android" } } [
    { arm.64 x86.64 } [ android swap default-ui-backend ] map
] unit-test

! Regression: choosing a GTK vocab is insufficient unless its native backend
! registration covers that target. These are the exact predicates used by the
! GTK2/GTK3 registration sites, including the formerly omitted systems.
{ { t t t t t t } } [
    { { haiku arm.64 } { freebsd ppc.64 } { netbsd x86.64 }
      { openbsd arm.64 } { dragonflybsd x86.64 } { linux x86.32 } }
    [
        dup first swap first2 default-ui-backend
        "ui.backend.gtk2" =
        [ gtk2-backend-platform? ] [ gtk3-backend-platform? ] if
    ] map
] unit-test

{ { t t t t } } [
    { netbsd openbsd dragonflybsd freebsd }
    [ gtk2-backend-platform? ] map
] unit-test

{ { t t t } } [
    { haiku freebsd linux } [ gtk3-backend-platform? ] map
] unit-test

! Keep the established Linux/FreeBSD paths and reject unrelated OS backends.
{ { t t } { f f f } { f f f } } [
    { linux freebsd } [ gtk2-backend-platform? ] map
    { haiku macos windows } [ gtk2-backend-platform? ] map
    { netbsd openbsd dragonflybsd } [ gtk3-backend-platform? ] map
] unit-test

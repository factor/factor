USING: accessors alien.accessors alien.c-types alien.data continuations
game.input game.input.dinput kernel locals namespaces system
tools.test windows.ole32 windows.types ;
IN: game.input.dinput.tests

! DirectInput enumeration uses a BOOL-sized native result and stops once
! it finds an attached pointer device.
{ 0 1 } [
    0 BOOL <ref> dup [ f swap (mark-attached-device) ] dip BOOL deref
] unit-test

! Exercise real enumeration without opening a window or acquiring devices.
{ t } [
    create-dinput [ mouse-present? boolean? ] [ delete-dinput ] finally
] unit-test

! A machine with no mouse still supports reads, resets and cleanup.
{ f f f f } [
    f (find-mouse)
    read-mouse
    reset-mouse
    release-mouse
    +mouse-device+ get-global
    +mouse-state+ get-global
    +mouse-buffer+ get-global
] unit-test

USING: accessors alien alien.accessors alien.c-types classes.struct
kernel layouts locals math tools.test unix.time unix.types ;
IN: unix.types.macos.tests

! Darwin's timeval uses long seconds and signed 32-bit microseconds.
{ 4 } [ suseconds_t heap-size ] unit-test
{ t } [ suseconds_t c-type-signed ] unit-test
{ t } [ "usec" timeval offset-of cell = ] unit-test
{ t } [ timeval heap-size cell 2 * = ] unit-test

:: check-timeval-padding ( -- usec padding )
    0 123456 <timeval> :> value
    0xa5a5a5a5 value >c-ptr 12 set-alien-unsigned-4
    value usec>>
    value 654321 >>usec drop
    value >c-ptr 12 alien-unsigned-4 ;

cell 8 = [
    ! A 64-bit getter would read padding; a 64-bit setter would overwrite it.
    { 123456 0xa5a5a5a5 } [ check-timeval-padding ] unit-test
] when

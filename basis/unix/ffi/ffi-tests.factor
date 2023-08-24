USING: accessors alien.c-types alien.utilities io.encodings.utf8
kernel sequences tools.test unix.ffi ;

{ 80 } [ "http" f getservbyname port>> ntohs ] unit-test

! Aliases seem unreliable. Leave this as an example but don't rely
! on aliases working.
{ } [
    "http" f getservbyname aliases>> utf8 alien>strings drop
] unit-test

{ "http" } [ 80 htons f getservbyport name>> ] unit-test

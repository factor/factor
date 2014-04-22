USING: accessors alien.c-types io.encodings.utf8 kernel
sequences tools.test unix.ffi unix.utilities ;
IN: unix.ffi.tests

[ 80 ] [ "http" f getservbyname port>> ntohs ] unit-test

[ t ] [
    0 "http" f getservbyname aliases>> utf8 alien>strings
    "www" swap member?
] unit-test

[ "http" ] [ 80 htons f getservbyport name>> ] unit-test

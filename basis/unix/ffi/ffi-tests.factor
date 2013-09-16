IN: unix.ffi.tests
USING: accessors alien.c-types tools.test unix.ffi ;

[ 80 ] [ "http" f getservbyname port>> ntohs ] unit-test

[ "www" ] [
    0 "http" f getservbyname aliases>> c-string alien-element
] unit-test

[ "http" ] [ 80 htons f getservbyport name>> ] unit-test

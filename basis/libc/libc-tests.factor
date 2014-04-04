IN: libc.tests
USING: libc libc.private tools.test namespaces assocs system
destructors kernel combinators ;

100 malloc "block" set

[ t ] [ "block" get malloc-exists? ] unit-test

[ ] [ [ "block" get &free drop ] with-destructors ] unit-test

[ f ] [ "block" get malloc-exists? ] unit-test

[ "Operation not permitted" ] [ 1 strerror ] unit-test

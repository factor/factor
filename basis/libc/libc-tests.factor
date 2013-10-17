IN: libc.tests
USING: libc libc.private tools.test namespaces assocs
destructors kernel ;

100 malloc "block" set

[ t ] [ "block" get malloc-exists? ] unit-test

[ ] [ [ "block" get &free drop ] with-destructors ] unit-test

[ f ] [ "block" get malloc-exists? ] unit-test

[ "No error" ] [ 0 strerror ] unit-test

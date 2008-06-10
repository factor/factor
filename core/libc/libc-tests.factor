IN: libc.tests
USING: libc libc.private tools.test namespaces assocs
destructors kernel ;

100 malloc "block" set

[ t ] [ "block" get mallocs get key? ] unit-test

[ ] [ [ "block" get &free drop ] with-destructors ] unit-test

[ f ] [ "block" get mallocs get key? ] unit-test

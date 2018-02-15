USING: destructors kernel libc libc.private namespaces
tools.test ;

100 malloc "block" set

{ t } [ "block" get malloc-exists? ] unit-test

{ } [ [ "block" get &free drop ] with-destructors ] unit-test

{ f } [ "block" get malloc-exists? ] unit-test

{ "Operation not permitted" } [ 1 strerror ] unit-test

! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.inline alien.marshall.syntax destructors
tools.test ;
IN: alien.marshall.syntax.tests

C-LIBRARY: test

C-MARSHALLED: void outarg1 ( int* a )
    *a += 2;
;

C-MARSHALLED: unsigned-long* outarg2 ( unsigned-long a, unsigned-long* b )
    unsigned long* x = (unsigned long*) malloc(sizeof(unsigned long));
    *b = 10 + *b;
    *x = a + *b;
    return x;
;

;C-LIBRARY

{ 1 1 } [ outarg1 ] must-infer-as
[ 3 ] [ [ 1 outarg1 ] with-destructors ] unit-test

{ 2 2 } [ outarg2 ] must-infer-as
[ 18 15 ] [ [ 3 5 outarg2 ] with-destructors ] unit-test

DELETE-C-LIBRARY: test

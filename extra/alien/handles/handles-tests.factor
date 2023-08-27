! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.handles alien.syntax
destructors kernel math tools.test ;
IN: alien.handles.tests

TUPLE: thingy { x integer } ;
C: <thingy> thingy

CALLBACK: int thingy-callback ( uint thingy-handle )
CALLBACK: int thingy-ptr-callback ( void* thingy-handle )

: test-thingy-callback ( -- alien )
    [ alien-handle> x>> 1 + ] thingy-callback ;

: test-thingy-ptr-callback ( -- alien )
    [ alien-handle-ptr> x>> 1 + ] thingy-ptr-callback ;

: invoke-test-thingy-callback ( thingy -- n )
    test-thingy-callback int { uint } cdecl alien-indirect ;
: invoke-test-thingy-ptr-callback ( thingy -- n )
    test-thingy-ptr-callback int { void* } cdecl alien-indirect ;

{ t f } [
    [ 5 <thingy> <alien-handle> &release-alien-handle [ alien-handle? ] keep ] with-destructors
    alien-handle?
] unit-test

{ t f } [
    [ 5 <thingy> <alien-handle-ptr> &release-alien-handle-ptr [ alien-handle-ptr? ] keep ] with-destructors
    alien-handle-ptr?
] unit-test

{ 6 } [
    [
        5 <thingy> <alien-handle> &release-alien-handle
        invoke-test-thingy-callback
    ] with-destructors
] unit-test

{ 6 } [
    [
        5 <thingy> <alien-handle-ptr> &release-alien-handle-ptr
        invoke-test-thingy-ptr-callback
    ] with-destructors
] unit-test

USING: alien.c-types cocoa cocoa.classes cocoa.subclassing
cocoa.types compiler.test core-graphics.types kernel math memory
namespaces tools.test ;
IN: cocoa.tests

<CLASS: Foo < NSObject
    COCOA-METHOD: void foo: NSRect rect [
        gc rect "x" set
    ] ;
;CLASS>

: test-foo ( -- )
    Foo send: alloc send: init
    dup 1.0 2.0 101.0 102.0 <CGRect> send: \foo:
    send: release ;

{ } [ test-foo ] unit-test

{ 1.0 } [ "x" get CGRect-x ] unit-test
{ 2.0 } [ "x" get CGRect-y ] unit-test
{ 101.0 } [ "x" get CGRect-w ] unit-test
{ 102.0 } [ "x" get CGRect-h ] unit-test

<CLASS: Bar < NSObject
    COCOA-METHOD: NSRect bar [ test-foo "x" get ] ;
;CLASS>

{ } [
    Bar [
        send: alloc send: init
        dup send: bar "x" set
        send: release
    ] compile-call
] unit-test

{ 1.0 } [ "x" get CGRect-x ] unit-test
{ 2.0 } [ "x" get CGRect-y ] unit-test
{ 101.0 } [ "x" get CGRect-w ] unit-test
{ 102.0 } [ "x" get CGRect-h ] unit-test

! Make sure that we can add methods
<CLASS: Bar < NSObject
    COCOA-METHOD: NSRect bar [ test-foo "x" get ] ;

    COCOA-METHOD: int babb: int x [ x sq ] ;
;CLASS>

{ 144 } [
    Bar [
        send: alloc send: init
        dup 12 send: \babb:
        swap send: release
    ] compile-call
] unit-test

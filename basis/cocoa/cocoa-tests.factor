USING: cocoa cocoa.messages cocoa.subclassing cocoa.types
compiler.test kernel namespaces cocoa.classes cocoa.runtime
tools.test memory compiler.units math core-graphics.types ;
FROM: alien.c-types => int void ;
IN: cocoa.tests

CLASS: Foo < NSObject
[
    METHOD: void foo: NSRect rect [
        gc rect "x" set
    ]
]

: test-foo ( -- )
    Foo -> alloc -> init
    dup 1.0 2.0 101.0 102.0 <CGRect> -> foo:
    -> release ;

{ } [ test-foo ] unit-test

{ 1.0 } [ "x" get CGRect-x ] unit-test
{ 2.0 } [ "x" get CGRect-y ] unit-test
{ 101.0 } [ "x" get CGRect-w ] unit-test
{ 102.0 } [ "x" get CGRect-h ] unit-test

CLASS: Bar < NSObject
[
    METHOD: NSRect bar [ test-foo "x" get ]
]

{ } [
    Bar [
        -> alloc -> init
        dup -> bar "x" set
        -> release
    ] compile-call
] unit-test

{ 1.0 } [ "x" get CGRect-x ] unit-test
{ 2.0 } [ "x" get CGRect-y ] unit-test
{ 101.0 } [ "x" get CGRect-w ] unit-test
{ 102.0 } [ "x" get CGRect-h ] unit-test

! Make sure that we can add methods
CLASS: Bar < NSObject
[
    METHOD: NSRect bar [ test-foo "x" get ]

    METHOD: int babb: int x [ x sq ]
]

{ 144 } [
    Bar [
        -> alloc -> init
        dup 12 -> babb:
        swap -> release
    ] compile-call
] unit-test

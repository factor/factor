IN: cocoa.tests
USING: cocoa cocoa.messages cocoa.subclassing cocoa.types
compiler kernel namespaces cocoa.classes tools.test memory
compiler.units math core-graphics.types ;

CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "Foo" }
} {
    "foo:"
    "void"
    { "id" "SEL" "NSRect" }
    [ gc "x" set 2drop ]
} ;

: test-foo ( -- )
    Foo -> alloc -> init
    dup 1.0 2.0 101.0 102.0 <CGRect> -> foo:
    -> release ;

test-foo

[ 1.0 ] [ "x" get CGRect-x ] unit-test
[ 2.0 ] [ "x" get CGRect-y ] unit-test
[ 101.0 ] [ "x" get CGRect-w ] unit-test
[ 102.0 ] [ "x" get CGRect-h ] unit-test

CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "Bar" }
} {
    "bar"
    "NSRect"
    { "id" "SEL" }
    [ 2drop test-foo "x" get ]
} ;

Bar [
    -> alloc -> init
    dup -> bar "x" set
    -> release
] compile-call

[ 1.0 ] [ "x" get CGRect-x ] unit-test
[ 2.0 ] [ "x" get CGRect-y ] unit-test
[ 101.0 ] [ "x" get CGRect-w ] unit-test
[ 102.0 ] [ "x" get CGRect-h ] unit-test

! Make sure that we can add methods
CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "Bar" }
} {
    "bar"
    "NSRect"
    { "id" "SEL" }
    [ 2drop test-foo "x" get ]
} {
    "babb"
    "int"
    { "id" "SEL" "int" }
    [ 2nip sq ]
} ;

[ 144 ] [
    Bar [
        -> alloc -> init
        dup 12 -> babb
        swap -> release
    ] compile-call
] unit-test

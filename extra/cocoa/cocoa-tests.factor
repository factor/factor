IN: temporary
USING: cocoa cocoa.messages cocoa.subclassing cocoa.types
compiler kernel namespaces cocoa.classes tools.test memory ;

CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "Foo" }
} {
    "foo:"
    "void"
    { "id" "SEL" "NSRect" }
    [ data-gc "x" set 2drop ]
} ;

recompile

: test-foo
    Foo -> alloc -> init
    dup 1.0 2.0 101.0 102.0 <NSRect> -> foo:
    -> release ;

test-foo

[ 1 ] [ "x" get NSRect-x ] unit-test
[ 2 ] [ "x" get NSRect-y ] unit-test
[ 101 ] [ "x" get NSRect-w ] unit-test
[ 102 ] [ "x" get NSRect-h ] unit-test

CLASS: {
    { +superclass+ "NSObject" }
    { +name+ "Bar" }
} {
    "bar"
    "NSRect"
    { "id" "SEL" }
    [ 2drop test-foo "x" get ]
} ;

recompile

Bar [
    -> alloc -> init
    dup -> bar "x" set
    -> release
] compile-1

[ 1 ] [ "x" get NSRect-x ] unit-test
[ 2 ] [ "x" get NSRect-y ] unit-test
[ 101 ] [ "x" get NSRect-w ] unit-test
[ 102 ] [ "x" get NSRect-h ] unit-test

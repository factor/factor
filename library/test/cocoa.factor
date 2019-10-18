IN: objc-classes
DEFER: Foo
DEFER: Bar

IN: temporary
USING: cocoa compiler kernel objc namespaces objc-classes test memory ;

"NSObject" "Foo"
{ { "foo:" "void" { "id" "SEL" "NSRect" } [ full-gc "x" set 2drop ] } }
{ }
define-objc-class

: test-foo
    Foo -> alloc -> init
    dup 1 2 101 102 <NSRect> -> foo:
    -> release ;

test-foo

[ 1 ] [ "x" get NSRect-x ] unit-test
[ 2 ] [ "x" get NSRect-y ] unit-test
[ 101 ] [ "x" get NSRect-w ] unit-test
[ 102 ] [ "x" get NSRect-h ] unit-test

"NSObject" "Bar"
{ { "bar" "NSRect" { "id" "SEL" } [ 2drop test-foo "x" get ] } }
{ }
define-objc-class

Bar [
    -> alloc -> init
    dup -> bar "x" set
    -> release
] compile-1

[ 1 ] [ "x" get NSRect-x ] unit-test
[ 2 ] [ "x" get NSRect-y ] unit-test
[ 101 ] [ "x" get NSRect-w ] unit-test
[ 102 ] [ "x" get NSRect-h ] unit-test

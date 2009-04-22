IN: compiler.tree.builder.tests
USING: compiler.tree.builder tools.test sequences kernel
compiler.tree stack-checker stack-checker.errors ;

: inline-recursive ( -- ) inline-recursive ; inline recursive

[ t ] [ \ inline-recursive build-tree [ #recursive? ] any? ] unit-test

: bad-recursion-1 ( a -- b )
    dup [ drop bad-recursion-1 5 ] [ ] if ;

[ \ bad-recursion-1 build-tree ] [ inference-error? ] must-fail-with

FORGET: bad-recursion-1

: bad-recursion-2 ( obj -- obj )
    dup [ dup first swap second bad-recursion-2 ] [ ] if ;

[ \ bad-recursion-2 build-tree ] [ inference-error? ] must-fail-with

FORGET: bad-recursion-2

: bad-bin ( a b -- ) 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] if ;

[ \ bad-bin build-tree ] [ inference-error? ] must-fail-with

FORGET: bad-bin

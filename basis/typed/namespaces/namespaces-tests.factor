USING: compiler.tree.debugger math tools.test typed.namespaces ;
IN: typed.namespaces.tests

SYMBOL: pi

[ 22/7 pi float typed-set ] [ variable-type-error? ] must-fail-with

{ 3.14159265358979 } [
    3.14159265358979 pi float typed-set
    pi float typed-get
] unit-test

[
    3.14159265358979 pi float typed-set
    pi integer typed-get
] [ variable-type-error? ] must-fail-with


{ t } [ [ 2.0 pi float typed-get * ] { * } inlined? ] unit-test

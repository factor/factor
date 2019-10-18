USING: accessors alien.syntax continuations debugger kernel
kernel.private literals namespaces tools.test ;
IN: debugger.tests

{ } [ [ drop ] [ error. ] recover ] unit-test

{ f } [ { } vm-error? ] unit-test
{ f } [ { "A" "B" } vm-error? ] unit-test

{ } [
    T{ test-failure
       { error
         {
             $[ KERNEL-ERROR ]
             10
             {
                 B{
                     88 73 110 112 117 116 69 110 97 98 108 101 0
                 }
                 B{
                     88 73 110 112 117 116 69 110 97 98 108 101
                     64 56 0
                 }
                 B{
                     95 88 73 110 112 117 116 69 110 97 98 108
                     101 64 56 0
                 }
                 B{
                     64 88 73 110 112 117 116 69 110 97 98 108
                     101 64 56 0
                 }
             }
             DLL" xinput1_3.dll"
         }
       }
       { asset { "Unit Test" [ ] [ dup ] } }
       { path "resource:basis/game/input/input-tests.factor" }
       { line# 6 }
       { continuation $[ current-continuation ] }
    } error.
] unit-test

{ "foo" { 1 2 3 "foo" } } [
    [ 1 2 3 "foo" throw ] [ ] recover error-continuation get data>>
] unit-test

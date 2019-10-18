USING: debugger kernel continuations tools.test ;
IN: debugger.tests

[ ] [ [ drop ] [ error. ] recover ] unit-test

[ f ] [ { } vm-error? ] unit-test
[ f ] [ { "A" "B" } vm-error? ] unit-test

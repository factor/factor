IN: debugger.tests
USING: debugger kernel continuations tools.test ;

[ ] [ [ drop ] [ error. ] recover ] unit-test

[ f ] [ { } vm-error? ] unit-test
[ f ] [ { "A" "B" } vm-error? ] unit-test
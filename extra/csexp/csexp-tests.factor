USING: tools.test csexp ;
IN: csexp.tests
{ "6:foobar" } [ "foobar" >csexp ] unit-test
{ "()" } [ V{ } >csexp ] unit-test
{ "(3:foo(1:a1:b))" } [ V{ "foo" V{ "a" "b" } } >csexp ] unit-test

{ "foobar" } [ "6:foobar" csexp> ] unit-test
{ "" } [ "0:" csexp> ] unit-test
{ V{ } } [ "()" csexp> ] unit-test
{ V{ "foo" } } [ "(3:foo)" csexp> ] unit-test
{ V{ "foo" V{ V{ } } "bar" V{ "a" "bb" "" } } } [ "(3:foo(())3:bar(1:a2:bb0:))" csexp> ] unit-test

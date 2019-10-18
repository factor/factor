IN: method-chains.tests
USING: method-chains tools.test arrays strings sequences kernel namespaces ;

GENERIC: testing ( a b -- c )

M: sequence testing nip reverse ;
AFTER: string testing append ;
BEFORE: array testing over prefix "a" set ;

{ V{ 3 2 1 } } [ 3 V{ 1 2 3 } testing ] unit-test
{ "heyyeh" } [ 4 "yeh" testing ] unit-test
{ { 4 2 0 } } [ 5 { 0 2 4 } testing ] unit-test
{ { 5 0 2 4 } } [ "a" get ] unit-test

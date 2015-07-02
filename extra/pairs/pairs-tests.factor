IN: pairs.tests
USING: namespaces assocs tools.test pairs ;

SYMBOL: blah

"blah" blah <pair> "b" set

{ "blah" t } [ blah "b" get at* ] unit-test
{ f f } [ "fdaf" "b" get at* ] unit-test
{ 1 } [ "b" get assoc-size ] unit-test
{ { { blah "blah" } } } [ "b" get >alist ] unit-test
{ } [ "bleah" blah "b" get set-at ] unit-test
{ 1 } [ "b" get assoc-size ] unit-test
{ { { blah "bleah" } } } [ "b" get >alist ] unit-test
{ "bleah" t } [ blah "b" get at* ] unit-test
{ f f } [ "fdaf" "b" get at* ] unit-test
[ blah "b" get delete-at ] must-fail
{ } [ 1 2 "b" get set-at ] unit-test
{ "bleah" t } [ blah "b" get at* ] unit-test
{ 1 t } [ 2 "b" get at* ] unit-test
{ f f } [ "fdaf" "b" get at* ] unit-test
{ 2 } [ "b" get assoc-size ] unit-test
{ { { 2 1 } { blah "bleah" } } } [ "b" get >alist ] unit-test

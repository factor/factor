USING: columns sequences kernel namespaces arrays tools.test math ;
IN: columns.tests

! Columns
{ { 1 2 3 } { 4 5 6 } { 7 8 9 } } [ clone ] map "seq" set

[ { 1 4 7 } ] [ "seq" get 0 <column> >array ] unit-test
[ ] [ "seq" get 1 <column> [ sq ] map! drop ] unit-test
[ { 4 25 64 } ] [ "seq" get 1 <column> >array ] unit-test

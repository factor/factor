USING: kernel namespaces interval-maps tools.test ;
IN: interval-maps.tests

SYMBOL: test

{ } [ { { { 4 8 } 3 } { 1 2 } } <interval-map> test set ] unit-test
{ 3 } [ 5 test get interval-at ] unit-test
{ 3 } [ 8 test get interval-at ] unit-test
{ 3 } [ 4 test get interval-at ] unit-test
{ f } [ 9 test get interval-at ] unit-test
{ 2 } [ 1 test get interval-at ] unit-test
{ f } [ 2 test get interval-at ] unit-test
{ f } [ 0 test get interval-at ] unit-test

[ { { { 1 4 } 3 } { { 4 8 } 6 } } <interval-map> ] must-fail

{ { { { 1 3 } 2 } { { 4 5 } 4 } { { 7 8 } 4 } } }
[ { { 1 2 } { 2 2 } { 3 2 } { 4 4 } { 5 4 } { 7 4 } { 8 4 } } coalesce ] unit-test

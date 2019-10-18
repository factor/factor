
USING: ascii kernel math sequences strings tools.test ;

IN: splitting.extras

{ { } } [ { } { 0 } split* ] unit-test
{ { { 1 2 3 } } } [ { 1 2 3 } { 0 } split* ] unit-test
{ { { 0 } } } [ { 0 } { 0 } split* ] unit-test
{ { { 0 } { 0 } } } [ { 0 0 } { 0 } split* ] unit-test
{ { { 1 2 } { 0 } { 3 } { 0 } { 0 } } } [ { 1 2 0 3 0 0 } { 0 } split* ] unit-test
{ { "hello" } } [ "hello" " " split* ] unit-test
{ { " " " " "hello" } } [ "  hello" " " split* ] unit-test
{ { "hello" " " " " " " "world" } } [ "hello   world" " " split* ] unit-test
{ { "hello" " " " " " " "world" " " } } [ "hello   world " " " split* ] unit-test

{ { } } [ { } [ 0 > ] split*-when ] unit-test
{ { { 0 } } } [ { 0 } [ 0 > ] split*-when ] unit-test
{ { { 0 0 } } } [ { 0 0 } [ 0 > ] split*-when ] unit-test
{ { { 1 } { 2 } { 0 } { 3 } { 0 0 } } } [ { 1 2 0 3 0 0 } [ 0 > ] split*-when ] unit-test
{ { { 1 } { 2 3 } { 1 } { 4 5 } { 1 } { 6 } } } [
    1 { 1 2 3 1 4 5 1 6 } [ dupd = ] split*-when nip
] unit-test

{ { "hello" " " " " " " "world" } } [
    "hello   world"
    [ [ blank? ] find drop ] split-find
    [ >string ] map
] unit-test

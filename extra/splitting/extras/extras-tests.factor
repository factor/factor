USING: ascii kernel math sequences splitting.extras strings
tools.test ;

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
    [ [ ascii:blank? ] find drop ] split-find
    [ >string ] map
] unit-test

{ { } } [ "" " " split-harvest ] unit-test
{ { } } [ " " " " split-harvest ] unit-test
{ { } } [ "  " " " split-harvest ] unit-test
{ { "a" } } [ "a" " " split-harvest ] unit-test
{ { "a" } } [ " a" " " split-harvest ] unit-test
{ { "a" } } [ " a " " " split-harvest ] unit-test
{ { "a" "b" } } [ "a b" " " split-harvest ] unit-test
{ { "a" "b" } } [ " a b" " " split-harvest ] unit-test
{ { "a" "b" } } [ " a b " " " split-harvest ] unit-test
{ { "a" "b" "c" } } [ "a b c" " " split-harvest ] unit-test
{ { "a" "b" "c" } } [ "a  b c" " " split-harvest ] unit-test
{ { "a" "b" "c" } } [ "a  b  c" " " split-harvest ] unit-test
{ { "a" "b" "c" } } [ " a  b  c" " " split-harvest ] unit-test
{ { "a" "b" "c" } } [ " a  b  c " " " split-harvest ] unit-test

{ "s" "1:2:3s" } [
    "s1:2:3s" [ letter? ] split-head
] unit-test

{ "s1:2:3" "s" } [
    "s1:2:3s" [ letter? ] split-tail
] unit-test

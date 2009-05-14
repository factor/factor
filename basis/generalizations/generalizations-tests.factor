USING: tools.test generalizations kernel math arrays sequences ascii ;
IN: generalizations.tests

{ 1 2 3 4 1 } [ 1 2 3 4 4 npick ] unit-test
{ 1 2 3 4 2 } [ 1 2 3 4 3 npick ] unit-test
{ 1 2 3 4 3 } [ 1 2 3 4 2 npick ] unit-test
{ 1 2 3 4 4 } [ 1 2 3 4 1 npick ] unit-test

[ 1 1 ndup ] must-infer
{ 1 1 } [ 1 1 ndup ] unit-test
{ 1 2 1 2 } [ 1 2 2 ndup ] unit-test
{ 1 2 3 1 2 3 } [ 1 2 3 3 ndup ] unit-test
{ 1 2 3 4 1 2 3 4 } [ 1 2 3 4 4 ndup ] unit-test
[ 1 2 2 nrot ] must-infer
{ 2 1 } [ 1 2 2 nrot ] unit-test
{ 2 3 1 } [ 1 2 3 3 nrot ] unit-test
{ 2 3 4 1 } [ 1 2 3 4 4 nrot ] unit-test
[ 1 2 2 -nrot ] must-infer
{ 2 1 } [ 1 2 2 -nrot ] unit-test
{ 3 1 2 } [ 1 2 3 3 -nrot ] unit-test
{ 4 1 2 3 } [ 1 2 3 4 4 -nrot ] unit-test
[ 1 2 3 4 3 nnip ] must-infer
{ 4 } [ 1 2 3 4 3 nnip ] unit-test
[ 1 2 3 4 4 ndrop ] must-infer
{ 0 } [ 0 1 2 3 4 4 ndrop ] unit-test
[ [ 1 ] 5 ndip ] must-infer
[ 1 2 3 4 ] [ 2 3 4 [ 1 ] 3 ndip ] unit-test

[ 1 2 3 4 5 [ drop drop drop drop drop 2 ] 5 nkeep ] must-infer
{ 2 1 2 3 4 5 } [ 1 2 3 4 5 [ drop drop drop drop drop 2 ] 5 nkeep ] unit-test
[ [ 1 2 3 + ] ] [ 1 2 3 [ + ] 3 ncurry ] unit-test

[ "HELLO" ] [ "hello" [ >upper ] 1 napply ] unit-test
[ { 1 2 } { 2 4 } { 3 8 } { 4 16 } { 5 32 } ] [ 1 2 3 4 5 [ dup 2^ 2array ] 5 napply ] unit-test
[ [ dup 2^ 2array ] 5 napply ] must-infer

[ { "xyc" "xyd" } ] [ "x" "y" { "c" "d" } [ 3append ] 2 nwith map ] unit-test

[ 1 2 3 4 ] [ { 1 2 3 4 } 4 firstn ] unit-test
[ ] [ { } 0 firstn ] unit-test
[ "a" ] [ { "a" } 1 firstn ] unit-test

[ [ 1 2 ] ] [ 1 2 2 [ ] nsequence ] unit-test

[ 4 5 1 2 3 ] [ 1 2 3 4 5 2 3 mnswap ] unit-test

[ 1 2 3 4 5 6 ] [ 1 2 3 4 5 6 2 4 mnswap 4 2 mnswap ] unit-test

[ { 1 2 3 4 } ] [ { 1 } { 2 } { 3 } { 4 } 4 nappend ] unit-test
[ V{ 1 2 3 4 } ] [ { 1 } { 2 } { 3 } { 4 } 4 V{ } nappend-as ] unit-test

[ 4 nappend ] must-infer
[ 4 { } nappend-as ] must-infer

[ 17 ] [ 3 1 3 3 7 5 nsum ] unit-test
{ 4 1 } [ 4 nsum ] must-infer-as

[ "e1" "o1" "o2" "e2" "o1" "o2" ] [ "e1" "e2" "o1" "o2" 2 nweave ] unit-test
{ 3 5 } [ 2 nweave ] must-infer-as

[ { 0 1 2 } { 3 5 4 } { 7 8 6 } ]
[ 9 [ ] each { [ 3array ] [ swap 3array ] [ rot 3array ] } 3 nspread ] unit-test
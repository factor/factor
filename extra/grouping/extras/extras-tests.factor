USING: arrays grouping.extras kernel math math.functions
sequences tools.test ;

{ { } } [ { 1 } [ 2array ] 2 clump-map ] unit-test
{ { { 1 2 } } } [ { 1 2 } [ 2array ] 2 clump-map ] unit-test
{ { { 1 2 } { 2 3 } } } [ { 1 2 3 } [ 2array ] 2 clump-map ] unit-test
{ { { 1 2 } { 2 3 } { 3 4 } } } [ { 1 2 3 4 } [ 2array ] 2 clump-map ] unit-test

{ { } } [ { 1 } [ 3array ] 3 clump-map ] unit-test
{ { } } [ { 1 2 } [ 3array ] 3 clump-map ] unit-test
{ { { 1 2 3 } } } [ { 1 2 3 } [ 3array ] 3 clump-map ] unit-test
{ { { 1 2 3 } { 2 3 4 } } } [ { 1 2 3 4 } [ 3array ] 3 clump-map ] unit-test

{ { } } [ { 1 } [ 4array ] 4 clump-map ] unit-test
{ { } } [ { 1 2 } [ 4array ] 4 clump-map ] unit-test
{ { { 1 2 3 4 } } } [ { 1 2 3 4 } [ 4array ] 4 clump-map ] unit-test
{ { { 1 2 3 4 } { 2 3 4 5 } } } [ { 1 2 3 4 5 } [ 4array ] 4 clump-map ] unit-test

{ { } } [ { 1 } [ 3array ] 3 group-map ] unit-test
{ { } } [ { 1 2 } [ 3array ] 3 group-map ] unit-test
{ { { 1 2 3 } } } [ { 1 2 3 } [ 3array ] 3 group-map ] unit-test
{ { { 1 2 3 } } } [ { 1 2 3 4 } [ 3array ] 3 group-map ] unit-test

{ { "tail" "ail" "il" "l" } } [ "tail" all-suffixes ] unit-test
{ { "h" "he" "hea" "head" } } [ "head" all-prefixes ] unit-test

{ { B{ 97 115 } B{ 100 102 } } } [ "asdf" 2 B{ } group-as ] unit-test
{ { { 97 115 } { 115 100 } { 100 102 } } } [ "asdf" 2 { } clump-as ] unit-test

{
    V{
        { 0 V{ 0 1 2 } }
        { 1 V{ 3 4 5 } }
        { 2 V{ 6 7 8 } }
        { 3 V{ 9 } } }
} [
    10 <iota> [ 3 / floor ] group-by
] unit-test

{ V{ { t V{ 0 1 2 3 4 5 6 7 8 9 } } } }
[ 10 <iota> [ drop t ] group-by ] unit-test

{ V{ } } [ { } [ drop t ] group-by ] unit-test

{ { { } { } { } } } [ { } 3 n-group ] unit-test
{ { { 1 } { } { } } } [ { 1 } 3 n-group ] unit-test
{ { { 1 } { 2 } { } } } [ { 1 2 } 3 n-group ] unit-test
{ { { 1 } { 2 } { 3 } } } [ { 1 2 3 } 3 n-group ] unit-test
{ { { 1 2 } { 3 } { 4 } } } [ { 1 2 3 4 } 3 n-group ] unit-test

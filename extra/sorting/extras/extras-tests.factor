USING: arrays kernel math math.order random sequences
tools.test ;
IN: sorting.extras

{ { 0 2 1 } } [ { 10 30 20 } [ <=> ] argsort ] unit-test
{ { 2 0 1 } } [
    { "hello" "goodbye" "yo" } [ 2length <=> ] argsort
] unit-test

{ { "blue" "green" "purple" } } [
    { "green" "blue" "purple" } [ length ] map-sort
] unit-test
{ 1 { 1 2 3 4 } } [ 1 { 4 2 1 3 } [ dupd + ] map-sort ] unit-test

{ 0 } [ 0 { 1 } bisect-right ] unit-test
{ 1 } [ 1 { 1 } bisect-right ] unit-test
{ 1 } [ 2 { 1 } bisect-right ] unit-test

{ 0 } [ 0 { 1 } bisect-left ] unit-test
{ 0 } [ 1 { 1 } bisect-left ] unit-test
{ 1 } [ 2 { 1 } bisect-left ] unit-test

{ { 0 1 2 3 4 5 6 7 8 9 } } [
    { }
    10 <iota> >array randomize
    [ swap insort-right ] each
] unit-test

{ V{ 0 1 2 3 4 5 6 7 8 9 } } [
    V{ } clone
    10 <iota> >array randomize
    [ swap insort-right! ] each
] unit-test

{ +gt+ } [ "lady" "bug" { [ length ] [ first ] } compare-with ] unit-test
{ +lt+ } [ "bug" "lady" { [ length ] [ first ] } compare-with ] unit-test
{ +eq+ } [ "bat" "bat" { [ length ] [ first ] } compare-with ] unit-test
{ +lt+ } [ "bat" "cat" { [ length ] [ first ] } compare-with ] unit-test
{ +gt+ } [ "fat" "cat" { [ length ] [ first ] } compare-with ] unit-test

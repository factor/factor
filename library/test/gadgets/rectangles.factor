USING: gadgets kernel namespaces test ;
[ t ] [
    [
        { 2000  2000 0 } origin set
        { 2030 2040 0 } { 10 20 0 } { 300 400 0 } <rectangle> inside?
    ] with-scope
] unit-test

[ f ] [
    [
        { 2000  2000 0 } origin set
        { 2500 2040 0 } { 10 20 0 } { 300 400 0 } <rectangle> inside?
    ] with-scope
] unit-test

[ t ] [
    [
        { -10 -20 0 } origin set
        { 0 0 0 } { 10 20 0 } { 300 400 0 } <rectangle> inside?
    ] with-scope
] unit-test

[ f ] [
    [
        { 0 0 0 } origin set
        { 10 10 0 } { 0 0 0 } { 10 10 0 } <rectangle> inside?
    ] with-scope
] unit-test

[ << rectangle f { 10 10 0 } { 20 20 0 } >> ]
[
    << rectangle f { 10 10 0 } { 50 50 0 } >>
    << rectangle f { -10 -10 0 } { 40 40 0 } >>
    intersect
] unit-test

[ << rectangle f { 200 200 0 } { 0 0 0 } >> ]
[
    << rectangle f { 100 100 0 } { 50 50 0 } >>
    << rectangle f { 200 200 0 } { 40 40 0 } >>
    intersect
] unit-test

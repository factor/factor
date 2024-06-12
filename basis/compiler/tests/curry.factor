USING: tools.test quotations math kernel sequences
assocs namespaces make compiler.units compiler.test
locals random ;
IN: compiler.tests.curry

{ 3 } [ 5 [ [ 2 - ] curry call ] compile-call ] unit-test
{ 3 } [ [ 5 [ 2 - ] curry call ] compile-call ] unit-test
{ 3 } [ [ 5 2 [ - ] 2curry call ] compile-call ] unit-test
{ 3 } [ 5 [ 2 [ - ] 2curry call ] compile-call ] unit-test
{ 3 } [ 5 2 [ [ - ] 2curry call ] compile-call ] unit-test
{ 3 } [ 5 2 [ [ - ] 2curry 9 swap call /i ] compile-call ] unit-test
{ 3 } [ 5 2 [ [ - ] 2curry [ 9 ] dip call /i ] compile-call ] unit-test

{ -10 -20 } [ 10 20 -1 [ [ * ] curry bi@ ] compile-call ] unit-test

{ [ 5 2 - ] } [ 5 [ [ 2 - ] curry ] compile-call >quotation ] unit-test
{ [ 5 2 - ] } [ [ 5 [ 2 - ] curry ] compile-call >quotation ] unit-test
{ [ 5 2 - ] } [ [ 5 2 [ - ] 2curry ] compile-call >quotation ] unit-test
{ [ 5 2 - ] } [ 5 [ 2 [ - ] 2curry ] compile-call >quotation ] unit-test
{ [ 5 2 - ] } [ 5 2 [ [ - ] 2curry ] compile-call >quotation ] unit-test

{ [ 6 2 + ] } [
    2 5
    [ [ [ + ] curry ] dip 0 < [ -2 ] [ 6 ] if swap curry ]
    compile-call >quotation
] unit-test

{ 8 } [
    2 5
    [ [ [ + ] curry ] dip 0 < [ -2 ] [ 6 ] if swap curry call ]
    compile-call
] unit-test

: foobar ( quot: ( ..a -- ..b ) -- )
    [ call ] 1guard [ foobar ] [ drop ] if ; inline recursive

{ } [ [ [ f ] foobar ] compile-call ] unit-test

{ { 6 7 8 } } [ { 1 2 3 } 5 [ [ + ] curry map ] compile-call ] unit-test
{ { 6 7 8 } } [ { 1 2 3 } [ 5 [ + ] curry map ] compile-call ] unit-test

: funky-assoc>map ( assoc quot -- seq )
    [
        [ call f ] curry assoc-find 3drop
    ] { } make ; inline

{ t } [| |
    1000 <iota> [ drop 1,000,000 random 1,000,000 random ] H{ } map>assoc :> a-hashtable
    a-hashtable [ [ drop , ] funky-assoc>map ] compile-call
    a-hashtable keys =
] unit-test

{ 3 } [ 1 [ 2 ] [ curry [ 3 ] [ 4 ] if ] compile-call ] unit-test

{ 3 } [ t [ 3 [ ] curry 4 [ ] curry if ] compile-call ] unit-test

{ 3 } [ t [ 3 [ ] curry [ 4 ] if ] compile-call ] unit-test

{ 4 } [ f [ 3 [ ] curry 4 [ ] curry if ] compile-call ] unit-test

{ 4 } [ f [ [ 3 ] 4 [ ] curry if ] compile-call ] unit-test

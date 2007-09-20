IN: temporary
USING: alien strings kernel math tools.test io prettyprint
namespaces combinators words ;

[ "even" ] [
    2 {
        { [ dup 2 mod 0 = ] [ drop "even" ] }
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
    } cond
] unit-test

[ "odd" ] [
    3 {
        { [ dup 2 mod 0 = ] [ drop "even" ] }
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
    } cond
] unit-test

[ "neither" ] [
    3 {
        { [ dup string? ] [ drop "string" ] }
        { [ dup float? ] [ drop "float" ] }
        { [ dup alien? ] [ drop "alien" ] }
        { [ t ] [ drop "neither" ] }
    } cond
] unit-test

: case-test-1
    {
        { 1 [ "one" ] }
        { 2 [ "two" ] }
        { 3 [ "three" ] }
        { 4 [ "four" ] }
    } case ;

[ "two" ] [ 2 case-test-1 ] unit-test

! Interpreted
[ "two" ] [ 2 \ case-test-1 word-def call ] unit-test

[ "x" case-test-1 ] unit-test-fails

: case-test-2
    {
        { 1 [ "one" ] }
        { 2 [ "two" ] }
        { 3 [ "three" ] }
        { 4 [ "four" ] }
        [ sq ]
    } case ;

[ 25 ] [ 5 case-test-2 ] unit-test

! Interpreted
[ 25 ] [ 5 \ case-test-2 word-def call ] unit-test

: case-test-3
    {
        { 1 [ "one" ] }
        { 2 [ "two" ] }
        { 3 [ "three" ] }
        { 4 [ "four" ] }
        { H{ } [ "a hashtable" ] }
        { { 1 2 3 } [ "an array" ] }
        [ sq ]
    } case ;

[ "an array" ] [ { 1 2 3 } case-test-3 ] unit-test

! Interpreted
[ "a hashtable" ] [ H{ } \ case-test-3 word-def call ] unit-test

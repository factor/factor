USING: combinators.lib kernel math random sequences tools.test continuations
    arrays vectors ;
IN: combinators.lib.tests

[ 5 ] [ [ 10 random ] [ 5 = ] generate ] unit-test
[ t ] [ [ 10 random ] [ even? ] generate even? ] unit-test

[ [ 99 ] 1 2 3 4 5 5 nslip ] must-infer
{ 99 1 2 3 4 5 } [ [ 99 ] 1 2 3 4 5 5 nslip ] unit-test
[ 1 2 3 4 5 [ drop drop drop drop drop 2 ] 5 nkeep ] must-infer
{ 2 1 2 3 4 5 } [ 1 2 3 4 5 [ drop drop drop drop drop 2 ] 5 nkeep ] unit-test
[ [ 1 2 3 + ] ] [ 1 2 3 [ + ] 3 ncurry ] unit-test
[ { 1 2 } { 2 4 } { 3 8 } { 4 16 } { 5 32 } ] [ 1 2 3 4 5 [ dup 2^ 2array ] 5 napply ] unit-test
[ [ dup 2^ 2array ] 5 napply ] must-infer

[ { "xyc" "xyd" } ] [ "x" "y" { "c" "d" } [ 3append ] 2 nwith map ] unit-test

[ { "foo" "xbarx" } ]
[
    { "oof" "bar" } { [ reverse ] [ "x" swap "x" 3append ] } parallel-call
] unit-test

{ 1 1 } [
    [ even? ] [ drop 1 ] [ drop 2 ] ifte
] must-infer-as
